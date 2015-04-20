_ = require('lodash')
async = require('async')
cron = require('cron').CronJob
ical = require('ical')
moment = require('moment')

registerJob = (expr, cb) ->
  new cron expr, cb, null, true

getEventsFromICalURL = (url, cb) ->
  ical.fromURL url, {}, (err, data) ->
    return if err

    tomorrow = moment().add(1, 'd')
    events = (data[key] for key of data).map (e) ->
      e.start = moment(e.start)
      e.end = moment(e.end)
      e
    .filter (e) -> e.start.isSame(tomorrow, 'day')

    cb(events)


module.exports = (robot) ->
  getCalendarList = -> robot.brain.get('calendars') || []
  registerJob '0 0 21 * * *', ->
    cals = getCalendarList()

    processes = cals.map (cal) ->
      return (cb) ->
        getEventsFromICalURL cal, (events) ->
          cb(null, events)

    async.parallel processes, (err, events) ->
      events = _.flatten(events)
      num = if events.length == 0 then 'no' else events.length
      pl = if num == 1 then '' else 's'
      text = "You have #{num} scheduled event#{pl} tomorrow.\n"
      text += events.map (e) ->
        location = if e.location then " @#{e.location}" else ''
        start = e.start.format('HH:mm')
        end = e.end.format('HH:mm')
        time = if start is '00:00' and end is '00:00'
          'all day'
        else
          "#{start} - #{end}"
        "#{e.summary}#{location} (#{time})"
      .join "\n"

      robot.send { room: 'calendar' }, text

  robot.respond /cal:add (.+)/, (msg) ->
    newCal = msg.match[1]
    cals = getCalendarList()
    cals.push newCal
    robot.brain.set 'calendars', cals

    text = "New calendar has been added!\n"
    pl = if cals.length == 1 then '' else 's'
    text += "Now you have #{cals.length} calendar#{pl}."
    msg.send text

  robot.respond /cal:list/, (msg) ->
    cals = getCalendarList()
    num = if cals.length == 0 then 'no' else cals.length
    pl = if cals.length == 1 then '' else 's'
    text = "You have #{num} calendar#{pl}."
    msg.send "#{text}\n" + cals.join "\n"
