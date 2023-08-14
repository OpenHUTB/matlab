

function enablePanelEditModeForActiveEditor()
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
    studio=studios(1);
    editor=studio.App.getActiveEditor();
    SLM3I.SLDomain.setPanelEditModeForEditor(editor,true);
end