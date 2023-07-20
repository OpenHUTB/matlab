function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;



    conductorWidth=rfblksGetLeafWidgetBase('edit','','ConductorWidth',...
    this,'ConductorWidth');
    conductorWidth.RowSpan=[1,1];
    conductorWidth.ColSpan=[lwidget,rwidget];

    conductorWidthprompt=rfblksGetLeafWidgetBase('text','Conductor width (m):',...
    'ConductorWidthPrompt',0);
    conductorWidthprompt.RowSpan=[1,1];
    conductorWidthprompt.ColSpan=[lprompt,rprompt];


    slotWidth=rfblksGetLeafWidgetBase('edit','','SlotWidth',...
    this,'SlotWidth');
    slotWidth.RowSpan=[2,2];
    slotWidth.ColSpan=[lwidget,rwidget];

    slotWidthprompt=rfblksGetLeafWidgetBase('text','Slot width (m):',...
    'SlotWidthPrompt',0);
    slotWidthprompt.RowSpan=[2,2];
    slotWidthprompt.ColSpan=[lprompt,rprompt];


    height=rfblksGetLeafWidgetBase('edit','','Height',this,'Height');
    height.RowSpan=[3,3];
    height.ColSpan=[lwidget,rwidget];

    heightprompt=rfblksGetLeafWidgetBase('text','Substrate height (m):',...
    'HeightPrompt',0);
    heightprompt.RowSpan=[3,3];
    heightprompt.ColSpan=[lprompt,rprompt];


    thickness=rfblksGetLeafWidgetBase('edit','','Thickness',this,'Thickness');
    thickness.RowSpan=[4,4];
    thickness.ColSpan=[lwidget,rwidget];

    thicknessprompt=rfblksGetLeafWidgetBase('text','Strip thickness (m):',...
    'ThicknessPrompt',0);
    thicknessprompt.RowSpan=[4,4];
    thicknessprompt.ColSpan=[lprompt,rprompt];


    epsilonR=rfblksGetLeafWidgetBase('edit','','EpsilonR',this,'EpsilonR');
    epsilonR.RowSpan=[5,5];
    epsilonR.ColSpan=[lwidget,rwidget];

    epsilonRprompt=rfblksGetLeafWidgetBase('text','Relative permittivity constant:',...
    'EpsilonRPrompt',0);
    epsilonRprompt.RowSpan=[5,5];
    epsilonRprompt.ColSpan=[lprompt,rprompt];


    lossTangent=rfblksGetLeafWidgetBase('edit','','LossTangent',this,'LossTangent');
    lossTangent.RowSpan=[6,6];
    lossTangent.ColSpan=[lwidget,rwidget];

    lossTangentprompt=rfblksGetLeafWidgetBase('text','Loss tangent of dielectric:',...
    'LossTangentPrompt',0);
    lossTangentprompt.RowSpan=[6,6];
    lossTangentprompt.ColSpan=[lprompt,rprompt];


    sigmaCond=rfblksGetLeafWidgetBase('edit','','SigmaCond',this,'SigmaCond');
    sigmaCond.RowSpan=[7,7];
    sigmaCond.ColSpan=[lwidget,rwidget];

    sigmaCondprompt=rfblksGetLeafWidgetBase('text','Conductivity of conductor (S/m):',...
    'SigmaCondPrompt',0);
    sigmaCondprompt.RowSpan=[7,7];
    sigmaCondprompt.ColSpan=[lprompt,rprompt];


    lineLength=rfblksGetLeafWidgetBase('edit','','LineLength',this,'LineLength');
    lineLength.RowSpan=[8,8];
    lineLength.ColSpan=[lwidget,rwidget];

    lineLengthprompt=rfblksGetLeafWidgetBase('text','Transmission line length (m):',...
    'LineLengthPrompt',0);
    lineLengthprompt.RowSpan=[8,8];
    lineLengthprompt.ColSpan=[lprompt,rprompt];


    stubMode=rfblksGetLeafWidgetBase('combobox','','StubMode',this,'StubMode');
    stubMode.RowSpan=[9,9];
    stubMode.ColSpan=[lwidget,rwidget];
    stubMode.Entries=set(this,'StubMode')';
    stubMode.DialogRefresh=1;

    stubModeprompt=rfblksGetLeafWidgetBase('text','Stub mode:',...
    'StubModePrompt',0);
    stubModeprompt.RowSpan=[9,9];
    stubModeprompt.ColSpan=[lprompt,rprompt];


    termination=rfblksGetLeafWidgetBase('combobox','','Termination',this,'Termination');
    termination.RowSpan=[10,10];
    termination.ColSpan=[lwidget,rwidget];
    termination.Entries=set(this,'Termination')';

    terminationprompt=rfblksGetLeafWidgetBase('text','Termination of stub:',...
    'TerminationPrompt',0);
    terminationprompt.RowSpan=[10,10];
    terminationprompt.ColSpan=[lprompt,rprompt];


    if strcmpi(this.StubMode,'Not a stub')
        termination.Enabled=0;
    else
        termination.Enabled=1;
    end

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[11,11];
    spacerMain.ColSpan=[lprompt,rprompt];


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');



    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={conductorWidth,slotWidth,height,epsilonR,lossTangent,...
    sigmaCond,lineLength,stubMode,termination,conductorWidthprompt,...
    slotWidthprompt,heightprompt,epsilonRprompt,lossTangentprompt,...
    sigmaCondprompt,lineLengthprompt,stubModeprompt,terminationprompt,...
    thickness,thicknessprompt,spacerMain};
    mainPane.LayoutGrid=[11,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[zeros(1,10),1];


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

