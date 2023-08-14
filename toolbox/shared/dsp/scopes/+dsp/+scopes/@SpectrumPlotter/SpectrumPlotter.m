classdef SpectrumPlotter<matlabshared.scopes.visual.AbstractFramePlotter&...
    matlabshared.scopes.mixin.InteractiveLegend





    properties

        MaxHoldTraceFlag=false

        MinHoldTraceFlag=false

        NormalTraceFlag=true

        CCDFGaussianReferenceFlag=false

        SpectralMaskVisibility='None'

        MaskSpecificationObject=[]

MaskPlotter


        MaxHoldTraceLines=[]


        MinHoldTraceLines=[]


        CCDFGaussianReferenceLine=[]

XLimitListener


ChannelNamesChangedListener

ChannelVisibilityChangedListener

YLimitListener

YLabel

        MinYLim='-20'

        MaxYLim='80'

FrequencyScale

        FrequencyOffset=0

        FrequencyLimits=[-5000,5000]

SpectrumUnits

SpectrumType

ViewType


SpectrumObject


        SpanReadOut=[]


        SamplesPerUpdateReadOut=[]


        XAxisHzPerDivReadout=[]

        CCDFMode=false

        PlotMode='Spectrum'

        PlotType='Line'

        InputDomain='Time'


        hImage=[]

        hColorBar=[]

        TimeVector=[-1,0]

        ShowXAxisLabels=true

        ShowYAxisLabels=true

        hRBWText=[]

TimeSpan

        ColorLim=[-80,20]

        ColorMap=[]


        MaxHoldUserDefinedChannelNames={}


        MinHoldUserDefinedChannelNames={}

AxesLayout
    end

    properties(Dependent)
XLabel
Title
ColorOrder
ContextMenu
XTick
XTickMode
XTickLabel
XTickLabelMode
YTick
YTickMode
YTickLabel
YTickLabelMode
    end

    properties(Dependent,AbortSet)


XLim
YLim
    end

    properties(Access=private)
        privXLabel=''
        privYLabel=''
        privSubDimensions=[]
        XExtents=[NaN,NaN]
        YExtents=[NaN,NaN]
XTickListener
YTickListener
        YLimCache=struct('MinYLim',[],'MaxYLim',[])
        pXTickLabelMode='auto'
pXTickLabel
        pYTickMode='auto'
pYTick
        pYTickLabelMode='auto'
