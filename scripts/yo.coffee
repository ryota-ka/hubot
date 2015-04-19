Yo = require 'yo-api'
yo = new Yo process.env.YO_API_TOKEN

module.exports = (robot) ->
  robot.respond /yo ([0-9a-zA-Z]+)/, (msg) ->
    recipient = msg.match[1].toUpperCase()
    yo.yo recipient, (err, res, body) ->
      if err
        msg.send "Failed to send Yo to #{recipient}"
      else
        msg.send "Sent Yo to #{recipient} successfully"
