function dlg=getSlimDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');

    type=get_param(blockHandle,'BlockType');
    switch type
    case 'AltimeterBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:Altimeter');
    case 'ArtificialHorizonBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:ArtificialHorizon');
    case 'HeadingIndicatorBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:HeadingIndicator');
    case 'TurnCoordinatorBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:TurnCoordinator');
    end


    dlg=obj.getBaseSlimDialogSchema();


    if utils.isAeroHMILibrary(model)
        labelPosition='hide';
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end


    gaugeTypeLabel.Type='text';
    gaugeTypeLabel.Tag='scaleTypeLabel';
    gaugeTypeLabel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeType');
    gaugeTypeLabel.Value=gaugeType;
    gaugeTypeLabel.Buddy='gaugeType';
    gaugeTypeLabel.RowSpan=[2,2];
    gaugeTypeLabel.ColSpan=[1,3];

    gaugeTypeValue.Type='text';
    gaugeTypeValue.Tag='gaugeType';
    gaugeTypeValue.Name=gaugeType;
    gaugeTypeValue.RowSpan=[2,2];
    gaugeTypeValue.ColSpan=[4,5];


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[3,3];
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
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[4,5];

    dlg.LayoutGrid=[4,5];
    dlg.RowStretch=[0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{gaugeTypeLabel,gaugeTypeValue,legendPositionLabel,legendPosition}];

end
