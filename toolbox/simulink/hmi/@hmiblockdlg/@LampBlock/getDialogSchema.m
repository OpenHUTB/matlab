

function dlg=getDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    text.Type='text';

    desc=DAStudio.message('SimulinkHMI:dialogs:LampDialogDesc');

    text.WordWrap=true;
    text.Name=desc;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:Lamp');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    dlg=obj.getBaseDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end

    states=get_param(blockHandle,'States');
    obj.States={};
    for idx=1:length(states{1})
        obj.States{idx}=num2str(states{1}(idx),16);
    end
    obj.StateColors=states{2};
    obj.DefaultColor=get_param(blockHandle,'DefaultColor');
    obj.Icon=get_param(blockHandle,'Icon');
    opacity=get_param(blockHandle,'Opacity');


    bindingTableBrowser=dlg.Items{1};
    bindingTableBrowser.RowSpan=[1,1];
    bindingTableBrowser.ColSpan=[1,3];


    propBrowser=dlg.Items{1};
    propBrowser.RowSpan=[2,2];
    propBrowser.ColSpan=[1,3];

    url=strcat('toolbox/simulink/hmi/web/Dialogs/SignalDialog/LampDialog.html?widgetID=',obj.widgetId,...
    '&model=',model,'&IsCoreBlock=','1');
    propBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propBrowser.Tag='lamp_properties_browser';
    propBrowser.DisableContextMenu=true;
    propBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));


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


    opacityField.Type='edit';
    opacityField.Tag='opacity';
    opacityField.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityField.Value=opacity;
    opacityField.RowSpan=[4,4];
    opacityField.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={bindingTableBrowser,propBrowser,legendPosition,opacityField};
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[4,3];
    propGroup.RowStretch=[1,0,0,0];
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
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_lamp'};
end



