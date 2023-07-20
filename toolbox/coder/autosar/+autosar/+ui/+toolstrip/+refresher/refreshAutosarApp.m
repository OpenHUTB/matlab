function refreshAutosarApp(cbinfo,action)




    studio=cbinfo.studio;
    editor=studio.App.getActiveEditor;
    current=editor.blockDiagramHandle;
    top=studio.App.blockDiagramHandle;
    currentName=get_param(current,'Name');
    topName=get_param(top,'Name');
    mdlMatch=strcmp(currentName,topName);

    if mdlMatch&&Simulink.CodeMapping.isMappedToAutosarComposition(topName)
        action.enabled=false;
    else
        action.enabled=true;
    end

end
