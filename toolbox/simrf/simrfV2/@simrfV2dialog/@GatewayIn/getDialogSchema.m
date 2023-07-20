function dlgStruct=getDialogSchema(this,~)





    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;


    rs=1;

    sourcetype=simrfV2GetLeafWidgetBase('combobox','','SimulinkInputSignalType',...
    this,'SimulinkInputSignalType');
    sourcetype.Entries=set(this,'SimulinkInputSignalType')';
    sourcetype.RowSpan=[rs,rs];
    sourcetype.ColSpan=[ledit,runit];
    sourcetype.DialogRefresh=1;

    sourcetypeprompt=simrfV2GetLeafWidgetBase('text','Source type:',...
    'SimulinkInputSignalTypePrompt',0);
    sourcetypeprompt.RowSpan=[rs,rs];
    sourcetypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    ZSprompt=simrfV2GetLeafWidgetBase('text','Source impedance (Ohm):',...
    'ZSPrompt',0);
    ZSprompt.RowSpan=[rs,rs];
    ZSprompt.ColSpan=[lprompt,rprompt];

    ZS=simrfV2GetLeafWidgetBase('edit','','ZS',this,'ZS');
    ZS.RowSpan=[rs,rs];
    ZS.ColSpan=[ledit,redit];


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Carrier frequencies:   ',...
    'CarrierFreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt,rprompt];

    freq=simrfV2GetLeafWidgetBase('edit','','CarrierFreq',0,'CarrierFreq');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[ledit,redit];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','CarrierFreq_unit',...
    this,'CarrierFreq_unit');
    frequnit.Entries=set(this,'CarrierFreq_unit')';
    frequnit.RowSpan=[rs,rs];
    frequnit.ColSpan=[lunit,runit];


    rs=rs+1;
    useSqWave=simrfV2GetLeafWidgetBase('checkbox','Use Square Wave',...
    'UseSqWave',this,'UseSqWave');
    useSqWave.RowSpan=[rs,rs];
    useSqWave.ColSpan=[lprompt,runit];
    useSqWave.DialogRefresh=1;


    plotbutton=...
    simrfV2GetLeafWidgetBase('pushbutton','View','PlotButton',this);
    plotbutton.RowSpan=[rs,rs];
    plotbutton.ColSpan=[ledit,runit];

    plotbutton.MatlabMethod='simrfV2_plot_square_wave';
    plotbutton.MatlabArgs={'%source'};


    rs=rs+1;
    numCoeffPrompt=simrfV2GetLeafWidgetBase('text','Number of Fourier Coefficients:',...
    'numCoeffPrompt',0);
    numCoeffPrompt.RowSpan=[rs,rs];
    numCoeffPrompt.ColSpan=[lprompt,rprompt];

    numCoeff=simrfV2GetLeafWidgetBase('edit','','NumCoeff',this,'NumCoeff');
    numCoeff.RowSpan=[rs,rs];
    numCoeff.ColSpan=[ledit,redit];


    rs=rs+1;
    biasPrompt=simrfV2GetLeafWidgetBase('text','DC Bias:','biasPrompt',0);
    biasPrompt.RowSpan=[rs,rs];
    biasPrompt.ColSpan=[lprompt,rprompt];

    bias=simrfV2GetLeafWidgetBase('edit','','Bias',this,'Bias');
    bias.RowSpan=[rs,rs];
    bias.ColSpan=[ledit,redit];


    rs=rs+1;
    dutyCycPrompt=simrfV2GetLeafWidgetBase('text','Duty Cycle (%):','dutyCycPrompt',0);
    dutyCycPrompt.RowSpan=[rs,rs];
    dutyCycPrompt.ColSpan=[lprompt,rprompt];

    dutyCyc=simrfV2GetLeafWidgetBase('edit','','DutyCyc',this,'DutyCyc');
    dutyCyc.RowSpan=[rs,rs];
    dutyCyc.ColSpan=[ledit,redit];



    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox','Ground and hide negative terminal',...
    'InternalGrounding',this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);



    switch lower(this.SimulinkInputSignalType)
    case 'ideal voltage'
        grounding.Visible=1;
        this.ZS='0';
        ZSprompt.Visible=0;
        ZS.Visible=0;
    case 'ideal current'
        grounding.Visible=1;
        this.ZS='Inf';
        ZSprompt.Visible=0;
        ZS.Visible=0;
    case 'power'
        grounding.Visible=1;
        if isinf(str2double(this.ZS))||isequal(str2double(this.ZS),0)
            this.ZS='50';
        end
        ZSprompt.Visible=1;
        ZS.Visible=1;
    end



    if this.UseSqWave
        numCoeffPrompt.Visible=1;
        numCoeff.Visible=1;
        biasPrompt.Visible=1;
        bias.Visible=1;
        dutyCycPrompt.Visible=1;
        dutyCyc.Visible=1;
        plotbutton.Enabled=true;
    else
        numCoeffPrompt.Visible=0;
        numCoeff.Visible=0;
        biasPrompt.Visible=0;
        bias.Visible=0;
        dutyCycPrompt.Visible=0;
        dutyCyc.Visible=0;
        plotbutton.Enabled=false;
    end





    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';

    mainParamsPanel.Items={sourcetype,sourcetypeprompt,ZS,freqprompt,...
    freq,frequnit,useSqWave,biasPrompt,bias,dutyCycPrompt,dutyCyc,...
    numCoeffPrompt,numCoeff,plotbutton,grounding,ZSprompt,spacerMain};

    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);



