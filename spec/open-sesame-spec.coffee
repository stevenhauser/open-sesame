{WorkspaceView} = require 'atom'
OpenSesame = require '../lib/open-sesame'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "OpenSesame", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('open-sesame')

  describe "when the open-sesame:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.open-sesame')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'open-sesame:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.open-sesame')).toExist()
        atom.workspaceView.trigger 'open-sesame:toggle'
        expect(atom.workspaceView.find('.open-sesame')).not.toExist()
