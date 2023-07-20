function ToolStrip(fncname,cbinfo,action)

    fcn=str2func(fncname);
    fcn(cbinfo,action);
end

function ToolStripSimulationSpeed(cbinfo,action)%#ok<DEFNU>
    if~strcmpi(action.entries.toArray,SLStudio.Utils.getSimSpeedEntries(cbinfo))
        action.validateAndSetEntries(SLStudio.Utils.getSimSpeedEntries(cbinfo));
    end

    if isempty(action.description)
        action.description='Simulink:studio:SimulationSpeedToolTip';
    end

    if isempty(action.callback)
        action.setCallbackFromArray(@ToolStripSimulationSpeedCB,dig.model.FunctionType.Action);
    end

    action.enabled=~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    SLM3I.SLDomain.isSimulationStartPauseContinueEnabled(cbinfo.model.Handle);

    action.selectedItem=SLStudio.Utils.getCurrentSimSpeed(cbinfo);


    if action.entries.Size<2
        action.enabled=false;
    end
end

function ToolStripSimulationSpeedCB(cbinfo)

    newSelection=cbinfo.EventData;
    switch(newSelection)
    case 'Simulink:studio:SimModeAutoToolBar'
        newSelection='Simulink:SimModeAuto';
    case 'Simulink:studio:SimModeNormalToolBar'
        newSelection='Simulink:SimModeNormal';
    case 'Simulink:studio:SimModeAcceleratedToolBar'
        newSelection='Simulink:SimModeAccelerated';
    case 'Simulink:studio:SimModeRapidAcceleratorToolBar'
        newSelection='Simulink:SimModeRapidAccelerator';
    end

    SLStudio.Utils.setSimulationMode(cbinfo,newSelection);
end

function ToolStripSimulationStopTime(cbinfo,action)%#ok<DEFNU>
    action.enabled=true;
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        action.description='Simulink:studio:StopTimeToolTip';

        modelname=cbinfo.model.Name;
        if~isempty(modelname)
            action.text=get_param(modelname,'StopTime');
        else
            action.text='';
        end
    else
        action.description='simulink_ui:studio:resources:stopTimeActionDescription';
        action.optOutLocked=true;
        action.optOutBusy=true;

        modelname=cbinfo.model.Name;
        if~isempty(modelname)
            action.text=get_param(modelname,'StopTime');
        else
            action.text='';
        end
    end
    action.setCallbackFromArray(@ToolStripSimulationStopTimeCB,dig.model.FunctionType.Action);

    enabled=SLM3I.SLDomain.isSimulationStartPauseContinueEnabled(cbinfo.model.Handle);
    if enabled



        cs=getActiveConfigSet(cbinfo.model);
        if isa(cs,'Simulink.ConfigSetRef')||...
            strcmpi(cbinfo.model.SimulationStatus,'external')
            enabled=false;
        end
    end
    action.enabled=enabled;
end

function ToolStripSimulationStopTimeCB(cbinfo)
    newTime=cbinfo.EventData;
    modelName=SLStudio.Utils.getModelName(cbinfo);
    if~isempty(modelName)
        set_param(modelName,'StopTime',newTime);
    end
end


function GenericDisableForActiveHarness(cbinfo,action)%#ok<DEFNU>
    action.enabled=~Simulink.harness.internal.lockMenus(cbinfo.model.handle);
end
