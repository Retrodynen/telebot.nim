import macros, httpclient, asyncdispatch, sam, strutils, types, options, logging, strtabs, random
from json import escapeJson
from streams import Stream, readAll

randomize()

const
  API_URL* = "https://api.telegram.org/bot$#/"
  FILE_URL* = "https://api.telegram.org/file/bot$#/$#"

template END_POINT*(name: string) =
  let endpoint {.used, inject.} = API_URL & name

template hasCommand*(update: Update, username: string): bool =
  var
    result = false
    hasMessage = false
  when not declaredInScope(command):
    var
      command {.inject.} = ""
      params {.inject.} = ""
      message {.inject.}: Message
  if update.message.isSome:
    hasMessage = true
    message = update.message.get()
  elif update.editedMessage.isSome:
    hasMessage = true
    message = update.editedMessage.get()
  else:
    result = false

  if hasMessage and message.entities.isSome:
    let
      entities = message.entities.get()
      messageText = message.text.get()
    if entities[0].kind == "bot_command":
      let
        offset = entities[0].offset
        length = entities[0].length
      command = messageText[(offset + 1)..<(offset + length)].strip()
      params = messageText[(offset + length)..^1].strip()
      result = true
      if '@' in command:
        var parts = command.split('@')
        command = parts[0]
        if (parts.len == 2 and parts[1].toLowerAscii != username):
          result = false
  result

proc isSet*(value: any): bool {.inline.} =
  when value is string:
    result = value.len > 0
  elif value is int:
    result = value != 0
  elif value is bool:
    result = value
  elif value is object:
    result = true
  elif value is float:
    result = value != 0
  elif value is enum:
      result = true
  else:
    result = not value.isNil

template d*(args: varargs[string, `$`]) =
  debug(args)

proc formatName*(s: string): string =
  if s == "kind":
    return "type"
  if s == "fromUser":
    return "from"

  result = newStringOfCap(s.len + 5)
  for c in s:
    if c in {'A'..'Z'}:
      result.add("_")
      result.add(c.toLowerAscii)
    else:
      result.add(c)

proc unmarshal*(n: JsonNode, T: typedesc): T =
  when result is object:
    for name, value in result.fieldPairs:
      let jsonKey = formatName(name)
      when value.type is Option:
        if n.hasKey(jsonKey):
          toOption(value, n[jsonKey])
      elif value.type is TelegramObject:
        value = unmarshal(n[jsonKey], value.type)
      elif value.type is seq:
        for item in n[jsonKey]:
          put(value, item)
      elif value.type is string:
        value = n[jsonKey].toStr
      else:
        value = to[value.type](n[jsonKey])
  elif result is seq:
    for item in n:
      result.put(item)

proc marshal*[T](t: T, s: var string) =
  when t is Option:
    if t.isSome:
      marshal(t.get, s)
  elif t is object:
    s.add "{"
    for name, value in t.fieldPairs:
      const jsonKey = formatName(name)
      # DIRTY hack to make internal fields invisible
      if name != "type":
        when value is Option:
          if value.isSome:
            s.add("\"" & jsonKey & "\":")
            marshal(value, s)
            s.add(',')
        else:
          s.add("\"" & jsonKey & "\":")
          marshal(value, s)
          s.add(',')
    s.removeSuffix(',')
    s.add "}"
  elif t is ref:
    marshal(t[], s)
  elif t is seq or t is openarray:
    s.add "["
    for item in t:
      marshal(item, s)
      s.add(',')
    s.removeSuffix(',')
    s.add "]"
  else:
    if t.isSet:
      when t is string:
        s.add(escapeJson(t))
      else:
        s.add($t)
    else:
      when t is bool:
        s.add("false")
      else:
        s.add("null")

proc marshal*[T](t: T): string = marshal(t, result)

proc put*[T](s: var seq[T], n: JsonNode) {.inline.} =
  s.add(unmarshal(n, T))

proc unref*[T: TelegramObject](r: ref T, n: JsonNode ): ref T {.inline.} =
  new(result)
  result[] =  unmarshal(n, T)

  # DIRTY hack to unmarshal keyboard markups
  when result is InlineKeyboardMarkup:
    result.type = kInlineKeyboardMarkup
  elif result is ReplyKeyboardMarkup:
    result.type = kReplyKeyboardMarkup
  elif result is ReplyKeyboardRemove:
    result.type = kReplyKeyboardRemove
  elif result is ForceReply:
    result.type = kForceReply

proc toOption*[T](o: var Option[T], n: JsonNode) {.inline.} =
  when T is TelegramObject:
    o = some(unmarshal(n, T))
  elif T is int:
    o = some(n.toInt)
  elif T is string:
    o = some(n.toStr)
  elif T is bool:
    o = some(n.toBool)
  elif T is seq:
    var arr: T = @[]
    for item in n:
      arr.put(item)
    o = some(arr)
  elif T is ref:
    var res: T
    o = some(unref(res, n))

proc initHttpClient(b: Telebot): AsyncHttpClient =
  result = newAsyncHttpClient(userAgent="telebot.nim/0.5.7", proxy=b.proxy)

proc makeRequest*(b: Telebot, endpoint: string, data: MultipartData = nil): Future[JsonNode] {.async.} =
  d("Making request to ", endpoint)
  let client = initHttpClient(b)
  defer: client.close()
  let r = await client.post(endpoint, multipart=data)
  if r.code == Http200 or r.code == Http400:
    var obj = parse(await r.body)
    if obj["ok"].toBool:
      result = obj["result"]
      d("Result: ", $result)
    else:
      raise newException(IOError, obj["description"].toStr)
  else:
    raise newException(IOError, r.status)

proc getMessage*(n: JsonNode): Message {.inline.} =
  result = unmarshal(n, Message)

