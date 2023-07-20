

function dlg=getDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    dlg=obj.getBaseDialogSchema();


    type=get_param(blockHandle,'BlockType');

    if Simulink.HMI.isLibrary(model)
        stateLabels={'off','on'};
        states=[0,1];
        labelPosition=0;
    else
        values=get_param(blockHandle,'Values');
        stateLabels=values{1};
        states=values{2};
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end


    text.Type='text';
    desc=[DAStudio.message('SimulinkHMI:dialogs:SwitchDialogDesc')];
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:Switch');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];







    label.Type='text';
    label.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchLabel');
    label.WordWrap=true;
    label.RowSpan=[1,1];
    label.ColSpan=[2,2];

    if strcmp(type,'SliderSwitchBlock')
        offRowHeader=DAStudio.message('SimulinkHMI:dialogs:SliderSwitchOffStatePos');
        onRowHeader=DAStudio.message('SimulinkHMI:dialogs:SliderSwitchOnStatePos');
        offStateRowSpan=[2,2];
        onStateRowSpan=[3,3];
    else
        offRowHeader=DAStudio.message('SimulinkHMI:dialogs:RockerSwitchOffStatePos');
        onRowHeader=DAStudio.message('SimulinkHMI:dialogs:RockerSwitchOnStatePos');
        offStateRowSpan=[3,3];
        onStateRowSpan=[2,2];
    end


    value.Type='text';
    value.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchValue');
    value.WordWrap=true;
    value.RowSpan=[1,1];
    value.ColSpan=[3,3];


    offState.Type='text';
    offState.Name=offRowHeader;
    offState.WordWrap=true;
    offState.RowSpan=offStateRowSpan;
    offState.ColSpan=[1,1];


    offLabel.Type='edit';
    offLabel.Tag='offLabel';
    offLabel.Value=stateLabels{1};
    offLabel.RowSpan=offStateRowSpan;
    offLabel.ColSpan=[2,2];


    offValue.Type='edit';
    offValue.Tag='offValue';
    offValue.Value=num2str(states(1),16);
    offValue.RowSpan=offStateRowSpan;
    offValue.ColSpan=[3,3];


    onState.Type='text';
    onState.Name=onRowHeader;
    onState.WordWrap=true;
    onState.RowSpan=onStateRowSpan;
    onState.ColSpan=[1,1];


    onLabel.Type='edit';
    onLabel.Tag='onLabel';
    onLabel.Value=stateLabels{2};
    onLabel.RowSpan=onStateRowSpan;
    onLabel.ColSpan=[2,2];


    onValue.Type='edit';
    onValue.Tag='onValue';
    onValue.Value=num2str(states(2),16);
    onValue.RowSpan=onStateRowSpan;
    onValue.ColSpan=[3,3];


    stateLabelsGroup.Type='group';
    stateLabelsGroup.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchStates');



    if strcmp(type,'SliderSwitchBlock')
        stateLabelsGroup.Items={label,value,offState,offLabel,offValue,onState,onLabel,onValue};
    else
        stateLabelsGroup.Items={label,value,onState,onLabel,onValue,offState,offLabel,offValue};
    end
    stateLabelsGroup.RowSpan=[2,2];
    stateLabelsGroup.ColSpan=[1,3];


    stateLabelsGroup.LayoutGrid=[3,4];
    stateLabelsGroup.ColStretch=[0,1,1,0];


    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={webbrowser,stateLabelsGroup,legendPosition};
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[3,3];
    propGroup.RowStretch=[1,0,0];
    propGroup.ColStretch=[1,1,1];

    dlg.Items={descGroup,propGroup};
    dlg.LayoutGrid=[2,2];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[1,1];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';

    switch type
    case 'RockerSwitchBlock'
        dlg.HelpArgs=...
        {[docroot,'/simulink/helptargets.map'],'hmi_rocker_switch'};
    case 'ToggleSwitchBlock'
        dlg.HelpArgs=...
        {[docroot,'/simulink/helptargets.map'],'hmi_toggle_switch'};
    case 'SliderSwitchBlock'
        dlg.HelpArgs=...
        {[docroot,'/simulink/helptargets.map'],'hmi_slider_switch'};
    end
end



