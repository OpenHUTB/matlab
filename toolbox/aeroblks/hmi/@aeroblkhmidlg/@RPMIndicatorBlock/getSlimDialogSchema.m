function dlg=getSlimDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');

    gaugeType=DAStudio.message('aeroblksHMI:aeroblkhmi:RPMIndicator');


    dlg=obj.getBaseSlimDialogSchema();


    if utils.isAeroHMILibrary(model)
        labelPosition='hide';
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    obj.ScaleColors=get_param(blockHandle,'ScaleColors');


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


    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true)];
    scColorsBrowser.Type='webbrowser';
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='slim_gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;
    scColorsBrowser.RowSpan=[4,4];
    scColorsBrowser.ColSpan=[1,5];
    scColorsBrowser.Enabled=~((utils.isAeroHMILibrary(model))||(utils.isLockedLibrary(model)));

    dlg.LayoutGrid=[5,5];
    dlg.RowStretch=[0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{gaugeTypeLabel,gaugeTypeValue,legendPositionLabel,...
    legendPosition,scColorsBrowser}];
end
