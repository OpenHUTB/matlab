function SaveModelRF(cbinfo,action)
    if SLStudio.toolstrip.internal.haveDirtyRefModels(cbinfo)||SLStudio.toolstrip.internal.haveDirtySSRefModels(cbinfo)
        action.text='simulink_ui:studio:resources:saveAllModelLabel';
        action.description='simulink_ui:studio:resources:saveAllModelDescription';
        action.icon='saveAll';
        action.enabled=true;
    else
        action.text='simulink_ui:studio:resources:saveModelLabel';
        action.icon='save';
        action.enabled=SLM3I.canSaveBlockDiagram(cbinfo.model.Handle);
    end
end

