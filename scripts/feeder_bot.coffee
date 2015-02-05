# Description:
#   feeder Hubot scripts 
#
# Notes:
#   

# library
request = require "request"
cheerio = require "cheerio"
cronJob = require("cron").CronJob

random = (n) -> Math.floor(Math.random() * n)

module.exports = (robot) ->

  # redis用キー
  KEY_OMIKUJI_COUNT = 'omikuji_count'

  # おみくじ
  robot.respond /おみくじ！$/i, (msg) ->
    # 保存した変数を読み込む
    point = robot.brain.get KEY_OMIKUJI_COUNT or {}
    # 1足して保存
    robot.brain.set KEY_OMIKUJI_COUNT, point+1
    kuji = ["大吉！", "中吉", "小吉", "吉", "凶…"]
    result = kuji[random(5)]
    
    msg.send "#{result} （#{point+1}回目）"

  # ケンミンショー用cron設定
  cronjob = new cronJob(
    cronTime: '0 0 0 * * thu'
    start: true
    timeZone: 'Asia/Tokyo'
    onTick: -> 
      robot.send {room: process.env.HUBOT_CHATWORK_ROOMS}, return # "ケンミンショーの日だよ！"
  )

  # 宇都宮の天気
  robot.respond	/宇都宮の天気$/i, (msg) ->
    options =
      url: "http://weather.yahoo.co.jp/weather/jp/9/4110.html"
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}

    request options, (error, response, body) ->
      $ = cheerio.load body
      title = $('div.forecastCity').find('p.pict').first().text().replace(/\n/g, '')
      msg.send(title)

  # 東京の天気
  robot.respond	/東京の天気$/i, (msg) ->
    options =
      url: "http://weather.yahoo.co.jp/weather/jp/13/4410.html"
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}

    request options, (error, response, body) ->
      $ = cheerio.load body
      title = $('div.forecastCity').find('p.pict').first().text().replace(/\n/g, '')
      msg.send(title)

