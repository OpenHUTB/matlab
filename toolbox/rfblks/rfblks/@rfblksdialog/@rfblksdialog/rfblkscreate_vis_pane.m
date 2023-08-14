function[items,layout]=rfblkscreate_vis_pane(this,varargin)




    mydata=varargin{1};
    create_new_dialog=varargin{2};
    sourcefreq_entry=varargin{3};
    plot_callback=varargin{4};


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    middle=9;
    lprompt2=middle+1+1;
    rprompt2=middle+1+rprompt;
    lwidget1=rprompt+1;
    rwidget1=middle;
    lwidget2=rprompt2+2;
    rwidget2=rwidget;
    number_grid=20;


    if~strcmpi(get_param(bdroot,'BlockDiagramType'),'library')&&...
        ~strcmpi(this.Block.MaskType,'Output Port')&&...
        isfield(this.Block.UserData,'Plot')&&~this.Block.UserData.Plot
        temptxt=sprintf(['Visualization is only available when all ',...
        'parameters for this block are valid.']);
        visTitle=rfblksGetLeafWidgetBase('text',temptxt,'VisTitle',0);
        visTitle.RowSpan=[1,1];
        visTitle.ColSpan=[lprompt,rwidget];

        spacerVis=rfblksGetLeafWidgetBase('text','','',0);
        spacerVis.RowSpan=[2,2];
        spacerVis.ColSpan=[lprompt,rwidget];


        items={visTitle,spacerVis};
        layout.LayoutGrid=[2,number_grid];
        layout.RowSpan=[1,1];
        layout.ColSpan=[1,1];
        layout.RowStretch=[0,1];
        return
    end



    sourceFreq=rfblksGetLeafWidgetBase('combobox','','SourceFreq',...
    this,'SourceFreq');
    sourceFreq.RowSpan=[1,1];
    sourceFreq.ColSpan=[lwidget,rwidget];
    sourceFreq.DialogRefresh=1;


    Udata=this.Block.UserData;
    if isfield(Udata,'Ckt')&&isa(Udata.Ckt,'rfckt.rfckt')&&...
        ~isempty(Udata.Ckt.SimulationFreq)
        sourceFreq.Entries={sourcefreq_entry{:},'User-specified',...
        'Derived from Input Port parameters'};
    else
        sourceFreq.Entries={sourcefreq_entry{:},'User-specified'};
    end

    sourceFreqprompt=rfblksGetLeafWidgetBase(...
    'text','Source of frequency data:','SourceFreqPrompt',0);
    sourceFreqprompt.RowSpan=[1,1];
    sourceFreqprompt.ColSpan=[lprompt,rprompt];


    freq=rfblksGetLeafWidgetBase('edit','','Freq',this,'Freq');
    freq.RowSpan=[2,2];
    freq.ColSpan=[lwidget+1,rwidget];

    freqprompt=rfblksGetLeafWidgetBase('text','Frequency data (Hz):',...
    'FreqPrompt',0);
    freqprompt.RowSpan=[2,2];
    freqprompt.ColSpan=[lprompt+1,rprompt];


    if strcmpi(this.SourceFreq,'User-specified')
        freq.Enabled=1;
    else
        freq.Enabled=0;
    end


    plotZ0=rfblksGetLeafWidgetBase('edit','','PlotZ0',this,'PlotZ0');
    plotZ0.RowSpan=[3,3];
    plotZ0.ColSpan=[lwidget,rwidget];

    plotZ0prompt=rfblksGetLeafWidgetBase(...
    'text','Reference impedance (ohms):','PlotZ0Prompt',0);
    plotZ0prompt.RowSpan=[3,3];
    plotZ0prompt.ColSpan=[lprompt,rprompt];


    allPlotType=rfblksGetLeafWidgetBase('combobox','',...
    'AllPlotType',this,'AllPlotType');
    allPlotType.Entries=set(this,'AllPlotType')';
    allPlotType.RowSpan=[4,4];
    allPlotType.ColSpan=[lwidget,rwidget];
    allPlotType.DialogRefresh=1;

    allPlotTypeprompt=rfblksGetLeafWidgetBase('text','Plot type:',...
    'AllPlotTypePrompt',0);
    allPlotTypeprompt.RowSpan=[4,4];
    allPlotTypeprompt.ColSpan=[lprompt,rprompt];


    networkData=rfblksGetLeafWidgetBase('combobox','',...
    'NetworkData1',this);
    networkData.RowSpan=[5,5];
    networkData.ColSpan=[lwidget1,rwidget1];
    networkData.DialogRefresh=1;
    networkData.ObjectMethod='rfblksstoreplotcontrol';
    networkData.ArgDataTypes={'handle','string','mxArray'};

    networkDataprompt=rfblksGetLeafWidgetBase('text','Y parameter1:',...
    'NetworkDataPrompt',0);
    networkDataprompt.RowSpan=[5,5];
    networkDataprompt.ColSpan=[lprompt,rprompt];


    complexFormat=rfblksGetLeafWidgetBase('combobox','',...
    'ComplexFormat1',this);
    complexFormat.RowSpan=[5,5];
    complexFormat.ColSpan=[lwidget2,rwidget2];
    complexFormat.ObjectMethod='rfblksstoreplotcontrol';
    complexFormat.ArgDataTypes={'handle','string','mxArray'};

    complexFormatprompt=rfblksGetLeafWidgetBase('text','Y format1:',...
    'ComplexFormatPrompt',0);
    complexFormatprompt.RowSpan=[5,5];
    complexFormatprompt.ColSpan=[lprompt2,rprompt2];


    networkData2=rfblksGetLeafWidgetBase('combobox','',...
    'NetworkData2',this);
    networkData2.RowSpan=[6,6];
    networkData2.ColSpan=[lwidget1,rwidget1];
    networkData2.DialogRefresh=1;
    networkData2.ObjectMethod='rfblksstoreplotcontrol';
    networkData2.ArgDataTypes={'handle','string','mxArray'};

    networkData2prompt=rfblksGetLeafWidgetBase('text','Y parameter2:',...
    'NetworkData2Prompt',0);
    networkData2prompt.RowSpan=[6,6];
    networkData2prompt.ColSpan=[lprompt,rprompt];


    complexFormat2=rfblksGetLeafWidgetBase('combobox','',...
    'ComplexFormat2',this);
    complexFormat2.RowSpan=[6,6];
    complexFormat2.ColSpan=[lwidget2,rwidget2];
    complexFormat2.ObjectMethod='rfblksstoreplotcontrol';
    complexFormat2.ArgDataTypes={'handle','string','mxArray'};

    complexFormat2prompt=rfblksGetLeafWidgetBase('text','Y format2:',...
    'ComplexFormat2Prompt',0);
    complexFormat2prompt.RowSpan=[6,6];
    complexFormat2prompt.ColSpan=[lprompt2,rprompt2];


    xParameter=rfblksGetLeafWidgetBase('combobox','',...
    'XParameter',this);
    xParameter.RowSpan=[7,7];
    xParameter.ColSpan=[lwidget1,rwidget1];
    xParameter.DialogRefresh=1;
    xParameter.ObjectMethod='rfblksstoreplotcontrol';
    xParameter.ArgDataTypes={'handle','string','mxArray'};

    xParameterprompt=rfblksGetLeafWidgetBase('text','X parameter:',...
    'XParameterPrompt',0);
    xParameterprompt.RowSpan=[7,7];
    xParameterprompt.ColSpan=[lprompt,rprompt];


    xFormat=rfblksGetLeafWidgetBase('combobox','','XFormat',this);
    xFormat.RowSpan=[7,7];
    xFormat.ColSpan=[lwidget2,rwidget2];
    xFormat.ObjectMethod='rfblksstoreplotcontrol';
    xFormat.ArgDataTypes={'handle','string','mxArray'};

    xFormatprompt=rfblksGetLeafWidgetBase('text','X format:',...
    'XFormatPrompt',0);
    xFormatprompt.RowSpan=[7,7];
    xFormatprompt.ColSpan=[lprompt2,rprompt2];


    yoption=rfblksGetLeafWidgetBase('combobox','',...
    'YOption',this,'YOption');
    yoption.RowSpan=[8,8];
    yoption.ColSpan=[lwidget1,rwidget1];

    yoptionprompt=rfblksGetLeafWidgetBase('text','Y scale:',...
    'YOptionPrompt',0);
    yoptionprompt.RowSpan=[8,8];
    yoptionprompt.ColSpan=[lprompt,rprompt];


    xoption=rfblksGetLeafWidgetBase('combobox','',...
    'XOption',this,'XOption');
    xoption.RowSpan=[8,8];
    xoption.ColSpan=[lwidget2,rwidget2];

    xoptionprompt=rfblksGetLeafWidgetBase('text','X scale:',...
    'XOptionPrompt',0);
    xoptionprompt.RowSpan=[8,8];
    xoptionprompt.ColSpan=[lprompt2,rprompt2];


    plotButton=rfblksGetLeafWidgetBase('pushbutton','Plot',...
    'PlotButton',this,'PlotButton');
    plotButton.RowSpan=[10,10];
    plotButton.ColSpan=[rwidget-1,rwidget];

    spacerVisualization=rfblksGetLeafWidgetBase('text','','',0);
    spacerVisualization.RowSpan=[9,9];
    spacerVisualization.ColSpan=[lprompt,rprompt];
    allparams=listparam(mydata,this.AllPlotType,this.Block.MaskType);

    switch this.AllPlotType
    case 'X-Y plane'
        networkData.Enabled=1;
        networkData.Entries=allparams;
        complexFormat.Enabled=1;
        networkData2.Enabled=1;
        complexFormat2.Enabled=1;
        xoption.Enabled=1;
        yoption.Enabled=1;
        xParameter.Enabled=1;
        xFormat.Enabled=1;

    case 'Composite data'
        networkData.Enabled=0;
        networkData.Entries=allparams;
        complexFormat.Enabled=0;
        networkData2.Enabled=0;
        complexFormat2.Enabled=0;
        xoption.Enabled=0;
        yoption.Enabled=0;
        xParameter.Enabled=0;
        xFormat.Enabled=0;

    case 'Polar plane'
        networkData.Enabled=1;
        networkData.Entries=allparams;
        complexFormat.Enabled=0;
        networkData2.Enabled=1;
        complexFormat2.Enabled=0;
        xoption.Enabled=0;
        yoption.Enabled=0;
        xParameter.Enabled=1;
        xFormat.Enabled=1;

    case{'Z Smith chart','Y Smith chart','ZY Smith chart'}
        networkData.Enabled=1;
        networkData.Entries=allparams;
        complexFormat.Enabled=0;
        networkData2.Enabled=1;
        complexFormat2.Enabled=0;
        xoption.Enabled=0;
        yoption.Enabled=0;
        xParameter.Enabled=1;
        xFormat.Enabled=1;

    case 'Link budget'
        networkData.Enabled=1;
        networkData.Entries=allparams;
        complexFormat.Enabled=1;
        networkData2.Enabled=0;
        complexFormat2.Enabled=0;
        xoption.Enabled=0;
        yoption.Enabled=0;
        xParameter.Enabled=1;
        xFormat.Enabled=1;

    end
    if~isempty(this.Block.UserData)&&...
        isfield(this.Block.UserData,'NetworkData1')
        networkData2.Entries=listparam(mydata,this.AllPlotType,...
        this.Block.MaskType,this.Block.UserData.NetworkData1);
    else
        networkData2.Entries=listparam(mydata,this.AllPlotType,...
        this.Block.MaskType,this.Block.AppliedNetworkData);
    end
    if create_new_dialog&&~isempty(this.Block.AppliedNetworkData)&&...
        ~isempty(this.Block.AppliedXParameter)&&...
        any(strcmpi(this.Block.AppliedNetworkData,allparams))&&...
        any(strcmpi(this.Block.AppliedNetworkData2,{allparams{:},'   '}))

        complexFormat.Entries=listformat(mydata,...
        this.Block.AppliedNetworkData,this.AllPlotType);
        if~isempty(strtrim(this.Block.AppliedNetworkData2))
            complexFormat2.Entries=listformat(mydata,...
            this.Block.AppliedNetworkData2,this.AllPlotType);
        else
            complexFormat2.Entries={'   '};
        end
        xParameter.Entries=listxparam(mydata,this.Block.AppliedNetworkData);
        xFormat.Entries=listxformat(mydata,this.Block.AppliedXParameter);

        networkData.Value=this.Block.AppliedNetworkData;
        networkData2.Value=this.Block.AppliedNetworkData2;
        complexFormat.Value=this.Block.AppliedComplexFormat;
        complexFormat2.Value=this.Block.AppliedComplexFormat2;
        xParameter.Value=this.Block.AppliedXParameter;
        xFormat.Value=this.Block.AppliedXFormat;

        [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
        if~isLibrary&&~isLocked
            this.Block.UserData.NetworkData1=this.Block.AppliedNetworkData;
            this.Block.UserData.NetworkData2=this.Block.AppliedNetworkData2;
            this.Block.UserData.ComplexFormat1=...
            this.Block.AppliedComplexFormat;
            this.Block.UserData.ComplexFormat2=...
            this.Block.AppliedComplexFormat2;
            this.Block.UserData.XParameter=this.Block.AppliedXParameter;
            this.Block.UserData.XFormat=this.Block.AppliedXFormat;
        end

    elseif all(isfield(this.Block.UserData,{'NetworkData1','XParameter',...
        'NetworkData2'}))&&...
        ~isempty(this.Block.UserData.NetworkData1)&&...
        ~isempty(this.Block.UserData.XParameter)&&...
        any(strcmpi(this.Block.UserData.NetworkData1,allparams))&&...
        any(strcmpi(this.Block.UserData.NetworkData2,...
        {allparams{:},'   '}))

        if any(strcmp(this.Block.UserData.NetworkData1,networkData.Entries))
            networkData.Value=this.Block.UserData.NetworkData1;
        else
            networkData.Value=networkData.Entries{1};
            this.Block.UserData.NetworkData1=networkData.Entries{1};
        end
        if any(strcmp(this.Block.UserData.NetworkData2,networkData2.Entries))
            networkData2.Value=this.Block.UserData.NetworkData2;
        else
            networkData2.Value=networkData2.Entries{1};
            this.Block.UserData.NetworkData2=networkData2.Entries{1};
        end

        complexFormat.Entries=listformat(mydata,...
        this.Block.UserData.NetworkData1,this.AllPlotType);
        if~isempty(strtrim(this.Block.UserData.NetworkData2))
            complexFormat2.Entries=listformat(mydata,...
            this.Block.UserData.NetworkData2,this.AllPlotType);
        else
            complexFormat2.Entries={'   '};
        end
        xParameter.Entries=listxparam(mydata,...
        this.Block.UserData.NetworkData1);

        if any(strcmp(this.Block.UserData.ComplexFormat1,...
            complexFormat.Entries))
            complexFormat.Value=this.Block.UserData.ComplexFormat1;
        else
            complexFormat.Value=complexFormat.Entries{1};
            this.Block.UserData.ComplexFormat1=complexFormat.Entries{1};
        end
        if any(strcmp(this.Block.UserData.ComplexFormat2,...
            complexFormat2.Entries))
            complexFormat2.Value=this.Block.UserData.ComplexFormat2;
        else
            complexFormat2.Value=complexFormat2.Entries{1};
            this.Block.UserData.ComplexFormat2=complexFormat2.Entries{1};
        end
        if any(strcmp(this.Block.UserData.XParameter,xParameter.Entries))
            xParameter.Value=this.Block.UserData.XParameter;
        else
            xParameter.Value=xParameter.Entries{1};
            this.Block.UserData.XParameter=xParameter.Entries{1};
        end

        xFormat.Entries=listxformat(mydata,this.Block.UserData.XParameter);
        if any(strcmp(this.Block.UserData.XFormat,xFormat.Entries))
            xFormat.Value=this.Block.UserData.XFormat;
        else
            xFormat.Value=xFormat.Entries{1};
            this.Block.UserData.XFormat=xFormat.Entries{1};
        end

    else
        complexFormat.Entries=listformat(mydata,networkData.Entries{1});
        if~isempty(strtrim(networkData2.Entries{1}))
            complexFormat2.Entries=listformat(mydata,...
            networkData2.Entries{1});
        else
            complexFormat2.Entries={'   '};
        end
        xParameter.Entries=listxparam(mydata,networkData.Entries{1});
        xFormat.Entries=listxformat(mydata,xParameter.Entries{1});

        networkData.Value=0;
        networkData2.Value=0;
        complexFormat.Value=0;
        complexFormat2.Value=0;
        xParameter.Value=0;
        xFormat.Value=0;

        this.Block.UserData.NetworkData1=networkData.Entries{1};
        this.Block.UserData.NetworkData2=networkData2.Entries{1};
        this.Block.UserData.ComplexFormat1=complexFormat.Entries{1};
        this.Block.UserData.ComplexFormat2=complexFormat2.Entries{1};
        this.Block.UserData.XParameter=xParameter.Entries{1};
        this.Block.UserData.XFormat=xFormat.Entries{1};

    end


    Udata=this.Block.UserData;
    if strcmpi(this.Block.MaskType,'Output Port')

        if~isempty(Udata.System.OriginalCkt.SimulationFreq)
            sourceFreq.Entries={'Derived from Input Port parameters';...
            'User-specified'};
        else
            sourceFreq.Entries={'User-specified'};
        end

        if numel(Udata.System.OriginalCkt.Ckts)>1
            allPlotType.Entries=set(this,'AllPlotType')';
        else
            allPlotType.Entries={...
            'Composite data',...
            'X-Y plane',...
            'Polar plane',...
            'Z Smith chart',...
            'Y Smith chart',...
            'ZY Smith chart'}';
        end
        plotflag='system';
    else
        plotflag='none';
    end

    networkData.MethodArgs={'%dialog','%tag',networkData.Entries};
    complexFormat.MethodArgs={'%dialog','%tag',complexFormat.Entries};
    networkData2.MethodArgs={'%dialog','%tag',networkData2.Entries};
    complexFormat2.MethodArgs={'%dialog','%tag',complexFormat2.Entries};
    xParameter.MethodArgs={'%dialog','%tag',xParameter.Entries};
    xFormat.MethodArgs={'%dialog','%tag',xFormat.Entries};
    plotButton.MatlabMethod=plot_callback;
    plotButton.MatlabArgs={[this.Block.Path,'/',this.Block.Name],...
    '%dialog',networkData.Entries,complexFormat.Entries,...
    networkData2.Entries,complexFormat2.Entries,xParameter.Entries,...
    xFormat.Entries,sourceFreq.Entries,allPlotType.Entries,plotflag};


    if strcmpi(networkData.Value,'PhaseNoise')||...
        strcmpi(networkData2.Value,'PhaseNoise')
        freq.Enabled=0;
        xoption.Enabled=0;
        yoption.Enabled=0;
        this.XOption='Log';
        this.YOption='Linear';
    end


    refz0_not_need={'Pout','Phase','LS11','LS21','LS12','LS22',...
    'AM/AM','AM/PM','OIP3','NF','RN','GAMMAOPT',...
    'FMIN','PhaseNoise'};
    if any(strcmpi(networkData.Value,refz0_not_need))||...
        any(strcmpi(networkData2.Value,refz0_not_need))
        tempstr='50';
        if hasnetworkreference(mydata)
            tempref=getreference(mydata);
            tempstr=num2str(tempref.NetworkData.Z0);
        end
        plotZ0.Enabled=0;
        plotZ0.Value=tempstr;
        this.PlotZ0=tempstr;
    else
        plotZ0.Enabled=1;
    end


    items={sourceFreq,sourceFreqprompt,freq,freqprompt,...
    allPlotType,allPlotTypeprompt,networkData,networkDataprompt,...
    complexFormat,complexFormatprompt,...
    networkData2,networkData2prompt,...
    complexFormat2,complexFormat2prompt,yoption,yoptionprompt,...
    xoption,xoptionprompt,plotButton,xParameter,xParameterprompt,...
    xFormat,xFormatprompt,plotZ0,plotZ0prompt,spacerVisualization};

    layout.LayoutGrid=[10,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,8),1,0];

