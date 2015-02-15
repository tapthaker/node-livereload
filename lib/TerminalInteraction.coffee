{ Interaction }  = require './Interaction.coffee'
blessed = require('blessed');
fs = require 'fs'

exports.TerminalInteraction =

class TerminalInteraction
  autoReload = false
  constructor: (interaction)->
    this.screen = blessed.screen();
    this.screen.title = 'Live Reload';
    bottomStatusBar = setupBottomStatusBar()
    this.screen.append(bottomStatusBar)
    this.consoleLogger = setupConsoleLogger()
    this.screen.append(this.consoleLogger)
    fileManager = setupFileManager process.env.HOMEPATH, (file) ->
      @showLog("Injecting file #{file}")
      this.interaction.sendEvent('inject',fs.readFileSync(file))
    fileManager.focus()
    this.screen.append(fileManager)

    this.screen.key ['a', 'A'], (ch, key) ->
      autoReload = !autoReload
      bottomStatusBar.setContent(getContentText())
      this.screen.render()
      interaction.sendEvent('key-press','a')

    this.screen.key ['r', 'R'], (ch, key)->
      interaction.sendEvent('key-press','r')

    this.screen.key ['escape', 'q', 'C-c'],  ->
      process.exit(0);


  showLog:(text) ->
    this.consoleLogger.setContent(this.consoleLogger.content + '\n' + text)
    this.screen.render();



  setupBottomStatusBar = ->
    blessed.box {
      top: '95%',
      left: '0%',
      width: '100%',
      height: '5%',
      content: getContentText(),
      tags: true,
      bg: 'blue',
      mouse: true
    }

  setupFileManager =  (currentWorkingDirectory,onFileSelected)  ->
    fm = blessed.filemanager({
      border: {
        type: 'ascii'
      },
      selectedBg: 'blue',
      height: '95%',
      width: 'half',
      top: '0%',
      left: '0%',
      label: ' {blue-fg}%path{/blue-fg} ',
      cwd: currentWorkingDirectory,
      keys: true,
      vi: true,
      scrollbar: {
        bg: 'white',
        ch: ' '
      }
    });
    fm.refresh()
    fm.on 'file', (file) ->
      stats = fs.statSync(file)
      if stats.isFile
        onFileSelected(file)
    return fm

  setupConsoleLogger = ->
    box = blessed.box {
      border: {
        type: 'ascii'
      },
      top: '0%',
      left: '50%',
      width: '50%',
      height: '95%',
      scrollable: true,
      scrollbar: {
        bg: 'blue'
      },
      tags: true,
      bg: 'black',
      mouse: true,
      autoFocus: true
    }

  getContentText= ->
    autoReloadText ='off'
    if autoReload
      autoReloadText = 'On'
    else
      autoReloadText = 'Off'
    "Options:   {bold}R{/bold}eload         {bold}A{/bold}uto Reload turned {bold}#{autoReloadText}{/bold}       Press {bold}Enter{/bold} on a js file to inject it."

  start: ->
    this.screen.render()
