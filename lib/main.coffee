{$} = require "atom"

module.exports =
    activate: (state) ->
        atom.project.getRepo()?.on "status-changed", @updateTabStatus
        atom.project.getRepo()?.on "statuses-changed", @updateTabStatus
        # atom.workspaceView.eachEditorView @registerForPathChange
        atom.workspaceView.eachEditorView @updateTabStatus
        process.nextTick @updateTabStatus

    registerForPathChange: (editor) ->
        editor.on("path-changed", @updateTabStatus)

    updateTabStatus: (changedPath, status) ->
        repo = atom.project.getRepo()
        editors = atom.workspace.getEditors()
        for editor in editors
            path = editor.getPath()
            path = changedPath if typeof changedPath is "string"
            isModified = repo?.isPathModified path
            isNew = repo?.isPathNew path
            # console.log(isModified + " " + isNew + " " + editor.getTitle())
            isIgnored = repo?.isPathIgnored path
            tab = $(".tab [data-path='#{path}']")
            if isModified
                tab?.addClass("status-modified")
            else if isNew
                tab?.addClass("file entry list-item status-added")
            else if isIgnored
                tab?.addClass("status-ignored")
            else
                tab?.removeClass("status-added status-modified status-ignored")
