function dlgStruct=getDialogSchema(this,~)







    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');

    [mainItems,mainLayout,slBlkVis]=simrfV2create_filedata_pane(this,...
    slBlkVis,idxMaskNames);


    allowMagModeling=any(strcmpi(this.DataSource,{'Data file',...
    'Network-parameters'}));
    if(allowMagModeling)
        hAuxData=get_param([this.getBlock.getFullName...
        ,'/AuxData'],'handle');
        uData=get_param(hAuxData,'UserData');
        if((~isfield(uData,'Spars'))||...
            (~isfield(uData.Spars,'OrigParamType'))||...
            (~strcmpi(uData.Spars.OrigParamType,'s')))
            allowMagModeling=false;
        end
    end
    [modItems,modLayout,slBlkVis]=...
    simrfV2create_modeling_pane(this,slBlkVis,idxMaskNames,...
    allowMagModeling);


    [visItems,visLayout,slBlkVis]=simrfV2create_vis_pane(this,...
    slBlkVis,idxMaskNames);


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end






    mainPane=simrfV2create_panel(this,'MainPane',mainItems,mainLayout);


    modelingPane=simrfV2create_panel(this,'ModelingPane',...
    modItems,modLayout);


    visualizationPane=simrfV2create_panel(this,'VisualizationPane',...
    visItems,visLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    modelingTab.Name='Modeling';
    modelingTab.Items={modelingPane};
    modelingTab.LayoutGrid=[1,1];
    modelingTab.RowStretch=0;
    modelingTab.ColStretch=0;


    visualizationTab.Name='Visualization';
    visualizationTab.Items={visualizationPane};
    visualizationTab.LayoutGrid=[1,1];
    visualizationTab.RowStretch=0;
    visualizationTab.ColStretch=0;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    if~strcmpi(this.DataSource,'Rational model')
        tabbedPane.Tabs={mainTab,modelingTab,visualizationTab};
    else
        tabbedPane.Tabs={mainTab,visualizationTab};
    end


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);

