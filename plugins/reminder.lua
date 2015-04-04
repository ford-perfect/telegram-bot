
usage_string = "!rem Event Name @02.28 Stunden:Minuten\n Monat oder sogar Tag kann weggelassen werden"
local _file_reminder = './data/reminder.lua'

--read reminder values
function read_file_reminder()
  local f = io.open(_file_reminder, "r+")
  -- If file doesn't exists
  if f == nil then
    -- Create a new empty table
    print ('Created reminder file '.._file_reminder)
    serialize_to_file({}, _file_reminder)
  else
    print ('Stats loaded: '.._file_reminder)
    f:close() 
  end
  return loadfile (_file_reminder)()
end

_reminder = read_file_reminder()

function cron()
    --reload file (unneccesary)
    --_reminder = read_file_reminder()
    iterate_all(remind_if)
end

function iterate_all(call_fkt)
  for chat_id, chat_table in next,_reminder,nil do
    for rem_id, rem_table in next,chat_table,nil do
    -- print(rem_table.e..'@'..rem_table.d)
        call_fkt(chat_id, rem_id, rem_table)
    end
  end
end

function remind_if(chat_id, rem_id, rem_table)
  if(rem_table.prior == nil) then 
    prior = 5*60
  else
    prior = rem_table.prior
  end
  if(rem_table.d < os.time() + prior and rem_table.reminded == nil) then

    text = '‼REMINDER‼\n\''..rem_table.e

    if(rem_table.d > os.time()) then
      text = text..'\'\nwill take place at\n'..int2date(rem_table.d)
    else
      text = '\nhappened at '..int2date(rem_table.d)..' Sorry for the delay '
    end

    send_msg(chat_id, text, ok_cb, false)
    _reminder[chat_id][rem_id]['reminded'] = os.time()
    serialize_to_file(_reminder, _file_reminder)
    --send_document(chat_id, '/Users/vad/.telegram-cli/downloads/download_1842540969984019.webp', ok_cb, false)
  end
end

function run(msg, matches)
    --split string
    event_name, event_date = string.match(msg.text, "^!rem (.+)@([%d%s:%.%-/]+)$")
    if (event_name == nil or event_date == nil) then
      return usage_string
    end
    --print(event_name)
    date = dateparse.parse(event_date)
    if date == nil then return usage_string end
    -- print(date)
    if date < os.time() then
        return 'Error: You are going 67,000 mph, '..
        'but to load the flux-capacitor ya need '..
        '1.21 gigawatts for 30ms. Find Doc and go to the nearest cityhall.'
    end
    -- add
    chat = get_receiver(msg)
    if _reminder[chat] == nil then
		_reminder[chat] = {}
	end
    value_name = '#'..event_name..date--string.match(event_name,'([%a+%d*]+)')..date
    _reminder[chat][value_name] = { e=event_name, d=date }
 
	-- Save reminder to file
	serialize_to_file(_reminder, _file_reminder)
    iterate_all(remind_if)
    --bestätigung
    ret = 'Reminder set:\n\''..event_name..'\'\n'..int2date(date)..'☑'
    return ret
end

function remove_old()
    if serialize_to_file == nil then
      --package.path = ';./?.lua'..package.path
      require '../bot/utils'
      serpent = require "../libs/serpent"
    end
    --_reminder = read_file_reminder()
    removed = 0
    function check_remove(chat_id, rem_id, rem_table)
        if rem_table.reminded ~= nil then
           _reminder[chat_id][rem_id] = nil
           removed = removed +1
        end
    end
    if not pcall(function() iterate_all(check_remove) end) then
        print 'No chats in file'
        return
    end
    
    -- save back to file
    print('Removed '..removed..' old reminders.\n _TODO:empty chats')
    serialize_to_file(_reminder, _file_reminder)
    print('Saved.')
end

function int2date(time_int)
    return os.date('%d.%m.%Y %H:%M', time_int)
end

return {
    description = "Remind the Chatgroup or peer of an event",
    usage = usage_string,
    patterns = {"^!rem (.*)@(.*)$"},
    run = run,
    cron = cron
}
