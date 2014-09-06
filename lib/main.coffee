{$} = require "atom"

module.exports =
    activate: (state) ->
        # atom.project.getRepo().on "status-changed", @updateTabStatus
        # atom.workspace.onDidAddTextEditor @updateTabStatus
        setInterval @updateTabStatus, 1000

    updateTabStatus: ->
        repo = atom.project.getRepo()
        if repo
            editors = atom.workspace.getEditors()
            for editor in editors
                path = editor.getPath()
                isModified = repo.isPathModified path
                isNew = repo.isPathNew path
                isIgnored = repo.isPathIgnored path
                tab = $(".tab [data-path='#{path}']")

                if isModified
                    tab.addClass("status-modified")
                else if isNew
                    tab.addClass("status-added")
                else if isIgnored
                    tab.addClass("status-ignored")
                else
                    tab.removeClass("status-added status-modified status-ignored")
