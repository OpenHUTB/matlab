function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);









    [mainItems,mainLayout]=rfblkscreate_netparam_pane(this);

    from_data_source='Determined from data source';

    [nonlinearItems,nonlinearLayout]=rfblkscreate_nonlinear_pane(this,0,[],[],...
    [],[],[],[],from_data_source);


    [noiseItems,noiseLayout]=rfblkscreate_noise_pane(this,0,[],[],...
    from_data_source);


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');




    mainPane=rfblkscreate_panel(this,'MainPane',mainItems,mainLayout);


    noisePane=rfblkscreate_panel(this,'NoisePane',noiseItems,noiseLayout);


    nonlinearPane=rfblkscreate_panel(this,'NonlinearPane',nonlinearItems,nonlinearLayout);


    visualizationPane=rfblkscreate_panel(this,'VisualizationPane',visItems,visLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    noiseTab.Name='Noise Data';
    noiseTab.Items={noisePane};
    noiseTab.LayoutGrid=[1,1];
    noiseTab.RowStretch=0;
    noiseTab.ColStretch=0;


    nonlinearTab.Name='Nonlinearity Data';
    nonlinearTab.Items={nonlinearPane};
    nonlinearTab.LayoutGrid=[1,1];
    nonlinearTab.RowStretch=0;
    nonlinearTab.ColStretch=0;


    visualizationTab.Name='Visualization';
    visualizationTab.Items={visualizationPane};
    visualizationTab.LayoutGrid=[1,1];
    visualizationTab.RowStretch=0;
    visualizationTab.ColStretch=0;


    tabbedPane=rfblksGetContainerWidgetBase('tab','','TabPane');
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    tabbedPane.Tabs={mainTab,noiseTab,nonlinearTab,visualizationTab};


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);


