function dlgStruct=getDialogSchema(this,~)





    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    leditImpResDur=ledit+2;
    redit=15;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    rs=1;
    sourcetype=simrfV2GetLeafWidgetBase('combobox','',...
    'SimulinkInputSignalType',this,'SimulinkInputSignalType');
    sourcetype.Entries=set(this,'SimulinkInputSignalType')';
    sourcetype.RowSpan=[rs,rs];
    sourcetype.ColSpan=[ledit,runit];
    sourcetype.DialogRefresh=1;

    sourcetypeprompt=simrfV2GetLeafWidgetBase('text','Source type:',...
    'SimulinkInputSignalTypePrompt',0);
    sourcetypeprompt.RowSpan=[rs,rs];
    sourcetypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    noisetype=simrfV2GetLeafWidgetBase('combobox','','NoiseType',...
    this,'NoiseType');
    noisetype.Entries=set(this,'NoiseType')';
    noisetype.RowSpan=[rs,rs];
    noisetype.ColSpan=[ledit,runit];
    noisetype.DialogRefresh=1;

    noisetypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Noise distribution:','NoiseTypePrompt',0);
    noisetypeprompt.RowSpan=[rs,rs];
    noisetypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    if strcmpi(this.SimulinkInputSignalType,'Ideal voltage')
        psdprompt=simrfV2GetLeafWidgetBase('text',...
        sprintf('Noise power spectral\n density (V^2/Hz):'),...
        'PSDPrompt',0);
    elseif strcmpi(this.SimulinkInputSignalType,'Ideal current')
        psdprompt=simrfV2GetLeafWidgetBase('text',...
        sprintf('Noise power spectral\n density (A^2/Hz):'),...
        'PSDPrompt',0);
    end
    psdprompt.RowSpan=[rs,rs];
    psdprompt.ColSpan=[lprompt,rprompt];

    psd=simrfV2GetLeafWidgetBase('edit','','NoisePSD',this,'NoisePSD');
    psd.RowSpan=[rs,rs];
    psd.ColSpan=[ledit,runit];


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Frequencies:',...
    'CarrierFreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt,rprompt];

    freq=simrfV2GetLeafWidgetBase('edit','','CarrierFreq',0,...
    'CarrierFreq');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[ledit,redit];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','CarrierFreq_unit',...
    this,'CarrierFreq_unit');
    frequnit.Entries=set(this,'CarrierFreq_unit')';
    frequnit.RowSpan=[rs,rs];
    frequnit.ColSpan=[lunit,runit];


    rs=rs+1;
    autoimp=simrfV2GetLeafWidgetBase('checkbox',...
    'Automatically estimate impulse response duration',...
    'AutoImpulseLength',this,'AutoImpulseLength');
    autoimp.RowSpan=[rs,rs];
    autoimp.ColSpan=[lprompt,redit];
    autoimp.DialogRefresh=1;


    rs=rs+1;
    imprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','ImpulseLengthprompt',0);
    imprespprompt.RowSpan=[rs,rs];
    imprespprompt.ColSpan=[lprompt,leditImpResDur];

    impresp=simrfV2GetLeafWidgetBase('edit','','ImpulseLength',this,...
    'ImpulseLength');
    impresp.RowSpan=[rs,rs];
    impresp.ColSpan=[leditImpResDur,redit];

    imprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    'ImpulseLength_unit',this,'ImpulseLength_unit');
    imprespunit.Entries=set(this,'ImpulseLength_unit')';
    imprespunit.RowSpan=[rs,rs];
    imprespunit.ColSpan=[lunit,runit];


    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminal','InternalGrounding',this,...
    'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);


    hBlk=get_param(this,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');
    slBlkVis(idxMaskNames.CarrierFreq)={'off'};
    autoimp.Visible=0;
    imprespprompt.Visible=0;
    impresp.Visible=0;
    imprespunit.Visible=0;
    switch this.Noisetype
    case 'White'
        freq.Visible=0;
        freqprompt.Visible=0;
        frequnit.Visible=0;
    case{'Piece-wise linear'}
        freq.Visible=1;
        freqprompt.Visible=1;
        frequnit.Visible=1;
        slBlkVis(idxMaskNames.CarrierFreq)={'on'};
    case{'Colored'}
        freq.Visible=1;
        freqprompt.Visible=1;
        frequnit.Visible=1;
        slBlkVis(idxMaskNames.CarrierFreq)={'on'};
        autoimp.Visible=1;
        if~this.AutoImpulseLength
            imprespprompt.Visible=1;
            impresp.Visible=1;
            imprespunit.Visible=1;
        end

    end

    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);
    end



    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={sourcetype,sourcetypeprompt,noisetype,...
    noisetypeprompt,psdprompt,psd,freqprompt,freq,frequnit,...
    autoimp,imprespprompt,impresp,imprespunit,...
    grounding,spacerMain};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

