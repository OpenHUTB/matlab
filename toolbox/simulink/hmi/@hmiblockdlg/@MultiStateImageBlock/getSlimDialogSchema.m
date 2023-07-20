



function dlg=getSlimDialogSchema(obj,~)
    dlg=obj.getBaseSlimDialogSchema();


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    labelPosition=get_param(blockHandle,'labelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    scaleMode=get_param(blockHandle,'ScaleMode');
    scaleMode=simulink.hmi.getModePosition(scaleMode);
    obj.States=get_param(blockHandle,'States');
    obj.DefaultImage=get_param(blockHandle,'DefaultImage');


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.RowSpan=[3,3];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Source=obj;
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.setCoreBlockLabelPosition';
    legendPosition.MatlabArgs={'%dialog','%source','%tag','%value'};
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[4,5];


    scaleModeLabel.Type='text';
    scaleModeLabel.Tag='scaleModeLabel';
    scaleModeLabel.Name=DAStudio.message('SimulinkHMI:dialogs:ScaleModePrompt');
    scaleModeLabel.Buddy='scaleModeEdit';
    scaleModeLabel.RowSpan=[2,2];
    scaleModeLabel.ColSpan=[1,3];

    scaleModeEdit.Type='combobox';
    scaleModeEdit.Tag='scaleModeEdit';
    scaleModeEdit.Entries={DAStudio.message('SimulinkHMI:dialogs:ScaleModeFixed'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModeFill'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModeFillAspectRatio')};
    scaleModeEdit.Values=[0,1,2];
    scaleModeEdit.Value=scaleMode;
    scaleModeEdit.RowSpan=[2,2];
    scaleModeEdit.ColSpan=[4,5];
    scaleModeEdit.MatlabMethod='utils.slimDialogUtils.scaleModeChanged';
    scaleModeEdit.MatlabArgs={'%dialog',obj};


    url=[...
    'toolbox/simulink/hmi/web/Dialogs/SignalDialog/MultiStateImageDialog.html?widgetID=',obj.widgetId...
    ,'&model=',model...
    ,'&isLibWidget=',num2str(obj.isLibWidget)...
    ,'&isSlimDialog=',num2str(true)];

    propBrowser.Type='webbrowser';
    propBrowser.Tag='multiStateImage_properties_browser';
    propBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propBrowser.DisableContextMenu=true;
    propBrowser.MatlabMethod='slDialogUtil';
    propBrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propBrowser.RowSpan=[4,4];
    propBrowser.ColSpan=[1,5];
    propBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));


    dlg.LayoutGrid=[5,5];
    dlg.RowStretch=[0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{...
    scaleModeLabel,scaleModeEdit,...
    legendPositionLabel,legendPosition,...
propBrowser...
    }];
end
