classesAdded = null
classesRemoved = null
gitTabStatus = require("../lib/git-tab-status")

gitTabStatus._findTabForPath = (path) ->
    return {
        addClass: (clazz) -> classesAdded.push(clazz),
        removeClass: -> classesRemoved = yes
    }

mockOutRepo = (isModified, isNew, isIgnored) ->
    gitTabStatus._getRepo = ->
        return {
            isPathModified: -> isModified,
            isPathNew: -> isNew,
            isPathIgnored: -> isIgnored
        }

describe "Git Tab Status Suite", ->
    TEST_PATH = "./path/file.foo"

    beforeEach ->
        gitTabStatus._pathExists = -> yes
        classesAdded = []
        classesRemoved = no

    it "should setup watch conditions for updating tabs upon package activation", ->
        called = no
        gitTabStatus._setupWatchConditions = ->
            called = yes

        gitTabStatus.activate()
        expect(called).toBe(yes)

    it "should update tabs for each editor that is currently open", ->
        gitTabStatus._getEditors = ->
            return [
                {getPath: -> TEST_PATH}
            ]
        originalFn = gitTabStatus._updateTabStylesForPath
        calledEditorPaths = []
        gitTabStatus._updateTabStylesForPath = (path) ->
            calledEditorPaths.push path
        gitTabStatus._updateTabs()
        expect(calledEditorPaths.length).toEqual(1)
        expect(calledEditorPaths).toContain(TEST_PATH)
        gitTabStatus._updateTabStylesForPath = originalFn

    it "should add status-modified class to tab", ->
        mockOutRepo yes
        gitTabStatus._updateTabStylesForPath TEST_PATH
        expect(classesRemoved).toBe(no)
        expect(classesAdded.length).toEqual(1)
        expect(classesAdded).toContain("status-modified")

    it "should add status-added class to tab", ->
        mockOutRepo no, yes
        gitTabStatus._updateTabStylesForPath TEST_PATH
        expect(classesRemoved).toBe(no)
        expect(classesAdded.length).toEqual(1)
        expect(classesAdded).toContain("status-added")

    it "should add status-ignored class to tab", ->
        mockOutRepo no, no, yes
        gitTabStatus._updateTabStylesForPath TEST_PATH
        expect(classesRemoved).toBe(no)
        expect(classesAdded.length).toEqual(1)
        expect(classesAdded).toContain("status-ignored")

    it "should remove status related classes from tab", ->
        mockOutRepo()
        gitTabStatus._updateTabStylesForPath TEST_PATH
        expect(classesRemoved).toBe(yes)
        expect(classesAdded.length).toEqual(0)

    it "should not do anything when path does not exist", ->
        mockOutRepo()
        gitTabStatus._pathExists = -> no
        gitTabStatus._updateTabStylesForPath TEST_PATH
        expect(classesRemoved).toBe(no)
        expect(classesAdded.length).toEqual(0)
