#
# ###Buffer Utility
#
#   - Tallies calls and returns false n times
#   - Reaches n threshold after n tallies and returns true
#
module.exports = Buffer = (n) ->
  nth = n
  rnd = Math.floor(Math.random() * nth) + 1
  if rnd is nth then return true
  else return false
