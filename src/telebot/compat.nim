import httpclient, asyncdispatch, strutils, macros
import private/[types, keyboard, utils]

proc newProcDef(name: string): NimNode {.compileTime.} =
  result = newNimNode(nnkProcDef)
  result.add(postfix(ident(name), "*"))
  result.add(
    newEmptyNode(),
    newEmptyNode(),
    newNimNode(nnkFormalParams),
    newEmptyNode(),
    newEmptyNode(),
    newStmtList()
  )

macro magic*(head, body: untyped): untyped =
  result = newStmtList()

  var
    objNameNode: NimNode

  if head.kind == nnkIdent:
    objNameNode = head
  else:
    quit "Invalid node: " & head.lispRepr

  var
    objectTy = newNimNode(nnkObjectTy)

  objectTy.add(newEmptyNode(), newEmptyNode())

  var
    objName = $objNameNode & "Object"
    objParamList = newNimNode(nnkRecList)
    objInitProc = newProcDef("new" & $objNameNode)
    objSendProc = newProcDef("send")
    objInitProcParams = objInitProc[3]
    objInitProcBody = objInitProc[6]
    objSendProcParams = objSendProc[3]
    objSendProcBody = objSendProc[6]

  objSendProc[4] = newNimNode(nnkPragma).add(ident("async"), ident("discardable"), ident("deprecated"))

  objectTy.add(objParamList)
  objInitProcParams.add(ident(objName))

  objSendProcParams.add(newNimNode(nnkBracketExpr).add(
    ident("Future"), ident("Message")) # return value
  ).add(newIdentDefs(ident("b"), ident("TeleBot"))
  ).add(newIdentDefs(ident("m"), ident(objName)))

  objSendProcBody.add(newConstStmt(
    ident("endpoint"),
    infix(ident("API_URL"), "&", newStrLitNode("send" & $objNameNode))
  )).add(newVarStmt(
      ident("data"),
      newCall(ident("newMultipartData"))
  ))

  for node in body:
    let fieldName = $node[0]

    case node[1][0].kind
    of nnkIdent:
      var identDefs = newIdentDefs(
        node[0],
        node[1][0] # objInitProcBody -> Ident
      )
      objParamList.add(identDefs)
      objInitProcParams.add(identDefs)
      objInitProcBody.add(newAssignment(
        newDotExpr(ident("result"), node[0]),
        node[0]
      ))

      # dirty hack to determine if the field might be `InputFile`
      # if  field is InputFile or string, `addData` will checks if it starts w/ file://
      # and do file upload
      var fileCheck = ident("false")
      if toLowerAscii(fieldName) == toLowerAscii($objNameNode):
        fileCheck = ident("true")


      objSendProcBody.add(
        newCall(
          ident("addData"),
          ident("data"),
          newStrLitNode(formatName(fieldName)),
          newDotExpr(ident("m"), node[0]),
          fileCheck
      ))

    of nnkPragmaExpr:
      objParamList.add(
        newIdentDefs(
          postfix(node[0], "*"),
          node[1][0][0] # stmtList -> pragma -> ident
        )
      )

      var ifStmt = newNimNode(nnkIfStmt).add(
        newNimNode(nnkElifBranch).add(
          newCall(
            ident("isSet"),
            newDotExpr(ident("m"), node[0])
          ),
          newStmtList(
            newCall(
              ident("addData"),
              ident("data"),
              newStrLitNode(formatName(fieldName)),
              newDotExpr(ident("m"), node[0])
            )
          )
        )
      )
      objSendProcBody.add(ifStmt)
    else:
      # silently ignore unsupported node
      discard

  var epilogue = parseStmt("""
try:
  let res = await makeRequest(b, endpoint % b.token, data)
  result = unmarshal(res, Message)
except:
  echo "Got exception ", repr(getCurrentException()), " with message: ", getCurrentExceptionMsg()
""")
  objSendProcBody.add(epilogue[0])

  result.add(newNimNode(nnkTypeSection).add(
    newNimNode(nnkTypeDef).add(postfix(ident(objName), "*"), newEmptyNode(), objectTy)
  ))
  result.add(objInitProc, objSendProc)


magic Message:
  chatId: int64
  text: string
  parseMode: string {.optional.}
  disableWebPagePreview: bool {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Photo:
  chatId: int64
  photo: string
  caption: string {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Audio:
  chatId: int64
  audio: string
  caption: string {.optional.}
  duration: int {.optional.}
  performer: string {.optional.}
  title: string {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Document:
  chatId: int64
  document: string
  caption: string {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Sticker:
  chatId: int64
  sticker: string
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Video:
  chatId: int64
  video: string
  duration: int {.optional.}
  width: int {.optional.}
  height: int {.optional.}
  caption: string {.optional.}
  supportsStreaming: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Voice:
  chatId: int64
  voice: string
  caption: string {.optional.}
  duration: int {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic VideoNote:
  chatId: int64
  videoNote: string
  duration: int {.optional.}
  length: int {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Location:
  chatId: int64
  latitude: float
  longitude: float
  livePeriod: int {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Venue:
  chatId: int64
  latitude: int
  longitude: int
  title: string
  address: string
  foursquareId: string {.optional.}
  foursquareType: string {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Contact:
  chatId: int64
  phoneNumber: string
  firstName: string
  lastName: string {.optional.}
  vcard: string {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Invoice:
  chatId: int64
  title: string
  description: string
  payload: string
  providerToken: string
  startParameter: string
  currency: string
  prices: seq[LabeledPrice]
  providerData: string {.optional.}
  photoUrl: string {.optional.}
  photoSize: int {.optional.}
  photoWidth: int {.optional.}
  photoHeight: int {.optional.}
  needName: bool {.optional.}
  needPhoneNumber: bool {.optional.}
  needEmail: bool {.optional.}
  needShippingAddress: bool {.optional.}
  sendPhoneNumberToProvider: bool {.optional.}
  sendEmailToProvider: bool {.optional.}
  isFlexible: bool {.optional.}
  disableNotification: bool {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Animation:
  chatId: int64
  animation: string
  duration: int {.optional.}
  width: int {.optional.}
  height: int {.optional.}
  thumb: string {.optional.}
  caption: string {.optional.}
  parseMode: string {.optional.}
  disableNotification: string {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Poll:
  chatId: int64
  question: string
  options: seq[string]
  isAnonymous: bool {.optional.}
  kind: string {.optional.}
  allowsMultipleAnswers: bool {.optional.}
  correctOptionId: int {.optional.}
  isClosed: bool {.optional.}
  disableNotification: string {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}

magic Dice:
  chatId: int64
  disableNotification: string {.optional.}
  replyToMessageId: int {.optional.}
  replyMarkup: KeyboardMarkup {.optional.}