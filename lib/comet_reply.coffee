class Reply
  constructor: ()->
    @offset = -2
    @newOffset = -2
    @newPath = ""
    @datas = []
    @status = 200
  
  toJSON: ()->
    obj = {}
    for key, value of @
      if @hasOwnProperty key
        obj[key] = value
    obj


module.exports = Reply