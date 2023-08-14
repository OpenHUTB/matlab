function dlgStruct=getDialogSchema(this,~)






    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');



    [mainItems,mainLayout,slBlkVis]=simrfV2create_filtmain_pane(this,...
    slBlkVis,idxMaskNames);

    mainPane=simrfV2create_panel(this,'MainPane',mainItems,mainLayout);


    [visItems,visLayout,slBlkVis]=...
    simrfV2create_filtvis_pane(this,slBlkVis,idxMaskNames);

    visualizationPane=simrfV2create_panel(this,'VisualizationPane',...
    visItems,visLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


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

    if strcmpi(this.designmethod,'Ideal')
        tabbedPane.Tabs={mainTab};
    else
        tabbedPane.Tabs={mainTab,visualizationTab};
    end


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end





    dlgStruct=getBaseSchemaStruct(this,tabbedPane);


