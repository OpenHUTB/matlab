function[items,layout,slBlkVis]=simrfV2create_filtmain_pane(this,...
    slBlkVis,idxMaskNames,varargin)





    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;
    number_grid=20;

    if((nargin>3)&&(~isempty(varargin{1})))
        tagEnd=varargin{1};


        if((nargin>4)&&(~isempty(varargin{2})))
            filtVisible=varargin{2};
        else
            filtVisible=true;
        end
    else
        tagEnd='';
        filtVisible=true;
    end


    isideal=strcmpi(this.(['designmethod',tagEnd]),'Ideal');

    switch this.(['responsetype',tagEnd])
    case{'Lowpass','Highpass'}
        if(~isideal)
            passFreqStr='Passband frequency:';
            stopFreqStr='Stopband frequency:';
        else
            passFreqStr='Passband edge frequency:';
            stopFreqStr='Stopband edge frequency:';
        end
    otherwise
        if(~isideal)
            passFreqStr='Passband frequencies:';
            stopFreqStr='Stopband frequencies:';
        else
            passFreqStr='Passband edge frequencies:';
            stopFreqStr='Stopband edge frequencies:';
        end
    end







    rs=1;
    designmethodprompt=simrfV2GetLeafWidgetBase('text',...
    'Design method:','DesignMethodprompt',0);
    designmethodprompt.RowSpan=[rs,rs];
    designmethodprompt.ColSpan=[lprompt,rprompt];

    designmethod=simrfV2GetLeafWidgetBase('combobox','',...
    ['DesignMethod',tagEnd],this,['DesignMethod',tagEnd]);
    designmethod.Entries=set(this,['DesignMethod',tagEnd])';
    designmethod.RowSpan=[rs,rs];
    designmethod.ColSpan=[ledit,runit];
    designmethod.DialogRefresh=1;




    rs=rs+1;
    responsetypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Filter type:','ResponseTypeprompt',0);
    responsetypeprompt.RowSpan=[rs,rs];
    responsetypeprompt.ColSpan=[lprompt,rprompt];

    responsetype=simrfV2GetLeafWidgetBase('combobox','',...
    ['ResponseType',tagEnd],this,['ResponseType',tagEnd]);
    responsetype.Entries=set(this,['ResponseType',tagEnd])';
    responsetype.RowSpan=[rs,rs];
    responsetype.ColSpan=[ledit,runit];
    responsetype.DialogRefresh=1;




    rs=rs+1;
    implementationprompt=simrfV2GetLeafWidgetBase('text',...
    'Implementation:','Implementationprompt',0);
    implementationprompt.RowSpan=[rs,rs];
    implementationprompt.ColSpan=[lprompt,rprompt];

    implementation=simrfV2GetLeafWidgetBase('combobox','',...
    ['Implementation',tagEnd],this,['Implementation',tagEnd]);
    implementation.Entries=set(this,['Implementation',tagEnd])';
    implementation.RowSpan=[rs,rs];
    implementation.ColSpan=[ledit,runit];

    implementationideal=simrfV2GetLeafWidgetBase('combobox','',...
    ['ImplementationIdeal',tagEnd],this,['ImplementationIdeal',tagEnd]);
    implementationideal.Entries=set(this,['ImplementationIdeal',tagEnd])';
    implementationideal.RowSpan=[rs,rs];
    implementationideal.ColSpan=[ledit,runit];
    implementationideal.DialogRefresh=1;

    implementationrational=simrfV2GetLeafWidgetBase('combobox','',...
    ['ImplementationRational',tagEnd],this,['ImplementationRational',tagEnd]);
    implementationrational.Entries=set(this,['ImplementationRational',tagEnd])';
    implementationrational.RowSpan=[rs,rs];
    implementationrational.ColSpan=[ledit,runit];
    implementationrational.Enabled=false;




    rs=rs+1;
    tfonlyprompt=simrfV2GetLeafWidgetBase('text',...
    'Implementation:','TFonlyprompt',0);
    tfonlyprompt.RowSpan=[rs,rs];
    tfonlyprompt.ColSpan=[lprompt,rprompt];

    tfonly=simrfV2GetLeafWidgetBase('text','Transfer function',...
    'TFonly',0);
    tfonly.RowSpan=[rs,rs];
    tfonly.ColSpan=[ledit,runit];



    rs=rs+1;

    usefilterorder=simrfV2GetLeafWidgetBase('checkbox',...
    'Implement using filter order',['UseFilterOrder',tagEnd],...
    this,['UseFilterOrder',tagEnd]);
    usefilterorder.RowSpan=[rs,rs];
    usefilterorder.ColSpan=[lprompt,redit];
    usefilterorder.DialogRefresh=1;














    rs=rs+1;
    filterorderprompt=simrfV2GetLeafWidgetBase('text','Filter order:',...
    'FilterOrderprompt',0);
    filterorderprompt.RowSpan=[rs,rs];
    filterorderprompt.ColSpan=[lprompt,rprompt];

    filterorder=simrfV2GetLeafWidgetBase('edit','',...
    ['FilterOrder',tagEnd],this,['FilterOrder',tagEnd]);
    filterorder.RowSpan=[rs,rs];
    filterorder.ColSpan=[ledit,runit];




    rs=rs+1;
    passbandprompt=simrfV2GetLeafWidgetBase('text',...
    passFreqStr,'PassBandprompt',0);
    passbandprompt.RowSpan=[rs,rs];
    passbandprompt.ColSpan=[lprompt,rprompt];

    passband_lp=simrfV2GetLeafWidgetBase('edit','',...
    ['PassFreq_lp',tagEnd],this,['PassFreq_lp',tagEnd]);
    passband_lp.RowSpan=[rs,rs];
    passband_lp.ColSpan=[ledit,redit];

    passband_lp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['PassFreq_lp_unit',tagEnd],this,['PassFreq_lp_unit',tagEnd]);
    passband_lp_unit.Entries=set(this,['PassFreq_lp_unit',tagEnd])';
    passband_lp_unit.RowSpan=[rs,rs];
    passband_lp_unit.ColSpan=[lunit,runit];

    passband_hp=simrfV2GetLeafWidgetBase('edit','',...
    ['PassFreq_hp',tagEnd],this,['PassFreq_hp',tagEnd]);
    passband_hp.RowSpan=[rs,rs];
    passband_hp.ColSpan=[ledit,redit];

    passband_hp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['PassFreq_hp_unit',tagEnd],this,['PassFreq_hp_unit',tagEnd]);
    passband_hp_unit.Entries=set(this,['PassFreq_hp_unit',tagEnd])';
    passband_hp_unit.RowSpan=[rs,rs];
    passband_hp_unit.ColSpan=[lunit,runit];

    passband_bp=simrfV2GetLeafWidgetBase('edit','',...
    ['PassFreq_bp',tagEnd],this,['PassFreq_bp',tagEnd]);
    passband_bp.RowSpan=[rs,rs];
    passband_bp.ColSpan=[ledit,redit];

    passband_bp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['PassFreq_bp_unit',tagEnd],this,['PassFreq_bp_unit',tagEnd]);
    passband_bp_unit.Entries=set(this,['PassFreq_bp_unit',tagEnd])';
    passband_bp_unit.RowSpan=[rs,rs];
    passband_bp_unit.ColSpan=[lunit,runit];

    passband_bs=simrfV2GetLeafWidgetBase('edit','',...
    ['PassFreq_bs',tagEnd],this,['PassFreq_bs',tagEnd]);
    passband_bs.RowSpan=[rs,rs];
    passband_bs.ColSpan=[ledit,redit];

    passband_bs_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['PassFreq_bs_unit',tagEnd],this,['PassFreq_bs_unit',tagEnd]);
    passband_bs_unit.Entries=set(this,['PassFreq_bs_unit',tagEnd])';
    passband_bs_unit.RowSpan=[rs,rs];
    passband_bs_unit.ColSpan=[lunit,runit];




    rs=rs+1;
    passattenprompt=simrfV2GetLeafWidgetBase('text',...
    'Passband attenuation (dB):','PassAttenprompt',0);
    passattenprompt.RowSpan=[rs,rs];
    passattenprompt.ColSpan=[lprompt,rprompt];

    passatten=simrfV2GetLeafWidgetBase('edit','',['PassAtten',tagEnd],...
    this,['PassAtten',tagEnd]);
    passatten.RowSpan=[rs,rs];
    passatten.ColSpan=[ledit,runit];




    rs=rs+1;
    stopbandprompt=simrfV2GetLeafWidgetBase('text',...
    stopFreqStr,'StopBandprompt',0);
    stopbandprompt.RowSpan=[rs,rs];
    stopbandprompt.ColSpan=[lprompt,rprompt];

    stopband_lp=simrfV2GetLeafWidgetBase('edit','',...
    ['StopFreq_lp',tagEnd],this,['StopFreq_lp',tagEnd]);
    stopband_lp.RowSpan=[rs,rs];
    stopband_lp.ColSpan=[ledit,redit];

    stopband_lp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['StopFreq_lp_unit',tagEnd],this,['StopFreq_lp_unit',tagEnd]);
    stopband_lp_unit.Entries=set(this,['StopFreq_lp_unit',tagEnd])';
    stopband_lp_unit.RowSpan=[rs,rs];
    stopband_lp_unit.ColSpan=[lunit,runit];

    stopband_hp=simrfV2GetLeafWidgetBase('edit','',...
    ['StopFreq_hp',tagEnd],this,['StopFreq_hp',tagEnd]);
    stopband_hp.RowSpan=[rs,rs];
    stopband_hp.ColSpan=[ledit,redit];

    stopband_hp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['StopFreq_hp_unit',tagEnd],this,['StopFreq_hp_unit',tagEnd]);
    stopband_hp_unit.Entries=set(this,['StopFreq_hp_unit',tagEnd])';
    stopband_hp_unit.RowSpan=[rs,rs];
    stopband_hp_unit.ColSpan=[lunit,runit];

    stopband_bp=simrfV2GetLeafWidgetBase('edit','',...
    ['StopFreq_bp',tagEnd],this,['StopFreq_bp',tagEnd]);
    stopband_bp.RowSpan=[rs,rs];
    stopband_bp.ColSpan=[ledit,redit];

    stopband_bp_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['StopFreq_bp_unit',tagEnd],this,['StopFreq_bp_unit',tagEnd]);
    stopband_bp_unit.Entries=set(this,['StopFreq_bp_unit',tagEnd])';
    stopband_bp_unit.RowSpan=[rs,rs];
    stopband_bp_unit.ColSpan=[lunit,runit];

    stopband_bs=simrfV2GetLeafWidgetBase('edit','',...
    ['StopFreq_bs',tagEnd],this,['StopFreq_bs',tagEnd]);
    stopband_bs.RowSpan=[rs,rs];
    stopband_bs.ColSpan=[ledit,redit];

    stopband_bs_unit=simrfV2GetLeafWidgetBase('combobox','',...
    ['StopFreq_bs_unit',tagEnd],this,['StopFreq_bs_unit',tagEnd]);
    stopband_bs_unit.Entries=set(this,['StopFreq_bs_unit',tagEnd])';
    stopband_bs_unit.RowSpan=[rs,rs];
    stopband_bs_unit.ColSpan=[lunit,runit];




    rs=rs+1;
    stopattenprompt=simrfV2GetLeafWidgetBase('text',...
    'Stopband attenuation (dB):','StopAttenprompt',0);
    stopattenprompt.RowSpan=[rs,rs];
    stopattenprompt.ColSpan=[lprompt,rprompt];

    stopatten=simrfV2GetLeafWidgetBase('edit','',['StopAtten',tagEnd],...
    this,['StopAtten',tagEnd]);
    stopatten.RowSpan=[rs,rs];
    stopatten.ColSpan=[ledit,runit];




    rs=rs+1;
    sourceresprompt=simrfV2GetLeafWidgetBase('text',...
    'Source impedance (Ohm):','SourceResprompt',0);
    sourceresprompt.RowSpan=[rs,rs];
    sourceresprompt.ColSpan=[lprompt,rprompt];

    sourceres=simrfV2GetLeafWidgetBase('edit','',['Rsrc',tagEnd],this,...
    ['Rsrc',tagEnd]);
    sourceres.RowSpan=[rs,rs];
    sourceres.ColSpan=[ledit,runit];




    rs=rs+1;
    loadresprompt=simrfV2GetLeafWidgetBase('text',...
    'Load impedance (Ohm):','LoadResprompt',0);
    loadresprompt.RowSpan=[rs,rs];
    loadresprompt.ColSpan=[lprompt,rprompt];

    loadres=simrfV2GetLeafWidgetBase('edit','',['Rload',tagEnd],this,...
    ['Rload',tagEnd]);
    loadres.RowSpan=[rs,rs];
    loadres.ColSpan=[ledit,runit];






    rs=rs+1;
    autoimp=simrfV2GetLeafWidgetBase('checkbox',...
    'Automatically estimate impulse response duration',...
    ['AutoImpulseLength',tagEnd],this,['AutoImpulseLength',tagEnd]);
    autoimp.RowSpan=[rs,rs];
    autoimp.ColSpan=[lprompt,redit];
    autoimp.DialogRefresh=1;


    rs=rs+1;
    imprespprompt=simrfV2GetLeafWidgetBase('text',...
    'Impulse response duration:','ImpulseLengthprompt',0);
    imprespprompt.RowSpan=[rs,rs];
    imprespprompt.ColSpan=[lprompt,ledit];

    impresp=simrfV2GetLeafWidgetBase('edit','',['ImpulseLength',tagEnd],...
    this,['ImpulseLength',tagEnd]);
    impresp.RowSpan=[rs,rs];
    impresp.ColSpan=[ledit,redit];

    imprespunit=simrfV2GetLeafWidgetBase('combobox','',...
    ['ImpulseLength_unit',tagEnd],this,['ImpulseLength_unit',tagEnd]);
    imprespunit.Entries=set(this,['ImpulseLength_unit',tagEnd])';
    imprespunit.RowSpan=[rs,rs];
    imprespunit.ColSpan=[lunit,runit];




    rs=rs+1;
    grounding=simrfV2GetLeafWidgetBase('checkbox',...
    'Ground and hide negative terminals','InternalGrounding',...
    this,'InternalGrounding');
    grounding.RowSpan=[rs,rs];
    grounding.ColSpan=[lprompt,runit];




    rs=rs+1;

    exportbutton=simrfV2GetLeafWidgetBase('pushbutton','Export',...
    'ExportButton',this,'ExportButton');
    exportbutton.RowSpan=[rs,rs];
    exportbutton.ColSpan=[redit,runit];
    exportbutton.ObjectMethod='simrfV2exportfilter';
    exportbutton.MethodArgs={'%dialog'};
    exportbutton.ArgDataTypes={'handle'};




    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];

    maxrows=spacerMain.RowSpan(1);



    if filtVisible


        if(~isempty(tagEnd)&&...
            strcmpi(slBlkVis{idxMaskNames.(['DesignMethod',tagEnd])},...
            'off'))



            fnames=fieldnames(idxMaskNames);
            CSfnames=fnames(cellfun(@(x)~isempty(x),...
            regexp(fnames,[tagEnd,'$'])));
            for CSfnameInd=1:length(CSfnames)
                CSfname=CSfnames{CSfnameInd};
                slBlkVis{idxMaskNames.(CSfname)}='on';
            end
        end
        slBlkVis([idxMaskNames.(['Implementation',tagEnd]),idxMaskNames.(['ImplementationIdeal',tagEnd])...
        ,idxMaskNames.(['ImplementationRational',tagEnd])...
        ,idxMaskNames.(['UseFilterOrder',tagEnd])...
        ,idxMaskNames.(['FilterOrder',tagEnd]),idxMaskNames.(['PassFreq_lp',tagEnd])...
        ,idxMaskNames.(['PassFreq_hp',tagEnd]),idxMaskNames.(['PassFreq_bp',tagEnd])...
        ,idxMaskNames.(['PassFreq_bs',tagEnd])...
        ,idxMaskNames.(['PassAtten',tagEnd])...
        ,idxMaskNames.(['StopFreq_lp',tagEnd]),idxMaskNames.(['StopFreq_hp',tagEnd])...
        ,idxMaskNames.(['StopFreq_bp',tagEnd]),idxMaskNames.(['StopFreq_bs',tagEnd])...
        ,idxMaskNames.(['StopFreq_lp_unit',tagEnd]),idxMaskNames.(['StopFreq_hp_unit',tagEnd])...
        ,idxMaskNames.(['StopFreq_bp_unit',tagEnd]),idxMaskNames.(['StopFreq_bs_unit',tagEnd])...
        ,idxMaskNames.(['StopAtten',tagEnd])...
        ,idxMaskNames.(['AutoImpulseLength',tagEnd]),idxMaskNames.(['ImpulseLength',tagEnd])...
        ,idxMaskNames.(['ImpulseLength_unit',tagEnd])])={'off'};
        filterorderprompt.Visible=0;
        filterorder.Visible=0;
        passbandprompt.Visible=0;
        passband_lp.Visible=0;
        passband_lp_unit.Visible=0;
        passband_hp.Visible=0;
        passband_hp_unit.Visible=0;
        passband_bp.Visible=0;
        passband_bp_unit.Visible=0;
        passband_bs.Visible=0;
        passband_bs_unit.Visible=0;
        passattenprompt.Visible=0;
        passatten.Visible=0;
        stopbandprompt.Visible=0;
        stopband_lp.Visible=0;
        stopband_lp_unit.Visible=0;
        stopband_hp.Visible=0;
        stopband_hp_unit.Visible=0;
        stopband_bp.Visible=0;
        stopband_bp_unit.Visible=0;
        stopband_bs.Visible=0;
        stopband_bs_unit.Visible=0;
        stopattenprompt.Visible=0;
        stopatten.Visible=0;

        isvis=any(strcmpi(this.(['designmethod',tagEnd]),...
        {'Butterworth','Chebyshev','InverseChebyshev','Ideal'}));
        isFreqDom=strcmpi(this.(['implementationideal',tagEnd]),...
        'Frequency domain');

        isinvcheby=strcmpi(this.(['designmethod',tagEnd]),'InverseChebyshev');
        implementationprompt.Visible=isvis;
        implementation.Visible=(isvis)&&(~isideal)&&(~isinvcheby);
        implementationideal.Visible=(isvis)&&(isideal);
        implementationrational.Visible=(isvis)&&(isinvcheby);
        if(isvis)
            if(~isideal)&&(~isinvcheby)
                slBlkVis([idxMaskNames.(['Implementation',tagEnd])])={'on'};
            elseif isinvcheby
                slBlkVis([idxMaskNames.(['ImplementationRational'...
                ,tagEnd])])={'on'};
            else
                slBlkVis([idxMaskNames.(['ImplementationIdeal',tagEnd])])=...
                {'on'};
            end
        end
        usefilterorder.Visible=(~isideal);
        if(~isideal)
            slBlkVis([idxMaskNames.(['UseFilterOrder',tagEnd])])={'on'};
        end
        sourceresprompt.Visible=((~isideal)||(isFreqDom));
        sourceres.Visible=((~isideal)||(isFreqDom));
        loadresprompt.Visible=((~isideal)||(isFreqDom));
        loadres.Visible=((~isideal)||(isFreqDom));
        tfonlyprompt.Visible=~isvis;
        tfonly.Visible=~isvis;
        exportbutton.Visible=(~isideal);

        switch this.(['responsetype',tagEnd])
        case 'Lowpass'
            passbandprompt.Visible=1;
            passband_lp.Visible=1;
            passband_lp_unit.Visible=1;
            slBlkVis([idxMaskNames.(['PassFreq_lp',tagEnd])...
            ,idxMaskNames.(['PassFreq_lp_unit',tagEnd])])={'on'};
            if(~isideal)
                passattenprompt.Visible=1;
                passatten.Visible=1;
                slBlkVis([idxMaskNames.(['PassAtten',tagEnd])])={'on'};
                if this.(['usefilterorder',tagEnd])==1
                    filterorderprompt.Visible=1;
                    filterorder.Visible=1;
                    slBlkVis([idxMaskNames.(['FilterOrder',tagEnd])])=...
                    {'on'};
                else
                    stopbandprompt.Visible=1;
                    stopband_lp.Visible=1;
                    stopband_lp_unit.Visible=1;
                    stopattenprompt.Visible=1;
                    stopatten.Visible=1;
                    slBlkVis([...
                    idxMaskNames.(['StopFreq_lp',tagEnd])...
                    ,idxMaskNames.(['StopFreq_lp_unit',tagEnd])...
                    ,idxMaskNames.(['StopAtten',tagEnd])])={'on'};
                end
            end
            if isinvcheby&&this.(['usefilterorder',tagEnd])==1
                stopattenprompt.Visible=1;
                stopatten.Visible=1;
                slBlkVis([...
                idxMaskNames.(['StopAtten',tagEnd])])={'on'};
            end
        case 'Highpass'
            passbandprompt.Visible=1;
            passband_hp.Visible=1;
            passband_hp_unit.Visible=1;
            slBlkVis([idxMaskNames.(['PassFreq_hp',tagEnd])...
            ,idxMaskNames.(['PassFreq_hp_unit',tagEnd])])={'on'};
            if(~isideal)
                passattenprompt.Visible=1;
                passatten.Visible=1;
                slBlkVis([idxMaskNames.(['PassAtten',tagEnd])])={'on'};
                if this.(['usefilterorder',tagEnd])==1
                    filterorderprompt.Visible=1;
                    filterorder.Visible=1;
                    slBlkVis([idxMaskNames.(['FilterOrder',tagEnd])])=...
                    {'on'};
                else
                    stopbandprompt.Visible=1;
                    stopband_hp.Visible=1;
                    stopband_hp_unit.Visible=1;
                    stopattenprompt.Visible=1;
                    stopatten.Visible=1;
                    slBlkVis([...
                    idxMaskNames.(['StopFreq_hp',tagEnd])...
                    ,idxMaskNames.(['StopFreq_hp_unit',tagEnd])...
                    ,idxMaskNames.(['StopAtten',tagEnd])])={'on'};
                end
            end
            if isinvcheby&&this.(['usefilterorder',tagEnd])==1
                stopattenprompt.Visible=1;
                stopatten.Visible=1;
                slBlkVis([...
                idxMaskNames.(['StopAtten',tagEnd])])={'on'};
            end
        case 'Bandpass'
            passbandprompt.Visible=1;
            passband_bp.Visible=1;
            passband_bp_unit.Visible=1;
            slBlkVis([idxMaskNames.(['PassFreq_bp',tagEnd])...
            ,idxMaskNames.(['PassFreq_bp_unit',tagEnd])])={'on'};
            if(~isideal)
                passattenprompt.Visible=(~isideal);
                passatten.Visible=(~isideal);
                slBlkVis([idxMaskNames.(['PassAtten',tagEnd])])={'on'};
                if this.(['usefilterorder',tagEnd])==1
                    filterorderprompt.Visible=1;
                    filterorder.Visible=1;
                    slBlkVis([idxMaskNames.(['FilterOrder',tagEnd])])=...
                    {'on'};
                else
                    stopbandprompt.Visible=1;
                    stopband_bp.Visible=1;
                    stopband_bp_unit.Visible=1;
                    stopattenprompt.Visible=1;
                    stopatten.Visible=1;
                    slBlkVis([idxMaskNames.(['StopFreq_bp',tagEnd])...
                    ,idxMaskNames.(['StopFreq_bp_unit',tagEnd])...
                    ,idxMaskNames.(['StopAtten',tagEnd])])={'on'};
                end
            end
            if isinvcheby&&this.(['usefilterorder',tagEnd])==1
                stopattenprompt.Visible=1;
                stopatten.Visible=1;
                slBlkVis([idxMaskNames.(['StopAtten',tagEnd])])={'on'};
            end
        case 'Bandstop'
            stopbandprompt.Visible=1;
            stopband_bs.Visible=1;
            stopband_bs_unit.Visible=1;
            slBlkVis([idxMaskNames.(['StopFreq_bs',tagEnd])...
            ,idxMaskNames.(['StopFreq_bs_unit',tagEnd])])={'on'};
            if(~isideal)&&(~isinvcheby)
                if(~strcmpi(this.(['designmethod',tagEnd]),...
                    {'Butterworth'}))||...
                    ~this.(['usefilterorder',tagEnd])
                    passattenprompt.Visible=1;
                    passatten.Visible=1;
                    slBlkVis(idxMaskNames.(['PassAtten',tagEnd]))={'on'};
                end
                stopattenprompt.Visible=1;
                stopatten.Visible=1;
                slBlkVis(idxMaskNames.(['StopAtten',tagEnd]))={'on'};
                if this.(['usefilterorder',tagEnd])==1
                    filterorderprompt.Visible=1;
                    filterorder.Visible=1;
                    slBlkVis([idxMaskNames.(['FilterOrder',tagEnd])])=...
                    {'on'};
                else
                    passbandprompt.Visible=1;
                    passband_bs.Visible=1;
                    passband_bs_unit.Visible=1;
                    slBlkVis([idxMaskNames.(['PassFreq_bs',tagEnd])...
                    ,idxMaskNames.(['StopFreq_bs_unit',tagEnd])])=...
                    {'on'};
                end
            elseif isinvcheby
                stopattenprompt.Visible=1;
                stopatten.Visible=1;
                slBlkVis(idxMaskNames.(['StopAtten',tagEnd]))={'on'};
                if this.(['usefilterorder',tagEnd])==1
                    filterorderprompt.Visible=1;
                    filterorder.Visible=1;
                    slBlkVis([idxMaskNames.(['FilterOrder',tagEnd])])=...
                    {'on'};
                else
                    passbandprompt.Visible=1;
                    passband_bs.Visible=1;
                    passband_bs_unit.Visible=1;
                    passattenprompt.Visible=1;
                    passatten.Visible=1;
                    slBlkVis([idxMaskNames.(['PassFreq_bs',tagEnd])...
                    ,idxMaskNames.(['PassFreq_bs_unit',tagEnd])...
                    ,idxMaskNames.(['PassAtten',tagEnd])])={'on'};
                end
            end
        end

        autoimp.Visible=0;
        imprespprompt.Visible=0;
        impresp.Visible=0;
        imprespunit.Visible=0;
        if((isideal)&&strcmpi(this.(['implementationideal',tagEnd]),...
            'Frequency domain'))
            autoimp.Visible=1;
            slBlkVis([idxMaskNames.(['AutoImpulseLength',tagEnd])])={'on'};
            if~this.(['AutoImpulseLength',tagEnd])
                imprespprompt.Visible=1;
                impresp.Visible=1;
                slBlkVis([idxMaskNames.(['ImpulseLength',tagEnd])])={'on'};
                imprespunit.Visible=1;
                slBlkVis([idxMaskNames.(['ImpulseLength_unit',tagEnd])])=...
                {'on'};
            end
        end



        if(~isempty(tagEnd))
            grounding.Visible=0;
            exportbutton.Visible=0;
        end
    else

        if strcmpi(slBlkVis{idxMaskNames.(['DesignMethod',tagEnd])},'on')




            fnames=fieldnames(idxMaskNames);
            CSfnames=fnames(cellfun(@(x)~isempty(x),...
            regexp(fnames,[tagEnd,'$'])));
            for CSfnameInd=1:length(CSfnames)
                CSfname=CSfnames{CSfnameInd};
                slBlkVis{idxMaskNames.(CSfname)}='off';
            end
        end
    end


    items={...
    designmethodprompt,designmethod,...
    responsetypeprompt,responsetype,...
    implementationprompt,implementation,...
    implementationideal,implementationrational,...
    tfonlyprompt,tfonly,...
    usefilterorder,filterorderprompt,filterorder,...
    passbandprompt,passband_lp,passband_lp_unit,...
    passband_hp,passband_hp_unit,...
    passband_bp,passband_bp_unit,...
    passband_bs,passband_bs_unit,...
    passattenprompt,passatten,...
    stopbandprompt,stopband_lp,stopband_lp_unit,...
    stopband_hp,stopband_hp_unit,...
    stopband_bp,stopband_bp_unit,...
    stopband_bs,stopband_bs_unit,...
    stopattenprompt,stopatten,...
    sourceresprompt,sourceres,...
    loadresprompt,loadres,...
    autoimp,...
    imprespprompt,impresp,imprespunit,...
    grounding,exportbutton,spacerMain};

    layout.LayoutGrid=[maxrows,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,maxrows-1),1];

end