pYTickLabel
        CurrentTitle=''
        SpectrumYExtents=[NaN,NaN];
    end

    properties(SetAccess=private)
        SamplesPerUpdateMsgStatus=false
        FrequencyMultiplier=1
        FrequencyUnitsDisplay=''
        TimeMultiplier=1
        TimeUnitsDisplay=''

        XDataStepSize;
        SpectralPeaks;
    end

    properties(Access=protected)

        MaxHoldLinePropertiesCache={}
        MinHoldLinePropertiesCache={}
    end

    properties(Hidden)
        LinePropertiesCache={}

        SettingProperties=false
    end

    properties(Constant)

        LinePropertyDefaults=struct(...
        'LineStyle',get(0,'DefaultLineLineStyle'),...
        'LineWidth',get(0,'DefaultLineLineWidth'),...
        'Marker',get(0,'DefaultLineMarker'),...
        'MarkerSize',get(0,'DefaultLineMarkerSize'),...
        'MarkerEdgeColor',get(0,'DefaultLineMarkerEdgeColor'),...
        'MarkerFaceColor',get(0,'DefaultLineMarkerFaceColor'),...
        'Visible',get(0,'DefaultLineVisible'));


        LinePropertyNames={...
        'DisplayName',...
        'Color',...
        'LineStyle',...
        'LineWidth',...
        'Marker',...
        'MarkerSize',...
        'MarkerEdgeColor',...
        'MarkerFaceColor',...
        'Visible'};
        MaxLineColorMultiplier=0.7
        MinLineColorMultiplier=0.5
    end

    methods
        function this=SpectrumPlotter(varargin)


            this@matlabshared.scopes.visual.AbstractFramePlotter(varargin{:});
            hAxes=this.Axes;


            set(hAxes,'ALimMode','manual');
            set(hAxes,'CLimMode','manual');
            set(hAxes,'ZLimMode','manual');
            set(hAxes,'ZTickLabelMode','manual');



            this.XTickListener=addlistener(hAxes(1,1),'SizeChanged',...
            @(~,~)updateSpectrumXTickLabels(this));
            this.YTickListener=addlistener(hAxes(1,1),'SizeChanged',...
            @(~,~)updateYTickLabels(this));

            this.XTickListener=addlistener(hAxes(1,2),'SizeChanged',...
            @(~,~)updateSpectrogramXTickLabels(this));
            this.YTickListener=addlistener(hAxes(1,2),'SizeChanged',...
            @(~,~)updateYTickLabels(this));



            this.XLimitListener=addlistener(hAxes(1,1),'XLim',...
            'PostSet',@(~,~)updateSpectrumXTickLabels(this));
            this.YLimitListener=addlistener(hAxes(1,1),'YLim',...
            'PostSet',@(~,~)updateYTickLabels(this));

            this.XLimitListener=addlistener(hAxes(1,2),'XLim',...
            'PostSet',@(~,~)updateSpectrogramXTickLabels(this));
            this.YLimitListener=addlistener(hAxes(1,2),'YLim',...
            'PostSet',@(~,~)updateYTickLabels(this));




            uiservices.setListenerEnable(this.XLimitListener,false);
            uiservices.setListenerEnable(this.YLimitListener,false);




            uiservices.setListenerEnable(this.XTickListener,false);
            uiservices.setListenerEnable(this.YTickListener,false);

            set(hAxes,'FontSize',8.5,...
            'ColorOrder',uiscopes.getColorOrder([0,0,0]));




            set(hAxes,'GridLineStyle','-');
            gridAlpha=0.3;
            set(hAxes,'GridColor',get(hAxes(1,1),'XColor'),...
            'GridAlpha',gridAlpha);

            this.Lines=[];
            this.MaxHoldTraceLines=[];
            this.MinHoldTraceLines=[];
            this.CCDFGaussianReferenceLine=[];
        end

        function delete(this)
            delete(this.XTickListener);
            delete(this.XLimitListener);
            delete(this.YTickListener);
            delete(this.YLimitListener);
            this.SpectrumObject=[];
            delete@matlabshared.scopes.visual.AbstractLinePlotter(this);
        end

        function set.PlotMode(this,value)
            this.PlotMode=value;
            uiservices.setListenerEnable(this.YTickListener,false);
            uiservices.setListenerEnable(this.YLimitListener,false);
            prepareAxesForMessage(this,false);
            if strcmp(value,'Spectrum')||this.CCDFMode

                this.Axes(1,1).OuterPosition=[0,0,1,1];
                this.Axes(1,1).Visible='on';
                this.Axes(1,2).Visible='off';
                uistack(this.Axes(1,2),'bottom');


                if~isempty(this.hImage)
                    delete(this.hImage)
                    this.hImage=[];
                end
                if~isempty(this.hColorBar)
                    delete(this.hColorBar);
                    this.hColorBar=[];
                end




                updateTitlePosition(this);
            elseif strcmp(value,'Spectrogram')

                this.Axes(1,1).Visible='off';
                this.Axes(1,2).OuterPosition=[0,0,1,1];
                this.Axes(1,2).Visible='on';
                uistack(this.Axes(1,1),'bottom');


                if isempty(this.hImage)
                    if strcmp(this.FrequencyScale,'Log')||strcmp(this.InputDomain,'Frequency')
                        X=[0,1];
                        Y=[-1,0];
                        C=-inf(2,2);
                        this.hImage=pcolor(X,Y,C,'Parent',this.Axes(1,2));
                        set(this.hImage,'LineStyle','none');
                    else
                        this.hImage=image('Parent',this.Axes(1,2));
                        set(this.hImage,'Cdata',[]);
                        set(this.hImage,'XData',[0,1]);
                    end
                    set(this.hImage,'Tag','SpectrumAnalyzerImage');
                    set(this.hImage,'CDataMapping','Scaled');
                    set(this.hImage,'UIContextMenu',get(this.Axes(1,2),'UIContextMenu'));
                end
                if isempty(this.hColorBar)
                    createColorBar(this);
                end
                updateColorBar(this);
                view(this.Axes(1,2),[0,90]);
                set(this.Axes(1,2),'CLim',[this.ColorLim(1),this.ColorLim(2)]);
                parent=ancestor(this.Axes(1,2),'figure');
                set(parent,'ColorMap',this.ColorMap);

            else
                if strcmp(this.AxesLayout,'Vertical')
                    set(this.Axes(1,1),'OuterPosition',[0,0.5,1,0.5]);
                    set(this.Axes(1,1),'Visible','on');

                    set(this.Axes(1,2),'OuterPosition',[0,0,1,0.5]);
                    set(this.Axes(1,2),'Visible','on');
                else
                    set(this.Axes(1,1),'OuterPosition',[0,0,0.5,1]);
                    set(this.Axes(1,1),'Visible','on');

                    set(this.Axes(1,2),'OuterPosition',[0.5,0,0.5,1]);
                    set(this.Axes(1,2),'Visible','on');
                end

                if isempty(this.hImage)
                    if strcmp(this.FrequencyScale,'Log')
                        X=[0,1];
                        Y=[-1,0];
                        C=-inf(2,2);
                        this.hImage=pcolor(X,Y,C,'Parent',this.Axes(1,2));
                        set(this.hImage,'LineStyle','none');
                    else
                        this.hImage=image('Parent',this.Axes(1,2));
                        set(this.hImage,'Cdata',[]);
                        set(this.hImage,'XData',[0,1]);
                    end
                    set(this.hImage,'Tag','SpectrumAnalyzerImage');
                    set(this.hImage,'CDataMapping','Scaled');
                    set(this.hImage,'UIContextMenu',get(this.Axes(1,2),'UIContextMenu'));
                end
                if isempty(this.hColorBar)
                    createColorBar(this);
                end
                updateColorBar(this);
                view(this.Axes(1,2),[0,90]);
                set(this.Axes(1,2),'CLim',[this.ColorLim(1),this.ColorLim(2)]);
                parent=ancestor(this.Axes(1,2),'figure');
                set(parent,'ColorMap',this.ColorMap);
            end
            updateYAxis(this);
            uiservices.setListenerEnable(this.YTickListener,this.ShowYAxisLabels);
            uiservices.setListenerEnable(this.YLimitListener,this.ShowYAxisLabels);
        end

        function set.ColorMap(this,value)
            parent=ancestor(this.Axes(1,2),'figure');
            set(parent,'ColorMap',value);
            this.ColorMap=value;
            updateColorBar(this);
        end

        function set.ColorLim(this,value)
            set(this.Axes,'CLim',[value(1),value(2)]);
            this.ColorLim=value;
            updateColorBar(this);
        end

        function set.FrequencyMultiplier(this,newFrequencyMultiplier)
            this.FrequencyMultiplier=newFrequencyMultiplier;
            if newFrequencyMultiplier==1
                enabState=false;
            else
                enabState=true;
            end
            uiservices.setListenerEnable(this.XTickListener,enabState);%#ok<*MCSUP>
            uiservices.setListenerEnable(this.XLimitListener,enabState);
        end

        function set.TimeMultiplier(this,newTimeMultiplier)
            this.TimeMultiplier=newTimeMultiplier;
        end

        function set.ChannelNamesChangedListener(this,cbFcn)
            delete(this.ChannelNamesChangedListener);
            if isempty(cbFcn)
                this.ChannelNamesChangedListener=[];
            else
                this.ChannelNamesChangedListener=event.listener(this,...
                'ChannelNamesChanged',@(~,~)cbFcn());
            end
        end

        function set.ChannelVisibilityChangedListener(this,cbFcn)
            delete(this.ChannelVisibilityChangedListener);
            if isempty(cbFcn)
                this.ChannelVisibilityChangedListener=[];
            else
                this.ChannelVisibilityChangedListener=event.listener(this,...
                'ChannelVisibilityChanged',@(~,~)cbFcn());
            end
        end

        function set.NormalTraceFlag(this,value)

            this.NormalTraceFlag=value||this.CCDFMode;
            hTraceLines=this.Lines;
            if~this.NormalTraceFlag
                delete(hTraceLines);
                this.Lines=[];
            elseif isempty(hTraceLines)
                setupLines(this,false);
            end
            nChannels=sum(this.NumberOfChannels);
            delete(this.Lines(nChannels+1:end));
            this.Lines(nChannels+1:end)=[];
        end

        function set.MaxHoldTraceFlag(this,value)

            this.MaxHoldTraceFlag=value;
            hTraceLines=this.MaxHoldTraceLines;
            if~this.MaxHoldTraceFlag
                delete(hTraceLines);
                this.MaxHoldTraceLines=[];
            elseif isempty(hTraceLines)
                setupMaxHoldLines(this);
            end
            nChannels=sum(this.NumberOfChannels);
            delete(this.MaxHoldTraceLines(nChannels+1:end));
            this.MaxHoldTraceLines(nChannels+1:end)=[];
            if length(this.MaxHoldUserDefinedChannelNames)>nChannels
                this.MaxHoldUserDefinedChannelNames=...
                this.MaxHoldUserDefinedChannelNames(1:nChannels);
            end
        end

        function set.MinHoldTraceFlag(this,value)

            this.MinHoldTraceFlag=value;
            hTraceLines=this.MinHoldTraceLines;
            if~this.MinHoldTraceFlag
                delete(hTraceLines);
                this.MinHoldTraceLines=[];
            elseif isempty(hTraceLines)
                setupMinHoldLines(this);
            end
            nChannels=sum(this.NumberOfChannels);
            delete(this.MinHoldTraceLines(nChannels+1:end));
            this.MinHoldTraceLines(nChannels+1:end)=[];
            if length(this.MinHoldUserDefinedChannelNames)>nChannels
                this.MinHoldUserDefinedChannelNames=...
                this.MinHoldUserDefinedChannelNames(1:nChannels);
            end
        end

        function set.SamplesPerUpdateMsgStatus(this,value)


            this.SamplesPerUpdateMsgStatus=value;
            if value||this.CCDFMode||strcmp(this.PlotMode,'Spectrogram')...
                ||strcmp(this.SpectrumUnits,'Watts')
                this.SpectralMaskVisibility='None';
            else
                this.SpectralMaskVisibility=this.MaskSpecificationObject.EnabledMasks;
            end
        end

        function set.SpectralMaskVisibility(this,value)



            if strcmp(this.SpectralMaskVisibility,value)
                return;
            end


            if isempty(this.MaskPlotter)||~isvalid(this.MaskPlotter)
                this.MaskPlotter=dsp.scopes.SpectralMaskPlotter(this);
            end


            this.SpectralMaskVisibility=value;
            this.MaskPlotter.MaskVisibility=value;
            updateLegend(this);
        end

        function set.MaxHoldTraceLines(this,hLines)
            this.MaxHoldTraceLines=hLines;


            if strcmpi(this.LegendVisibility,'on')
                createLegend(this);

                createDisplayNameListeners(this);
            end

            applyDisplayNames(this);
        end

        function set.MinHoldTraceLines(this,hLines)
            this.MinHoldTraceLines=hLines;


            if strcmpi(this.LegendVisibility,'on')
                createLegend(this);

                createDisplayNameListeners(this);
            end

            applyDisplayNames(this);
        end

        function set.MaxHoldUserDefinedChannelNames(this,newUserDefinedNames)
            this.MaxHoldUserDefinedChannelNames=newUserDefinedNames;


            applyDisplayNames(this);


            notify(this,'ChannelNamesChanged');
        end

        function set.MinHoldUserDefinedChannelNames(this,newUserDefinedNames)
            this.MinHoldUserDefinedChannelNames=newUserDefinedNames;


            applyDisplayNames(this);


            notify(this,'ChannelNamesChanged');
        end

        function set.FrequencyScale(this,value)
            if this.CCDFMode
                set(this.Axes,'XScale','lin');
            else
                if any(strcmp(this.PlotMode,{'Spectrogram','SpectrumAndSpectrogram'}))
                    updateSpectrogramImageType(this,value,this.InputDomain);
                end
                set(this.Axes,'XScale',value);
            end
            updateXTickLabels(this);
            this.FrequencyScale=value;
            drawSpectralMask(this);
        end

        function set.InputDomain(this,value)
            if any(strcmp(this.PlotMode,{'Spectrogram','SpectrumAndSpectrogram'}))
                updateSpectrogramImageType(this,this.FrequencyScale,value);
            end
            this.InputDomain=value;
        end

        function set.XTickMode(this,value)
            set(this.Axes,'XTickMode',value);
            updateXTickLabels(this);
        end

        function value=get.XTickMode(this)
            value=get(this.Axes(1),'XTickMode');
        end

        function set.XTick(this,value)
            set(this.Axes,'XTick',value/this.FrequencyMultiplier);
            updateXTickLabels(this);
        end

        function value=get.XTick(this)
            value=get(this.Axes(1),'XTick')*this.FrequencyMultiplier;
        end

        function set.XTickLabelMode(this,value)
            this.pXTickLabelMode=value;
            updateXTickLabels(this);
        end

        function value=get.XTickLabelMode(this)
            value=this.pXTickLabelMode;
        end

        function set.XTickLabel(this,value)
            this.pXTickLabel=value;
            this.pXTickLabelMode='manual';
            updateXTickLabels(this);
        end

        function value=get.XTickLabel(this)
            value=get(this.Axes(1),'XTickLabel');
        end

        function set.YTickMode(this,value)
            if any(strcmp(this.PlotMode,{'SpectrumAndSpectrogram','Spectrogram'}))
                set(this.Axes,'YTickMode',value);
            end
            this.pYTickMode=value;
            updateYTickLabels(this);
        end

        function value=get.YTickMode(this)
            value=this.pYTickMode;
        end

        function set.YTick(this,value)
            if any(strcmp(this.PlotMode,{'SpectrumAndSpectrogram','Spectrogram'}))
                set(this.Axes,'XTick',value/this.TimeMultiplier);
            else
                if~isnumeric(value)||any(diff(value)<=0)
                    error(message('Spcuilib:scopes:InvalidYTicks'));
                end
                this.pYTickMode='manual';
            end
            this.pYTick=value;
            updateYTickLabels(this);
        end

        function value=get.YTick(this)
            if any(strcmp(this.PlotMode,{'SpectrumAndSpectrogram','Spectrogram'}))
                value=get(this.Axes(1),'XTick')*this.TimeMultiplier;
            else
                value=get(this.Axes(1),'YTick');
            end
        end

        function set.YTickLabelMode(this,value)
            this.pYTickLabelMode=value;
            updateYTickLabels(this);
        end

        function value=get.YTickLabelMode(this)
            value=this.pYTickLabelMode;
        end

        function set.YTickLabel(this,value)
            this.pYTickLabel=value;
            this.pYTickLabelMode='manual';
            updateYTickLabels(this);
        end

        function value=get.YTickLabel(this)
            value=get(this.Axes(1),'YTickLabel');
        end

        function set.YLim(this,newYLim)
            if this.CCDFMode
                set(this.Axes(1,1),'YLim',...
                [max(1e-12,newYLim(1)),min(100,newYLim(2))]);
            else
                set(this.Axes(1,1),'YLim',newYLim);
            end
        end

        function yLim=get.YLim(this)
            yLim=get(this.Axes(1),'YLim');
        end

        function set.YLabel(this,newYLabel)
            this.privYLabel=newYLabel;
            updateYLabel(this);
        end

        function yLabel=get.YLabel(this)
            yLabel=get(get(this.Axes,'YLabel'),'String');
        end

        function set.XLabel(this,newXLabel)
            this.privXLabel=newXLabel;
            updateXLabel(this);
        end

        function xLabel=get.XLabel(this)
            xLabel=get(get(this.Axes(1),'XLabel'),'String');
        end

        function set.Title(this,v)
            title(this.Axes(1),v,'Interpreter','tex','Units','normalized');
            title(this.Axes(2),v,'Interpreter','tex','Units','normalized');
        end

        function v=get.Title(this)
            if any(strcmpi(this.PlotMode,{'Spectrum','SpectrumAndSpectrogram'}))||this.CCDFMode
                v=get(get(this.Axes(1),'Title'),'String');
            else
                v=get(get(this.Axes(2),'Title'),'String');
            end
        end

        function set.XLim(this,v)
            setAxesProp(this,'XLim',v);
        end

        function v=get.XLim(this)
            v=get(this.Axes(1),'XLim');
        end

        function set.ColorOrder(this,v)
            setAxesProp(this,'ColorOrder',v);
        end

        function v=get.ColorOrder(this)
            v=get(this.Axes(1),'ColorOrder');
        end

        function set.MinYLim(this,v)

            this.YLimCache.MinYLim=v;
            this.MinYLim=v;
        end

        function set.MaxYLim(this,v)

            this.YLimCache.MaxYLim=v;
            this.MaxYLim=v;
        end

        function set.SpectrumUnits(this,v)
            this.SpectrumUnits=v;
            updateColorBar(this);
        end

        function set.PlotType(this,newPlotType)
            if~strcmp(this.PlotType,newPlotType)&&~isempty(this.Lines)

                this.PlotType=newPlotType;
                updateLinesForPlotType(this);
            else
                this.PlotType=newPlotType;
            end
        end
    end

    methods(Access=protected)
        channelNames=getDefaultChannelNames(this)
        channelNames=getAllChannelNames(this)
        onLegendStringChanged(this)
        updateLinesForPlotType(this)
        setupLines(this,varargin)
        setupNormalTraceLines(this,plotTypeChanged)
        setupMaxHoldLines(this)
        setupMinHoldLines(this)
        hLines=getAllLines(this,onlySpectrumLines)
        hTraceLines=addHoldLines(this,hTraceLines,type)
        addCCDFGaussianReferenceLine(this)
        updateLegend(this)
        applyDisplayNames(this)
        updateLabels(this)
        updateSpectrogramImageType(this,scale,domain)
        createColorBar(this)
    end

    methods(Static)
        mergedStruct=mergeStructs(defaultStruct,newStruct)
    end
end
