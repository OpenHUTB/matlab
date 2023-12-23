function dlgstruct=getDialogSchema(this,~)

    items=getItems(this);
    dlgstruct=getDlgStruct(items,this);

end


function panel=getChildPanel(this)

    items={};
    childLabel.Name=DAStudio.message('dataflow:UI:SubsystemPopupChildLabel');
    childLabel.Type='text';
    childLabel.Tag='childLabel';
    childLabel.RowSpan=[1,1];
    childLabel.ColSpan=[1,2];
    childLabel.FontPointSize=10;
    childLabel.Alignment=1;

    items{end+1}=childLabel;
    findHLink.Name=getfullname(this.HConfigBlock);
    findHLink.Type='hyperlink';
    findHLink.Tag='findConfigBlkHLink';
    findHLink.MatlabMethod='findConfigBlk';
    findHLink.MatlabArgs={this};
    findHLink.RowSpan=[2,2];
    findHLink.ColSpan=[1,2];
    findHLink.Enabled=true;
    findHLink.ToolTip=DAStudio.message('dataflow:UI:ConcurrentSubsystemPopupChildHyperlinkToolTip');
    findHLink.Alignment=1;

    items{end+1}=findHLink;

    panel.Type='panel';
    panel.Tag='childPanel';
    panel.Flat=false;
    panel.LayoutGrid=[2,2];
    panel.RowSpan=[2,2];
    panel.ColSpan=[1,2];
    panel.Items=items;

end


function panel=getInfoPanel(this)
    items={};
    threadsLabel.Name=DAStudio.message('dataflow:UI:SubsystemPopupThreadsLabel',this.NumThreadsStr);
    threadsLabel.Type='text';
    threadsLabel.Tag='threadsLabel';
    threadsLabel.RowSpan=[1,1];
    threadsLabel.ColSpan=[1,1];
    threadsLabel.FontPointSize=10;
    threadsLabel.Alignment=1;

    items{end+1}=threadsLabel;

    if this.ShowUpdate

        updateHLink.Name=DAStudio.message('dataflow:UI:SubsystemPopupUpdateHyperlinkLabel');
        updateHLink.Type='hyperlink';
        updateHLink.Tag='updateHLink';
        updateHLink.MatlabMethod='updateModel';
        updateHLink.MatlabArgs={this};
        updateHLink.RowSpan=[1,1];
        updateHLink.ColSpan=[2,2];
        updateHLink.DialogRefresh=true;
        updateHLink.Enabled=true;
        updateHLink.ToolTip=DAStudio.message('dataflow:UI:SubsystemPopupUpdateHyperlinkToolTip');
        updateHLink.Alignment=1;

        items{end+1}=updateHLink;
    end

    if(this.ShowLatency)

        latencyLabel.Name=DAStudio.message('dataflow:UI:SubsystemPopupLatencyLabel',this.Latency);
        latencyLabel.Type='text';
        latencyLabel.Tag='latencyLabel';
        latencyLabel.RowSpan=[2,2];
        latencyLabel.ColSpan=[1,1];
        latencyLabel.FontPointSize=10;
        latencyLabel.Alignment=1;

        items{end+1}=latencyLabel;
        openDialog.Name=DAStudio.message('dataflow:UI:SubsystemPopupConfigureHyperlinkLabel');
        openDialog.Type='hyperlink';
        openDialog.Tag='openConfigBlkDialogHLink';
        openDialog.MatlabMethod='openConfigBlkDialog';
        openDialog.MatlabArgs={this};
        openDialog.RowSpan=[2,2];
        openDialog.ColSpan=[2,2];
        openDialog.DialogRefresh=true;
        openDialog.Enabled=true;
        openDialog.ToolTip=DAStudio.message('dataflow:UI:ConcurrentSubsystemPopupConfigureHyperlinkToolTip');
        openDialog.Alignment=1;

        items{end+1}=openDialog;
    end

    if this.ShowSuggested
        latencyLabel.Name=DAStudio.message('dataflow:UI:SubsystemPopupSuggestedLatencyLabel',this.OptimumLatency);
        latencyLabel.Type='text';
        latencyLabel.Tag='suggestedLatencyLabel';
        latencyLabel.RowSpan=[3,3];
        latencyLabel.ColSpan=[1,1];
        latencyLabel.FontPointSize=10;
        latencyLabel.Alignment=1;

        items{end+1}=latencyLabel;

        if this.ShowAccept
            acceptHLink.Name=DAStudio.message('dataflow:UI:SubsystemPopupAcceptHyperlinkLabel');
            acceptHLink.Type='hyperlink';
            acceptHLink.Tag='acceptHLink';
            acceptHLink.MatlabMethod='accept';
            acceptHLink.MatlabArgs={this};
            acceptHLink.RowSpan=[3,3];
            acceptHLink.ColSpan=[2,2];
            acceptHLink.DialogRefresh=true;
            acceptHLink.Enabled=true;
            acceptHLink.ToolTip=DAStudio.message('dataflow:UI:SubsystemPopupAcceptHyperlinkToolTip',this.OptimumLatency);
            acceptHLink.Alignment=1;

            items{end+1}=acceptHLink;

        end
    end

    panel.Type='panel';
    panel.Tag='infoPanel';
    panel.Flat=false;
    panel.LayoutGrid=[3,2];
    panel.RowSpan=[2,2];
    panel.ColSpan=[1,2];
    panel.Items=items;

end


function items=getItems(this)
    items={};
    popupLabel.Name=DAStudio.message('dataflow:UI:ConcurrentSubsystemPopupTitleLabel');
    popupLabel.Type='text';
    popupLabel.Tag='popupLabel';
    popupLabel.RowSpan=[1,1];
    popupLabel.ColSpan=[1,1];
    popupLabel.Alignment=2;
    popupLabel.FontPointSize=10;
    popupLabel.Bold=true;

    items{end+1}=popupLabel;
    openHelp.Name=DAStudio.message('dataflow:UI:SubsystemPopupHelpLabel');
    openHelp.Type='hyperlink';
    openHelp.Tag='helpHLink';
    openHelp.MatlabMethod='openHelp';
    openHelp.MatlabArgs={this};
    openHelp.RowSpan=[1,1];
    openHelp.ColSpan=[2,2];
    openHelp.Enabled=true;
    openHelp.ToolTip=DAStudio.message('dataflow:UI:ConcurrentSubsystemPopupHelpToolTip');
    openHelp.Alignment=4;
    openHelp.Bold=true;

    items{end+1}=openHelp;

    if strcmp(this.PopupType,'Child')
        items{end+1}=getChildPanel(this);
    else
        items{end+1}=getInfoPanel(this);
    end

    mainPanel.Type='panel';
    mainPanel.Tag='mainPanel';
    mainPanel.Flat=false;
    mainPanel.LayoutGrid=[2,2];
    mainPanel.RowSpan=[1,1];
    mainPanel.ColSpan=[1,2];
    mainPanel.Items=items;
    items={mainPanel};
end


function dlgstruct=getDlgStruct(items,~)
    dlgstruct.DialogTitle=DAStudio.message('dataflow:UI:ConcurrentSubsystemPopupTitle');
    dlgstruct.DialogTag=dlgstruct.DialogTitle;
    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.IsScrollable=false;
    dlgstruct.Transient=true;
    dlgstruct.DialogStyle='frameless';
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.MinimalApply=true;
    dlgstruct.ExplicitShow=true;
    dlgstruct.Items=items;
end


