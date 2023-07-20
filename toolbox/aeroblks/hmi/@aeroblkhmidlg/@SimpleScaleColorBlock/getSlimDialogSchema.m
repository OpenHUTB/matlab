function dlg=getSlimDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');

    type=get_param(blockHandle,'BlockType');
    switch type
    case 'AirspeedIndicatorBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:AirspeedIndicator');
    case 'EGTIndicatorBlock'
        gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:EGTIndicator');
    end


    dlg=obj.getBaseSlimDialogSchema();


    if utils.isAeroHMILibrary(model)
        labelPosition='hide';
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    obj.ScaleColors=get_param(blockHandle,'ScaleColors');
    ScaleMin=get_param(blockHandle,'ScaleMin');
    ScaleMax=get_param(blockHandle,'ScaleMax');


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


    minimumLabel.Type='text';
    minimumLabel.Tag='minimumLabel';
    minimumLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumLabel.Buddy='minimumValue';
    minimumLabel.RowSpan=[3,3];
    minimumLabel.ColSpan=[1,3];

    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Value=ScaleMin;
    minimumValue.MatlabMethod='utils.gaugeAeroMinMaxChanged';
    minimumValue.MatlabArgs={'%dialog',obj,true};
    minimumValue.RowSpan=[3,3];
    minimumValue.ColSpan=[4,5];


    maximumLabel.Type='text';
    maximumLabel.Tag='maximumLabel';
    maximumLabel.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumLabel.Buddy='maximumValue';
    maximumLabel.RowSpan=[4,4];
    maximumLabel.ColSpan=[1,3];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=ScaleMax;
    maximumValue.MatlabMethod='utils.gaugeAeroMinMaxChanged';
    maximumValue.MatlabArgs={'%dialog',obj,true};
    maximumValue.RowSpan=[4,4];
    maximumValue.ColSpan=[4,5];



    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[5,5];
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
    legendPosition.RowSpan=[5,5];
    legendPosition.ColSpan=[4,5];


    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true)];
    scColorsBrowser.Type='webbrowser';
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='slim_gauge_scalecolors_browser';
    scColorsBrowser.RowSpan=[6,6];
    scColorsBrowser.ColSpan=[1,5];
    scColorsBrowser.DisableContextMenu=true;
    scColorsBrowser.Enabled=~((utils.isAeroHMILibrary(model))||(utils.isLockedLibrary(model)));

    dlg.LayoutGrid=[7,5];
    dlg.RowStretch=[0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{gaugeTypeLabel,gaugeTypeValue,...
    minimumLabel,minimumValue,...
    maximumLabel,maximumValue,...
    legendPositionLabel,legendPosition,...
    scColorsBrowser}];
end
