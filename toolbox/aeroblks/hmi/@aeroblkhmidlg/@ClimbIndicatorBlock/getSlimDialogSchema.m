function dlg=getSlimDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');

    gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:ClimbIndicator');


    dlg=obj.getBaseSlimDialogSchema();


    if utils.isAeroHMILibrary(model)
        labelPosition='hide';
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end


    gaugeTypeLabel.Type='text';
    gaugeTypeLabel.Tag='scaleTypeLabel';
    gaugeTypeLabel.Name=DAStudio.message('aeroblksHMI:aeroblkhmi:instrumentType');
    gaugeTypeLabel.Value=gaugeType;
    gaugeTypeLabel.Buddy='gaugeType';
    gaugeTypeLabel.RowSpan=[2,2];
    gaugeTypeLabel.ColSpan=[1,3];

    gaugeTypeValue.Type='text';
    gaugeTypeValue.Tag='gaugeType';
    gaugeTypeValue.Name=gaugeType;
    gaugeTypeValue.RowSpan=[2,2];
    gaugeTypeValue.ColSpan=[4,5];


    maximumLabel.Type='text';
    maximumLabel.Tag='maximumLabel';
    maximumLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumLabel.Buddy='maximumValue';
    maximumLabel.RowSpan=[3,3];
    maximumLabel.ColSpan=[1,3];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=get_param(blockHandle,'ScaleMax');
    maximumValue.MatlabMethod='utils.gaugeAeroMinMaxChanged';
    maximumValue.MatlabArgs={'%dialog',obj,true};
    maximumValue.RowSpan=[3,3];
    maximumValue.ColSpan=[4,5];



    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[4,4];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.labelAeroPositionChanged';
    legendPosition.MatlabArgs={'%dialog',obj};
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[4,5];

    dlg.LayoutGrid=[5,5];
    dlg.RowStretch=[0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{gaugeTypeLabel,gaugeTypeValue,...
    maximumLabel,maximumValue,legendPositionLabel,legendPosition}];
end
