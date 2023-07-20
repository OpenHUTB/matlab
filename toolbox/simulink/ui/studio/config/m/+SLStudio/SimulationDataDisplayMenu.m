function schema=SimulationDataDisplayMenu(fncname,cbinfo,eventData)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=SimulationDataDisplayMenuDisabledImpl(cbinfo)
    schema=sl_container_schema;
    menu=cbinfo.userdata;

    schema.label=DAStudio.message(['Simulink:studio:',menu,'DataDisplayMenu']);
    schema.tag=['Simulink:',menu,'SimulationDataDisplayMenu'];

    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    schema.autoDisableWhen='Never';
end

function state=loc_getSimulationDataDisplayMenuState(~)
    state='Enabled';
end

function schema=SimulationDataDisplayMenuImpl(cbinfo)%#ok<*DEFNU> % ( menu, cbinfo )
    schema=SimulationDataDisplayMenuDisabledImpl(cbinfo);

    schema.state=loc_getSimulationDataDisplayMenuState(cbinfo);


    menu=cbinfo.userdata;
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if slfeature('SignalsSparklines')<6
        schema.childrenFcns={im.getAction(['Simulink:',menu,'RemoveAllValueLabels']),...
        im.getAction(['Simulink:',menu,'ShowValueLabelForSelectedPort']),...
        im.getAction(['Simulink:',menu,'ShowValueLabelsWhenHovering']),...
        im.getAction(['Simulink:',menu,'ToggleValueLabelsWhenClicked']),...
        im.getAction(['Simulink:',menu,'ValueLabelDisplayOptions'])};
    end

    if slfeature('SignalsSparklines')>0
        if slfeature('SignalsSparklines')<6
            schema.childrenFcns=[schema.childrenFcns,'separator'];
        end
        schema.childrenFcns=[schema.childrenFcns,{
        im.getAction(['Simulink:',menu,'RemoveAllSparklines']),...
        im.getAction(['Simulink:',menu,'ToggleSparklinesWhenClicked']),...
        im.getAction(['Simulink:',menu,'SparklinesOptions'])
        }];
    end
end


function schema=RemoveAllValueLabelsDisabled(cbinfo)
    schema=sl_action_schema;
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        menu=cbinfo.userdata;
        schema.tag=['Simulink:',menu,'RemoveAllValueLabels'];
        schema.label=DAStudio.message('Simulink:studio:RemoveAllValueLabels');
    end
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=RemoveAllValueLabels(cbinfo)
    schema=RemoveAllValueLabelsDisabled(cbinfo);
    schema.state='Enabled';
    schema.callback=@RemoveAllValueLabelsCB;
end

function RemoveAllValueLabelsCB(cbinfo,~)
    SLM3I.SLDomain.removeAllValueLabels(cbinfo.editorModel.handle);
end

function schema=ShowValueLabelsWhenHoveringDisabled(cbinfo)
    schema=sl_toggle_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'ShowValueLabelsWhenHovering'];
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ShowValueLabelsWhenHovering');
    else
        schema.icon='valueLabel';
    end
    schema.obsoleteTags={'Simulink:ShowHovering'};
    schema.checked='Checked';
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=ShowValueLabelsWhenHovering(cbinfo)
    schema=ShowValueLabelsWhenHoveringDisabled(cbinfo);
    schema.state='Enabled';
    currentMode=SLM3I.SLDomain.getValueLabelDisplayMode(cbinfo.editorModel.handle);
    if(currentMode==1)
        newMode=0;
        schema.checked='Checked';
    else
        newMode=1;
        schema.checked='Unchecked';
    end
    schema.userdata=newMode;
    schema.callback=@ValueLabelDisplayModeCB;
end

function schema=ToggleValueLabelsWhenClickedDisabled(cbinfo)
    schema=sl_toggle_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'ToggleValueLabelsWhenClicked'];
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ToggleValueLabelsWhenClicked');
    else
        schema.icon='valueLabelToggle';
    end
    schema.obsoleteTags={'Simulink:ShowSelect'};
    schema.checked='Checked';
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=ToggleValueLabelsWhenClicked(cbinfo)
    schema=ToggleValueLabelsWhenClickedDisabled(cbinfo);
    schema.state='Enabled';
    currentMode=SLM3I.SLDomain.getValueLabelDisplayMode(cbinfo.editorModel.handle);
    if(currentMode==2)
        newMode=0;
        schema.checked='Checked';
    else
        newMode=2;
        schema.checked='Unchecked';
    end
    schema.userdata=newMode;
    schema.callback=@ValueLabelDisplayModeCB;
end

function ValueLabelDisplayModeCB(cbinfo,~)
    newMode=cbinfo.userdata;
    SLM3I.SLDomain.setValueLabelDisplayMode(cbinfo.editorModel.handle,newMode);
end

