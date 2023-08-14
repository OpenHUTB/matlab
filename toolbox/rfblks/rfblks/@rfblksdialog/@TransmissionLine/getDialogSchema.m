function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    z0=rfblksGetLeafWidgetBase('edit','','Z0',this,'Z0');
    z0.RowSpan=[1,1];
    z0.ColSpan=[lwidget,rwidget];

    z0prompt=rfblksGetLeafWidgetBase('text','Characteristic impedance (ohms):',...
    'Z0Prompt',0);
    z0prompt.RowSpan=[1,1];
    z0prompt.ColSpan=[lprompt,rprompt];


    pv=rfblksGetLeafWidgetBase('edit','','PV',this,'PV');
    pv.RowSpan=[2,2];
    pv.ColSpan=[lwidget,rwidget];

    pvprompt=rfblksGetLeafWidgetBase('text','Phase velocity (m/s):',...
    'PVPrompt',0);
    pvprompt.RowSpan=[2,2];
    pvprompt.ColSpan=[lprompt,rprompt];


    loss=rfblksGetLeafWidgetBase('edit','','Loss',this,'Loss');
    loss.RowSpan=[3,3];
    loss.ColSpan=[lwidget,rwidget];

    lossprompt=rfblksGetLeafWidgetBase('text','Loss (dB/m):',...
    'LossPrompt',0);
    lossprompt.RowSpan=[3,3];
    lossprompt.ColSpan=[lprompt,rprompt];


    paramFreq=rfblksGetLeafWidgetBase('edit','','ParamFreq',this,'ParamFreq');
    paramFreq.RowSpan=[4,4];
    paramFreq.ColSpan=[lwidget,rwidget];

    paramFreqprompt=rfblksGetLeafWidgetBase('text','Frequency (Hz):',...
    'ParamFreqPrompt',0);
    paramFreqprompt.RowSpan=[4,4];
    paramFreqprompt.ColSpan=[lprompt,rprompt];


    interpMethod=rfblksGetLeafWidgetBase('combobox','','InterpMethod',this,'InterpMethod');
    interpMethod.RowSpan=[5,5];
    interpMethod.ColSpan=[lwidget,rwidget];
    interpMethod.Entries=set(this,'InterpMethod')';

    interpMethodprompt=rfblksGetLeafWidgetBase('text','Interpolation method:',...
    'InterpMethodPrompt',0);
    interpMethodprompt.RowSpan=[5,5];
    interpMethodprompt.ColSpan=[lprompt,rprompt];


    lineLength=rfblksGetLeafWidgetBase('edit','','LineLength',this,'LineLength');
    lineLength.RowSpan=[6,6];
    lineLength.ColSpan=[lwidget,rwidget];

    lineLengthprompt=rfblksGetLeafWidgetBase('text','Transmission line length (m):',...
    'LineLengthPrompt',0);
    lineLengthprompt.RowSpan=[6,6];
    lineLengthprompt.ColSpan=[lprompt,rprompt];


    stubMode=rfblksGetLeafWidgetBase('combobox','','StubMode',this,'StubMode');
    stubMode.RowSpan=[7,7];
    stubMode.ColSpan=[lwidget,rwidget];
    stubMode.Entries=set(this,'StubMode')';
    stubMode.DialogRefresh=1;

    stubModeprompt=rfblksGetLeafWidgetBase('text','Stub mode:',...
    'StubModePrompt',0);
    stubModeprompt.RowSpan=[7,7];
    stubModeprompt.ColSpan=[lprompt,rprompt];


    termination=rfblksGetLeafWidgetBase('combobox','','Termination',this,'Termination');
    termination.RowSpan=[8,8];
    termination.ColSpan=[lwidget,rwidget];
    termination.Entries=set(this,'Termination')';

    terminationprompt=rfblksGetLeafWidgetBase('text','Termination of stub:',...
    'TerminationPrompt',0);
    terminationprompt.RowSpan=[8,8];
    terminationprompt.ColSpan=[lprompt,rprompt];


    if strcmpi(this.StubMode,'Not a stub')
        termination.Enabled=0;
    else
        termination.Enabled=1;
    end

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[9,9];
    spacerMain.ColSpan=[lprompt,rprompt];


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');



    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={lineLength,lineLengthprompt,stubMode,stubModeprompt,...
    termination,terminationprompt,z0,z0prompt,pv,pvprompt,loss,...
    lossprompt,paramFreq,paramFreqprompt,interpMethod,...
    spacerMain,interpMethodprompt};
    mainPane.LayoutGrid=[9,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[zeros(1,8),1];


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


