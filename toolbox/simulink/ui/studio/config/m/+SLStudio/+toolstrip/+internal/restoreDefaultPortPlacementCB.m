

function restoreDefaultPortPlacementCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    editor.sendMessageToTools('SLRestoreDefaultPortPlacement');
end