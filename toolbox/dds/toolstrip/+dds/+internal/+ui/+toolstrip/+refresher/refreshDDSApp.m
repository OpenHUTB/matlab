function refreshDDSApp(cbinfo,action)




    studio=cbinfo.studio;
    editor=studio.App.getActiveEditor;
    current=editor.blockDiagramHandle;
    top=studio.App.blockDiagramHandle;
    currentName=get_param(current,'Name');
    topName=get_param(top,'Name');
    mdlMatch=strcmp(currentName,topName);











    action.selected=dds.internal.simulink.Util.checkIfModelMappingIsSetToDDS(topName);
    action.enabled=mdlMatch;

end

