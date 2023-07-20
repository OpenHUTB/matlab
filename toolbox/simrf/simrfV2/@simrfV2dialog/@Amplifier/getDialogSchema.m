function dlgStruct=getDialogSchema(this,~)







    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;
    lbutton=19;
    rbutton=number_grid;
    lunit=19;
    runit=number_grid;


    rs=1;

    Source_linear_gainprompt=simrfV2GetLeafWidgetBase('text',...
    'Source of amplifier gain:','Source_linear_gainPrompt',0);
    Source_linear_gainprompt.RowSpan=[rs,rs];
    Source_linear_gainprompt.ColSpan=[lprompt,rprompt];

    Source_linear_gain=simrfV2GetLeafWidgetBase('combobox','',...
    'Source_linear_gain',this,'Source_linear_gain');
    Source_linear_gain.Entries=set(this,'Source_linear_gain')';
    Source_linear_gain.RowSpan=[rs,rs];
    Source_linear_gain.ColSpan=[lwidget,runit];
    Source_linear_gain.DialogRefresh=1;


    rs=rs+1;


    line2_prompt=simrfV2GetLeafWidgetBase('text',...
    [this.Source_linear_gain,':'],'line2_prompt',0);
    line2_prompt.RowSpan=[rs,rs];
    line2_prompt.ColSpan=[lprompt,rprompt];



    linear_gain=simrfV2GetLeafWidgetBase('edit','','linear_gain',this,...
    'linear_gain');
    linear_gain.RowSpan=[rs,rs];
    linear_gain.ColSpan=[lwidget,rwidget];

    linear_gain_unit=simrfV2GetLeafWidgetBase('combobox','',...
    'linear_gain_unit',this,'linear_gain_unit');
    linear_gain_unit.Entries=set(this,'linear_gain_unit')';
    linear_gain_unit.RowSpan=[rs,rs];
    linear_gain_unit.ColSpan=[lunit,runit];


    datasource=simrfV2GetLeafWidgetBase('combobox','','DataSource',...
    this,'DataSource');
    datasource.Entries=set(this,'DataSource')';
    datasource.RowSpan=[rs,rs];
    datasource.ColSpan=[lwidget,runit];
    datasource.DialogRefresh=1;


    Poly_Coeffs=simrfV2GetLeafWidgetBase('edit','','Poly_Coeffs',this,...
    'Poly_Coeffs');
    Poly_Coeffs.RowSpan=[rs,rs];
    Poly_Coeffs.ColSpan=[lwidget,runit];


    AmAmTable=simrfV2GetLeafWidgetBase('edit','','AmAmAmPmTable',...
    this,'AmAmAmPmTable');
    AmAmTable.RowSpan=[rs,rs];
    AmAmTable.ColSpan=[lwidget,runit];


    rs=rs+1;

    Zinprompt=simrfV2GetLeafWidgetBase('text','Input impedance (Ohm):',...
    'Zinprompt',0);
    Zinprompt.RowSpan=[rs,rs];
    Zinprompt.ColSpan=[lprompt,rprompt];

    Zin=simrfV2GetLeafWidgetBase('edit','','Zin',this,'Zin');
    Zin.RowSpan=[rs,rs];
    Zin.ColSpan=[lwidget,runit];


    fileprompt=simrfV2GetLeafWidgetBase('text','Data file:',...
    'FilePrompt',0);
    fileprompt.RowSpan=[rs,rs];
    fileprompt.ColSpan=[lprompt,rprompt];

    file=simrfV2GetLeafWidgetBase('edit','','File',this,'File');
    file.RowSpan=[rs,rs];
    file.ColSpan=[lwidget,rwidget-1];

    browse=simrfV2GetLeafWidgetBase('pushbutton','Browse ...','Browse',...
    this);
    browse.RowSpan=[rs,rs];
    browse.ColSpan=[lbutton-1,rbutton];
    browse.ObjectMethod='simrfV2browsefile';
    browse.MethodArgs={'%dialog'};
    browse.ArgDataTypes={'handle'};


    if this.isNetworkObj
        extraChar=':';
    else
        extraChar='';
    end
    isnetworkobj=simrfV2GetLeafWidgetBase('checkbox',...
    ['Network-parameter object',extraChar],'isNetworkObj',...
    this,'isNetworkObj');
    isnetworkobj.RowSpan=[rs,rs];
    isnetworkobj.ColSpan=[lprompt,rprompt];
    isnetworkobj.DialogRefresh=1;

    networkobjectname=simrfV2GetLeafWidgetBase('edit','',...
    'NetworkObject',this,'NetworkObject');
    networkobjectname.RowSpan=[rs,rs];
    networkobjectname.ColSpan=[lwidget,runit];


    if this.isRationalObj
        extraChar=':';
    else
        extraChar=' ';
    end
    isrationalobj=simrfV2GetLeafWidgetBase('checkbox',...
    ['Use rational object',extraChar],'isRationalObj',...
    this,'isRationalObj');
    isrationalobj.RowSpan=[rs,rs];
    isrationalobj.ColSpan=[lprompt,rprompt];
    isrationalobj.DialogRefresh=1;

    rationalobjectname=simrfV2GetLeafWidgetBase('edit','',...
    'RationalObject',this,'RationalObject');
    rationalobjectname.RowSpan=[rs,rs];
    rationalobjectname.ColSpan=[lwidget,runit];


    rs=rs+1;

    Paramtypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Network parameter type:','ParamtypePrompt',0);
    Paramtypeprompt.RowSpan=[rs,rs];
    Paramtypeprompt.ColSpan=[lprompt,rprompt];

    Paramtype=simrfV2GetLeafWidgetBase('combobox','','Paramtype',...
    this,'Paramtype');

    Paramtype.RowSpan=[rs,rs];
    Paramtype.ColSpan=[lwidget,runit];
    Paramtype.DialogRefresh=1;
    Paramtype.MatlabMethod='simrfV2_set_netpar_defaults';
    Paramtype.MatlabArgs={'%dialog'};


    residuesprompt=simrfV2GetLeafWidgetBase('text','Residues:',...
    'ResiduesPrompt',0);
    residuesprompt.RowSpan=[rs,rs];
    residuesprompt.ColSpan=[lprompt,rprompt];

    residues=simrfV2GetLeafWidgetBase('edit','','Residues',...
    this,'Residues');
    residues.RowSpan=[rs,rs];
    residues.ColSpan=[lwidget,runit];


    Zoutprompt=simrfV2GetLeafWidgetBase('text',...
    'Output impedance (Ohm):','Zoutprompt',0);
    Zoutprompt.RowSpan=[rs,rs];
    Zoutprompt.ColSpan=[lprompt,rprompt];

    Zout=simrfV2GetLeafWidgetBase('edit','','Zout',this,'Zout');
    Zout.RowSpan=[rs,rs];
    Zout.ColSpan=[lwidget,runit];


    rs=rs+1;

    sparamprompt=simrfV2GetLeafWidgetBase('text','Network-parameters:',...
    'SparamPrompt',0);
    sparamprompt.RowSpan=[rs,rs];
    sparamprompt.ColSpan=[lprompt,rprompt];

    sparam=simrfV2GetLeafWidgetBase('edit','','Sparam',this,'Sparam');
    sparam.RowSpan=[rs,rs];
    sparam.ColSpan=[lwidget,runit];


    polesprompt=simrfV2GetLeafWidgetBase('text','Poles:','PolesPrompt',0);
    polesprompt.RowSpan=[rs,rs];
    polesprompt.ColSpan=[lprompt,rprompt];

    poles=simrfV2GetLeafWidgetBase('edit','','Poles',this,'Poles');
    poles.RowSpan=[rs,rs];
    poles.ColSpan=[lwidget,runit];


    rs=rs+1;

    sparamfreqprompt=simrfV2GetLeafWidgetBase('text','Frequency:',...
    'SparamFreqPrompt',0);
    sparamfreqprompt.RowSpan=[rs,rs];
    sparamfreqprompt.ColSpan=[lprompt,rprompt];

    sparamfreq=simrfV2GetLeafWidgetBase('edit','','SparamFreq',...
    this,'SparamFreq');
    sparamfreq.RowSpan=[rs,rs];
    sparamfreq.ColSpan=[lwidget,rwidget];

    sparamfrequnit=simrfV2GetLeafWidgetBase('combobox','',...
    'SparamFreq_unit',this,'SparamFreq_unit');
    sparamfrequnit.Entries=set(this,'SparamFreq_unit')';
    sparamfrequnit.RowSpan=[rs,rs];
    sparamfrequnit.ColSpan=[lunit,runit];

    dfprompt=simrfV2GetLeafWidgetBase('text','Direct feedthrough:',...
    'DFPrompt',0);
    dfprompt.RowSpan=[rs,rs];
    dfprompt.ColSpan=[lprompt,rprompt];

    df=simrfV2GetLeafWidgetBase('edit','','DF',this,'DF');
    df.RowSpan=[rs,rs];
    df.ColSpan=[lwidget,runit];


    rs=rs+1;

    sparamz0prompt=simrfV2GetLeafWidgetBase('text',...
    'Reference impedance (Ohm):','SparamZ0Prompt',0);
    sparamz0prompt.RowSpan=[rs,rs];
    sparamz0prompt.ColSpan=[lprompt,rprompt];

    sparamz0=simrfV2GetLeafWidgetBase('edit','','SparamZ0',this,...
    'SparamZ0');
    sparamz0.RowSpan=[rs,rs];
    sparamz0.ColSpan=[lwidget,runit];


    consts21nlmain=simrfV2GetLeafWidgetBase('checkbox',...
    'Use constant S21 and nonlinearity','ConstS21NL',this,'ConstS21NL');
    consts21nlmain.RowSpan=[rs,rs];
    consts21nlmain.ColSpan=[lprompt,rwidget];
    consts21nlmain.DialogRefresh=1;


    rs=rs+1;

    opfreqpromptmain=simrfV2GetLeafWidgetBase('text',...
    'Operation frequency:','OpFreqPromptMain',0);
    opfreqpromptmain.RowSpan=[rs,rs];
    opfreqpromptmain.ColSpan=[lprompt,rprompt];

    opfreqmain=simrfV2GetLeafWidgetBase('edit','','OpFreq',0,...
    'OpFreq');
    opfreqmain.RowSpan=[rs,rs];
    opfreqmain.ColSpan=[lwidget,rwidget];

    opfreqmainunit=simrfV2GetLeafWidgetBase('combobox','',...
    'OpFreq_unit',this,'OpFreq_unit');
    opfreqmainunit.Entries=set(this,'OpFreq_unit')';
    opfreqmainunit.RowSpan=[rs,rs];
    opfreqmainunit.ColSpan=[lunit,runit];


    plotButton=simrfV2GetLeafWidgetBase('pushbutton','Plot Power Characteristics',...
    'PlotButton',this,'PlotButton');
    plotButton.RowSpan=[rs,rs];
    plotButton.ColSpan=[lunit,runit];
    plotButton.ObjectMethod='simrfV2polynumerialplot';
    plotButton.MethodArgs={'%dialog'};
    plotButton.ArgDataTypes={'handle'};


    rs=rs+1;

    setopfreqasmaxs21main=simrfV2GetLeafWidgetBase('checkbox',...
    'Use operation frequency at maximum S21 magnitude',...
    'SetOpFreqAsMaxS21',this,...
    'SetOpFreqAsMaxS21');
    setopfreqasmaxs21main.RowSpan=[rs,rs];
    setopfreqasmaxs21main.ColSpan=[lprompt,rwidget];
    setopfreqasmaxs21main.DialogRefresh=1;


    rs=rs+1;

    spacernoise=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacernoise.RowSpan=[rs,rs];
    spacernoise.ColSpan=[lprompt,runit];


    rs=rs+1;
    choosenS21=simrfV2GetLeafWidgetBase('text','Due to...','choosenS21',0);
    choosenS21.RowSpan=[rs,rs];
    choosenS21.ColSpan=[lprompt,runit];
    choosenS21.WordWrap=true;


    rs=rs+1;

    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',this,...
    'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,number_grid];


    rs=rs+1;

    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,runit];

    maxrows=spacerMain.RowSpan(1);



    hBlk=get_param(this,'Handle');
    MaskVals=get_param(hBlk,'MaskValues');
    MaskWSValues=simrfV2getblockmaskwsvalues(hBlk);
    slBlkVis=get_param(hBlk,'MaskVisibilities');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);






    nonLinear=false;
    if strcmpi(MaskVals{idxMaskNames.Source_linear_gain},...
        'Polynomial coefficients')
        if(~isfield(MaskWSValues,'Poly_Coeffs')||...
            ~isnumeric(MaskWSValues.Poly_Coeffs)||...
            isempty(MaskWSValues.Poly_Coeffs)||...
            MaskWSValues.Poly_Coeffs(1)~=0||...
            ((length(MaskWSValues.Poly_Coeffs)>=3)&&...
            any(MaskWSValues.Poly_Coeffs(3:end)~=0)))
            nonLinear=true;
        end
    else
        if~(isfield(MaskWSValues,'IP3')&&...
            (isnumeric(MaskWSValues.IP3)&&isscalar(MaskWSValues.IP3)))
            nonLinear=true;
        else
            switch MaskVals{idxMaskNames.Source_Poly}
            case 'Odd order'
                if(~(isfield(MaskWSValues,'P1dB')&&...
                    (isnumeric(MaskWSValues.P1dB)&&...
                    isscalar(MaskWSValues.P1dB)))||...
                    ~(isfield(MaskWSValues,'Psat')&&...
                    (isnumeric(MaskWSValues.Psat)&&...
                    isscalar(MaskWSValues.Psat))))
                    nonLinear=true;
                else
                    if~(isinf(MaskWSValues.IP3)&&...
                        isinf(MaskWSValues.P1dB)&&...
                        isinf(MaskWSValues.Psat))
                        nonLinear=true;
                    end
                end
            case 'Even and odd order'
                if~(isfield(MaskWSValues,'IP2')&&...
                    (isnumeric(MaskWSValues.IP2)&&...
                    isscalar(MaskWSValues.IP2)))
                    nonLinear=true;
                else
                    if~(isinf(MaskWSValues.IP2)&&...
                        isinf(MaskWSValues.IP3))
                        nonLinear=true;
                    end
                end
            end
        end
    end

    SetOpFreqAsMaxS21=this.SetOpFreqAsMaxS21;

    Source_linear_gainprompt.Visible=1;
    line2_prompt.Visible=1;
    linear_gain.Visible=0;
    linear_gain_unit.Visible=0;
    datasource.Visible=0;
    Poly_Coeffs.Visible=0;
    AmAmTable.Visible=0;
    Zinprompt.Visible=0;
    Zin.Visible=0;
    fileprompt.Visible=0;
    file.Visible=0;
    browse.Visible=0;
    Paramtypeprompt.Visible=0;
    Paramtype.Visible=0;
    plotButton.Visible=0;
    residuesprompt.Visible=0;
    residues.Visible=0;
    polesprompt.Visible=0;
    poles.Visible=0;
    df.Visible=0;
    dfprompt.Visible=0;
    Zoutprompt.Visible=0;
    Zout.Visible=0;
    isnetworkobj.Visible=0;
    networkobjectname.Visible=0;
    sparamprompt.Visible=0;
    sparam.Visible=0;
    sparamfreqprompt.Visible=0;
    sparamfreq.Visible=0;
    sparamfrequnit.Visible=0;
    sparamz0prompt.Visible=0;
    sparamz0.Visible=0;
    isrationalobj.Visible=0;
    rationalobjectname.Visible=0;
    consts21nlmain.Visible=0;
    slBlkVis(idxMaskNames.ConstS21NL)={'off'};
    setopfreqasmaxs21main.Visible=0;
    slBlkVis(idxMaskNames.SetOpFreqAsMaxS21)={'off'};
    opfreqpromptmain.Visible=0;
    opfreqmain.Visible=0;
    slBlkVis(idxMaskNames.OpFreq)={'off'};
    opfreqmainunit.Visible=0;
    slBlkVis(idxMaskNames.OpFreq_unit)={'off'};
    NFfileVisible=0;
    choosenS21.Visible=1;
    spacernoise.Visible=0;

    slBlkVis([...
    idxMaskNames.File,idxMaskNames.Paramtype...
    ,idxMaskNames.isNetworkObj,idxMaskNames.NetworkObject...
    ,idxMaskNames.isRationalObj,idxMaskNames.RationalObject...
    ,idxMaskNames.Sparam,idxMaskNames.SparamFreq...
    ,idxMaskNames.SparamFreq_unit,idxMaskNames.SparamZ0...
    ,idxMaskNames.Residues,idxMaskNames.Poles...
    ,idxMaskNames.DF,idxMaskNames.Poly_Coeffs...
    ,idxMaskNames.AmAmAmPmTable,idxMaskNames.linear_gain...
    ,idxMaskNames.linear_gain_unit,idxMaskNames.DataSource...
    ,idxMaskNames.Zin,idxMaskNames.Zout...
    ])={'off'};

    slBlkVis([idxMaskNames.Source_linear_gain])={'on'};

    switch this.Source_linear_gain
    case 'Data source'
        if nonLinear
            spacernoise.Visible=0;
            choosenS21.Visible=1;
        end
        datasource.Visible=1;
        slBlkVis(idxMaskNames.DataSource)={'on'};
        switch this.DataSource
        case 'Data file'
            file.Visible=1;
            fileprompt.Visible=1;
            browse.Visible=1;
            slBlkVis(idxMaskNames.File)={'on'};
            hAuxData=get_param([this.getBlock.getFullName...
            ,'/AuxData'],'handle');
            uData=get_param(hAuxData,'UserData');
            if isfield(uData,'Noise')&&uData.Noise.HasNoisefileData
                NFfileVisible=1;
            end
        case 'Network-parameters'
            isnetworkobj.Visible=1;
            slBlkVis([idxMaskNames.isNetworkObj])={'on'};
            if this.isnetworkobj
                networkobjectname.Visible=1;
                slBlkVis([idxMaskNames.NetworkObject])={'on'};
            else
                Paramtype.Visible=1;
                Paramtypeprompt.Visible=1;
                sparam.Visible=1;
                sparamprompt.Visible=1;
                sparamfreq.Visible=1;
                sparamfrequnit.Visible=1;
                sparamfreqprompt.Visible=1;
                sparamz0.Visible=1;
                sparamz0prompt.Visible=1;
                slBlkVis([idxMaskNames.Paramtype...
                ,idxMaskNames.Sparam,idxMaskNames.SparamFreq...
                ,idxMaskNames.SparamFreq_unit,idxMaskNames.SparamZ0...
                ])={'on'};
            end
        case 'Rational model'
            isrationalobj.Visible=1;
            slBlkVis([idxMaskNames.isRationalObj])={'on'};
            if this.isrationalobj
                rationalobjectname.Visible=1;
                slBlkVis([idxMaskNames.RationalObject])={'on'};
            else
                residues.Visible=1;
                residuesprompt.Visible=1;
                poles.Visible=1;
                polesprompt.Visible=1;
                df.Visible=1;
                dfprompt.Visible=1;
                slBlkVis([idxMaskNames.Residues,idxMaskNames.Poles...
                ,idxMaskNames.DF])={'on'};
            end
        end

    case 'Polynomial coefficients'
        Poly_Coeffs.Visible=1;
        Zinprompt.Visible=1;
        Zin.Visible=1;
        Zoutprompt.Visible=1;
        Zout.Visible=1;
        slBlkVis([idxMaskNames.Poly_Coeffs,idxMaskNames.Zin...
        ,idxMaskNames.Zout])={'on'};

    case 'AM/AM-AM/PM table'
        AmAmTable.Visible=1;
        Zinprompt.Visible=1;
        Zin.Visible=1;
        Zoutprompt.Visible=1;
        Zout.Visible=1;
        slBlkVis([idxMaskNames.AmAmAmPmTable,idxMaskNames.Zin...
        ,idxMaskNames.Zout])={'on'};

    otherwise
        linear_gain.Visible=1;
        linear_gain_unit.Visible=1;
        Zinprompt.Visible=1;
        Zin.Visible=1;
        Zoutprompt.Visible=1;
        Zout.Visible=1;
        slBlkVis([idxMaskNames.linear_gain...
        ,idxMaskNames.linear_gain_unit,idxMaskNames.Zin...
        ,idxMaskNames.Zout])={'on'};
    end

    if(isfield(MaskWSValues,'OpFreq')&&...
        (isnumeric(MaskWSValues.OpFreq)&&...
        isscalar(MaskWSValues.OpFreq)))
        opFreq=simrfV2convert2baseunit(MaskWSValues.OpFreq,...
        MaskWSValues.OpFreq_unit);
        if opFreq<1
            opFreqUnitsPrefix='';
        else
            [opFreq,opFreq_exp,opFreqUnitsPrefix]=engunits(opFreq);
            if(opFreq_exp<1e-9)
                opFreq=opFreq*(1/opFreq_exp)*1e-9;
                opFreqUnitsPrefix='G';
            end
        end
        opFreqStr=num2str(opFreq,['%g ',opFreqUnitsPrefix,'Hz']);
    else
        opFreqStr='<undefined frequency>';
    end

    freqDepended=false;
    if(~strcmpi(MaskVals{idxMaskNames.NoiseDist},'White'))
        freqDepended=true;
    end

    choosenS21Str=sprintf(' \n ');
    if(strcmpi(MaskVals{idxMaskNames.Source_linear_gain},'Data source'))
        freqDepended=true;
        if(nonLinear&&this.ConstS21NL)
            S21FromFile=(strcmpi(this.DataSource,'Data file'));
            switch((~S21FromFile)*2+SetOpFreqAsMaxS21)
            case 3
                choosenS21Str=['Due to nonlinearity, simulating '...
                ,'constant S21 based on data specified above at '...
                ,'frequency where its magnitude is maximal.'];
            case 2
                choosenS21Str=['Due to nonlinearity, simulating '...
                ,'constant S21 based on data specified above at '...
                ,'frequency ',opFreqStr,'.'];
            case 1
                choosenS21Str=['Due to nonlinearity, simulating '...
                ,'constant S21 based on data specified in file at '...
                ,'frequency where its magnitude is maximal.'];
            case 0
                choosenS21Str=['Due to nonlinearity, simulating '...
                ,'constant S21 based on data specified in file at '...
                ,'frequency ',opFreqStr,'.'];
            end
        end
    end
    choosenS21.Name=choosenS21Str;
    nonLinear4Noise=false;



    if(strcmpi(this.Source_linear_gain,'Polynomial coefficients')&&...
        (nonLinear4Noise&&freqDepended))
        consts21nlmain.Visible=1;
        slBlkVis(idxMaskNames.ConstS21NL)={'on'};
        setopfreqasmaxs21main.Visible=1;
        slBlkVis(idxMaskNames.SetOpFreqAsMaxS21)={'on'};
        if~SetOpFreqAsMaxS21
            opfreqpromptmain.Visible=1;
            opfreqmain.Visible=1;
            slBlkVis(idxMaskNames.OpFreq)={'on'};
            opfreqmainunit.Visible=1;
            slBlkVis(idxMaskNames.OpFreq_unit)={'on'};
        end
    end


    [visItems,visLayout,slBlkVis]=simrfV2create_vis_pane(this,...
    slBlkVis,idxMaskNames);


    allowMagModeling=any(strcmpi(this.DataSource,{'Data file',...
    'Network-parameters'}));
    if(allowMagModeling)
        hAuxData=get_param([this.getBlock.getFullName...
        ,'/AuxData'],'handle');
        uData=get_param(hAuxData,'UserData');
        if((~isfield(uData,'Spars'))||...
            (~strcmpi(uData.Spars.OrigParamType,'s')))
            allowMagModeling=false;
        end
    end
    [modItems,modLayout,slBlkVis]=simrfV2create_modeling_pane(this,...
    slBlkVis,idxMaskNames,allowMagModeling,true);


    [noiseItems,noiseLayout,slBlkVis]=...
    simrfV2create_noise_pane(this,slBlkVis,idxMaskNames,...
    NFfileVisible,(nonLinear4Noise&&this.ConstS21NL),...
    SetOpFreqAsMaxS21,opFreqStr);


    [nlItems,nlLayout,slBlkVis]=simrfV2create_nldata_opfreq_pane(this,...
    slBlkVis,idxMaskNames,(nonLinear&&freqDepended),opFreqStr);


    if~strcmpi(get_param(bdroot(hBlk),'Lock'),'on')
        set_param(hBlk,'MaskVisibilities',slBlkVis);

        set_param(hBlk,'MaskVisibilities',slBlkVis);

    end






    mainItems={Source_linear_gainprompt,Source_linear_gain,...
    line2_prompt,linear_gain,linear_gain_unit,datasource,...
    Poly_Coeffs,AmAmTable,...
    Zinprompt,Zin,isnetworkobj,networkobjectname,...
    fileprompt,file,browse,Paramtypeprompt,Paramtype,...
    isrationalobj,rationalobjectname,residuesprompt,residues,...
    polesprompt,poles,plotButton,...
    df,dfprompt,...
    Zoutprompt,Zout,...
    sparamprompt,sparam,...
    sparamfreqprompt,sparamfreq,sparamfrequnit,...
    sparamz0prompt,sparamz0,...
    choosenS21,...
    grounding,spacerMain};
    if strcmpi(this.Source_linear_gain,'Polynomial coefficients')
        mainItems=[mainItems,{consts21nlmain,setopfreqasmaxs21main,...
        opfreqpromptmain,opfreqmain,opfreqmainunit}];
    end
    mainLayout.LayoutGrid=[maxrows,number_grid];
    mainLayout.RowSpan=[2,2];
    mainLayout.ColSpan=[1,1];
    mainLayout.RowStretch=[zeros(1,maxrows-1),1];


    mainPane=simrfV2create_panel(this,'MainPane',mainItems,mainLayout);


    visualizationPane=simrfV2create_panel(this,'VisualizationPane',...
    visItems,visLayout);


    modelingPane=simrfV2create_panel(this,'ModelingPane',modItems,...
    modLayout);


    nonlinearityPane=simrfV2create_panel(this,'NonlinearPane',nlItems,...
    nlLayout);


    noisePane=simrfV2create_panel(this,'NoisePane',noiseItems,...
    noiseLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    nonlinearityTab.Name='Nonlinearity';
    nonlinearityTab.Items={nonlinearityPane};
    nonlinearityTab.LayoutGrid=[1,1];
    nonlinearityTab.RowStretch=0;
    nonlinearityTab.ColStretch=0;


    modelingTab.Name='Modeling';
    modelingTab.Items={modelingPane};
    modelingTab.LayoutGrid=[1,1];
    modelingTab.RowStretch=0;
    modelingTab.ColStretch=0;


    visualizationTab.Name='Visualization';
    visualizationTab.Items={visualizationPane};
    visualizationTab.LayoutGrid=[1,1];
    visualizationTab.RowStretch=0;
    visualizationTab.ColStretch=0;


    noiseTab.Name='Noise';
    noiseTab.Items={noisePane};
    noiseTab.LayoutGrid=[1,1];
    noiseTab.RowStretch=0;
    noiseTab.ColStretch=0;


    tabbedPane.Type='tab';
    tabbedPane.Name='';
    tabbedPane.Tag='TabPane';
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];

    tabbedPane.Tabs={mainTab};
    if isempty(regexp(this.Source_linear_gain,...
        '^(Polynomial coefficients|AM/AM-AM/PM table)$','once'))
        tabbedPane.Tabs=[tabbedPane.Tabs,nonlinearityTab];
    end
    tabbedPane.Tabs=[tabbedPane.Tabs,noiseTab];
    if strcmpi(this.Source_linear_gain,'Data source')
        if~strcmpi(this.DataSource,'Rational model')
            tabbedPane.Tabs=[tabbedPane.Tabs,modelingTab,visualizationTab];
        else
            tabbedPane.Tabs=[tabbedPane.Tabs,visualizationTab];
        end
    end


    dlgStruct=getBaseSchemaStruct(this,tabbedPane);

