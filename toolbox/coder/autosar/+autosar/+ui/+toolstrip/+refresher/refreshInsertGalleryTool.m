function refreshInsertGalleryTool(cbinfo,action)





    if isvalid(action)
        modelH=SLStudio.Utils.getDiagramHandle(cbinfo);
        isAdaptiveComposition=Simulink.CodeMapping.isAutosarAdaptiveSTF(bdroot(modelH));
        if isAdaptiveComposition&&...
            (~strcmp(action.name,'autosarInsertCompositionAction')&&...
            ~strcmp(action.name,'autosarInsertComponentAction'))


            action.enabled=false;
        end
    end
