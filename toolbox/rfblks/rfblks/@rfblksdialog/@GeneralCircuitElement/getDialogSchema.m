function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    cktobj=rfblksGetLeafWidgetBase('edit','','Ckt',...
    this,'Ckt');
    cktobj.RowSpan=[1,1];
    cktobj.ColSpan=[lwidget,rwidget];

    cktobjprompt=rfblksGetLeafWidgetBase('text','RFCKT object:',...
    'CktobjPrompt',0);
    cktobjprompt.RowSpan=[1,1];
    cktobjprompt.ColSpan=[lprompt,rprompt];

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[2,2];
    spacerMain.ColSpan=[lprompt,rprompt];


    sourcefreq_entry={};

    Udata=this.Block.UserData;
    if strcmpi(get_param(bdroot,'BlockDiagramType'),'library')
        mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
    elseif isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')





        myckt=Udata.Ckt;

        try
            myckt=analyze(myckt,100e9);
            mydata=myckt.AnalyzedResult;
        catch
            mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
        end
    else
        mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
    end

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');



    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={cktobj,cktobjprompt,spacerMain};
    mainPane.LayoutGrid=[2,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[0,1];


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

