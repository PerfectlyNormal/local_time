{getI18nValue, translate} = LocalTime

LocalTime.strftime = strftime = (time, formatString) ->
  day    = (time.getDay() + 6) % 7 + 1
  date   = time.getDate()
  month  = time.getMonth()
  year   = time.getFullYear()
  hour   = time.getHours()
  minute = time.getMinutes()
  second = time.getSeconds()

  formatString.replace /%([%aAbBcdDeHIlmMpPSwWyYZ])/g, ([match, modifier]) ->
    switch modifier
      when "%" then "%"
      when "a" then getI18nValue("date.abbrDayNames")[day]
      when "A" then getI18nValue("date.dayNames")[day]
      when "b" then getI18nValue("date.abbrMonthNames")[month]
      when "B" then getI18nValue("date.monthNames")[month]
      when "c" then time.toString()
      when "d" then pad(date)
      when "e" then date
      when "H" then pad(hour)
      when "I" then pad(strftime(time, "%l"))
      when "l" then (if hour is 0 or hour is 12 then 12 else (hour + 12) % 12)
      when "m" then pad(month + 1)
      when "M" then pad(minute)
      when "p" then translate("time.#{(if hour > 11 then "pm" else "am")}").toUpperCase()
      when "P" then translate("time.#{(if hour > 11 then "pm" else "am")}")
      when "S" then pad(second)
      when "w" then day
      when "W" then getWeekNumber(time)
      when "y" then pad(year % 100)
      when "Y" then year
      when "Z" then parseTimeZone(time)

pad = (num) ->
  ("0#{num}").slice(-2)

getWeekNumber = (time) ->
  # Copy date so don't modify original
  d = new Date(Date.UTC(time.getFullYear(), time.getMonth(), time.getDate()))

  # Set to nearest Thursday: current date + 4 - current day number
  # Make Sunday's day number 7
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay()||7))

  # Get first day of year
  yearStart = new Date(Date.UTC(d.getUTCFullYear(),0,1))

  # Calculate full weeks to nearest Thursday
  return Math.ceil(( ( (d - yearStart) / 86400000) + 1)/7)

parseTimeZone = (time) ->
  string = time.toString()
  # Sun Aug 30 2015 10:22:57 GMT-0400 (NAME)
  if name = string.match(/\(([\w\s]+)\)$/)?[1]
    if /\s/.test(name)
      # Sun Aug 30 2015 10:22:57 GMT-0400 (Eastern Daylight Time)
      name.match(/\b(\w)/g).join("")
    else
      # Sun Aug 30 2015 10:22:57 GMT-0400 (EDT)
      name
  # Sun Aug 30 10:22:57 EDT 2015
  else if name = string.match(/(\w{3,4})\s\d{4}$/)?[1]
    name
  # "Sun Aug 30 10:22:57 UTC-0400 2015"
  else if name = string.match(/(UTC[\+\-]\d+)/)?[1]
    name
  else
    ""
