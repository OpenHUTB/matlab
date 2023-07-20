function[items,layout,slBlkVis]=...
    simrfV2create_nldata_opfreq_pane(this,slBlkVis,idxMaskNames,...
    varargin)





    lprompt=1;
    rprompt=4;
    ledit=rprompt+1;
    redit=18;
    lunit=redit+1;
    runit=20;




    rs=1;
    Source_Poly=simrfV2GetLeafWidgetBase('combobox','','Source_Poly',...
    this,'Source_Poly');
    Source_Poly.Entries=set(this,'Source_Poly')';
    Source_Poly.RowSpan=[rs,rs];
    Source_Poly.ColSpan=[ledit,runit];
    Source_Poly.DialogRefresh=1;

    Source_Polyprompt=simrfV2GetLeafWidgetBase('text',...
    'Nonlinear polynomial type:','Source_PolyPrompt',0);
    Source_Polyprompt.RowSpan=[rs,rs];
    Source_Polyprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    IPType=simrfV2GetLeafWidgetBase('combobox','','IPType',this,...
    'IPType');
    IPType.Entries=set(this,'IPType')';
    IPType.RowSpan=[rs,rs];
    IPType.ColSpan=[ledit,runit];
    IPType.DialogRefresh=1;

    IPTypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Intercept points convention:','IPTypePrompt',0);
    IPTypeprompt.RowSpan=[rs,rs];
    IPTypeprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    IP2prompt=simrfV2GetLeafWidgetBase('text','IP2:','IP2prompt',0);
    IP2prompt.RowSpan=[rs,rs];
    IP2prompt.ColSpan=[lprompt,rprompt];

    IP2=simrfV2GetLeafWidgetBase('edit','','IP2',this,'IP2');
    IP2.RowSpan=[rs,rs];
    IP2.ColSpan=[ledit,redit];

    IP2_unit=simrfV2GetLeafWidgetBase('combobox','','IP2_unit',...
    this,'IP2_unit');
    IP2_unit.Entries=set(this,'IP2_unit')';
    IP2_unit.RowSpan=[rs,rs];
    IP2_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    IP3prompt=simrfV2GetLeafWidgetBase('text','IP3:','IP3prompt',0);
    IP3prompt.RowSpan=[rs,rs];
    IP3prompt.ColSpan=[lprompt,rprompt];

    IP3=simrfV2GetLeafWidgetBase('edit','','IP3',this,'IP3');
    IP3.RowSpan=[rs,rs];
    IP3.ColSpan=[ledit,redit];

    IP3_unit=simrfV2GetLeafWidgetBase('combobox','','IP3_unit',...
    this,'IP3_unit');
    IP3_unit.Entries=set(this,'IP3_unit')';
    IP3_unit.RowSpan=[rs,rs];
    IP3_unit.ColSpan=[lunit,runit];


    rs=rs+1;
    P1dB=simrfV2GetLeafWidgetBase('edit','','P1dB',this,'P1dB');
    P1dB.RowSpan=[rs,rs];
    P1dB.ColSpan=[ledit,redit];

    P1dB_unit=simrfV2GetLeafWidgetBase('combobox','','P1dB_unit',...
    this,'P1dB_unit');
    P1dB_unit.Entries=set(this,'P1dB_unit')';
    P1dB_unit.RowSpan=[rs,rs];
    P1dB_unit.ColSpan=[lunit,runit];

    P1dBprompt=simrfV2GetLeafWidgetBase('text',...
    '1-dB gain compression power:','P1dBprompt',0);
    P1dBprompt.RowSpan=[rs,rs];
    P1dBprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    Psat=simrfV2GetLeafWidgetBase('edit','','Psat',this,'Psat');
    Psat.RowSpan=[rs,rs];
    Psat.ColSpan=[ledit,redit];

    Psat_unit=simrfV2GetLeafWidgetBase('combobox','','Psat_unit',...
    this,'Psat_unit');
    Psat_unit.Entries=set(this,'Psat_unit')';
    Psat_unit.RowSpan=[rs,rs];
    Psat_unit.ColSpan=[lunit,runit];

    Psatprompt=simrfV2GetLeafWidgetBase('text',...
    'Output saturation power:','Psatprompt',0);
    Psatprompt.RowSpan=[rs,rs];
    Psatprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    Gcomp=simrfV2GetLeafWidgetBase('edit','','Gcomp',this,'Gcomp');
    Gcomp.RowSpan=[rs,rs];
    Gcomp.ColSpan=[ledit,redit];

    Gcomp_unit=simrfV2GetLeafWidgetBase('combobox','','Gcomp_unit',...
    this,'Gcomp_unit');
    Gcomp_unit.Entries=set(this,'Gcomp_unit')';
    Gcomp_unit.RowSpan=[rs,rs];
    Gcomp_unit.ColSpan=[lunit,runit];

    Gcompprompt=simrfV2GetLeafWidgetBase('text',...
    'Gain compression at saturation:','Gcompprompt',0);
    Gcompprompt.RowSpan=[rs,rs];
    Gcompprompt.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    opfreqprompt=simrfV2GetLeafWidgetBase('text',...
    'Operation frequency:','OpFreqPrompt',0);
    opfreqprompt.RowSpan=[rs,rs];
    opfreqprompt.ColSpan=[lprompt,rprompt];

    opfreq=simrfV2GetLeafWidgetBase('edit','','OpFreq',0,'OpFreq');
    opfreq.RowSpan=[rs,rs];
    opfreq.ColSpan=[ledit,redit];

    opfrequnit=simrfV2GetLeafWidgetBase('combobox','',...
    'OpFreq_unit',this,'OpFreq_unit');
    opfrequnit.Entries=set(this,'OpFreq_unit')';
    opfrequnit.RowSpan=[rs,rs];
    opfrequnit.ColSpan=[lunit,runit];


    rs=rs+1;
    setopfreqasmaxs21=simrfV2GetLeafWidgetBase('checkbox',...
    'Use operation frequency at maximum S21 magnitude',...
    'SetOpFreqAsMaxS21',this,'SetOpFreqAsMaxS21');
    setopfreqasmaxs21.RowSpan=[rs,rs];
    setopfreqasmaxs21.ColSpan=[lprompt,redit];
    setopfreqasmaxs21.DialogRefresh=1;


    rs=rs+1;
    consts21nl=simrfV2GetLeafWidgetBase('checkbox',...
    'Use constant S21 and nonlinearity','ConstS21NL',this,'ConstS21NL');
    consts21nl.RowSpan=[rs,rs];
    consts21nl.ColSpan=[lprompt,redit];
    consts21nl.DialogRefresh=1;


    rs=rs+1;
    spaceropfreq=simrfV2GetLeafWidgetBase('text',' ','',0);
    spaceropfreq.RowSpan=[rs,rs];
    spaceropfreq.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    choosenNL=simrfV2GetLeafWidgetBase('text','Due to...','choosenNL',0);
    choosenNL.RowSpan=[rs,rs];
    choosenNL.ColSpan=[lprompt,runit];
    choosenNL.WordWrap=true;


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt,rprompt];


    if strcmpi(class(this),'simrfV2dialog.Amplifier')
        rs=rs+1;
        plotButton=simrfV2GetLeafWidgetBase(...
        'pushbutton','Plot Power Characteristics',...
        'PlotCharButton',this,'PlotButton');
        plotButton.RowSpan=[rs,rs];
        plotButton.ColSpan=[lunit-6,runit];
        plotButton.ObjectMethod='simrfV2polynumerialplot';
        plotButton.MethodArgs={'%dialog'};
        plotButton.ArgDataTypes={'handle'};
    end


    IPType.Visible=1;
    IPTypeprompt.Visible=1;
    IP2.Visible=0;
    IP2_unit.Visible=0;
    IP2prompt.Visible=0;
    IP3.Visible=0;
    IP3_unit.Visible=0;
    IP3prompt.Visible=0;
    P1dB.Visible=0;
    P1dB_unit.Visible=0;
    P1dBprompt.Visible=0;
    Psat.Visible=0;
    Psat_unit.Visible=0;
    Psatprompt.Visible=0;
    Gcomp.Visible=0;
    Gcomp_unit.Visible=0;
    Gcompprompt.Visible=0;
    Gcomp.Enabled=0;
    Gcomp_unit.Enabled=0;
    consts21nl.Visible=0;
    slBlkVis(idxMaskNames.ConstS21NL)={'off'};
    setopfreqasmaxs21.Visible=0;
    slBlkVis(idxMaskNames.SetOpFreqAsMaxS21)={'off'};
    opfreqprompt.Visible=0;
    opfreq.Visible=0;
    slBlkVis(idxMaskNames.OpFreq)={'off'};
    opfrequnit.Visible=0;
    slBlkVis(idxMaskNames.OpFreq_unit)={'off'};
    spaceropfreq.Visible=0;
    choosenNL.Visible=1;
    slBlkVis([...
    idxMaskNames.IP2,idxMaskNames.IP3...
    ,idxMaskNames.IP2_unit,idxMaskNames.IP3_unit...
    ,idxMaskNames.P1dB,idxMaskNames.P1dB_unit...
    ,idxMaskNames.Psat,idxMaskNames.Psat_unit...
    ,idxMaskNames.Gcomp,idxMaskNames.Gcomp_unit])={'off'};

    switch this.Source_Poly
    case 'Even and odd order'
        IP2.Visible=1;
        IP2_unit.Visible=1;
        IP2prompt.Visible=1;
        IP3.Visible=1;
        IP3_unit.Visible=1;
        IP3prompt.Visible=1;
        slBlkVis([...
        idxMaskNames.IP2,idxMaskNames.IP3...
        ,idxMaskNames.IP2_unit,idxMaskNames.IP3_unit...
        ,idxMaskNames.IPType])={'on'};
    case 'Odd order'
        IP3.Visible=1;
        IP3_unit.Visible=1;
        IP3prompt.Visible=1;
        P1dB.Visible=1;
        P1dB_unit.Visible=1;
        P1dBprompt.Visible=1;
        Psat.Visible=1;
        Psat_unit.Visible=1;
        Psatprompt.Visible=1;
        Gcomp.Visible=1;
        Gcomp_unit.Visible=1;
        Gcompprompt.Visible=1;
        slBlkVis([...
        idxMaskNames.IP3,idxMaskNames.IP3_unit...
        ,idxMaskNames.P1dB,idxMaskNames.P1dB_unit...
        ,idxMaskNames.Psat,idxMaskNames.Psat_unit])={'on'};
        if~strcmpi(this.Psat,'inf')
            Gcomp.Enabled=1;
            Gcomp_unit.Enabled=1;
            slBlkVis([idxMaskNames.Gcomp,idxMaskNames.Gcomp_unit])={'on'};
        end
    end
    choosenNLStr=sprintf(' \n ');
    if((nargin>3)&&(varargin{1}))

        choosenNL.Visible=1;
        consts21nl.Visible=1;
        slBlkVis(idxMaskNames.ConstS21NL)={'on'};
        setopfreqasmaxs21.Visible=1;
        slBlkVis(idxMaskNames.SetOpFreqAsMaxS21)={'on'};
        if~(this.SetOpFreqAsMaxS21)
            opfreqprompt.Visible=1;
            opfreq.Visible=1;
            slBlkVis(idxMaskNames.OpFreq)={'on'};
            opfrequnit.Visible=1;
            slBlkVis(idxMaskNames.OpFreq_unit)={'on'};
            spaceropfreq.Visible=0;
            if~(this.ConstS21NL)
                if(nargin>4)
                    opFreqStr=varargin{2};
                    choosenNLStr=['Due to variation of S21, nonlinearity '...
                    ,'may differ from specifications at frequencies '...
                    ,'other than ',opFreqStr,'.'];
                else
                    choosenNLStr=['Due to variation of S21, nonlinearity may '...
                    ,'differ from specifications'];
                end
            end
        else
            if~(this.ConstS21NL)
                spaceropfreq.Visible=0;
                choosenNLStr=['Due to variation of S21, nonlinearity may '...
                ,'differ from specifications at frequencies other than '...
                ,'the frequency at which S21 magnitude is maximal.'];
            end
        end
    end
    choosenNL.Name=choosenNLStr;

    if strcmpi(class(this),'simrfV2dialog.Amplifier')
        items={Source_Poly,Source_Polyprompt,IPType,IPTypeprompt,...
        IP2,IP2_unit,IP2prompt,IP3,IP3_unit,IP3prompt,...
        Psat,Psat_unit,Psatprompt,P1dB,P1dB_unit,P1dBprompt...
        ,Gcomp,Gcomp_unit,Gcompprompt,consts21nl,setopfreqasmaxs21,...
        opfreqprompt,opfreq,opfrequnit,spaceropfreq,choosenNL,...
        plotButton};
    else
        items={Source_Poly,Source_Polyprompt,IPType,IPTypeprompt,...
        IP2,IP2_unit,IP2prompt,IP3,IP3_unit,IP3prompt,...
        Psat,Psat_unit,Psatprompt,P1dB,P1dB_unit,P1dBprompt...
        ,Gcomp,Gcomp_unit,Gcompprompt,consts21nl,setopfreqasmaxs21,...
        opfreqprompt,opfreq,opfrequnit,spaceropfreq,choosenNL};
    end

    layout.LayoutGrid=[rs,runit];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,rs-1),1];

end