function schema=ValueLabelDisplayOptionsDisabled(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'ValueLabelDisplayOptions'];
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ValueLabelDisplayOptions');
    else
        schema.icon='valueLabelConfig';
    end
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=ValueLabelDisplayOptions(cbinfo)
    schema=ValueLabelDisplayOptionsDisabled(cbinfo);
    schema.state='Enabled';
    schema.callback=@ValueLabelDisplayOptionsCB;
end

function ValueLabelDisplayOptionsCB(cbinfo)
    SLM3I.SLDomain.showValueLabelDisplayOptionsDialog(cbinfo.editorModel.handle);
end

function schema=ShowValueLabelForSelectedPortDisabled(cbinfo)
    schema=sl_toggle_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'ShowValueLabelForSelectedPort'];

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        if slfeature('SignalsSparklines')>=6
            schema.label=DAStudio.message('Simulink:studio:SparklinesDisplayForSelectedPort');
        else
            schema.label=DAStudio.message('Simulink:studio:ShowValueLabelForSelectedPort');
        end
    else
        schema.tag='valueLabelSelectedSignal';
    end
    schema.state='disabled';
    schema.autoDisableWhen='Never';
end

function schema=ShowValueLabelForSelectedPort(cbinfo)
    schema=ShowValueLabelForSelectedPortDisabled(cbinfo);
    schema.callback=@ShowValueLabelForSelectedPortCB;

    schema.userdata=[];


    try
        srcPortHandles=SLStudio.Utils.getSrcPortsOfSelectedSegments(cbinfo);
    catch
        srcPortHandles={};
    end
    if isempty(srcPortHandles),return;end

    checkedState='Checked';
    for i=1:length(srcPortHandles)


        if isequal(get_param(srcPortHandles(i),'ShowValueLabel'),'off')
            checkedState='Unchecked';
        end
    end

    schema.userdata.portHandles=srcPortHandles;
    schema.userdata.enable='on';
    if strcmp(checkedState,'Checked')
        schema.userdata.enable='off';
    end

    if Simulink.internal.isArchitectureModel(cbinfo.studio.App.getActiveEditor.blockDiagramHandle)

        schema.state='hidden';
    else
        schema.state='enabled';
    end
    schema.checked=checkedState;
end

function ShowValueLabelForSelectedPortCB(cbinfo,~)
    modelHandle=cbinfo.editorModel.Handle;
    showValueLabel=cbinfo.userdata.enable;
    for i=1:length(cbinfo.userdata.portHandles)
        portHndl=cbinfo.userdata.portHandles(i);




        if length(cbinfo.userdata.portHandles)>1||strcmp(showValueLabel,'off')
            set_param(portHndl,'ShowValueLabel',showValueLabel);
        else





            sh=get_param(portHndl,'SignalHierarchyNoWarn');

            if(isstruct(sh)&&~isempty(sh.Children))
                Simulink.internal.SigHierDialogMgr.openDialog(portHndl,modelHandle,0,0,cbinfo.studio);
            else
                set_param(portHndl,'ShowValueLabel',showValueLabel);
            end
        end
    end
end

function schema=RemoveAllSparklines(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'RemoveAllSparklines'];
    schema.label=DAStudio.message('Simulink:studio:SparklinesRemoveAllSparklines');
    if slfeature('SignalsSparklines')>0
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
    schema.callback=@RemoveAllSparklinesCB;
end

function RemoveAllSparklinesCB(cbinfo)
    SLM3I.SLCommonDomain.removeAllValuePlotsMultiDomain(cbinfo.editorModel.handle,2);
end

function schema=ToggleSparklinesWhenClicked(cbinfo)
    schema=sl_toggle_schema;
    menu=cbinfo.userdata;
    currentMode=SLM3I.SLCommonDomain.getValuePlotDisplayModeMultiDomain(cbinfo.editorModel.handle,2);
    if currentMode==1
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.tag=['Simulink:',menu,'ToggleSparklinesWhenClicked'];
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SparklinesToggleWhenClicked');
    if slfeature('SignalsSparklines')>0
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
    schema.callback=@ToggleSparklinesWhenClickedCB;
end

function ToggleSparklinesWhenClickedCB(cbinfo)
    currentMode=SLM3I.SLCommonDomain.getValuePlotDisplayModeMultiDomain(cbinfo.editorModel.handle,2);
    newMode=currentMode~=1;
    SLM3I.SLCommonDomain.setValuePlotDisplayModeMultiDomain(cbinfo.editorModel.handle,newMode,2);
end

function schema=SparklinesOptions(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'SparklinesOptions'];
    schema.label=DAStudio.message('Simulink:studio:SparklinesOptions');
    if slfeature('SignalsSparklines')>0
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
    schema.callback=@SparklinesOptionsCB;
end

function SparklinesOptionsCB(cbinfo)
    SLM3I.SLCommonDomain.portValuePlotDisplayOptionsDialog(cbinfo.editorModel.handle);
end


