WORD_REGEX = /[\/A-Z\.\d-_]+/i
OPEN_COMMAND = 'open-sesame:open-file-under-cursor'

getPathUnderCursor = ->
  atom.workspace.getActiveEditor()?.getWordUnderCursor
    wordRegex: WORD_REGEX

openFileUnderCursor = ->
  path = getPathUnderCursor()
  atom.workspaceView.open(path) if path

module.exports =

  activate: (state) ->
    atom.workspaceView.command OPEN_COMMAND, openFileUnderCursor
