

function dlg=getSlimDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    blockType=get(blockHandle,'BlockType');


    dlg=obj.getBaseSlimDialogSchema();


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

    stateTitleLabel.Type='text';
    stateTitleLabel.Name=[DAStudio.message('SimulinkHMI:dialogs:SwitchStates'),':'];
    stateTitleLabel.WordWrap=true;
    stateTitleLabel.RowSpan=[2,2];
    stateTitleLabel.ColSpan=[1,5];



    if strcmp(blockType,'SliderSwitchBlock')
        offRowHeader=DAStudio.message('SimulinkHMI:dialogs:SliderSwitchOffStatePos');
        onRowHeader=DAStudio.message('SimulinkHMI:dialogs:SliderSwitchOnStatePos');
        offStateRowSpan=[3,3];
        onStateRowSpan=[6,6];
    else
        offRowHeader=DAStudio.message('SimulinkHMI:dialogs:RockerSwitchOffStatePos');
        onRowHeader=DAStudio.message('SimulinkHMI:dialogs:RockerSwitchOnStatePos');
        offStateRowSpan=[6,6];
        onStateRowSpan=[3,3];
    end


    offState.Type='text';
    offState.Name=offRowHeader;
    offState.WordWrap=true;
    offState.RowSpan=offStateRowSpan;
    offState.ColSpan=[1,3];


    offStateLabel.Type='text';
    offStateLabel.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchLabel');
    offStateLabel.WordWrap=true;
    offStateLabel.RowSpan=offStateRowSpan+[1,1];
    offStateLabel.ColSpan=[2,3];


    offLabel.Type='edit';
    offLabel.Tag='offLabel';
    offLabel.Value=stateLabels{1};
    offLabel.MatlabMethod='utils.slimDialogUtils.switchLabelValueChanged';
    offLabel.MatlabArgs={'%dialog',obj};
    offLabel.RowSpan=offStateRowSpan+[1,1];
    offLabel.ColSpan=[4,5];


    offValueLabel.Type='text';
    offValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchValue');
    offValueLabel.WordWrap=true;
    offValueLabel.RowSpan=offStateRowSpan+[2,2];
    offValueLabel.ColSpan=[2,3];


    offValue.Type='edit';
    offValue.Tag='offValue';
    offValue.Value=num2str(states(1),16);
    offValue.MatlabMethod='utils.slimDialogUtils.switchLabelValueChanged';
    offValue.MatlabArgs={'%dialog',obj};
    offValue.RowSpan=offStateRowSpan+[2,2];
    offValue.ColSpan=[4,5];


    onState.Type='text';
    onState.Name=onRowHeader;
    onState.WordWrap=true;
    onState.RowSpan=onStateRowSpan;
    onState.ColSpan=[1,3];


    onStateLabel.Type='text';
    onStateLabel.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchLabel');
    onStateLabel.WordWrap=true;
    onStateLabel.RowSpan=onStateRowSpan+[1,1];
    onStateLabel.ColSpan=[2,3];


    onLabel.Type='edit';
    onLabel.Tag='onLabel';
    onLabel.Value=stateLabels{2};
    onLabel.MatlabMethod='utils.slimDialogUtils.switchLabelValueChanged';
    onLabel.MatlabArgs={'%dialog',obj};
    onLabel.RowSpan=onStateRowSpan+[1,1];
    onLabel.ColSpan=[4,5];


    onValueLabel.Type='text';
    onValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:SwitchValue');
    onValueLabel.WordWrap=true;
    onValueLabel.RowSpan=onStateRowSpan+[2,2];
    onValueLabel.ColSpan=[2,3];


    onValue.Type='edit';
    onValue.Tag='onValue';
    onValue.Value=num2str(states(2),16);
    onValue.MatlabMethod='utils.slimDialogUtils.switchLabelValueChanged';
    onValue.MatlabArgs={'%dialog',obj};
    onValue.RowSpan=onStateRowSpan+[2,2];
    onValue.ColSpan=[4,5];





    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[9,9];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.labelPositionChanged';
    legendPosition.MatlabArgs={'%dialog',obj};
    legendPosition.RowSpan=[9,9];
    legendPosition.ColSpan=[4,5];

    if strcmp(blockType,'sliderswitch')
        stateFields={stateTitleLabel,...
        offState,...
        offStateLabel,offLabel,...
        offValueLabel,offValue,...
        onState,...
        onStateLabel,onLabel,...
        onValueLabel,onValue,...
        legendPositionLabel,legendPosition};
    else
        stateFields={stateTitleLabel,...
        onState,...
        onStateLabel,onLabel,...
        onValueLabel,onValue,...
        offState,...
        offStateLabel,offLabel,...
        offValueLabel,offValue,...
        legendPositionLabel,legendPosition};
    end

    dlg.Items=[dlg.Items,stateFields];

    dlg.LayoutGrid=[10,5];
    dlg.RowStretch=[0,0,0,0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
end



