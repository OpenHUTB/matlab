function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);









    [mainItems,mainLayout,mainInfo]=rfblkscreate_filedata_pane_generalpassive(this);
    mydata=mainInfo{1};


    sourcefreq_entry={'Extracted from data source'};

    Udata=this.Block.UserData;
    if isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')...
        &&isa(Udata.Ckt.AnalyzedResult,'rfdata.data')...
        &&~isempty(Udata.Ckt.AnalyzedResult.S_Parameters)
        plotdata=Udata.Ckt.AnalyzedResult;
    else
        plotdata=mydata;
    end

    [visItems,visLayout]=rfblkscreate_vis_pane(this,plotdata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');




    mainPane=rfblkscreate_panel(this,'MainPane',mainItems,mainLayout);


    visualizationPane=rfblkscreate_panel(this,'VisualizationPane',visItems,visLayout);



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


    tabbedPane=rfblksGetContainerWidgetBase('tab','','TabPane');
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    tabbedPane.Tabs={mainTab,visualizationTab};


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);


