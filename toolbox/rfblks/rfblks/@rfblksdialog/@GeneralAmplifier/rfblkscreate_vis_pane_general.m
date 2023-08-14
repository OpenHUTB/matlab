function[items,layout]=rfblkscreate_vis_pane_general(this,varargin)






    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;


    [items,layout]=rfblkscreate_vis_pane(this,varargin{:});
    if~strcmpi(get_param(bdroot,'BlockDiagramType'),'library')&&...
        isfield(this.Block.UserData,'Plot')&&~this.Block.UserData.Plot
        return
    end

    [sourceFreq,sourceFreqprompt,freq,freqprompt,...
    allPlotType,allPlotTypeprompt,networkData,networkDataprompt,...
    complexFormat,complexFormatprompt,networkData2,networkData2prompt,...
    complexFormat2,complexFormat2prompt,yoption,yoptionprompt,...
    xoption,xoptionprompt,plotButton,xParameter,xParameterprompt,...
    xFormat,xFormatprompt,plotZ0,plotZ0prompt,spacerVisualization]...
    =deal(items{:});



    sourcePin=rfblksGetLeafWidgetBase('combobox','','SourcePin',this,'SourcePin');
    sourcePin.Entries=set(this,'SourcePin')';
    sourcePin.ColSpan=[lwidget,rwidget];
    sourcePin.DialogRefresh=1;

    sourcePinprompt=rfblksGetLeafWidgetBase('text','Source of input power data:',...
    'SourcePinPrompt',0);
    sourcePinprompt.ColSpan=[lprompt,rprompt];


    pin=rfblksGetLeafWidgetBase('edit','','Pin',this,'Pin');
    pin.ColSpan=[lwidget+1,rwidget];

    pinprompt=rfblksGetLeafWidgetBase('text','Input power data (dBm):',...
    'PinPrompt',0);
    pinprompt.ColSpan=[lprompt+1,rprompt];


    sourceFreq.RowSpan=[1,1];
    sourceFreqprompt.RowSpan=[1,1];
    freq.RowSpan=[2,2];
    freqprompt.RowSpan=[2,2];
    sourcePin.RowSpan=[3,3];
    sourcePinprompt.RowSpan=[3,3];
    pin.RowSpan=[4,4];
    pinprompt.RowSpan=[4,4];
    plotZ0.RowSpan=[5,5];
    plotZ0prompt.RowSpan=[5,5];
    allPlotType.RowSpan=[6,6];
    allPlotTypeprompt.RowSpan=[6,6];
    networkData.RowSpan=[7,7];
    networkDataprompt.RowSpan=[7,7];
    complexFormat.RowSpan=[7,7];
    complexFormatprompt.RowSpan=[7,7];
    networkData2.RowSpan=[8,8];
    networkData2prompt.RowSpan=[8,8];
    complexFormat2.RowSpan=[8,8];
    complexFormat2prompt.RowSpan=[8,8];
    xParameter.RowSpan=[9,9];
    xParameterprompt.RowSpan=[9,9];
    xFormat.RowSpan=[9,9];
    xFormatprompt.RowSpan=[9,9];
    yoption.RowSpan=[10,10];
    yoptionprompt.RowSpan=[10,10];
    xoption.RowSpan=[10,10];
    xoptionprompt.RowSpan=[10,10];
    plotButton.RowSpan=[12,12];
    spacerVisualization.RowSpan=[11,11];



    power_nature={'Pout','Phase','LS11','LS21','LS12','LS22','AM/AM','AM/PM'};
    if~any(strcmpi(networkData.Value,power_nature))&&...
        ~any(strcmpi(networkData2.Value,power_nature))
        sourcePin.Enabled=0;
        pin.Enabled=0;
    else
        sourcePin.Enabled=1;
        pin.Enabled=1;
    end

    if sourcePin.Enabled&&strcmpi(this.SourcePin,'User-specified')
        pin.Enabled=1;
    else
        pin.Enabled=0;
    end

    plotButton.MatlabArgs={[this.Block.Path,'/',this.Block.Name],...
    '%dialog',networkData.Entries,complexFormat.Entries,...
    networkData2.Entries,complexFormat2.Entries,xParameter.Entries,...
    xFormat.Entries,sourceFreq.Entries,allPlotType.Entries,...
    'generalactive'};

    items={sourceFreq,sourceFreqprompt,freq,freqprompt,...
    allPlotType,allPlotTypeprompt,networkData,networkDataprompt,...
    complexFormat,complexFormatprompt,networkData2,networkData2prompt,...
    complexFormat2,complexFormat2prompt,yoption,yoptionprompt,...
    xoption,xoptionprompt,plotButton,xParameter,xParameterprompt,...
    xFormat,xFormatprompt,sourcePin,sourcePinprompt,...
    pin,pinprompt,plotZ0,plotZ0prompt,spacerVisualization};
    layout.LayoutGrid=[12,number_grid];
    layout.RowStretch=[zeros(1,10),1,0];


