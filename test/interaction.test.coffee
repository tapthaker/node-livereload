should = require 'should'
{ Interaction }  = require '../lib/Interaction.coffee'

class MockInteractionHandler
  constructor: ->
    @_log = []

  obtainLog: ->
    result = @_log.join("\n");
    @_log = [];
    result
  obtainLastLog: ->
    result = ""
    if @_log.length > 0 then result = @_log[0];
    result

  log: (message) ->
    @_log.push message

  setAutoReloadOn: ->
    @log "auto-reload-on"
  setAutoReloadOff: ->
    @log "auto-reload-off"
  reloadNow: ->
    @log "reload-now"
  injectJS:(javascriptString) ->
    @log "inject(#{javascriptString})"

describe 'Interaction Reader', ->

  mockInteractionHandler = {}
  interaction = {}

  beforeEach ->
    mockInteractionHandler = new MockInteractionHandler()
    interaction = new Interaction(mockInteractionHandler)

  it "should toggle on autoreload when 'a' is pressed", ->
    interaction.sendEvent('key-press','a')
    mockInteractionHandler.obtainLastLog().should.equal("auto-reload-on")

  it "should toggle off autoreload when 'a' is pressed again", ->
    interaction.sendEvent('key-press','a')
    interaction.sendEvent('key-press','A')
    mockInteractionHandler.obtainLastLog().should.equal("auto-reload-off")

  it "should call reloadNow when 'r' is pressed", ->
    interaction.sendEvent('key-press','r')
    mockInteractionHandler.obtainLastLog().should.equal("reload-now")
    interaction.sendEvent('key-press','R')
    mockInteractionHandler.obtainLastLog().should.equal("reload-now")

  it "should call intectJS when inject is sent", ->
    javascriptString = "alert('hello world')"
    interaction.sendEvent('inject',javascriptString)
    mockInteractionHandler.obtainLastLog().should.equal("inject(#{javascriptString})")
