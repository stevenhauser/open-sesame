OpenSesameView = require './open-sesame-view'

module.exports =
  openSesameView: null

  activate: (state) ->
    @openSesameView = new OpenSesameView(state.openSesameViewState)

  deactivate: ->
    @openSesameView.destroy()

  serialize: ->
    openSesameViewState: @openSesameView.serialize()
