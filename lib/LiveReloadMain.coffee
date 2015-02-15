livereload = require('../lib/livereload.coffee');
{ Interaction }  = require '../lib/Interaction.coffee'
{ TerminalInteraction }  = require '../lib/TerminalInteraction.coffee'



exports.LiveReloadMain  =
  class  LiveReloadMain
    constructor: (@options) ->
      @autoReload = off

    startServer: ->
      compileHandler = (path) ->
        console.log("Attempting to compile: " + path);
        result = @options.compileHandler(path);
        result.success =  result.success && @autoReload;

      @server = livereload.createServer({applyJSLive:true,debug:true,compileHandler:compileHandler});
      @server.watch(@options.path);

      interaction = new Interaction(this)
      terminalInteraction = new TerminalInteraction(interaction)
      terminalInteraction.start();

    console.log = (text) ->
      terminalInteraction.showLog(text)

    setAutoReloadOn: ->
      @autoReload = on;

    setAutoReloadOff: ->
      @autoReload = off;

    injectJS: (javascriptString) ->
      @server.injectJS(javascriptString)

    reloadNow: ->
      @server.refresh();