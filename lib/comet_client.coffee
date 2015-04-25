url = require 'url'
Reply = require './comet_reply'
DataList = require './data_list'
Path = require 'path'

class Client
  constructor: (@id, @listenType, @comet, @timeWait = 4, @timeInterval = 10000)->
    @removeCountdown = 10;
    @waitRemove = false
    
    @offsets = new DataList
    
    @requests = []
    
    @offsets.add @comet.getOffsets @listenType
    @startAutoReply()
    
    @intervalId = null
    
  startAutoReply: ()->
    @intervalId = setInterval ()=>
      for req in @requests
        req.countDown--
        if req.countDown is 0
          @sendNoChange req.req, req.res
          req.waitRemove = true
      
      @requests = @requests.filter (req)-> req.waitRemove isnt true
      
    , @timeInterval
  
  handleRequest: (req, res, next, offset)->
    @removeCountdown = 10
    if not @offsets.get offset
      @sendReSync req, res, next
      return
    
    if not @comet.satisfied @offsets.get offset
      @sendReSync req, res, next
      return
    
    datas = @comet.queryData @offsets.get offset
    
    if datas
      @sendNewData req, res, next, datas
      return
    
    @wait req, res
    
  notifyNewData: ()->
    @removeCountdown--
    if @removeCountdown == 0
      @waitRemove = true
      clearInterval @intervalId
      @comet.notifyRemove()
      
    #console.log @offsets.getLast(), @comet.getOffsets @listenType
    datas = @comet.queryData @offsets.getLast() 
    @offsets.add @comet.getOffsets @listenType
    
    for connection in @requests
      @sendNewData connection.req, connection.res, null, datas
    
    @requests = []
    
  #private methods
  
  wait: (req, res)->
    connection = {req : req, res : res}
    @requests.push connection
    connection.countDown = @timeWait
    
  sendNewData: (req, res, next, datas)->
    reply = new Reply
    reply.datas = datas
    reply.offset = reply.newOffset = @offsets.last
    reply.newPath = @getPath @offsets.last, req.baseUrl
    res.jsonp(reply)
    
  sendReSync: (req, res)->
    reply = new Reply
    reply.offset = -2
    reply.newOffset = @offsets.last
    
    #console.log req
    reply.newPath = @getPath @offsets.last, req.baseUrl
    reply.status = 302
    
    res.header 'Location', reply.newPath
    res.status 302
    .jsonp reply
  
  sendNoChange: (req, res)->
    reply = new Reply
    reply.offset = -1
    reply.newOffset = @offsets.last
    reply.newPath = @getPath @offsets.last, req.baseUrl
    res.jsonp(reply)
      
  getPath: (offset, baseURL)->
    #console.log baseURL, (@listenType.join ','), @id, offset
    path = Path.resolve baseURL, (@listenType.join ','), @id, offset.toString 10
    #console.log path
    path
    
  Client.parsePath = (path)->
    path = path.replace /^\/|\/$/g, ''
      .split '/'
      .filter (i)-> i isnt ''
      
    #console.log path
    if path.length != 3 && path.length != 1
      return null
    
    if path[2] != undefined
      path[2] = parseInt path[2], 10
      if isNaN path[2]
        return null
    #console.log path[0], path[0].split ','
    return {
      types : path[0].split ','
      id : path[1]
      offset : path[2]
    }


module.exports = Client