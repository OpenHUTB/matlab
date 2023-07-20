

function dlg=getSlimDialogSchema(obj,~)



    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    opacity=obj.getBlock().Opacity;


    dlg=obj.getBaseSlimDialogSchema();


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


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[2,2];
    legendPositionLabel.ColSpan=[1,2];

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
    legendPosition.RowSpan=[2,2];
    legendPosition.ColSpan=[3,5];


    opacityLabel.Type='text';
    opacityLabel.Tag='opacityLabel';
    opacityLabel.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityLabel.RowSpan=[3,3];
    opacityLabel.ColSpan=[1,2];

    opacityCB.Type='edit';
    opacityCB.Tag='opacity';
    opacityCB.Source=obj;
    opacityCB.Value=opacity;
    opacityCB.MatlabMethod='utils.slimDialogUtils.setDashboardBlockTransparency';
    opacityCB.MatlabArgs={'%dialog','%source','%tag','%value'};
    opacityCB.RowSpan=[3,3];
    opacityCB.ColSpan=[3,5];


    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/LampDialog.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true),...
    '&IsCoreBlock=','1'];
    LampColorsBrowser.Type='webbrowser';
    LampColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    LampColorsBrowser.Tag='lamp_properties_browser';
    LampColorsBrowser.DisableContextMenu=true;
    LampColorsBrowser.RowSpan=[4,4];
    LampColorsBrowser.ColSpan=[1,5];
    LampColorsBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));

    dlg.LayoutGrid=[5,5];
    dlg.RowStretch=[0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{legendPositionLabel,legendPosition,opacityLabel,opacityCB,LampColorsBrowser}];
end
