function[items,layout,slBlkVis]=...
    simrfV2create_filtvis_pane(this,slBlkVis,idxMaskNames,varargin)





    pwidth=4;
    lprompt1=1;
    rprompt1=lprompt1+pwidth;
    lwidget1=rprompt1+1;
    rwidget1=lwidget1+pwidth;
    lprompt2=rwidget1+1;
    rprompt2=lprompt2+pwidth;
    lwidget2=rprompt2+1;
    rwidget2=lwidget2+pwidth;


    rs=1;



    plotleftprompt=simrfV2GetLeafWidgetBase('text','Parameter1: ',...
    'PlotLeftPrompt',0);
    plotleftprompt.RowSpan=[rs,rs];
    plotleftprompt.ColSpan=[lprompt1,rprompt1];

    plotleftfunc=simrfV2GetLeafWidgetBase('combobox','','PlotFuncLeft',...
    this,'PlotFuncLeft');
    plotleftfunc.RowSpan=[rs,rs];
    plotleftfunc.ColSpan=[lwidget1,rwidget1];
    plotleftfunc.Entries=set(this,'PlotFuncLeft');
    plotleftfunc.DialogRefresh=1;


    plotleftformatprompt=simrfV2GetLeafWidgetBase('text','    Format1:',...
    'YFormat1Prompt',0);
    plotleftformatprompt.RowSpan=[rs,rs];
    plotleftformatprompt.ColSpan=[lprompt2,rprompt2];

    plotleftformat=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotLeftForm',this,'PlotLeftForm');
    plotleftformat.RowSpan=[rs,rs];
    plotleftformat.ColSpan=[lwidget2,rwidget2];
    plotleftformat.Entries=refineEntries(this.PlotFuncLeft,...
    set(this,'PlotLeftForm')');

    rs=rs+1;



    plotrightprompt=simrfV2GetLeafWidgetBase('text',...
    'Parameter2: ','PlotRightPrompt',0);
    plotrightprompt.RowSpan=[rs,rs];
    plotrightprompt.ColSpan=[lprompt1,rprompt1];

    plotrightfuncnovt=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightOnVT',this,'PlotRightOnVT');
    plotrightfuncnovt.RowSpan=[rs,rs];
    plotrightfuncnovt.ColSpan=[lwidget1,rwidget1];
    plotrightfuncnovt.Entries=set(this,'PlotRightOnVT');
    plotrightfuncnovt.Visible=0;
    plotrightfuncnovt.DialogRefresh=1;

    plotrightfuncnotd=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightNoTD',this,'PlotRightNoTD');
    plotrightfuncnotd.RowSpan=[rs,rs];
    plotrightfuncnotd.ColSpan=[lwidget1,rwidget1];
    plotrightfuncnotd.Entries=set(this,'PlotRightNoTD');
    plotrightfuncnotd.Visible=0;
    plotrightfuncnotd.DialogRefresh=1;

    plotrightfuncnogd=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightNoGD',this,'PlotRightNoGD');
    plotrightfuncnogd.RowSpan=[rs,rs];
    plotrightfuncnogd.ColSpan=[lwidget1,rwidget1];
    plotrightfuncnogd.Entries=set(this,'PlotRightNoGD');
    plotrightfuncnogd.Visible=0;
    plotrightfuncnogd.DialogRefresh=1;

    plotrightfuncnoir=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightNoIR',this,'PlotRightNoIR');
    plotrightfuncnoir.RowSpan=[rs,rs];
    plotrightfuncnoir.ColSpan=[lwidget1,rwidget1];
    plotrightfuncnoir.Entries=set(this,'PlotRightNoIR');
    plotrightfuncnoir.Visible=0;

    plotrightfuncnosr=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightNoSR',this,'PlotRightNoSR');
    plotrightfuncnosr.RowSpan=[rs,rs];
    plotrightfuncnosr.ColSpan=[lwidget1,rwidget1];
    plotrightfuncnosr.Entries=set(this,'PlotRightNoSR');
    plotrightfuncnosr.Visible=0;


    plotrightformatprompt=simrfV2GetLeafWidgetBase('text',...
    '    Format2:','YFormat2Prompt',0);
    plotrightformatprompt.RowSpan=[rs,rs];
    plotrightformatprompt.ColSpan=[lprompt2,rprompt2];

    plotrightformat=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotRightForm',this,'PlotRightForm');
    plotrightformat.RowSpan=[rs,rs];
    plotrightformat.ColSpan=[lwidget2,rwidget2];



    rs=rs+1;



    freqprompt=simrfV2GetLeafWidgetBase('text','Frequency points:',...
    'FreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt1,rprompt1];
    freqprompt.Visible=0;

    freq=simrfV2GetLeafWidgetBase('edit','','FreqPoints',this,...
    'FreqPoints');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[lwidget1,rwidget2-2];
    freq.Visible=0;

    freq_unit=simrfV2GetLeafWidgetBase('combobox','','Freq_unit',...
    this,'Freq_unit');
    freq_unit.RowSpan=[rs,rs];
    freq_unit.ColSpan=[rwidget2-1,rwidget2];
    freq_unit.Entries=set(this,'Freq_unit')';
    freq_unit.Visible=1;


    timeprompt=simrfV2GetLeafWidgetBase('text','Time points:',...
    'TimePrompt',0);
    timeprompt.RowSpan=[rs,rs];
    timeprompt.ColSpan=[lprompt1,rprompt1];
    timeprompt.Visible=0;

    time=simrfV2GetLeafWidgetBase('edit','','TimePoints',this,...
    'TimePoints');
    time.RowSpan=[rs,rs];
    time.ColSpan=[lwidget1,rwidget2-2];
    time.Visible=0;

    time_unit=simrfV2GetLeafWidgetBase('combobox','','Time_unit',...
    this,'Time_unit');
    time_unit.RowSpan=[rs,rs];
    time_unit.ColSpan=[rwidget2-1,rwidget2];
    time_unit.Entries=set(this,'Time_unit')';
    time_unit.Visible=0;

    rs=rs+1;



    xaxisscaleprompt=simrfV2GetLeafWidgetBase('text','X-axis scale:',...
    'XaxisScalePrompt',0);
    xaxisscaleprompt.RowSpan=[rs,rs];
    xaxisscaleprompt.ColSpan=[lprompt1,rprompt1];

    xaxisscale=simrfV2GetLeafWidgetBase('combobox','',...
    'XaxisScale',this,'XaxisScale');
    xaxisscale.RowSpan=[rs,rs];
    xaxisscale.ColSpan=[lwidget1,rwidget1];


    yaxisscaleprompt=simrfV2GetLeafWidgetBase('text',...
    '    Y-axis scale:','YaxisScalePrompt',0);
    yaxisscaleprompt.RowSpan=[rs,rs];
    yaxisscaleprompt.ColSpan=[lprompt2,rprompt2];

    yaxisscale=simrfV2GetLeafWidgetBase('combobox','',...
    'YaxisScale',this,'YaxisScale');
    yaxisscale.RowSpan=[rs,rs];
    yaxisscale.ColSpan=[lwidget2,rwidget2];

    rs=rs+1;
    spacerVisualization=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerVisualization.RowSpan=[rs,rs];
    spacerVisualization.ColSpan=[lprompt1,rprompt1];

    rs=rs+1;

    plotButton=simrfV2GetLeafWidgetBase('pushbutton','Plot',...
    'PlotButton',this,'PlotButton');
    plotButton.RowSpan=[rs,rs];
    plotButton.ColSpan=[rwidget2-1,rwidget2];
    plotButton.ObjectMethod='simrfV2filtvisualplot';
    plotButton.MethodArgs={'%dialog'};
    plotButton.ArgDataTypes={'handle'};




    slBlkVis([...
    idxMaskNames.FreqPoints,idxMaskNames.TimePoints])={'off'};

    switch this.PlotFuncLeft
    case 'Voltage transfer'
        plotrightfuncnovt.Visible=1;
        freqprompt.Visible=1;
        freq.Visible=1;
        freq_unit.Visible=1;
        slBlkVis(idxMaskNames.FreqPoints)={'on'};
        plotFunc=this.PlotRightOnVT;
    case 'Phase delay'
        plotrightfuncnotd.Visible=1;
        freqprompt.Visible=1;
        freq.Visible=1;
        freq_unit.Visible=1;
        slBlkVis(idxMaskNames.FreqPoints)={'on'};
        plotFunc=this.PlotRightNoTD;
    case 'Group delay'
        plotrightfuncnogd.Visible=1;
        freqprompt.Visible=1;
        freq.Visible=1;
        freq_unit.Visible=1;
        slBlkVis(idxMaskNames.FreqPoints)={'on'};
        plotFunc=this.PlotRightNoGD;
    case 'Impulse response'
        plotrightfuncnoir.Visible=1;
        timeprompt.Visible=1;
        time.Visible=1;
        time_unit.Visible=1;
        slBlkVis(idxMaskNames.TimePoints)={'on'};
        plotFunc=this.PlotRightNoIR;
    case 'Step response'
        plotrightfuncnosr.Visible=1;
        timeprompt.Visible=1;
        time.Visible=1;
        time_unit.Visible=1;
        slBlkVis(idxMaskNames.TimePoints)={'on'};
        plotFunc=this.PlotRightNoSR;
    end
    plotrightformat.Entries=refineEntries(plotFunc,...
    set(this,'PlotLeftForm')');

    if any(strcmpi(this.PlotFuncLeft,{'Phase delay','Group delay'}))&&...
        any(strcmpi(this.PlotLeftForm,{'Angle (degrees)','Real','Imaginary'}))
        this.PlotLeftForm='Magnitude (dB)';
    end

    if any(strcmpi(plotFunc,{'Phase delay','Group delay'}))&&...
        any(strcmpi(this.PlotRightForm,{'Angle (degrees)','Real','Imaginary'}))
        this.PlotRightForm='Magnitude (dB)';
    end


    items={...
    plotleftfunc,plotleftformat,...
    plotleftformatprompt,plotleftprompt,...
    plotrightfuncnovt,plotrightfuncnotd,...
    plotrightfuncnogd,plotrightfuncnoir,...
    plotrightfuncnosr,plotrightformat,...
    plotrightformatprompt,plotrightprompt,...
    xaxisscaleprompt,xaxisscale...
    ,yaxisscaleprompt,yaxisscale...
    ,freqprompt,freq,...
    freq_unit,...
    timeprompt,time,...
    time_unit,...
    spacerVisualization,plotButton};

    layout.LayoutGrid=[rs,rwidget2];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.ColStretch=[zeros(1,rs-2),ones(1,2)];
    layout.RowStretch=[zeros(1,rprompt1),ones(1,rwidget2-rprompt1)];

end

function entries=refineEntries(plotFunc,entries)

    if any(strcmpi(plotFunc,{'Phase delay','Group delay',...
        'Impulse response','Step response'}))
        entries=entries(1:2);
    end

end

