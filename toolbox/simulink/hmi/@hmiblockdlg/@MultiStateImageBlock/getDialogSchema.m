


function dlg=getDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    dlg=obj.getBaseDialogSchema();


    labelPosition=get_param(blockHandle,'labelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    scaleMode=get_param(blockHandle,'ScaleMode');
    scaleMode=simulink.hmi.getModePosition(scaleMode);
    obj.States=get_param(blockHandle,'States');
    obj.DefaultImage=get_param(blockHandle,'DefaultImage');


    text.Type='text';
    text.WordWrap=true;
    text.Name=DAStudio.message('SimulinkHMI:dialogs:MultiStateImageDialogDesc');
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:MultiStateImage');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    bindingTableBrowser=dlg.Items{1};
    bindingTableBrowser.RowSpan=[1,1];
    bindingTableBrowser.ColSpan=[1,3];


    url=[...
    'toolbox/simulink/hmi/web/Dialogs/SignalDialog/MultiStateImageDialog.html?widgetID=',obj.widgetId...
    ,'&model=',model...
    ,'&isLibWidget=',num2str(obj.isLibWidget)];

    propBrowser.Type='webbrowser';
    propBrowser.Tag='multiStateImage_properties_browser';
    propBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propBrowser.DisableContextMenu=true;
    propBrowser.MatlabMethod='slDialogUtil';
    propBrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propBrowser.RowSpan=[3,3];
    propBrowser.ColSpan=[1,3];
    propBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));


    scaleModeCombo.Type='combobox';
    scaleModeCombo.Tag='scaleMode';
    scaleModeCombo.Name=...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModePrompt');
    scaleModeCombo.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModeFixed'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModeFill'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleModeFillAspectRatio')...
    };
    scaleModeCombo.Value=scaleMode;
    scaleModeCombo.RowSpan=[2,2];
    scaleModeCombo.ColSpan=[1,3];


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
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={bindingTableBrowser,scaleModeCombo,propBrowser,legendPosition};
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[3,3];
    propGroup.RowStretch=[1,0,0];
    propGroup.ColStretch=[0,0,1];


    dlg.Items={descGroup,propGroup};

    dlg.LayoutGrid=[3,3];
    dlg.RowStretch=[0,1,1];
    dlg.ColStretch=[0,0,1];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_multistate_image'};
end
