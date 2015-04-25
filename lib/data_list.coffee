class DataList
  constructor: (@maxLength = 10)->
    @data = []
    @head = 0
    @last = -1
  
  add: (item)->
    @data.push item
    @last += 1
    
    if @data.length > @maxLength
      @shift()
    
  shift: ()->
    @data.shift()
    @head += 1
  
  get: (index)->
    @data[index - @head]
  
  inRange: (index)->
    @head - 1 <= index && @last >= index
  
  queryAfter: (index)->
    if @inRange index
      return @data[index + 1 - @head .. @last - @head]
  
    null
  
  getLast: ()-> @get @last



module.exports = DataList