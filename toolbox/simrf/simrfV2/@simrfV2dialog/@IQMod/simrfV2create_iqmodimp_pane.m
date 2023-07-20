function[items,layout,slBlkVis]=simrfV2create_iqmodimp_pane(this,...
    slBlkVis,idxMaskNames,varargin)





    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=16;
    lunit=redit+1;
    number_grid=20;
    runit=number_grid;


    rs=1;
    gainmismatchprompt=simrfV2GetLeafWidgetBase('text',...
    'I/Q gain mismatch:','gainmismatchprompt',0);
    gainmismatchprompt.RowSpan=[rs,rs];
    gainmismatchprompt.ColSpan=[lprompt,rprompt];

    gainmismatch=simrfV2GetLeafWidgetBase('edit','','GainMismatch',...
    this,'GainMismatch');
    gainmismatch.RowSpan=[rs,rs];
    gainmismatch.ColSpan=[ledit,redit];

    gainmismatch_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'GainMismatch_unit',this,'GainMismatch_unit');
    gainmismatch_unit.Entries=set(this,'GainMismatch_unit')';
    gainmismatch_unit.RowSpan=[rs,rs];
    gainmismatch_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    phasemismatchprompt=simrfV2GetLeafWidgetBase('text',...
    'I/Q phase mismatch:','PhaseShiftprompt',0);
    phasemismatchprompt.RowSpan=[rs,rs];
    phasemismatchprompt.ColSpan=[lprompt,rprompt];

    phasemismatch=simrfV2GetLeafWidgetBase('edit','','PhaseMismatch',...
    this,'PhaseMismatch');
    phasemismatch.RowSpan=[rs,rs];
    phasemismatch.ColSpan=[ledit,redit];


    phasemismatch_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'PhaseMismatch_unit',this,'PhaseMismatch_unit');
    phasemismatch_unit.Entries=set(this,'PhaseMismatch_unit')';
    phasemismatch_unit.RowSpan=[rs,rs];
    phasemismatch_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    isolationprompt=simrfV2GetLeafWidgetBase('text',...
    'LO to RF isolation:','isolationprompt',0);
    isolationprompt.RowSpan=[rs,rs];
    isolationprompt.ColSpan=[lprompt,rprompt];

    isolation=simrfV2GetLeafWidgetBase('edit','','Isolation',this,...
    'Isolation');
    isolation.RowSpan=[rs,rs];
    isolation.ColSpan=[ledit,redit];

    isolation_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'Isolation_unit',this,'Isolation_unit');
    isolation_unit.Entries=set(this,'Isolation_unit')';
    isolation_unit.RowSpan=[rs,rs];
    isolation_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    NFloor=simrfV2GetLeafWidgetBase('edit','','NFloor',this,'NFloor');
    NFloor.RowSpan=[rs,rs];
    NFloor.ColSpan=[ledit,runit];

    NFloorprompt=simrfV2GetLeafWidgetBase('text','Noise floor (dBm/Hz):',...
    'NFloorprompt',0);
    NFloorprompt.RowSpan=[rs,rs];
    NFloorprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    addphasenoise=simrfV2GetLeafWidgetBase('checkbox',...
    'Add phase noise',...
    'AddPhaseNoise',this,'AddPhaseNoise');
    addphasenoise.RowSpan=[rs,rs];
    addphasenoise.ColSpan=[lprompt,redit];
    addphasenoise.DialogRefresh=1;


    rs=rs+1;
    phasenoiseoffsetprompt=simrfV2GetLeafWidgetBase('text',...
    'Phase noise frequency offset (Hz):','PhaseNoiseOffsetprompt',0);
    phasenoiseoffsetprompt.RowSpan=[rs,rs];
    phasenoiseoffsetprompt.ColSpan=[lprompt,rprompt];

    phasenoiseoffset=simrfV2GetLeafWidgetBase('edit','',...
    'PhaseNoiseOffset',this,'PhaseNoiseOffset');
    phasenoiseoffset.RowSpan=[rs,rs];
    phasenoiseoffset.ColSpan=[ledit,redit];


    rs=rs+1;
    phasenoiselevelprompt=simrfV2GetLeafWidgetBase('text',...
    'Phase noise level (dBc/Hz):','PhaseNoiseLevelprompt',0);
    phasenoiselevelprompt.RowSpan=[rs,rs];
    phasenoiselevelprompt.ColSpan=[lprompt,rprompt];

    phasenoiselevel=simrfV2GetLeafWidgetBase('edit','',...
    'PhaseNoiseLevel',this,'PhaseNoiseLevel');
    phasenoiselevel.RowSpan=[rs,rs];
    phasenoiselevel.ColSpan=[ledit,redit];


    rs=rs+1;
    autoimp=simrfV2GetLeafWidgetBase('checkbox',...
    'Automatically estimate impulse response duration',...
    'AutoImpulseLengthPN',this,'AutoImpulseLengthPN');
    autoimp.RowSpan=[rs,rs];
    autoimp.ColSpan=[lprompt,redit];
    autoimp.DialogRefresh=1;


    rs=rs+1;
    imprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','ImpulseLengthprompt',0);
    imprespprompt.RowSpan=[rs,rs];
    imprespprompt.ColSpan=[lprompt,ledit];

    impresp=simrfV2GetLeafWidgetBase('edit','','ImpulseLengthPN',this,...
    'ImpulseLengthPN');
    impresp.RowSpan=[rs,rs];
    impresp.ColSpan=[ledit,redit];

    imprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    'ImpulseLength_unitPN',this,'ImpulseLength_unitPN');
    imprespunit.Entries=set(this,'ImpulseLength_unitPN')';
    imprespunit.RowSpan=[rs,rs];
    imprespunit.ColSpan=[lunit,runit];


    rs=rs+1;
    plotbutton=simrfV2GetLeafWidgetBase('pushbutton',...
    '    Plot phase noise characteristics    ','PlotButton',this);
    plotbutton.RowSpan=[rs,rs];
    plotbutton.ColSpan=[ledit,runit];

    plotbutton.MatlabMethod='simrfV2_plot_pn_chars';
    plotbutton.MatlabArgs={'%source'};


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];


    slBlkVis([idxMaskNames.PhaseNoiseOffset...
    ,idxMaskNames.PhaseNoiseLevel...
    ,idxMaskNames.AutoImpulseLengthPN...
    ,idxMaskNames.ImpulseLengthPN...
    ,idxMaskNames.ImpulseLength_unitPN])={'off'};
    phasenoiseoffsetprompt.Visible=0;
    phasenoiseoffset.Visible=0;
    phasenoiselevelprompt.Visible=0;
    phasenoiselevel.Visible=0;
    autoimp.Visible=0;
    imprespprompt.Visible=0;
    impresp.Visible=0;
    imprespunit.Visible=0;
    plotbutton.Visible=0;
    if this.AddPhaseNoise
        phasenoiseoffsetprompt.Visible=1;
        phasenoiseoffset.Visible=1;
        slBlkVis([idxMaskNames.PhaseNoiseOffset])={'on'};
        phasenoiselevelprompt.Visible=1;
        phasenoiselevel.Visible=1;
        slBlkVis([idxMaskNames.PhaseNoiseLevel])={'on'};
        autoimp.Visible=1;
        plotbutton.Visible=1;
        slBlkVis([idxMaskNames.AutoImpulseLengthPN])={'on'};
        if~this.AutoImpulseLengthPN
            imprespprompt.Visible=1;
            impresp.Visible=1;
            slBlkVis([idxMaskNames.ImpulseLengthPN])={'on'};
            imprespunit.Visible=1;
            slBlkVis([idxMaskNames.ImpulseLength_unitPN])={'on'};
        end
    end


    items={gainmismatchprompt,gainmismatch,gainmismatch_unit,...
    phasemismatchprompt,phasemismatch,phasemismatch_unit,...
    isolationprompt,isolation,isolation_unit,...
    gainmismatch_unit,NFloor,NFloorprompt,...
    addphasenoise,phasenoiseoffsetprompt,phasenoiseoffset,...
    phasenoiselevelprompt,phasenoiselevel,...
    autoimp,imprespprompt,impresp,imprespunit,plotbutton};

    layout.LayoutGrid=[rs,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,13),1];

end

