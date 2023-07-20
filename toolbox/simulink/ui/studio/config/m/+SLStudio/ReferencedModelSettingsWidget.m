function ReferencedModelSettingsWidget(fncname,cbinfo,action)



    fcn=str2func(fncname);
    fcn(cbinfo,action);
end




function OpenReferencedModelConfigSet(cbinfo,action)%#ok<DEFNU>
    if isempty(action.callback)
        action.setCallbackFromArray(...
        @OpenReferencedModelConfigSetCB,...
        dig.model.FunctionType.Action);
    end

    action.enabled=...
    ~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    ~lcl_topModelIsOpenInEditor(cbinfo);
end



function OpenReferencedModelConfigSetCB(cbinfo)
    assert(~lcl_topModelIsOpenInEditor(cbinfo));

    refModelName=cbinfo.editorModel.Name;

    configSet=getActiveConfigSet(refModelName);

    openDialog(configSet);
end





function OpenReferencedModelProperties(cbinfo,action)%#ok<DEFNU>
    if isempty(action.callback)
        action.setCallbackFromArray(...
        @OpenReferencedModelPropertiesCB,...
        dig.model.FunctionType.Action);
    end

    action.enabled=...
    ~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    ~lcl_topModelIsOpenInEditor(cbinfo);
end



function OpenReferencedModelPropertiesCB(cbinfo)
    assert(~lcl_topModelIsOpenInEditor(cbinfo));

    refModelName=cbinfo.editorModel.Name;

    SLStudio.internal.openModelProperties(refModelName);
end





function topModelIsOpen=lcl_topModelIsOpenInEditor(cbinfo)
    topModelIsOpen=strcmp(cbinfo.model.Name,cbinfo.editorModel.Name);
end
