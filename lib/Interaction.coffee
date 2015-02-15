
exports.Interaction = class Interaction
  autoReload = false
  constructor: (@interactionHandler) ->

  sendEvent: (eventName,value) ->
    if 'key-press' is eventName and (value is 'A' || value is 'a')
      autoReload = !autoReload
      if(autoReload) then return @interactionHandler.setAutoReloadOn() else return @interactionHandler.setAutoReloadOff()
    else if 'key-press' is eventName and (value is 'r' || value is 'R')
      return @interactionHandler.reloadNow()
    else if 'inject' is eventName
      return @interactionHandler.injectJS(value)
