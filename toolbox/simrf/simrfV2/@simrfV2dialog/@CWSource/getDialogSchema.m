function dlgStruct=getDialogSchema(this,~)








    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;
    number_grid=20;



    rs=1;
    sourcetype=simrfV2GetLeafWidgetBase('combobox','','CWSourceType',...
    this,'CWSourceType');
    sourcetype.Entries=set(this,'CWSourceType')';
    sourcetype.RowSpan=[rs,rs];
    sourcetype.ColSpan=[ledit,runit];
    sourcetype.DialogRefresh=1;

    sourcetypeprompt=simrfV2GetLeafWidgetBase('text','Source type:',...
    'SourceTypePrompt',0);
    sourcetypeprompt.RowSpan=[rs,rs];
    sourcetypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    z0=simrfV2GetLeafWidgetBase('edit','','Z0',this,'Z0');
    z0.RowSpan=[rs,rs];
    z0.ColSpan=[ledit,redit];

    z0prompt=simrfV2GetLeafWidgetBase('text','Source impedance (Ohm):',...
    'Z0Prompt',0);
    z0prompt.RowSpan=[rs,rs];
    z0prompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    ivoltage=simrfV2GetLeafWidgetBase('edit','','IVoltage',this,'IVoltage');
    ivoltage.RowSpan=[rs,rs];
    ivoltage.ColSpan=[ledit,redit];

    icurrent=simrfV2GetLeafWidgetBase('edit','','ICurrent',this,'ICurrent');
    icurrent.RowSpan=[rs,rs];
    icurrent.ColSpan=[ledit,redit];

    magpower=simrfV2GetLeafWidgetBase('edit','','MagPower',this,'MagPower');
    magpower.RowSpan=[rs,rs];
    magpower.ColSpan=[ledit,redit];

    ivoltageunit=simrfV2GetLeafWidgetBase('combobox','','IVoltage_unit',...
    this,'IVoltage_unit');
    ivoltageunit.Entries=set(this,'IVoltage_unit')';
    ivoltageunit.RowSpan=[rs,rs];
    ivoltageunit.ColSpan=[lunit,runit];

    icurrentunit=simrfV2GetLeafWidgetBase('combobox','','ICurrent_unit',...
    this,'ICurrent_unit');
    icurrentunit.Entries=set(this,'ICurrent_unit')';
    icurrentunit.RowSpan=[rs,rs];
    icurrentunit.ColSpan=[lunit,runit];

    powerunit=simrfV2GetLeafWidgetBase('combobox','','MagPower_unit',...
    this,'MagPower_unit');
    powerunit.Entries=set(this,'MagPower_unit')';
    powerunit.RowSpan=[rs,rs];
    powerunit.ColSpan=[lunit,runit];

    ivalprompt=simrfV2GetLeafWidgetBase('text','Constant in-phase value:',...
    'IValPrompt',0);
    ivalprompt.RowSpan=[rs,rs];
    ivalprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    qvoltage=simrfV2GetLeafWidgetBase('edit','','QVoltage',this,'QVoltage');
    qvoltage.RowSpan=[rs,rs];
    qvoltage.ColSpan=[ledit,redit];

    qcurrent=simrfV2GetLeafWidgetBase('edit','','QCurrent',this,'QCurrent');
    qcurrent.RowSpan=[rs,rs];
    qcurrent.ColSpan=[ledit,redit];

    anglepower=simrfV2GetLeafWidgetBase('edit','','AnglePower',this,'AnglePower');
    anglepower.RowSpan=[rs,rs];
    anglepower.ColSpan=[ledit,redit];

    qvoltageunit=simrfV2GetLeafWidgetBase('combobox','','QVoltage_unit',...
    this,'QVoltage_unit');
    qvoltageunit.Entries=set(this,'QVoltage_unit')';
    qvoltageunit.RowSpan=[rs,rs];
    qvoltageunit.ColSpan=[lunit,runit];

    qcurrentunit=simrfV2GetLeafWidgetBase('combobox','','QCurrent_unit',...
    this,'QCurrent_unit');
    qcurrentunit.Entries=set(this,'QCurrent_unit')';
    qcurrentunit.RowSpan=[rs,rs];
    qcurrentunit.ColSpan=[lunit,runit];

    qvalprompt=simrfV2GetLeafWidgetBase('text','Constant quadrature value:',...
    'QValPrompt',0);
    qvalprompt.RowSpan=[rs,rs];
    qvalprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Carrier frequencies:',...
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
    'AutoImpulseLength',this,'AutoImpulseLength');
    autoimp.RowSpan=[rs,rs];
    autoimp.ColSpan=[lprompt,redit];
    autoimp.DialogRefresh=1;


    rs=rs+1;
    imprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','ImpulseLengthprompt',0);
    imprespprompt.RowSpan=[rs,rs];
    imprespprompt.ColSpan=[lprompt,ledit];

    impresp=simrfV2GetLeafWidgetBase('edit','','ImpulseLength',this,...
    'ImpulseLength');
    impresp.RowSpan=[rs,rs];
    impresp.ColSpan=[ledit,redit];

    imprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    'ImpulseLength_unit',this,'ImpulseLength_unit');
    imprespunit.Entries=set(this,'ImpulseLength_unit')';
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
    grounding=simrfV2GetLeafWidgetBase('checkbox','Ground and hide negative terminal',...
    'InternalGrounding',this,'InternalGrounding');
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
    slBlkVis([...
    idxMaskNames.PhaseNoiseOffset...
    ,idxMaskNames.PhaseNoiseLevel...
    ,idxMaskNames.AutoImpulseLength...
    ,idxMaskNames.ImpulseLength...
    ,idxMaskNames.ImpulseLength_unit])={'off'};

    switch this.CWSourceType
    case 'Ideal voltage'
        ivoltage.Visible=1;
        ivoltageunit.Visible=1;
        icurrent.Visible=0;
        icurrentunit.Visible=0;
        magpower.Visible=0;
        powerunit.Visible=0;

        qvoltage.Visible=1;
        qvoltageunit.Visible=1;
        qcurrent.Visible=0;
        qcurrentunit.Visible=0;
        anglepower.Visible=0;
        this.Z0='0';
        z0.Visible=0;
        z0prompt.Visible=0;

    case 'Ideal current'
        ivoltage.Visible=0;
        ivoltageunit.Visible=0;
        icurrent.Visible=1;
        icurrentunit.Visible=1;
        magpower.Visible=0;
        powerunit.Visible=0;

        qvoltage.Visible=0;
        qvoltageunit.Visible=0;
        qcurrent.Visible=1;
        qcurrentunit.Visible=1;
        anglepower.Visible=0;
        this.Z0='Inf';
        z0.Visible=0;
        z0prompt.Visible=0;

    case 'Power'
        ivoltage.Visible=0;
        ivoltageunit.Visible=0;
        icurrent.Visible=0;
        icurrentunit.Visible=0;
        magpower.Visible=1;
        powerunit.Visible=1;

        qvoltage.Visible=0;
        qvoltageunit.Visible=0;
        qcurrent.Visible=0;
        qcurrentunit.Visible=0;
        anglepower.Visible=1;

        ivalprompt.Name='Available power:';
        qvalprompt.Name='Angle (degrees):';

        z0.Visible=1;
        z0prompt.Visible=1;
        if isinf(str2double(this.Z0))||isequal(str2double(this.Z0),0)
            this.Z0='50';
        end
    end
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
        phasenoiselevelprompt.Visible=1;
        phasenoiselevel.Visible=1;
        autoimp.Visible=1;
        plotbutton.Visible=1;
        slBlkVis([...
        idxMaskNames.PhaseNoiseOffset...
        ,idxMaskNames.PhaseNoiseLevel...
        ,idxMaskNames.AutoImpulseLength])={'on'};
        if~this.AutoImpulseLength
            imprespprompt.Visible=1;
            impresp.Visible=1;
            imprespunit.Visible=1;
            slBlkVis([...
            idxMaskNames.ImpulseLength...
            ,idxMaskNames.ImpulseLength_unit])={'on'};
        end
    end


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end






    mainParamsPanel.Type='group';
    mainParamsPanel.Name='Parameters';
    mainParamsPanel.Tag='mainParamsPanel';
    mainParamsPanel.Items={sourcetype,sourcetypeprompt,z0,z0prompt,freqprompt,...
    freq,frequnit,ivoltage,icurrent,magpower,ivoltageunit,icurrentunit,...
    powerunit,ivalprompt,qvoltage,qcurrent,anglepower,qvoltageunit,...
    qcurrentunit,qvalprompt,addphasenoise,phasenoiseoffsetprompt,...
    phasenoiseoffset,phasenoiselevelprompt,phasenoiselevel,...
    autoimp,imprespprompt,impresp,imprespunit,plotbutton,...
    grounding,spacerMain};
    mainParamsPanel.LayoutGrid=[maxrows,number_grid];
    mainParamsPanel.ColStretch=[0,0,0,0,ones(1,14),0,0];
    mainParamsPanel.RowSpan=[2,2];
    mainParamsPanel.ColSpan=[1,1];


    dlgStruct=getBaseSchemaStruct(this,mainParamsPanel);

