function dlgStruct=getDialogSchema(this,dummy)









    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;

    maxrows=0;




    simulinksignalis=rfblksGetLeafWidgetBase('combobox','','TreatSimulinkInputSignalAs',...
    this,'TreatSimulinkInputSignalAs');
    simulinksignalis.Entries=set(this,'TreatSimulinkInputSignalAs')';
    simulinksignalis.RowSpan=[1,1];
    simulinksignalis.ColSpan=[lwidget,rwidget];

    simulinksignalisprompt=rfblksGetLeafWidgetBase('text','Treat input Simulink signal as:',...
    'TreatSimulinkInputSignalAsPrompt',0);
    simulinksignalisprompt.RowSpan=[1,1];
    simulinksignalisprompt.ColSpan=[lprompt,rprompt];


    zs=rfblksGetLeafWidgetBase('edit','','Zs',this,'Zs');
    zs.RowSpan=[2,2];
    zs.ColSpan=[lwidget,rwidget];

    zsprompt=rfblksGetLeafWidgetBase('text','Source impedance (ohms):',...
    'ZsPrompt',0);
    zsprompt.RowSpan=[2,2];
    zsprompt.ColSpan=[lprompt,rprompt];


    maxLength=rfblksGetLeafWidgetBase('edit','','MaxLength',this,'MaxLength');
    maxLength.RowSpan=[3,3];
    maxLength.ColSpan=[lwidget,rwidget];

    maxLengthprompt=rfblksGetLeafWidgetBase('text',...
    'Finite impulse response filter length:','MaxLengthPrompt',0);
    maxLengthprompt.RowSpan=[3,3];
    maxLengthprompt.ColSpan=[lprompt,rprompt];


    fracbw=rfblksGetLeafWidgetBase('edit','','FracBW',this,'FracBW');
    fracbw.RowSpan=[4,4];
    fracbw.ColSpan=[lwidget,rwidget];

    fracbwprompt=rfblksGetLeafWidgetBase('text','Fractional bandwidth of guard bands:',...
    'FracBWPrompt',0);
    fracbwprompt.RowSpan=[4,4];
    fracbwprompt.ColSpan=[lprompt,rprompt];


    modeldelay=rfblksGetLeafWidgetBase('edit','','ModelDelay',this,'ModelDelay');
    modeldelay.RowSpan=[5,5];
    modeldelay.ColSpan=[lwidget,rwidget];

    modeldelayprompt=rfblksGetLeafWidgetBase('text','Modeling delay (samples):',...
    'ModelDelayPrompt',0);
    modeldelayprompt.RowSpan=[5,5];
    modeldelayprompt.ColSpan=[lprompt,rprompt];


    fc=rfblksGetLeafWidgetBase('edit','','Fc',this,'Fc');
    fc.RowSpan=[6,6];
    fc.ColSpan=[lwidget,rwidget];

    fcprompt=rfblksGetLeafWidgetBase('text','Center frequency (Hz):',...
    'FcPrompt',0);
    fcprompt.RowSpan=[6,6];
    fcprompt.ColSpan=[lprompt,rprompt];


    ts=rfblksGetLeafWidgetBase('edit','','Ts',this,'Ts');
    ts.RowSpan=[7,7];
    ts.ColSpan=[lwidget,rwidget];

    tsprompt=rfblksGetLeafWidgetBase('text','Sample time (s):',...
    'TsPrompt',0);
    tsprompt.RowSpan=[7,7];
    tsprompt.ColSpan=[lprompt,rprompt];


    custRFhasDSP=rfblksGetLeafWidgetBase('combobox','','RFhasDSP',this,'RFhasDSP');
    custRFhasDSP.Entries=set(this,'RFhasDSP')';
    custRFhasDSP.RowSpan=[8,8];
    custRFhasDSP.ColSpan=[lwidget,rwidget];

    custRFhasDSPprompt=rfblksGetLeafWidgetBase('text','Input processing:',...
    'RFhasDSPPrompt',0);
    custRFhasDSPprompt.RowSpan=[8,8];
    custRFhasDSPprompt.ColSpan=[lprompt,rprompt];


    if builtin('license','test','Signal_Blocks')
        custRFhasDSP.Enabled=1;
    else
        custRFhasDSP.Enabled=0;
    end


    noiseFlag=rfblksGetLeafWidgetBase('checkbox','Add noise','NoiseFlag',this,'NoiseFlag');
    noiseFlag.RowSpan=[9,9];
    noiseFlag.ColSpan=[lprompt,rwidget];
    noiseFlag.DialogRefresh=1;


    seed=rfblksGetLeafWidgetBase('edit','','seed',this,'seed');
    seed.RowSpan=[10,10];
    seed.ColSpan=[lwidget+1,rwidget];

    seedprompt=rfblksGetLeafWidgetBase('text','Initial seed:',...
    'SeedPrompt',0);
    seedprompt.RowSpan=[10,10];
    seedprompt.ColSpan=[lprompt+1,rprompt];

    maxrows=max([maxrows,seed.RowSpan(1)]);


    if builtin('license','test','Signal_Blocks')
        custRFhasDSP.Enabled=1;
    else
        custRFhasDSP.Enabled=0;
    end


    if this.NoiseFlag
        seed.Enabled=1;
    else
        seed.Enabled=0;
    end




    mainParamsPanel=rfblksGetContainerWidgetBase('group','Parameters','mainParamsPanel');
    mainParamsPanel.Items={simulinksignalis,simulinksignalisprompt,zs,zsprompt,...
    maxLength,maxLengthprompt,fracbw,fracbwprompt,modeldelay,modeldelayprompt,...
    fc,fcprompt,ts,tsprompt,custRFhasDSP,custRFhasDSPprompt,noiseFlag,seed,seedprompt};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);


