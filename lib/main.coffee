{$} = require "atom"
fs = require "fs"

class GitTabStatus
    activate: (state) ->
        # atom.project.getRepo()?.on "status-changed", @updateTabs
        # atom.workspaceView.eachEditorView @updateTabs
        # process.nextTick @updateTabs
        setInterval @updateTabs, 1000

    updateTabs: ->
        editors = atom.workspace.getEditors()
        for editor in editors
            updateTabStylesForPath editor.getPath()

    updateTabStylesForPath = (path) ->
        if fs.existsSync path
            repo = atom.project.getRepo()
            isModified = repo?.isPathModified path
            isNew = repo?.isPathNew path
            isIgnored = repo?.isPathIgnored path
            tab = $(".tab [data-path='#{path}']")
            if isModified
                tab?.addClass "status-modified"
            else if isNew
                tab?.addClass "status-added"
            else if isIgnored
                tab?.addClass "status-ignored"
            else
                tab?.removeClass "status-added status-modified status-ignored"


module.exports = new GitTabStatus()
