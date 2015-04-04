
function run(msg, matches)
  if string.find(matches[1], "!echo") ~=nil then
    return "I'm sorry, Dave, I'm afraid I can't do that. The real exploit is in an other cas[tl]e anyway"
  elseif string.find(matches[1], "!") ~= nil then
    return string.gsub(matches[1], "!", "!!")
  else 
    return matches[1]
  end
end

return {
  description = "Simplest plugin ever!",
  usage = "!echo [whatever]: echoes the msg",
  patterns = {
    "^!echo (.*)$"
  }, 
  run = run 
}
