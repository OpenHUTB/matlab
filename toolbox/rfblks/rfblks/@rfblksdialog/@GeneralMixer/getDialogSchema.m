function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);










    [mainItems,mainLayout,mainInfo]=rfblkscreate_filedata_pane_generalmixer(this);
    [opTab_Enable,multiref_filename_changed,mydata,noisedata,nfdata,...
    powerdata,ip3data,p2ddata,OneDBC,PS,GCS]=deal(mainInfo{:});

    from_data_source='Determined from data source';

    [nonlinearItems,nonlinearLayout]=rfblkscreate_nonlinear_pane(this,0,p2ddata,...
    powerdata,ip3data,OneDBC,PS,GCS,from_data_source);


    [noiseItems,noiseLayout]=rfblkscreate_noise_pane_mixer(this,2,noisedata,nfdata,...
    from_data_source);


    sourcefreq_entry={'Extracted from data source'};

    Udata=this.Block.UserData;
    if isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')...
        &&isa(Udata.Ckt.AnalyzedResult,'rfdata.data')...
        &&~isempty(Udata.Ckt.AnalyzedResult.S_Parameters)
        plotdata=Udata.Ckt.AnalyzedResult;
    else
        plotdata=mydata;
    end

    [visItems,visLayout]=rfblkscreate_vis_pane_general(this,plotdata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');


    [opItems,opLayout]=rfblkscreate_op_pane(this,opTab_Enable,...
    create_new_dialog,multiref_filename_changed,mydata);




    mainPane=rfblkscreate_panel(this,'MainPane',mainItems,mainLayout);


    noisePane=rfblkscreate_panel(this,'NoisePane',noiseItems,noiseLayout);


    nonlinearPane=rfblkscreate_panel(this,'NonlinearPane',nonlinearItems,nonlinearLayout);


    visualizationPane=rfblkscreate_panel(this,'VisualizationPane',visItems,visLayout);


    opPane=rfblkscreate_panel(this,'OpPane',opItems,opLayout);



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


    opTab.Name='Operating Conditions';
    opTab.Items={opPane};
    opTab.LayoutGrid=[1,1];
    opTab.RowStretch=0;
    opTab.ColStretch=0;


    tabbedPane=rfblksGetContainerWidgetBase('tab','','TabPane');
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    tabbedPane.Tabs={mainTab,noiseTab,nonlinearTab,...
    visualizationTab,opTab};


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);

