{View} = require 'atom'

module.exports =
class OpenSesameView extends View
  @content: ->
    @div class: 'open-sesame overlay from-top', =>
      @div "The OpenSesame package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "open-sesame:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "OpenSesameView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
