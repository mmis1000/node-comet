express = require 'express'
Client = require './comet_client'
Reply = require './comet_reply'
DataList = require './data_list'

UUID = ->
  s4 = ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
  s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

class Comet
  constructor: (@dataTypes)->
    @datas = {}
    
    for type in @dataTypes
      @datas[type] = new DataList
    
    @clients = []
    
  getMiddleWare: (path)->
    middleWareHandle = (req, res, next)=>
      #res.end 'test'
      @handleRequest req, res, next
    
    router = new express.Router
    
    router.use middleWareHandle
    return router
    
  pushData: (type, data)->
    @datas[type].add data
    for client in @clients
      if type in client.listenType
        client.notifyNewData()
    
  handleRequest: (req, res, next)->
    path = req.path
    parsed = Client.parsePath path
    
    if not parsed
      reply = new Reply
      reply.status = 404
      reply.error = 'bad format query'
      res.status 404
        .jsonp reply
      return
    
    for type in parsed.types
      #console.log type in @dataTypes
      if not (type in @dataTypes)
        reply = new Reply
        reply.status = 404
        reply.error = 'unknown query type ' + type
        res.status 404
          .jsonp reply
        return
    #console.log parsed.types
    client = @getClient parsed.id, parsed.types
    
    client.handleRequest req, res, next, parsed.offset
    
  getClient: (id, types)->
    client = (@clients.filter (i)-> i.id == id)[0]
    
    if not client
      client = new Client UUID(), types, @
      @clients.push client
    client
    
  getOffsets: (types)->
    offsets = {}
    for type in types
      offsets[type] = @datas[type].last
    offsets
  
  satisfied: (offsets)->
    #console.log @datas, offsets
    for key, value of offsets
      if not @datas[key].inRange value
        return false
    true
    
  queryData: (offsets)->
    datas = []
    for key, value of offsets
      data = @datas[key].queryAfter value
      if data
        data = data.map (item)->{data : item, type : key}
        datas = datas.concat data
    if datas.length > 0
      return datas
      
    null
  
  notifyRemove: ()->
    process.nextTick ()=>
      @clients =  @clients.filter (i)-> i.waitRemove is false

module.exports = Comet