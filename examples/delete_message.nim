import telebot, asyncdispatch, logging, options
from strutils import strip

var L = newConsoleLogger(fmtStr="$levelname, [$time] ")
addHandler(L)

const API_KEY = slurp("secret.key").strip()

proc commandHandler(b: Telebot, c: Command): Future[bool] {.async, gcsafe.} =
  echo await b.deleteMessage($c.message.chat.id, c.message.messageId)
  return true

when isMainModule:
  let bot = newTeleBot(API_KEY)

  bot.onCommand("deleteme", commandHandler)
  bot.poll(timeout=300)
