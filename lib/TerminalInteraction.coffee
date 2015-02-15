{ Interaction }  = require './Interaction.coffee'
blessed = require('blessed');
fs = require 'fs'

class TerminalInteraction
  autoReload = false

  constructor: (@interaction)->
    this.screen = blessed.screen();
    this.screen.title = 'Live Reload';
    debugger;
    bottomStatusBar = setupBottomStatusBar()
    this.screen.append(bottomStatusBar)
    consoleLogger = setupConsoleLogger()
    this.screen.append(consoleLogger)
    fileManager = setupFileManager process.env.HOMEPATH, (file) ->
      consoleLogger.setContent(consoleLogger.content + '\n' + fs.readFileSync(file))
      this.screen.render()
    fileManager.focus()
    this.screen.append(fileManager)

    this.screen.key ['a', 'A'], (ch, key) ->
      autoReload = !autoReload
      bottomStatusBar.setContent(getContentText())
      this.screen.render()
      @interaction.sentEvent('key-press',key)

    this.screen.key ['r', 'R'], (ch, key)->
      @interaction.sendEvent('key-press',key)

    this.screen.key ['escape', 'q', 'C-c'],  ->
      process.exit(0);


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




terminalInteraction = new TerminalInteraction()
terminalInteraction.start()