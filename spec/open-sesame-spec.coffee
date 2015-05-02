OpenSesame = require '../lib/open-sesame'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe 'OpenSesame', ->

  stubActiveEditor = (path = 'sample-stub.js') ->
    atom.workspace.openSync(path)
    atom.workspace.getActiveTextEditor()

  triggerOpenFile = ->
    atom.commands.dispatch(
      atom.views.getView(atom.workspace.getActiveTextEditor()),
      'open-sesame:open-file-under-cursor'
    )

  beforeEach ->
    spyOn(atom.workspace, 'open').andReturn
      done: (cb) -> cb()
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
        'path/with/file-number.js:88'
      ]
      validPaths.forEach (path) ->
        expect(OpenSesame.PATH_REGEX.test(path)).toEqual(true)

    # @TODO: These tests don't work well because the regex isn't a `/^...$/`
    # style regex. If it is, the the actual usage doesn't work. Not sure
    # which is the better route at this time.
    xit 'does not match invalid paths', ->
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
      activeEditorStub = stubActiveEditor()
      spyOn(activeEditorStub, 'getWordUnderCursor')
      spyOn(activeEditorStub, 'setCursorBufferPosition')
      spyOn(activeEditorStub, 'moveCursorToFirstCharacterOfLine')
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn(activeEditorStub)

    it 'gets the current word under the cursor with a custom regex', ->
      triggerOpenFile()
      # @TODO: Get `jasmine.any(RegExp)` working with `toHaveBeenCalledWith` here
      expect(activeEditorStub.getWordUnderCursor).toHaveBeenCalled()

    describe 'when there is a valid path under the cursor', ->

      beforeEach ->
        spyOn(activeEditorStub, 'scrollToBufferPosition')

      describe 'when the path is absolute', ->

        it 'opens the file at that path', ->
          activeEditorStub.getWordUnderCursor.andReturn('/an/absolute/valid-path')
          triggerOpenFile()
          expect(atom.workspace.open).toHaveBeenCalledWith('/an/absolute/valid-path')

      describe 'when the path is relative as a sibling', ->

        it 'opens the file at that path', ->
          spyOn(activeEditorStub, 'getPath').andReturn('some/path/file.js')
          activeEditorStub.getWordUnderCursor.andReturn('a/relative/valid-path')
          triggerOpenFile()
          expect(atom.workspace.open).toHaveBeenCalledWith('some/path/a/relative/valid-path')

      describe 'when the path is relative as an ancestor', ->

        it 'opens the file at that path', ->
          spyOn(activeEditorStub, 'getPath').andReturn('some/very/deep/path/file.js')
          activeEditorStub.getWordUnderCursor.andReturn('../../some-parent/valid-path')
          triggerOpenFile()
          expect(atom.workspace.open).toHaveBeenCalledWith('some/very/some-parent/valid-path')

      describe 'when there is a line number on the path', ->

        it 'tries to scroll to the line', ->
          activeEditorStub.getWordUnderCursor.andReturn('a-valid-path:54')
          triggerOpenFile()
          expect(activeEditorStub.scrollToBufferPosition).toHaveBeenCalled()

      describe 'when there is not a line number on the path', ->

        it 'does not try to scroll the the line', ->
          activeEditorStub.getWordUnderCursor.andReturn('a-valid-path')
          triggerOpenFile()
          expect(activeEditorStub.scrollToBufferPosition).not.toHaveBeenCalled()

    describe 'when there is an invalid path under the cursor', ->

      it 'does not open the file at that invalid path', ->
        activeEditorStub.getWordUnderCursor.andReturn('')
        triggerOpenFile()
        activeEditorStub.getWordUnderCursor.andReturn(null)
        triggerOpenFile()
        activeEditorStub.getWordUnderCursor.andReturn(false)
        triggerOpenFile()
        expect(atom.workspace.open).not.toHaveBeenCalled()

  describe 'when there is not an active editor', ->

    beforeEach ->
      stubActiveEditor()
      spyOn(atom.workspace, 'getActiveEditor').andReturn(null)

    it 'does not choke like an idiot', ->
      expect(triggerOpenFile).not.toThrow()

    it 'does not open the path', ->
      triggerOpenFile()
      expect(atom.workspace.open).not.toHaveBeenCalled()
