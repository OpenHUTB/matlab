function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    res=rfblksGetLeafWidgetBase('edit','','R',this,'R');
    res.RowSpan=[1,1];
    res.ColSpan=[lwidget,rwidget];

    resprompt=rfblksGetLeafWidgetBase('text','Resistance per length (ohms/m):',...
    'RPrompt',0);
    resprompt.RowSpan=[1,1];
    resprompt.ColSpan=[lprompt,rprompt];


    ind=rfblksGetLeafWidgetBase('edit','','L',this,'L');
    ind.RowSpan=[2,2];
    ind.ColSpan=[lwidget,rwidget];

    indprompt=rfblksGetLeafWidgetBase('text','Inductance per length (H/m):',...
    'LPrompt',0);
    indprompt.RowSpan=[2,2];
    indprompt.ColSpan=[lprompt,rprompt];


    cap=rfblksGetLeafWidgetBase('edit','','C',this,'C');
    cap.RowSpan=[3,3];
    cap.ColSpan=[lwidget,rwidget];

    capprompt=rfblksGetLeafWidgetBase('text','Capacitance per length (F/m):',...
    'CPrompt',0);
    capprompt.RowSpan=[3,3];
    capprompt.ColSpan=[lprompt,rprompt];


    cond=rfblksGetLeafWidgetBase('edit','','G',this,'G');
    cond.RowSpan=[4,4];
    cond.ColSpan=[lwidget,rwidget];

    condprompt=rfblksGetLeafWidgetBase('text','Conductance per length (S/m):',...
    'GPrompt',0);
    condprompt.RowSpan=[4,4];
    condprompt.ColSpan=[lprompt,rprompt];


    paramFreq=rfblksGetLeafWidgetBase('edit','','ParamFreq',this,'ParamFreq');
    paramFreq.RowSpan=[5,5];
    paramFreq.ColSpan=[lwidget,rwidget];

    paramFreqprompt=rfblksGetLeafWidgetBase('text','Frequency (Hz):',...
    'ParamFreqPrompt',0);
    paramFreqprompt.RowSpan=[5,5];
    paramFreqprompt.ColSpan=[lprompt,rprompt];


    interpMethod=rfblksGetLeafWidgetBase('combobox','','InterpMethod',this,'InterpMethod');
    interpMethod.RowSpan=[6,6];
    interpMethod.ColSpan=[lwidget,rwidget];
    interpMethod.Entries=set(this,'InterpMethod')';

    interpMethodprompt=rfblksGetLeafWidgetBase('text','Interpolation method:',...
    'InterpMethodPrompt',0);
    interpMethodprompt.RowSpan=[6,6];
    interpMethodprompt.ColSpan=[lprompt,rprompt];


    lineLength=rfblksGetLeafWidgetBase('edit','','LineLength',this,'LineLength');
    lineLength.RowSpan=[7,7];
    lineLength.ColSpan=[lwidget,rwidget];

    lineLengthprompt=rfblksGetLeafWidgetBase('text','Transmission line length (m):',...
    'LineLengthPrompt',0);
    lineLengthprompt.RowSpan=[7,7];
    lineLengthprompt.ColSpan=[lprompt,rprompt];


    stubMode=rfblksGetLeafWidgetBase('combobox','','StubMode',this,'StubMode');
    stubMode.RowSpan=[8,8];
    stubMode.ColSpan=[lwidget,rwidget];
    stubMode.Entries=set(this,'StubMode')';
    stubMode.DialogRefresh=1;

    stubModeprompt=rfblksGetLeafWidgetBase('text','Stub mode:',...
    'StubModePrompt',0);
    stubModeprompt.RowSpan=[8,8];
    stubModeprompt.ColSpan=[lprompt,rprompt];


    termination=rfblksGetLeafWidgetBase('combobox','','Termination',this,'Termination');
    termination.RowSpan=[9,9];
    termination.ColSpan=[lwidget,rwidget];
    termination.Entries=set(this,'Termination')';

    terminationprompt=rfblksGetLeafWidgetBase('text','Termination of stub:',...
    'TerminationPrompt',0);
    terminationprompt.RowSpan=[9,9];
    terminationprompt.ColSpan=[lprompt,rprompt];


    if strcmpi(this.StubMode,'Not a stub')
        termination.Enabled=0;
    else
        termination.Enabled=1;
    end

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[10,10];
    spacerMain.ColSpan=[lprompt,rprompt];


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');



    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={lineLength,lineLengthprompt,stubMode,stubModeprompt,...
    termination,terminationprompt,res,resprompt,ind,indprompt,cap,...
    capprompt,cond,condprompt,paramFreq,paramFreqprompt,...
    interpMethod,interpMethodprompt,spacerMain};
    mainPane.LayoutGrid=[10,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[zeros(1,9),1];


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


