{Point} = require('atom')

PATH_REGEX = /[\/A-Z\.\d-_]+(:\d+)?/i
OPEN_COMMAND = 'open-sesame:open-file-under-cursor'

getPathUnderCursor = ->
  atom.workspace.getActiveEditor()?.getWordUnderCursor
    wordRegex: PATH_REGEX

openFileUnderCursor = ->
  fullPath = getPathUnderCursor()
  return unless fullPath
  [path, lineNumber] = breakPathApart(fullPath)
  promise = atom.workspaceView.open(path)
  promise.done(-> moveToLine(lineNumber))

breakPathApart = (fullPath) ->
  [path, lineNumber] = fullPath.split(':')
  [path, parseInt(lineNumber, 10)]

# Lifted from fuzzy finder view. Thanks.
moveToLine = (lineNumber) ->
  editorView = atom.workspaceView.getActiveView()
  return unless (editorView and !isNaN(lineNumber))
  position = new Point(lineNumber - 1)
  editorView.scrollToBufferPosition(position, center: true)
  editorView.editor.setCursorBufferPosition(position)
  editorView.editor.moveCursorToFirstCharacterOfLine()

module.exports =

  PATH_REGEX: PATH_REGEX

  activate: (state) ->
    atom.workspaceView.command OPEN_COMMAND, openFileUnderCursor
