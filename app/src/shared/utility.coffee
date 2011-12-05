module.exports = Util =
  factorForty: (n) ->
    if n < 41 then return n
    else
      timesOver = parseInt n / 40, 10
      extra = timesOver * 40
      return n - extra
