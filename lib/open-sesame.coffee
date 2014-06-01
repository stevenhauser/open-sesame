{Point} = require('atom')

PATH_REGEX = /[\/A-Z\.\d-_]+(:\d+)?/i
OPEN_COMMAND = 'open-sesame:open-file-under-cursor'

getPathUnderCursor = ->
  atom.workspace.getActiveEditor()?.getWordUnderCursor
    wordRegex: PATH_REGEX

isAbsolutePath = (path) ->
  path[0] is '/'

getCurrentProjPath = ->
  # not a fan of the trailing `.` syntax, but CS complains
  # about leading `.` :( :( :(
  curPath = (atom.workspaceView.
    getActiveView()?.
    editor?.
    getPath() or '').
    # Remove the project base path
    replace(atom.project?.getPath() or '', '').
    # Remove any leading slash
    replace(/^\//, '').
    split('/')
  curPath.pop() # remove file
  curPath.join('/')

# Takes a `path` and returns a cleaned up version of it
# by removing any parent references (../) with the actual
# directory names, based on the current project path
constructPath = (path) ->
  return path if isAbsolutePath(path)
  parts = path.split('/')
  numParents = parts.filter((part) -> part is '..').length
  # Remove parent parts from `path`
  path = parts.slice(numParents).join('/')
  curProjPathParts = getCurrentProjPath().split('/')
  # Remove nested directories considered parents
  curProjPathParts.pop() while --numParents > -1
  curProjPathParts.push(path)
  curProjPathParts.join('/')

openFileUnderCursor = ->
  fullPath = getPathUnderCursor()
  return unless fullPath
  [path, lineNumber] = breakPathApart(fullPath)
  promise = atom.workspaceView.open(constructPath(path))
  promise.done(-> moveToLine(lineNumber))

# Breaks a `fullPath` apart and returns the main `path`
# part and a possible `lineNumber`
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
