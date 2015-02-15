
exports.Interaction = class Interaction

  constructor: (@interactionHandler) ->
    @autoReload = false
  sendEvent: (eventName,value) ->
    if 'key-press' is eventName and (value is 'A' || value is 'a')
      @autoReload = !@autoReload
      if(autoReload) then  @interactionHandler.setAutoReloadOn() else  @interactionHandler.setAutoReloadOff()
    else if 'key-press' is eventName and (value is 'r' || value is 'R')
       @interactionHandler.reloadNow()
    else if 'inject' is eventName
       @interactionHandler.injectJS(value)