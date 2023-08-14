


function dlg=getSlimDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');

    panelInfo=jsondecode(get_param(blockHandle,'PanelInfo'));


    panelNameTxt.Type='text';
    panelNameTxt.Name=DAStudio.message('simulink_ui:webblocks:resources:PropertyInspectorPanelNamePrompt');
    panelNameTxt.WordWrap=true;
    panelNameTxt.RowSpan=[1,1];
    panelNameTxt.ColSpan=[1,1];

    panelNameValue.Type='edit';
    panelNameValue.Tag='panelName';
    panelNameValue.Value=panelInfo.name;
    panelNameValue.RowSpan=[1,1];
    panelNameValue.ColSpan=[2,2];
    panelNameValue.MatlabMethod='panelwebblockdlgs.PanelWebBlock.PanelWebBlockDialogPropertyCB';
    panelNameValue.MatlabArgs={'%dialog',obj};


    dlg.DialogTitle='';
    dlg.DialogMode='Slim';
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};


    dlg.CloseMethod='closeCallback';
    dlg.CloseMethodArgs={'%dialog'};
    dlg.CloseMethodArgsDT={'handle'};


    dlg.Items={panelNameTxt,panelNameValue};

    dlg.DialogTag='DashboardPanelPropertyInspectorDialog';
    dlg.LayoutGrid=[2,2];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[0,1];
end
