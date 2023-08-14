function ModelBlockTab(fncname,cbinfo,action)




    fcn=str2func(fncname);

    private_getScalarModelBlockHandleRefreshAndPassToFcn(cbinfo,...
    @(modelBlockHandle)fcn(cbinfo,action,modelBlockHandle));
end







function ModelBlockSimulationMode(cbinfo,action,modelBlockHandle)%#ok<DEFNU>
    simModeEntries=SLStudio.Utils.getModelBlockSimModeEntries(modelBlockHandle);

    if~strcmpi(action.entries.toArray,simModeEntries)
        action.validateAndSetEntries(simModeEntries);
    end

    if isempty(action.callback)
        action.setCallbackFromArray(...
        @ModelBlockSimulationModeCB,...
        dig.model.FunctionType.Action);
    end

    private_ModelBlockSimulationModeAction_SetEnable(cbinfo,action,modelBlockHandle);

    action.selectedItem=...
    SLStudio.Utils.getCurrentModelBlockSimModeSelection(modelBlockHandle);
end

function ModelBlockSimulationModeCB(cbinfo)
    newSelection=cbinfo.EventData;

    private_getScalarModelBlockHandleRefreshAndPassToFcn(cbinfo,...
    @(modelBlockHandle)...
    SLStudio.Utils.setModelBlockSimModeFromSelection(modelBlockHandle,newSelection));
end

function private_ModelBlockSimulationModeAction_SetEnable(cbinfo,action,modelBlockHandle)
    action.enabled=...
    ~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    SLStudio.Utils.getModelBlockSimulationModeShouldBeEnabled(modelBlockHandle);
end




function ModelBlockSimulationModeLabel(cbinfo,action,modelBlockHandle)%#ok<DEFNU>
    private_ModelBlockSimulationModeAction_SetEnable(cbinfo,action,modelBlockHandle);
end




function ModelBlockCodeInterface(cbinfo,action,modelBlockHandle)%#ok<DEFNU>
    codeInterfaceEntries=...
    SLStudio.Utils.getModelBlockCodeInterfaceEntries();

    if~strcmpi(action.entries.toArray,codeInterfaceEntries)
        action.validateAndSetEntries(codeInterfaceEntries);
    end

    if isempty(action.callback)
        action.setCallbackFromArray(...
        @ModelBlockCodeInterfaceCB,...
        dig.model.FunctionType.Action);
    end

    action.selectedItem=...
    SLStudio.Utils.getCurrentModelBlockCodeInterfaceSelection(modelBlockHandle);

    private_ModelBlockCodeInterfaceAction_SetEnable(cbinfo,action,modelBlockHandle);
end

function ModelBlockCodeInterfaceCB(cbinfo)
    newSelection=cbinfo.EventData;

    private_getScalarModelBlockHandleRefreshAndPassToFcn(cbinfo,...
    @(modelBlockHandle)...
    SLStudio.Utils.setModelBlockCodeInterfaceFromSelection(modelBlockHandle,newSelection));
end

function private_ModelBlockCodeInterfaceAction_SetEnable(cbinfo,action,modelBlockHandle)
    action.enabled=...
    ~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    SLStudio.Utils.getModelBlockCodeInterfaceShouldBeEnabled(modelBlockHandle);
end




function ModelBlockCodeInterfaceLabel(cbinfo,action,modelBlockHandle)%#ok<DEFNU>
    private_ModelBlockCodeInterfaceAction_SetEnable(cbinfo,action,modelBlockHandle);
end




function ModelBlockOpenAsTopModel(~,action,modelBlockHandle)%#ok<DEFNU>
    if isempty(action.callback)
        action.setCallbackFromArray(...
        @ModelBlockOpenAsTopModelCB,...
        dig.model.FunctionType.Action);
    end

    action.enabled=...
    ~isempty(private_callGetModelNameToOpen(modelBlockHandle));
end

function ModelBlockOpenAsTopModelCB(cbinfo)
    private_getScalarModelBlockHandleRefreshAndPassToFcn(cbinfo,...
    @(modelBlockHandle)private_doOpenAsTopModel(modelBlockHandle));
end

function private_doOpenAsTopModel(modelBlockHandle)
    modelNameToOpen=private_callGetModelNameToOpen(modelBlockHandle);

    if~isempty(modelNameToOpen)
        open_system(modelNameToOpen);
    end
end

function[modelNameToOpen]=private_callGetModelNameToOpen(modelBlockHandle)
    modelNameToOpen=slInternal('getModelNameToOpen',modelBlockHandle);
end






function private_getScalarModelBlockHandleRefreshAndPassToFcn(cbinfo,fcn)
    blockHandle=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    if SLStudio.Utils.isValidBlockHandle(blockHandle)&&...
        strcmp('ModelReference',get_param(blockHandle,'BlockType'))

        fcn(blockHandle);
    end
end
