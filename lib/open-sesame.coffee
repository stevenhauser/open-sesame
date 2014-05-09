PATH_REGEX = /[\/A-Z\.\d-_]+/i
OPEN_COMMAND = 'open-sesame:open-file-under-cursor'

getPathUnderCursor = ->
  atom.workspace.getActiveEditor()?.getWordUnderCursor
    wordRegex: PATH_REGEX

openFileUnderCursor = ->
  path = getPathUnderCursor()
  atom.workspaceView.open(path) if path

module.exports =

  PATH_REGEX: PATH_REGEX

  activate: (state) ->
    atom.workspaceView.command OPEN_COMMAND, openFileUnderCursor
