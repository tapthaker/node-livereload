livereload = require '../lib/livereload'
should = require 'should'
request = require 'request'
http = require 'http'
url = require 'url'
fs = require 'fs'
path = require 'path'
WebSocket = require 'ws'

describe 'livereload http file serving', ->

  it 'should serve up livereload.js', (done) ->
    server = livereload.createServer({port: 35729})

    fileContents = fs.readFileSync('./ext/livereload.js').toString()

    request 'http://localhost:35729/livereload.js?snipver=1', (error, response, body) ->
      should.not.exist error
      response.statusCode.should.equal 200
      fileContents.should.equal body

      server.config.server.close()

      done()

  it 'should connect to the websocket server', (done) ->
    server = livereload.createServer({port: 35729})

    ws = new WebSocket('ws://localhost:35729/livereload')
    ws.on 'message', (data, flags) ->
      data.should.equal '!!ver:1.6'

      server.config.server.close()

      done()

  it 'should allow you to override the internal http server', (done) ->
    app = http.createServer (req, res) ->
      if url.parse(req.url).pathname is '/livereload.js'
        res.writeHead(200, {'Content-Type': 'text/javascript'})
        res.end '// nothing to see here'

    server = livereload.createServer({port: 35729, server: app})

    request 'http://localhost:35729/livereload.js?snipver=1', (error, response, body) ->
      should.not.exist error
      response.statusCode.should.equal 200
      body.should.equal '// nothing to see here'

      server.config.server.close()

      done()

  it 'should allow you to specify ssl certificates to run via https', (done)->
    server = livereload.createServer
      port: 35729
      https:
        cert: fs.readFileSync path.join __dirname, 'ssl/localhost.cert'
        key: fs.readFileSync path.join __dirname, 'ssl/localhost.key'

    fileContents = fs.readFileSync('./ext/livereload.js').toString()

    # allow us to use our self-signed cert for testing
    unsafeRequest = request.defaults
      strictSSL: false
      rejectUnauthorized: false

    unsafeRequest 'https://localhost:35729/livereload.js?snipver=1', (error, response, body) ->
      should.not.exist error
      response.statusCode.should.equal 200
      fileContents.should.equal body

      server.config.server.close()

      done()

  it 'should call the compileHandler' , (done) ->
    filePath = "xxx/yyy/zzz"
    compileHandler = (path) ->
      path.should.equal(filePath)
      done()
      debugger;

    server = livereload.createServer(port: 35729,compileHandler:compileHandler)
    server.refresh(filePath)
    server.config.server.close()

  it 'should send message to client if compileHandler succeeded' , (done) ->
    filePath ='xxx/yyy/zzz.coffee'
    compiledPath=filePath.replace('.coffee','.js')
    compileHandler = (path) ->
      return {success:true,outputFilePath:compiledPath}

    server = livereload.createServer(port: 35729,compileHandler:compileHandler)


    ws = new WebSocket('ws://localhost:35729/livereload')
    ws.on 'message', (data, flags) ->
      message
      try
        message = JSON.parse data
        if message[0] is 'refresh'
          message[1].path.should.equal(compiledPath)
          server.config.server.close();
          done()
      catch

    refresh = ->
      server.refresh(filePath,compileHandler)

    setTimeout(refresh,100)

  it 'should not send message to client if compileHandler failed' , (done) ->
    compileHandler = (path) ->
    refreshCalled = false
    server = livereload.createServer(port: 35729,compileHandler:compileHandler)


    ws = new WebSocket('ws://localhost:35729/livereload')
    ws.on 'message', (data, flags) ->
      message
      try
        message = JSON.parse data
        if message[0] is 'refresh'
          refreshCalled = true
      catch

    refresh = ->
      server.refresh('',compileHandler)

    testPass = ->
      refreshCalled.should.equal(false)
      server.config.server.close();
      done();

    setTimeout(refresh,100)
    setTimeout(testPass,200)


describe 'livereload file watching', ->

  it 'should correctly watch common files', ->
    # TODO check it watches default exts

  it 'should correctly ignore common exclusions', ->
    # TODO check it ignores common exclusions

  it 'should not exclude a dir named git', ->
    # cf. issue #20
