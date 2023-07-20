function[items,layout,slBlkVis]=simrfV2create_vis_pane(this,...
    slBlkVis,idxMaskNames,varargin)





    lprompt=1;
    rprompt=4;
    lwidget1=rprompt+1;
    rwidget1=9;
    lprompt2=rwidget1+5;
    rprompt2=rwidget1+1+rprompt;
    lwidget2=rprompt2+3;
    runit=20;




    rs=1;
    sourceFreqprompt=simrfV2GetLeafWidgetBase('text',...
    'Source of frequency data:','SourceFreqPrompt',0);
    sourceFreqprompt.RowSpan=[rs,rs];
    sourceFreqprompt.ColSpan=[lprompt,rprompt];

    sourceFreq=simrfV2GetLeafWidgetBase('combobox','','SourceFreq',...
    this,'SourceFreq');
    sourceFreq.RowSpan=[rs,rs];
    sourceFreq.ColSpan=[lwidget1,runit];
    sourceFreq.DialogRefresh=1;
    sourceFreq.Entries=set(this,'SourceFreq')';


    rs=rs+1;
    freqprompt=simrfV2GetLeafWidgetBase('text','Frequency data:',...
    'FreqPrompt',0);
    freqprompt.RowSpan=[rs,rs];
    freqprompt.ColSpan=[lprompt+1,rprompt+1];

    freq=simrfV2GetLeafWidgetBase('edit','','PlotFreq',this,'PlotFreq');
    freq.RowSpan=[rs,rs];
    freq.ColSpan=[lwidget1+1,lwidget2-1];

    frequnit=simrfV2GetLeafWidgetBase('combobox','','PlotFreq_unit',...
    this,'PlotFreq_unit');
    frequnit.RowSpan=[rs,rs];
    frequnit.ColSpan=[lwidget2,runit];
    frequnit.Entries=set(this,'PlotFreq_unit')';



    if strcmpi(this.SourceFreq,'User-specified')
        freq.Visible=1;
        frequnit.Visible=1;
        freqprompt.Visible=1;
        slBlkVis([idxMaskNames.PlotFreq,idxMaskNames.PlotFreq_unit])={'on'};
    else
        freq.Visible=0;
        frequnit.Visible=0;
        freqprompt.Visible=0;
        slBlkVis([idxMaskNames.PlotFreq,idxMaskNames.PlotFreq_unit])={'off'};
    end


    rs=rs+1;
    allPlotTypeprompt=simrfV2GetLeafWidgetBase('text','Plot type:',...
    'PlotTypePrompt',0);
    allPlotTypeprompt.RowSpan=[rs,rs];
    allPlotTypeprompt.ColSpan=[lprompt,rprompt];

    allPlotType=simrfV2GetLeafWidgetBase('combobox','',...
    'PlotType',this,'PlotType');
    allPlotType.Entries=set(this,'PlotType')';
    allPlotType.RowSpan=[rs,rs];
    allPlotType.ColSpan=[lwidget1,runit];
    allPlotType.DialogRefresh=1;


    rs=rs+1;
    networkDataprompt=simrfV2GetLeafWidgetBase('text','Parameter1:',...
    'YParam1Prompt',0);
    networkDataprompt.RowSpan=[rs,rs];
    networkDataprompt.ColSpan=[lprompt,rprompt];

    networkData=simrfV2GetLeafWidgetBase('combobox','',...
    'YParam1',this,'YParam1');
    networkData.RowSpan=[rs,rs];
    networkData.ColSpan=[lwidget1,rwidget1];
    networkData.Entries=this.Block.getPropAllowedValues('YParam1');
    networkData.DialogRefresh=1;


    complexFormatprompt=simrfV2GetLeafWidgetBase('text','Format1:',...
    'YFormat1Prompt',0);
    complexFormatprompt.RowSpan=[rs,rs];
    complexFormatprompt.ColSpan=[lprompt2,rprompt2];

    complexFormat=simrfV2GetLeafWidgetBase('combobox','',...
    'YFormat1',this,'YFormat1');
    complexFormat.RowSpan=[rs,rs];
    complexFormat.ColSpan=[lwidget2,runit];
    complexFormat.Entries=refineFormat(this,set(this,'YFormat1')',...
    this.YParam1,'YFormat1');


    rs=rs+1;
    networkData2prompt=simrfV2GetLeafWidgetBase('text','Parameter2:',...
    'YParam2Prompt',0);
    networkData2prompt.RowSpan=[rs,rs];
    networkData2prompt.ColSpan=[lprompt,rprompt];

    networkData2=simrfV2GetLeafWidgetBase('combobox','',...
    'YParam2',this,'YParam2');
    networkData2.RowSpan=[rs,rs];
    networkData2.ColSpan=[lwidget1,rwidget1];
    networkData2.Entries=this.Block.getPropAllowedValues('YParam2');
    networkData2.DialogRefresh=1;


    complexFormat2prompt=simrfV2GetLeafWidgetBase('text','Format2:',...
    'YFormat2Prompt',0);
    complexFormat2prompt.RowSpan=[rs,rs];
    complexFormat2prompt.ColSpan=[lprompt2,rprompt2];

    complexFormat2=simrfV2GetLeafWidgetBase('combobox','',...
    'YFormat2',this,'YFormat2');
    complexFormat2.RowSpan=[rs,rs];
    complexFormat2.ColSpan=[lwidget2,runit];
    complexFormat2.Entries=set(this,'YFormat2')';
    complexFormat2.Entries=refineFormat(this,set(this,'YFormat2')',...
    this.YParam2,'YFormat2');


    rs=rs+1;
    yoptionprompt=simrfV2GetLeafWidgetBase('text','Y-axis scale:',...
    'YOptionPrompt',0);
    yoptionprompt.RowSpan=[rs,rs];
    yoptionprompt.ColSpan=[lprompt,rprompt];

    yoption=simrfV2GetLeafWidgetBase('combobox','','YOption',...
    this,'YOption');
    yoption.RowSpan=[rs,rs];
    yoption.ColSpan=[lwidget1,rwidget1];


    xoptionprompt=simrfV2GetLeafWidgetBase('text','X-axis scale:',...
    'XOptionPrompt',0);
    xoptionprompt.RowSpan=[rs,rs];
    xoptionprompt.ColSpan=[lprompt2,rprompt2];

    xoption=simrfV2GetLeafWidgetBase('combobox','',...
    'XOption',this,'XOption');
    xoption.RowSpan=[rs,rs];
    xoption.ColSpan=[lwidget2,runit];


    rs=rs+1;
    spacerVisualization=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerVisualization.RowSpan=[rs,rs];
    spacerVisualization.ColSpan=[lprompt,rprompt];


    rs=rs+1;
    plotButton=simrfV2GetLeafWidgetBase('pushbutton','Plot',...
    'PlotButton',this,'PlotButton');
    plotButton.RowSpan=[rs,rs];
    plotButton.ColSpan=[runit-1,runit];
    plotButton.ObjectMethod='simrfV2visualplot';
    plotButton.MethodArgs={'%dialog'};
    plotButton.ArgDataTypes={'handle'};


    switch this.PlotType
    case 'X-Y plane'
        networkData.Visible=1;
        complexFormat.Visible=1;
        networkData2.Visible=1;
        complexFormat2.Visible=1;
        xoption.Visible=1;
        yoption.Visible=1;
        complexFormatprompt.Visible=1;
        complexFormat2prompt.Visible=1;
        xoptionprompt.Visible=1;
        yoptionprompt.Visible=1;

    case 'Polar plane'
        networkData.Visible=1;
        complexFormat.Visible=0;
        networkData2.Visible=1;
        complexFormat2.Visible=0;
        xoption.Visible=0;
        yoption.Visible=0;
        complexFormatprompt.Visible=0;
        complexFormat2prompt.Visible=0;
        xoptionprompt.Visible=0;
        yoptionprompt.Visible=0;

    case{'Z Smith chart','Y Smith chart','ZY Smith chart'}
        networkData.Visible=1;
        complexFormat.Visible=0;
        networkData2.Visible=1;
        complexFormat2.Visible=0;
        xoption.Visible=0;
        yoption.Visible=0;
        complexFormatprompt.Visible=0;
        complexFormat2prompt.Visible=0;
        xoptionprompt.Visible=0;
        yoptionprompt.Visible=0;
    end


    items={sourceFreq,sourceFreqprompt,freq,frequnit,freqprompt,...
    allPlotType,allPlotTypeprompt,networkData,networkDataprompt,...
    complexFormat,complexFormatprompt,networkData2,...
    networkData2prompt,complexFormat2,complexFormat2prompt,...
    yoption,yoptionprompt,xoption,xoptionprompt,plotButton,...
    spacerVisualization};

    layout.LayoutGrid=[rs,runit];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,8),1];

end


function entries=refineFormat(this,entries,yparm,yformat)



    if strcmpi(yparm,'NF')
        this.Block.(yformat)='Magnitude (dB)';
        this.(yformat)='Magnitude (dB)';
        entries=entries(1);
    end
end

