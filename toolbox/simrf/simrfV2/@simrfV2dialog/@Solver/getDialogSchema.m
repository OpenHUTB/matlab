function dlgStruct=getDialogSchema(this,~)








    [RFItems,RFLayout]=simrfV2create_RFparam_pane(this);



    SpectrumItemGroup=...
    RFItems{cellfun(@(x)strcmp(x.Tag,'SpectrumContainer'),RFItems)};
    TotalfreqsItem=SpectrumItemGroup.Items{cellfun(@(x)...
    strcmp(x.Tag,'Totalfreqs'),SpectrumItemGroup.Items)};
    [solverItems,solverLayout]=simrfV2create_Solverparam_pane(this,...
    TotalfreqsItem.Name);



    RFPane=simrfV2create_panel(this,'RFPane',RFItems,RFLayout);


    solverPane=simrfV2create_panel(this,'SolverPane',...
    solverItems,solverLayout);



    RFTab.Name='Main';
    RFTab.Items={RFPane};
    RFTab.LayoutGrid=[1,1];
    RFTab.RowStretch=1;
    RFTab.ColStretch=1;


    modelingTab.Name='Advanced';
    modelingTab.Items={solverPane};
    modelingTab.LayoutGrid=[1,1];
    modelingTab.RowStretch=1;
    modelingTab.ColStretch=1;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    tabbedPane.Tabs={RFTab,modelingTab};


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);
    dlgStruct.CloseMethod='simrfV2closesolver';


