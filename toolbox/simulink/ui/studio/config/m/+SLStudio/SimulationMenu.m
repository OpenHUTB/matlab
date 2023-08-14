function schema=SimulationMenu(fncname,cbinfo)

    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function schema=AddConditionalPauseDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:AddConditionalPause');
    schema.tag='Simulink:AddConditionalPause';
    schema.state='Disabled';
end
function schema=DebuggerContinue(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:sfprivate:Continue');
    schema.tag='Simulink:DebuggerContinue';
    schema.state='Enabled';
    schema.callback=@DebuggerContinueCB;
    schema.accelerator='F5';
    schema.refreshCategories={'Simulink:DebuggerSimulationPause','interval#2'};
    schema.autoDisableWhen='Never';
end
function DebuggerContinueCB(cbinfo)

    if SFStudio.Utils.isStateflowApp(cbinfo)
        Stateflow.App.Cdr.Runtime.InstanceIndRuntime.dbcont;
    end
end
function schema=AddConditionalPause(cbinfo)
    schema=AddConditionalPauseDisabled(cbinfo);
    schema.state='Disabled';
    schema.callback=@AddConditionalPauseCB;
    schema.autoDisableWhen='Never';
    schema.userdata=[];
    signalLine=SLStudio.Utils.getSingleSelectedLine(cbinfo);
    if isempty(signalLine)
        val=slfeature('ConditionalPause');
        if val==4
            blockObj=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

            if isempty(blockObj)
                return;
            end
            if~SLStudio.Utils.objectIsValidBlock(blockObj)
                return;
            end
            schema.userdata=blockObj.handle;
            schema.callback=@AddBlockConditionalPauseCB;
        else
            return;
        end
    else
        srcPort=SLStudio.Utils.getLineSourcePort(signalLine);
        if(isempty(srcPort)||...
            ~SLStudio.Utils.objectIsValidPort(srcPort))
            return;
        end
        schema.userdata=srcPort.handle;
    end

    schema.state='Enabled';

    if~isempty(cbinfo.model)
        modelH=cbinfo.model.handle;
        if~loc_isSimulationSteppingEnabled(cbinfo)
            if cbinfo.isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        end
        simState=cbinfo.model.SimulationStatus;
        if~cbinfo.domain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        elseif(strcmpi(simState,'running'))
            schema.state='Disabled';
        end
    else
        schema.state='Disabled';
    end
end

function AddConditionalPauseCB(cbinfo)

    portHandle=cbinfo.userdata;
    SLStudio.ShowAddConditionalPauseDialog(cbinfo.model.handle,portHandle);
end
function AddBlockConditionalPauseCB(cbinfo)

    blockHandle=cbinfo.userdata;
    SLStudio.ShowBlockConditionalPauseDialog(cbinfo.model.handle,blockHandle);
end
function schema=ConditionalPauseList(cbinfo)
    val=slfeature('ConditionalPause');


    if(val==2||val==4)
        schema=sl_toggle_schema;
        bplist=cbinfo.studio.getComponent('GLUE2:SpreadSheet',...
        SLStudio.StepperBreakpointList.mName);
        if~isempty(bplist)&&bplist.isVisible
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end
    else
        schema=sl_action_schema;
    end

    schema.tag='Simulink:ConditionalPauseList';
    schema.label=DAStudio.message('Simulink:studio:ConditionalPauseList');
    schema.state='Enabled';
    schema.callback=@ConditionalPauseListCB;
    schema.autoDisableWhen='Never';

    if~isempty(cbinfo.model)
        modelH=cbinfo.model.handle;
        if~loc_isSimulationSteppingEnabled(cbinfo)
            if cbinfo.isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        end
        simState=cbinfo.model.SimulationStatus;
        if~cbinfo.domain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        elseif(strcmpi(simState,'running'))
            schema.state='Disabled';
        end
    else
        schema.state='Disabled';
    end
end

function ConditionalPauseListCB(cbinfo)
    if strcmp(get_param(cbinfo.model.handle,'BlockDiagramType'),'model')
        SLStudio.ShowBlockDiagramConditionalPauseList(cbinfo.model.handle,0);
    end
end

function res=loc_isSimulationSteppingEnabled(cbinfo)
    modelH=cbinfo.model.handle;
    sim_mode=get_param(modelH,'SimulationMode');
    switch sim_mode
    case{'auto','normal','accelerator'}
        res=cbinfo.domain.isSimulationStartPauseContinueEnabled(modelH);
    otherwise
        res=false;
    end
end

function schema=SimulationInput(~)
    schema=sl_action_schema;

    schema.label=DAStudio.message('Simulink:studio:Input');
    schema.tag='Simulink:SimulationInput';
    schema.icon='Simulink:SimulationInput';

    schema.state='Hidden';
    schema.callback=@OpenSTACB;
    schema.autoDisableWhen='Busy';
end

function OpenSTACB(~)

    Simulink.sta.StaDialog('Model',bdroot);
end



function schema=LogSelectedSignals(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:LogSelectedSignals';
    schema.label=DAStudio.message('SDI:sdi:SLMenuLogSelectedSignals');
    schema.icon='Simulink:LogSelectedSignals';

    schema.state='Enabled';

    srcPortHandle=locGetValidSrcPortHandles(cbinfo);
    if isequal(length(srcPortHandle),0)
        schema.state='Disabled';
    end

    schema.callback=@LogSelectedSignalsCB;

end

function LogSelectedSignalsCB(cbinfo)



    srcPortHandle=locGetValidSrcPortHandles(cbinfo);
    a=zeros(length(srcPortHandle),1);
    for idx=1:length(srcPortHandle)
        a(idx)=isequal('off',get_param(srcPortHandle(idx),'DataLogging'));
    end

    if any(a)
        set(srcPortHandle,'DataLogging','on');
    else
        set(srcPortHandle,'DataLogging','off');
    end

end



function valSrcPortsHdls=locGetValidSrcPortHandles(cbinfo)

    cbObj=cbinfo.uiObject;
    if isa(cbObj,'Simulink.BlockDiagram')||...
        isa(cbObj,'Simulink.SubSystem')
        line=find_system(cbObj.handle,'LookUnderMasks','all',...
        'SearchDepth',1,'FindAll','on',...
        'Type','line','Selected','on');
    else
        valSrcPortsHdls=[];
        return;
    end

    valSrcPortsHdls=zeros(length(line));

    for idx=1:length(line)
        onePort=get_param(line(idx),'SrcPortHandle');
        if isequal(-1,onePort)||...
            isequal(get_param(onePort,'PortType'),'connection')
            continue;
        else
            valSrcPortsHdls(idx)=onePort;
        end
    end

    valSrcPortsHdls=valSrcPortsHdls(valSrcPortsHdls~=0);

end

function schema=SimulationRecordMenu(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.simOutputMenu(cbinfo);
end


function schema=SimulationRecord(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.simulationRecord(cbinfo);
end

function schema=SimulationVisualize(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.simulationVisualize(cbinfo);
end

function schema=InspectSelectedSignals(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.visualizeSelectedSignals(cbinfo);
end

function schema=StreamStateflowChartActivity(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.streamStateflowStateActivity(cbinfo,'chart');
end

function schema=StreamStateflowStateActivity(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.streamStateflowStateActivity(cbinfo,'state');
end


function schema=StreamStateflowChartActivityForBlock(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.streamStateflowStateActivity(cbinfo,'chartblock');
end

function schema=ConfigureSignalLogging(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.configureLogging(cbinfo);
end

function schema=AboutSignalLogging(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.aboutSDI(cbinfo);
end

function schema=OpenSDI(cbinfo)
    schema=Simulink.sdi.internal.SLMenus.openSDI(cbinfo);
end

function OpenSDI_CB(cbinfo)
    Simulink.sdi.internal.SLMenus.openSDI(cbinfo,'openSDI_CB');
end

function schema=SelectSignalsToLogDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SelectSignalsToLog');
    schema.tag='Simulink:SelectSignalsToLog';
    schema.icon='Simulink:SelectSignalsToLog';
    schema.state='Disabled';
end

function schema=SelectSignalsToLog(cbinfo)
    schema=SelectSignalsToLogDisabled(cbinfo);
    schema.state='Enabled';
    schema.callback=@SelectSignalsToLogCB;
    schema.icon='Simulink:SelectSignalsToLog';
end

function SelectSignalsToLogCB(cbinfo)
    modelName=cbinfo.model.Name;
    SigLogSelector.launch('Create',modelName);
end

function state=loc_getLogReferencedSignalsState(cbinfo)
    if cbinfo.isContextMenu
        state='Hidden';
    else
        state='Disabled';
    end

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(block)&&...
        cbinfo.domain.isBdInEditMode(cbinfo.model.handle)
        state='Enabled';
    end
end

function schema=LogReferencedSignalsDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:LogReferencedSignals';
    schema.label=DAStudio.message('Simulink:studio:LogReferencedSignals');
    schema.state='Disabled';
end

function schema=LogReferencedSignals(cbinfo)
    schema=LogReferencedSignalsDisabled(cbinfo);
    schema.state=loc_getLogReferencedSignalsState(cbinfo);
    schema.callback=@LogReferencedSignalsCB;
end

function LogReferencedSignalsCB(cbinfo)
    modelName=cbinfo.model.Name;
    SigLogSelector.launch('Create',modelName);
end

function schema=SimulationModeMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:SimulationModeMenu';
    schema.label=DAStudio.message('Simulink:studio:SimulationModeMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:SimModeNormal'),...
    im.getAction('Simulink:SimModeAccelerated'),...
    im.getAction('Simulink:SimModeRapidAccelerator'),...
    im.getAction('Simulink:SimModeSIL'),...
    im.getAction('Simulink:SimModePIL'),...
    im.getAction('Simulink:SimModeExternal'),...
    };
    assert(...
    slfeature('EnhancedNormalMode')==0||...
    slfeature('EnhancedNormalMode')==1...
    );
    assert(...
    slsvTestingHook('EnhancedNormalFSpec')==0||...
    slsvTestingHook('EnhancedNormalFSpec')==1...
    );
    if slfeature('EnhancedNormalMode')==1&&...
        slsvTestingHook('EnhancedNormalFSpec')==1
        autoChildFcn={im.getAction('Simulink:SimModeAuto')};
        schema.childrenFcns=[autoChildFcn,schema.childrenFcns];
    end


    availableModes=SLStudio.Utils.getSimModeEntries(cbinfo);
    if length(availableModes)<2
        schema.state='Hidden';
    end

    schema.autoDisableWhen='Busy';
end

function schema=SimModeAuto(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeAuto';
    schema.label=DAStudio.message('Simulink:studio:SimModeAuto');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'auto');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeAuto','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeAuto','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SimModeNormal(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeNormal';
    schema.label=DAStudio.message('Simulink:studio:SimModeNormal');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'normal');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeNormal','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeNormal','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SimModeAccelerated(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeAccelerated';
    schema.label=DAStudio.message('Simulink:studio:SimModeAccelerated');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'accelerator');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeAccelerated','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeAccelerated','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';

end

function schema=SimModeRapidAccelerator(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeRapidAccelerator';
    schema.label=DAStudio.message('Simulink:studio:SimModeRapidAccelerator');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'rapid-accelerator');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeRapidAccelerator','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeRapidAccelerator','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';

end

function schema=SimModeSIL(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeSIL';
    schema.label=DAStudio.message('Simulink:studio:SimModeSIL');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'software-in-the-loop (sil)');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeSIL','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeSIL','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SimModePIL(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModePIL';
    schema.label=DAStudio.message('Simulink:studio:SimModePIL');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'processor-in-the-loop (pil)');
    if~cbinfo.queryMenuAttribute('Simulink:SimModePIL','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModePIL','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SimModeExternal(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimModeExternal';
    schema.label=DAStudio.message('Simulink:studio:SimModeExternal');
    schema.userdata=schema.tag;
    schema.callback=@SimulationModeCB;
    schema.checked=SLStudio.Utils.isCurrentSimMode(cbinfo,'external');
    if~cbinfo.queryMenuAttribute('Simulink:SimModeExternal','visible',cbinfo.model.Handle)
        schema.state='Hidden';
    elseif~cbinfo.queryMenuAttribute('Simulink:SimModeExternal','enabled',cbinfo.model.Handle)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function SimulationModeCB(cbinfo)
    newSelection=cbinfo.userdata;
    SLStudio.Utils.setSimulationMode(cbinfo,newSelection);
end

function schema=DebugMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DebugMenu';
    schema.label=DAStudio.message('Simulink:studio:DebugMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Debugger'),...
    im.getAction('Stateflow:DebugMenuItem'),...
    im.getAction('Simulink:ShowSimulationTarget'),...
    'separator',...
    im.getAction('Stateflow:ForceDebugging'),...
    im.getSubmenu('Stateflow:SetBreakpointsMenu'),...
    im.getSubmenu('Stateflow:ClearBreakpointsMenu'),...
    'separator',...
    im.getSubmenu('Stateflow:ErrorCheckingOptionsMenu')
    };

    schema.childrenFcns=...
    [{im.getAction('Simulink:AddConditionalPause')...
    ,im.getAction('Simulink:ConditionalPauseList')...
    ,'separator'},...
    schema.childrenFcns];

    schema.autoDisableWhen='Never';
end

function schema=ShowSimulationTarget(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ShowSimulationTarget';
    schema.label=DAStudio.message('Simulink:studio:ShowSimulationTarget');
    schema.icon='Simulink:ShowSimulationTarget';
    if isa(cbinfo.domain,'SLM3I.SLDomain')||isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain')
        schema.callback=@ShowSimulationTargetCB;
    else
        schema.callback=@ShowSimulationTargetSFCB;
    end

    schema.autoDisableWhen='Never';
end

function ShowSimulationTargetCB(cbinfo)
    cs=getActiveConfigSet(cbinfo.model);
    page='Simulation Target';
    configset.showParameterGroup(cs,{page});
end

function ShowSimulationTargetSFCB(cbinfo)
    machine=SFStudio.Utils.getMachineId(cbinfo);
    sfprivate('goto_target',machine,'sfun');
end

function CodeImporterCB(cbinfo)
    internal.CodeImporter.launchFromModel(cbinfo.model.Handle);
end






