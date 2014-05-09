{Workspace, WorkspaceView} = require 'atom'
OpenSesame = require '../lib/open-sesame'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe 'OpenSesame', ->

  stubActiveView = ->
    atom.workspaceView.openSync('sample-stub.js')

  triggerOpenFile = ->
    atom.workspaceView.getActiveView().trigger('open-sesame:open-file-under-cursor')

  beforeEach ->
    atom.workspace = new Workspace
    atom.workspaceView = new WorkspaceView
    spyOn(atom.workspaceView, 'open')
    waitsForPromise ->
      atom.packages.activatePackage('open-sesame')

  describe 'path regex', ->

    it 'matches valid paths', ->
      # There are probably a ton of possibilities missing here,
      # update this as needed when bugs come in
      validPaths = [
        'smashedfilename.md'
        'hyphenated-file-name.txt'
        'underscored_file_name.js'
        'file-name-with-many-extensions.js.coffee.holy.crap'
        'file-name-with-no-extensions'
        'path/file'
        'nested-path/path/file'
        '/absolute/nested-path/path/file'
      ]
      validPaths.forEach (path) ->
        expect(OpenSesame.PATH_REGEX.test(path)).toEqual(true)

    it 'does not match invalid paths', ->
      # There are probably a ton of possibilities missing here,
      # update this as needed when bugs come in
      invalidPaths = [
        'what\\is\\this\\windows'
        'i am full of spaces'
        '"i-am-wrapped-quotes.for.some.reason"'
      ]
      invalidPaths.forEach (path) ->
        expect(OpenSesame.PATH_REGEX.test(path)).toEqual(false)

  describe 'when there is an active editor', ->

    activeEditorStub = null

    beforeEach ->
      stubActiveView()
      activeEditorStub = jasmine.createSpyObj('activeEditorStub', ['getWordUnderCursor'])
      spyOn(atom.workspace, 'getActiveEditor').andReturn(activeEditorStub)

    it 'gets the current word under the cursor with a custom regex', ->
      triggerOpenFile()
      # @TODO: Get `jasmine.any(RegExp)` working with `toHaveBeenCalledWith` here
      expect(activeEditorStub.getWordUnderCursor).toHaveBeenCalled()

    describe 'when there is a valid path under the cursor', ->

      it 'opens the file at that path', ->
        activeEditorStub.getWordUnderCursor.andReturn('a-valid-path')
        triggerOpenFile()
        expect(atom.workspaceView.open).toHaveBeenCalledWith('a-valid-path')

    describe 'when there is an invalid path under the cursor', ->

      it 'does not open the file at that invalid path', ->
        activeEditorStub.getWordUnderCursor.andReturn('')
        triggerOpenFile()
        activeEditorStub.getWordUnderCursor.andReturn(null)
        triggerOpenFile()
        activeEditorStub.getWordUnderCursor.andReturn(false)
        triggerOpenFile()
        expect(atom.workspaceView.open).not.toHaveBeenCalled()

  describe 'when there is not an active editor', ->

    beforeEach ->
      stubActiveView()
      spyOn(atom.workspace, 'getActiveEditor').andReturn(null)

    it 'does not choke like an idiot', ->
      expect(triggerOpenFile).not.toThrow()

    it 'does not open the path', ->
      triggerOpenFile()
      expect(atom.workspaceView.open).not.toHaveBeenCalled()
