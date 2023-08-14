function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;


    ind=rfblksGetLeafWidgetBase('edit','','L',this,'L');
    ind.RowSpan=[1,1];
    ind.ColSpan=[lwidget,rwidget];

    indprompt=rfblksGetLeafWidgetBase('text','Inductance (H):',...
    'IndPrompt',0);
    indprompt.RowSpan=[1,1];
    indprompt.ColSpan=[lprompt,rprompt];

    cap=rfblksGetLeafWidgetBase('edit','','C',this,'C');
    cap.RowSpan=[2,2];
    cap.ColSpan=[lwidget,rwidget];

    capprompt=rfblksGetLeafWidgetBase('text','Capacitance (F):',...
    'CapPrompt',0);
    capprompt.RowSpan=[2,2];
    capprompt.ColSpan=[lprompt,rprompt];

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[3,3];
    spacerMain.ColSpan=[lprompt,rprompt];


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');




    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={ind,indprompt,cap,capprompt,spacerMain};
    mainPane.LayoutGrid=[3,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[0,0,1];


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


