function modelH=getModelSF(client)
    editor=client.getEditor;
    hid=editor.getHierarchyId;
    blockH=StateflowDI.SFDomain.getSLHandleForHID(hid);
    modelH=bdroot(blockH);
end
