function dlg=getDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    if utils.isAeroHMILibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
    end
    obj.ScaleColors=get_param(blockHandle,'ScaleColors');


    dlg=obj.getBaseDialogSchema();

    text.Type='text';
    desc=DAStudio.message('aeroblksHMI:aeroblkhmi:RPMIndicatorDialogDesc');

    text.WordWrap=true;
    text.Name=desc;

    descGroup.Type='group';
    descGroup.Name=DAStudio.message('aeroblksHMI:aeroblkhmi:RPMIndicator');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];


    scColorsBrowser=dlg.Items{1};
    scColorsBrowser.RowSpan=[2,2];
    scColorsBrowser.ColSpan=[1,3];

    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(false)];
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;
    scColorsBrowser.Enabled=~((utils.isAeroHMILibrary(model))||(utils.isLockedLibrary(model)));


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
    propGroup.Items={...
    webbrowser,scColorsBrowser,legendPosition...
    };
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.RowStretch=[1,0,0];
    propGroup.LayoutGrid=[3,3];

    dlg.Items={descGroup,propGroup};

    dlg.LayoutGrid=[2,3];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[0,0,0];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='asbhmihelp';
    dlg.HelpArgs={'rpmindicator'};
end
