import httpclient, sam, asyncdispatch, utils, strutils, options, strtabs
from tables import hasKey, `[]`
import types, keyboard

proc getMe*(b: TeleBot): Future[User] {.botapi.}
  ## Returns basic information about the bot

proc sendMessage*(
    b: TeleBot,
    chatId: int64,
    text: string,
    parseMode = "",
    disableWebPagePreview = false,
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendPhoto*(
    b: TeleBot,
    chatId: int64,
    photo: InputFileOrString,
    caption = "",
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendAudio*(
    b: TeleBot,
    chatId: int64,
    audio: InputFileOrString,
    caption = "",
    duration = 0,
    performer = "",
    title = "",
    thumb: InputFileOrString = "",
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendDocument*(
    b: TeleBot,
    chatId: int64,
    document: InputFileOrString,
    thumb: InputFileOrString = "",
    caption = "",
    parseMode = "",
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendSticker*(
    b: TeleBot,
    chatId: int64,
    sticker: InputFileOrString,
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendVideo*(
    b: TeleBot,
    chatId: int64,
    video: InputFileOrString,
    duration = 0,
    width = 0,
    height = 0,
    thumb = "",
    caption = "",
    parseMode = "",
    supportsStreaming = false,
    disableNotification = false,
    replyToMessageId = 0,
    replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendVoice*(
  b: TeleBot,
  chatId: int64,
  voice: string,
  caption = "", duration = 0,
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendVideoNote*(b: TeleBot,
  chatId: int64,
  videoNote: string,
  duration = 0,
  length = 0,
  thumb = "",
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendLocation*(b: TeleBot,
  chatId: int64,
  latitude: float,
  longitude: float,
  livePeriod = 0,
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil

): Future[Message] {.botapi.}

proc sendVenue*(b: TeleBot,
  chatId: int64,
  latitude: float,
  longitude: float,
  address: string,
  foursquareId = "",
  foursquareType = "",
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendContact*(b: TeleBot,
  chatId: int64,
  phoneNumber: string,
  firstName: string,
  lastName = "",
  vcard = "",
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendInvoice*(b: TeleBot,
  chatId: int64,
  title: string,
  description: string,
  payload: string,
  providerToken: string,
  startParameter: string,
  currency: string,
  prices: seq[LabeledPrice],
  providerData = "",
  photoUrl = "",
  photoSize = 0,
  photoWidth = 0,
  photoHeight = 0,
  needName = false,
  needPhoneNumber = false,
  needEmail = false,
  needShippingAddress = false,
  sendPhoneNumberToProvider = false,
  sendEmailToProvider = false,
  isFlexible = false,
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendAnimation*(b: TeleBot,
  chatId: int64,
  animation: string,
  duration = 0,
  width = 0,
  height = 0,
  thumb = "",
  caption = "",
  parseMode = "",
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendPoll*(b: TeleBot,
  chatId: int64,
  question: string,
  options: seq[string],
  isAnonymous = false,
  kind = "",
  allowsMultipleAnswers = false,
  correctOptionId = 0,
  explanation = "",
  explanationParseMode = "",
  openPeriod = 0,
  closeDate = 0,
  isClosed = false,
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc sendDice*(b: TeleBot,
  chatId: int64,
  emoji = "",
  disableNotification = false,
  replyToMessageId = 0,
  replyMarkup: KeyboardMarkup = nil
): Future[Message] {.botapi.}

proc forwardMessage*(b: TeleBot,
  chatId: string,
  fromChatId: string,
  messageId: int,
  disableNotification = false
): Future[Message] {.botapi.}

proc sendChatAction*(b: TeleBot,
  chatId: string,
  action: string
): Future[
  void] {.botapi.}

proc getUserProfilePhotos*(b: TeleBot,
  userId: int,
  offset = 0,
  limit = 100
): Future[UserProfilePhotos] {.botapi.}

proc getFile*(b: TeleBot,
  fileId: string
): Future[types.File] {.botapi.}

proc kickChatMember*(b: TeleBot,
  chatId: string,
  userId: int,
  untilDate = 0
): Future[bool] {.botapi.}

proc unbanChatMember*(b: TeleBot,
  chatId: string,
  userId: int
): Future[bool] {.botapi.}

proc restrictChatMember*(b: TeleBot,
  chatId: string,
  userId: int,
  permissions: ChatPermissions,
  untilDate = 0
): Future[bool] {.botapi.}

proc promoteChatMember*(b: TeleBot,
  chatId: string,
  userId: int,
  canChangeInfo = false,
  canPostMessages = false,
  canEditMessages = false,
  canDeleteMessages = false,
  canInviteUsers = false,
  canRestrictMembers = false,
  canPinMessages = false,
  canPromoteMembers = false
): Future[bool] {.botapi.}

proc setChatPermissions*(b: TeleBot,
  chatId: string,
  permissions: ChatPermissions
): Future[bool] {.botapi.}

proc exportChatInviteLink*(b: TeleBot,
  chatId: string
): Future[string] {.botapi.}

proc setChatPhoto*(b: TeleBot,
  chatId: string,
  photo: string
): Future[bool] {.botapi.}

proc deleteChatPhoto*(b: TeleBot,
  chatId: string
): Future[bool] {.botapi.}

proc setChatTitle*(b: TeleBot,
  chatId: string,
  title: string
): Future[bool] {.botapi.}

proc setChatDescription*(b: TeleBot,
  chatId: string,
  description = ""): Future[
  bool] {.botapi.}

proc pinChatMessage*(b: TeleBot,
  chatId: string,
  messageId: int,
  disableNotification = false
): Future[bool] {.botapi.}

proc unpinChatMessage*(b: TeleBot,
  chatId: string
): Future[bool] {.botapi.}

proc leaveChat*(b: TeleBot,
  chatId: string
): Future[bool] {.botapi.}

proc getChat*(b: TeleBot,
  chatId: string
): Future[Chat] {.botapi.}

proc getChatAdministrators*(b: TeleBot,
  chatId: string
): Future[seq[
  ChatMember]] {.botapi.}

proc getChatMemberCount*(b: TeleBot,
  chatId: string
): Future[int] {.botapi.}

proc getChatMember*(b: TeleBot,
  chatId: string,
  userId: int
): Future[
  ChatMember] {.botapi.}

proc getStickerSet*(b: TeleBot,
  name: string
): Future[StickerSet] {.botapi.}

proc uploadStickerFile*(b: TeleBot,
  userId: int,
  pngSticker: InputFileOrString
): Future[types.File] {.botapi.}

proc createNewStickerSet*(b: TeleBot,
  userId: int,
  name: string,
  title: string,
  pngSticker: string,
  tgsSticker: string,
  emojis: string,
  containsMasks = false,
  maskPosition = none(MaskPosition)
): Future[bool] {.botapi.}

proc addStickerToSet*(b: TeleBot,
  userId: int,
  name: string,
  pngSticker: InputFileOrString,
  tgsSticker: InputFileOrString,
  emojis: string,
  maskPosition = none(MaskPosition)
): Future[bool] {.botapi.}

proc setStickerPositionInSet*(b: TeleBot,
  sticker: string,
  position: int
): Future[bool] {.botapi.}

proc deleteStickerFromSet*(b: TeleBot,
  sticker: string
): Future[bool] {.botapi.}

proc setStickerSetThumb*(b: TeleBot,
  name: string,
  userId: int,
  thumb: InputFileOrString = ""
): Future[bool] {.botapi.}

proc setChatStickerSet*(b: TeleBot,
  chatId: string,
  stickerSetname: string
): Future[bool] {.botapi.}

proc deleteChatStickerSet*(b: TeleBot,
  chatId: string
): Future[bool] {.botapi.}

proc editMessageLiveLocation*(b: TeleBot,
  latitude: float,
  longitude: float,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  replyMarkup: KeyboardMarkup = nil
): Future[bool] {.botapi.}

proc stopMessageLiveLocation*(b: TeleBot,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  replyMarkup: KeyboardMarkup = nil
): Future[bool] {.botapi.}

proc sendMediaGroup*(b: TeleBot,
  chatId = "",
  media: seq[InputMedia],
  disableNotification = false,
  replyToMessageId = 0
): Future[bool] {.botapi.}

proc editMessageMedia*(b: TeleBot,
  media: InputMedia,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  replyMarkup: KeyboardMarkup = nil
): Future[Option[Message]] {.async.} =

  END_POINT("editMessageMedia")
  var data = newMultipartData()
  if chatId.len > 0:
    data["chat_id"] = chat_id
  if messageId != 0:
    data["message_id"] = $messageId
  if inlineMessageId.len != 0:
    data["inline_message_id"] = inlineMessageId

  uploadInputMedia(data, media)
  var json = ""
  marshal(media, json)
  data["media"] = json
  if replyMarkup != nil:
    data["reply_markup"] = $replyMarkup

  let res = await makeRequest(b, endpoint % b.token, data)
  if res.isPrimitive:
    result = none(Message)
  else:
    result = some(unmarshal(res, Message))

proc editMessageText*(b: TeleBot,
  text: string,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  parseMode = "",
  replyMarkup: KeyboardMarkup = nil,
  disableWebPagePreview = false
): Future[Option[Message]] {.async.} =

  END_POINT("editMessageText")
  var data = newMultipartData()
  if chatId.len > 0:
    data["chat_id"] = chat_id
  if messageId != 0:
    data["message_id"] = $messageId
  if inlineMessageId.len != 0:
    data["inline_message_id"] = inlineMessageId
  if replyMarkup != nil:
    data["reply_markup"] = $replyMarkup
  if parseMode != "":
    data["parse_mode"] = parseMode
  if disableWebPagePreview == true:
    data["disable_web_page_preview"] = "true"

  data["text"] = text

  let res = await makeRequest(b, endpoint % b.token, data)
  if res.isPrimitive:
    result = none(Message)
  else:
    result = some(unmarshal(res, Message))

proc editMessageCaption*(b: TeleBot,
  caption = "",
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  parseMode = "",
    replyMarkup: KeyboardMarkup = nil
): Future[Option[Message]] {.async.} =

  END_POINT("editMessageCaption")
  var data = newMultipartData()
  if chatId.len > 0:
    data["chat_id"] = chat_id
  if messageId != 0:
    data["message_id"] = $messageId
  if inlineMessageId.len != 0:
    data["inline_message_id"] = inlineMessageId
  if replyMarkup != nil:
    data["reply_markup"] = $replyMarkup
  if parseMode != "":
    data["parse_mode"] = parseMode

  data["caption"] = caption

  let res = await makeRequest(b, endpoint % b.token, data)
  if res.isPrimitive:
    result = none(Message)
  else:
    result = some(unmarshal(res, Message))

proc editMessageReplyMarkup*(b: TeleBot,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  replyMarkup: KeyboardMarkup = nil
): Future[Option[Message]] {.async.} =

  END_POINT("editMessageReplyMarkup")
  var data = newMultipartData()
  if chatId.len > 0:
    data["chat_id"] = chat_id
  if messageId != 0:
    data["message_id"] = $messageId
  if inlineMessageId.len != 0:
    data["inline_message_id"] = inlineMessageId
  if replyMarkup != nil:
    data["reply_markup"] = $replyMarkup

  let res = await makeRequest(b, endpoint % b.token, data)
  if res.isPrimitive:
    result = none(Message)
  else:
    result = some(unmarshal(res, Message))

proc stopPoll*(b: TeleBot,
  chatId = "",
  messageId = 0,
  inlineMessageId = "",
  replyMarkup: KeyboardMarkup = nil
): Future[Option[Poll]] {.async.} =

  END_POINT("stopPool")
  var data = newMultipartData()
  if chatId.len > 0:
    data["chat_id"] = chat_id
  if messageId != 0:
    data["message_id"] = $messageId
  if inlineMessageId.len != 0:
    data["inline_message_id"] = inlineMessageId
  if replyMarkup != nil:
    data["reply_markup"] = $replyMarkup

  let res = await makeRequest(b, endpoint % b.token, data)
  if res.isPrimitive:
    result = none(Poll)
  else:
    result = some(unmarshal(res, Poll))

proc deleteMessage*(b: Telebot,
  chatId: string,
  messageId: int
): Future[bool] {.botapi.}

proc answerCallbackQuery*(b: TeleBot,
  callbackQueryId: string,
  text = "",
  showAlert = false,
  url = "",
  cacheTime = 0
): Future[bool] {.botapi.}

proc setMyCommands*(b: TeleBot,
  commands: seq[BotCommand]): Future[bool] {.botapi.}

proc answerInlineQuery*[T](b: TeleBot,
  id: string,
  results: seq[T],
  cacheTime = 0,
  isPersonal = false,
  nextOffset = "",
  switchPmText = "",
  switchPmParameter = ""): Future[bool] {.botapi.}

proc setChatAdministratorCustomTitle*(b: TeleBot,
  chatId: string,
  userId: int,
  customTitle: string
): Future[bool] {.botapi.}

proc getUpdates*(b: TeleBot, offset, limit = 0, timeout = 50,
    allowedUpdates: seq[string] = @[]): Future[JsonNode] {.async.} =
  END_POINT("getUpdates")
  var data = newMultipartData()

  if offset > 0:
    data["offset"] = $offset
  elif b.lastUpdateId > 0:
    data["offset"] = $(b.lastUpdateId+1)
  if limit > 0:
    data["limit"] = $limit
  if timeout > 0:
    data["timeout"] = $timeout
  if allowedUpdates.len > 0:
    data["allowed_updates"] = $allowedUpdates

  result = await makeRequest(b, endpoint % b.token, data)

  if result.len > 0:
    b.lastUpdateId = result[result.len - 1]["update_id"].toInt

proc handleUpdate*(b: TeleBot, update: Update) {.async.} =
  # stop process other callbacks if a callback returns true
  var stop = false
  if update.inlineQuery.isSome:
    for cb in b.inlineQueryCallbacks:
      stop = await cb(b, update.inlineQuery.get)
      if stop: break
  elif update.hasCommand(b.username):
    var cmd = Command(
      command: command,
      message: message,
      params: params
    )
    if b.commandCallbacks.hasKey(command):
      for cb in b.commandCallbacks[command]:
        stop = await cb(b, cmd)
        if stop: break
    elif b.catchallCommandCallback != nil:
      stop = await b.catchallCommandCallback(b, cmd)
  if not stop:
    for cb in b.updateCallbacks:
      stop = await cb(b, update)
      if stop: break

proc cleanUpdates*(b: TeleBot) {.async.} =
  var updates = await b.getUpdates(timeout = 0)
  while updates.len >= 100:
    updates = await b.getUpdates()

proc loop(b: TeleBot, timeout = 50, offset, limit = 0) {.async.} =
  try:
    let me = waitFor b.getMe()
    b.id = me.id
    if me.username.isSome:
      b.username = me.username.get().toLowerAscii()
  except IOError, OSError:
    d("Unable to fetch my info ", getCurrentExceptionMsg())

  while true:
    let updates = await b.getUpdates(timeout = timeout, offset = offset, limit = limit)
    for item in updates:
      let update = unmarshal(item, Update)
      asyncCheck b.handleUpdate(update)

proc poll*(b: TeleBot, timeout = 50, offset, limit = 0, clean = false) =
  if clean:
    waitFor b.cleanUpdates()
  waitFor loop(b, timeout, offset, limit)

proc pollAsync*(b: TeleBot, timeout = 50, offset, limit = 0, clean = false) {.async.} =
  if clean:
    await b.cleanUpdates()
  await loop(b, timeout, offset, limit)
