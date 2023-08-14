

function dlg=getSlimDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    dlg=obj.getBaseSlimDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
        scaleType=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);

        scaleType=get_param(blockHandle,'ScaleType');
        scaleType=simulink.hmi.getScaleType(scaleType);
    end


    scaleTypeLabel.Type='text';
    scaleTypeLabel.Name=DAStudio.message('SimulinkHMI:dialogs:ScaleType');
    scaleTypeLabel.WordWrap=true;
    scaleTypeLabel.RowSpan=[2,2];
    scaleTypeLabel.ColSpan=[1,3];

    scaleTypeValue.Type='combobox';
    scaleTypeValue.Tag='scaleType';
    scaleTypeValue.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLinear'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLog')
    };
    scaleTypeValue.Value=scaleType;
    scaleTypeValue.RowSpan=[2,2];
    scaleTypeValue.ColSpan=[4,5];
    scaleTypeValue.MatlabMethod='utils.scaleTypeChanged';
    scaleTypeValue.MatlabArgs={'%dialog',obj,true};


    minValLabel.Type='text';
    minValLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minValLabel.WordWrap=true;
    minValLabel.RowSpan=[3,3];
    minValLabel.ColSpan=[1,3];

    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Value=get_param(blockHandle,'ScaleMin');
    minimumValue.RowSpan=[3,3];
    minimumValue.ColSpan=[4,5];
    minimumValue.MatlabMethod='utils.slimDialogUtils.knobSettingsChanged';
    minimumValue.MatlabArgs={'%dialog',obj};


    maxValLabel.Type='text';
    maxValLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maxValLabel.WordWrap=true;
    maxValLabel.RowSpan=[4,4];
    maxValLabel.ColSpan=[1,3];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=get_param(blockHandle,'ScaleMax');
    maximumValue.RowSpan=[4,4];
    maximumValue.ColSpan=[4,5];
    maximumValue.MatlabMethod='utils.slimDialogUtils.knobSettingsChanged';
    maximumValue.MatlabArgs={'%dialog',obj};


    tickIntervalLabel.Type='text';
    if scaleType
        tickIntervalLabel.Name=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalPrompt');
    else
        tickIntervalLabel.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    end
    tickIntervalLabel.WordWrap=true;
    tickIntervalLabel.RowSpan=[5,5];
    tickIntervalLabel.ColSpan=[1,3];

    tickInterval.Type='edit';
    tickInterval.Tag='tickInterval';
    tickInterval.Value=get_param(blockHandle,'TickInterval');
    tickInterval.RowSpan=[5,5];
    tickInterval.ColSpan=[4,5];
    tickInterval.MatlabMethod='utils.slimDialogUtils.knobSettingsChanged';
    tickInterval.MatlabArgs={'%dialog',obj};


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[6,6];
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
    legendPosition.RowSpan=[6,6];
    legendPosition.ColSpan=[4,5];

    dlg.Items=[dlg.Items,{scaleTypeLabel,scaleTypeValue,...
    minValLabel,minimumValue,...
    maxValLabel,maximumValue,...
    tickIntervalLabel,tickInterval,...
    legendPositionLabel,legendPosition}];
    dlg.LayoutGrid=[7,5];
    dlg.RowStretch=[0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
end