proc addData*(p: var MultipartData, name: string, content: auto, fileCheck = false) {.inline.} =
  when content is string:
    if fileCheck and content.startsWith("file://"):
      p.addFiles({name: content[7..content.len-1]})
    else:
      p.add(name, content)
  else:
    p.add(name, $content)

proc addData*(p: var MultipartData, name: string, content: Stream, fileName = "", contentType = "") {.inline.} =
  p.add(name, content.readAll(), fileName, contentType)

proc uploadInputMedia*(p: var MultipartData, m: InputMedia) =
  var name = "file_upload_" & $rand(high(int))
  if m.media.startsWith("file://"):
    m.media = "attach://" & name
    p.addFiles({name: m.media[7..m.media.len-1]})

  if m.thumb.isSome:
    name = "file_upload_" & $rand(high(int))
    m.thumb = some("attach://" & name)
    p.addFiles({name: m.media[7..m.media.len-1]})

macro genInputMedia*(mediaType: untyped): untyped =
  let
    media = "InputMedia" & $mediaType
    kind = toLowerAscii($mediaType)
    objName = newIdentNode(media)
    funcName = newIdentNode("new" & media)

  result = quote do:
    proc `funcName`*(media: string; caption=""; parseMode=""): `objName` =
      var inputMedia = new(`objName`)
      inputMedia.kind = `kind`
      inputMedia.media = media
      if caption.len > 0:
        inputMedia.caption = some(caption)
      if parseMode.len > 0:
        inputMedia.parseMode = some(parseMode)
      return inputMedia

macro botapi*(node: untyped) : untyped =
  if node.kind != nnkProcDef:
    return
  result = node
  #echo treeRepr(result)
  var
    apiName: string
    params = result[3]
    param: NimNode
    pragma: NimNode
    body = newStmtList()

  # api same as proc name
  if result[0].kind == nnkIdent:
    apiName = $result[0]
  else:
    apiName = $result[0][1]
  # pragma
  if result[4].kind == nnkEmpty:
    result[4] = newNimNode(nnkPragma)
  result[4].add(ident("async"))

  # prologue
  body.add(newLetStmt(
    ident("endpoint"),
    infix(ident("API_URL"), "&", newStrLitNode(apiName))
  )).add(newVarStmt(
      ident("data"),
      newCall(ident("newMultipartData"))
  ))
  for param in params:
    if param.kind != nnkIdentDefs:
      continue

    var
      paramName = param[0]
      paramKind = param[1]
      paramDefault = param[2]
      name = formatName($paramName)

    #if $paramName == "maskPosition":
    #  echo treeRepr(param)

    if paramKind.kind == nnkIdent and toLowerAscii($paramKind) == "telebot":
      continue
    var leftSide = newNimNode(nnkBracketExpr)
                    .add(ident("data"))
                    .add(newStrLitNode(name))
    if paramKind.kind != nnkEmpty and paramDefault.kind == nnkEmpty:
      # mandatory params
      if paramKind.kind == nnkIdent:
        if $paramKind == "string":
          body.add(newAssignment(leftSide, ident($paramName)))
        elif $paramKind == "InputFileOrString":
          body.add(newCall(
            ident("addData"),
            ident("data"),
            newStrLitNode($paramName),
            paramName,
            ident("true")
          ))
      elif paramKind.kind == nnkBracketExpr and $paramKind[0] == "seq":
        body.add(newAssignment(leftSide, newCall("marshal", paramName)))
      else:
        body.add(newAssignment(leftSide, prefix(paramName, "$")))
    elif paramKind.kind == nnkEmpty and paramDefault.kind != nnkEmpty:
      # optional param with out type
      if paramDefault.kind == nnkStrLit:
        body.add(quote do:
          if `paramName`.len != 0:
            data[`name`] = `paramName`
        )
      elif paramDefault.kind == nnkIntLit:
        body.add(quote do:
          if `paramName` != `paramDefault`:
            data[`name`] = $`paramName`
        )
      elif paramDefault.kind == nnkIdent and $paramDefault in ["true", "false"]:
        body.add(quote do:
          if `paramName`:
            data[`name`] = "true"
        )
      else:
        body.add(quote do:
          if `paramName`.isSome():
            data[`name`] = marshal(`paramName`)
        )
        #echo treeRepr(param)
    else:
      # optional param with type
      if paramKind.kind == nnkIdent and $paramKind == "InputFileOrString":
        body.add(quote do:
          if `paramName`.len != 0:
            data.addData(`name`, paramName, true)
        )
      else:
        if paramKind.kind == nnkBracketExpr:
          # seq
          body.add(quote do:
            if `paramName`.len != 0:
              data[`name`] = $`paramName`
          )
          echo treeRepr(paramKind)
        else:
          body.add(quote do:
            if `paramName` != nil:
              data[`name`] = $`paramName`
          )
  var epilogue = parseStmt("""
let res = await makeRequest(`b`, `endpoint` % `b`.token, data)
""")
  body.add(epilogue[0])
  var retType = ""
  if params[0][1].kind == nnkIdent:
    retType = $params[0][1]
  if retType == "Message":
    body.add(newAssignment(
      ident("result"),
      newCall("getMessage", ident("res"))
    ))
  elif retType == "bool":
    body.add(newAssignment(
      ident("result"),
      newCall("toBool", ident("res"))
    ))
  elif retType == "int":
    body.add(newAssignment(
      ident("result"),
      newCall("toInt", ident("res"))
    ))
  elif retType == "void":
    discard
  else:
    body.add(newAssignment(
      ident("result"),
      newCall("unmarshal", ident("res"), params[0][1])
    ))

  # set proc body
  result[6] = body
  #echo treeRepr(result)