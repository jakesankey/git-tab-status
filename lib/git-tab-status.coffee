{$} = require "atom"
fs = require "fs"

class GitTabStatus
    activate: ->
        @_setupWatchConditions()

    _setupWatchConditions: ->
        atom.project.getRepo()?.onDidChangeStatus @_updateTabs
        atom.project.getRepo()?.onDidChangeStatuses @_updateTabs
        atom.workspace.observeTextEditors (editor) =>
            editor.getBuffer().onDidSave @_updateTabs
            editor.onDidChangePath @_updateTabs

    _updateTabs: =>
        @_updateTabStylesForPath editor.getPath() for editor in @_getEditors()

    _getEditors: -> atom.workspace.getTextEditors()

    _getRepo: -> atom.project.getRepo()

    _updateTabStylesForPath: (path) =>
        if @_pathExists path
            repo = @_getRepo()
            isModified = repo?.isPathModified path
            isNew = repo?.isPathNew path
            isIgnored = repo?.isPathIgnored path
            tab = @_findTabForPath path
            if isModified
                tab?.addClass "status-modified"
            else if isNew
                tab?.addClass "status-added"
            else if isIgnored
                tab?.addClass "status-ignored"
            else
                tab?.removeClass "status-added status-modified status-ignored"

    _pathExists: (path) -> fs.existsSync path

    _findTabForPath: (path) ->
        path = path.replace /\\/g, '\\\\'
        $(".tab [data-path='#{path}']")

module.exports = new GitTabStatus()
