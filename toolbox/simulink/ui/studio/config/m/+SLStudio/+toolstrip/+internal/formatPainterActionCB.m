



function formatPainterActionCB(cbinfo)

    studioApp=cbinfo.studio.App;
    activeEditor=studioApp.getActiveEditor;

    selection=cbinfo.selection;
    assert(selection.size==1);
    element=selection.at(1);

    activeEditor.sendMessageToToolsWithDiagramElement('SLInitiateFormatPainting',element);

end
