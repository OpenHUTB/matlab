classdef SpectrumVisual<dsp.scopes.LineVisual





    properties
SpectrumObject
DataBuffer


        CCDFModeEnable=false
        CurrentCCDFSampleCount=[]
        NumCCDFHistogramBins=10000
        CCDFPowerResolutionInDB=0.01
        CurrentCCDFMaxPower=[]
        CurrentCCDFAvgPower=[]
        CurrentCCDFDistribution=[]


        CCDFDeprecationDialogShown=false;


        CurrentPSD=[]
        CurrentFVector=[]
        CurrentMaxHoldPSD=[]
        CurrentMinHoldPSD=[]
        CurrentSpectrogram=[]


        FrequencyInputData=[]
        ScaledFrequencyInputData=[]




        ScaledPSD=[]
        ScaledMaxHoldTrace=[]
        ScaledMinHoldTrace=[]
        ScaledSpectrogram=[]

        NoDataAvailableTxt=[]
        CorrectionModeTxt=[]
        CorrectionModeAxes=[]
        IsPropertyChangedFromSettingsDlg=false
        IsUpdateReady=false



        IsRemoveScreenMsg=true



        IsValidSettingsDialogReadouts=false
        SpectrumSettingsDialogEnabled=false
        SpectralMaskDialogEnabled=false


        IsNotInCorrectionMode=true


        DrawNowTimer=[]

        ReduceUpdates=true


        PropChanged=false
        UpdateInProgress=false
        TreatMby1SignalsAsOneChannel=true
        ProcessLastSegmentOnly=false
        UserGeneratedYLimChange=true
        IsSystemObjectSource=false


        updateTracesRequired=true
        TimeVector=[-1,0]
        FrequencyVector=[0,1]



        LastSpectrumUpdate=[]


        LastSpectrumPowerWeight=[]


        SpectrogramLineCounter=0
        PowerColorExtents=[NaN,NaN]

        SimulationTime=0;

        OldEnabledMasks='None';

        SpectrumData=[];


        IsNewDataReady=false;


        IsNewMeasurementsDataReady=false;

        NumSegments=1;


        SpectrumDataFieldNames={'SimulationTime',...
        'Spectrum',...
        'Spectrogram',...
        'MinHoldTrace',...
        'MaxHoldTrace',...
        'FrequencyVector'};
        MeasurementsDataFieldNames={'SimulationTime',...
        'PeakFinder',...
        'CursorMeasurements',...
        'ChannelMeasurements',...
        'DistortionMeasurements',...
        'CCDFMeasurements'};

        MeasurementTag='SpectralMask';
    end

    properties(Hidden)



        SelectedDialogTab='main'

DialogMgr


        PlotNavigationSettings=[]
    end

    properties(Access=protected)
SourceListeners
DisplayListener
FigureColorListener
ViewMenuListener
ToolsMenuListener
MaskUpdatedListener
Handles


        ProcessedSamplesInBuffer=0

SpectrumDataUpdatedListener

pDataSource

PeakFinderUpdatedListener


CursorMeasurementsUpdatedListener


ChannelMeasurementsUpdatedListener


DistortionMeasurementsUpdatedListener


CCDFMeasurementsUpdatedListener
    end


    properties(SetAccess=protected,Hidden)


        pSpectrumType='Power'
        pFullScale=1;
        pAxesLayout='Vertical'
        pViewType='Spectrum'
        pCustomWindow='hann'
        pMethod='Welch'
        pNumTapsPerBand=12
        pReferenceLoad=1
        pSpectrumUnits='dBm'
        pTwoSidedSpectrum=true
        pTimeSpan=0.1
        pTimeResolution=0.001
        pChannelNumber=1
        pFrequencyResolutionMethod='RBW';
        pSampleRate=10000;
        pInputDomain='Time';
        pInputUnits='Magnitude';
        pRBW=10;

MaskSpecificationObject


MaskTesterObject

        pAutoScaleListenerState=true

        NumSpectralUpdatesPerLine=1

        ActualTimeResolution=1

        TimeIncrement=[]


        TimeIncrementNoExtraIncrement=[]



        NeedToRestoreLines=false
        NeedToUpdateTimeResolution=false
        NeedToUpdateTimeSpan=false
        NeedToUpdateYLimits=false
        NeedToUpdateMaxHoldTrace=false
        NeedToUpdateMinHoldTrace=false
        NeedToUpdateNormalTrace=false


        ForceAutoScaleOnUpdate=false

OffsetLabel
        TimeOffsetShiftIndex=0

        ColorMapMatrix=jet(256);

        IsInitModeFlag=true

        IsVisualStartingUp=true

        IsUpdatingStyle=false

        IsRescaleOnly=false;



        SimscapeMode=false;
        InvalidSettingsInSimscapeMode=false;


AxesContainerSpectrum
AxesContainerSpectrogram


        pLegacySpectrumType=false;


        pInputDataType='double'
        pInputRange=32767
        pInputPeakValue=0.5



        pRawInputFrameSize=0;
        pRawInputTotalSimTime=0;




        pMaxHoldTrace=[];

        pMinHoldTrace=[];

        pFrequencyVectorSource='Auto';

        pFrequencyInputRBWSource='Auto';

        PeakFinderObject;

        CursorMeasurementsObject;

        ChannelMeasurementsObject;

DistortionMeasurementsObject

CCDFMeasurementsObject
        pCachedSpectrumData;
        pCachedEnabledData=[true,false,false,false,false,true];
        pCachedMeasurementsData;
        pCachedEnabledMeasurements=[true,false,false,false,false,false];

        pVectorScopeLegacyMode=false;
    end

    events
SpectrumDataUpdated
    end

    methods
        function this=SpectrumVisual(varargin)



            mlock;


            this@dsp.scopes.LineVisual(varargin{:});

            hApp=this.Application;
            this.SourceListeners=[...
            event.listener(hApp,'SourceRun',@this.onSourceRun),...
            event.listener(hApp,'SourceStop',@this.onSourceStop),...
            event.listener(hApp,'DataSourceChanged',@this.onDataSourceChanged)];

            this.DisplayListener=event.listener(this,'DisplayUpdated',makeCallback(this,@onDisplayChanged));




            this.RenderedListener=event.listener(hApp,'Rendered',...
            @(hApp,~)onVisualRendered(this,hApp));




            propNames={'Span','CenterFrequency','StartFrequency',...
            'StopFrequency','RBW','SidelobeAttenuation',...
            'SpectralAverages','FFTLength','ReferenceLoad',...
            'TimeSpan','TimeResolution','MinYLim','MaxYLim',...
            'MinColorLim','MaxColorLim',...
            };
            setAbortSet(this.Config.PropertySet,propNames,'off');



            [~,~,licenseType]=checkLicense(hApp.Specification,false);
            this.SimscapeMode=any(strcmpi(licenseType,{'simscape','rfblockset'}));

            this.SpectrumDataUpdatedListener=...
            event.listener(this,'SpectrumDataUpdated',@this.getCurrentSpectrumData);


            this.pCachedMeasurementsData=createEmptyMeasurementsDataTable(this);
        end

        function set.DialogMgr(this,hDlg)



            this.DialogMgr=hDlg;
            updateSpanReadOut(this);
            updateSamplesPerUpdateMessage(this);
            updateNoDataAvailableMessage(this);
            updateInset(this);
        end

        function axesContainers=getAxesContainers(this)


            if isempty(this.Axes)
                axesContainersObj=dsp.scopes.AxesContainer(this.Axes,'Spectrum',this);
                axesContainers={axesContainersObj};
                return;
            end
            if strcmp(this.pViewType,'Spectrum')||isCCDFMode(this)

                axesContainers={this.AxesContainerSpectrum};
            elseif strcmp(this.pViewType,'Spectrogram')&&~isCCDFMode(this)

                axesContainers={this.AxesContainerSpectrogram};
            elseif isCombinedViewMode(this)&&~isCCDFMode(this)

                axesContainers={this.AxesContainerSpectrum,this.AxesContainerSpectrogram};
            end
        end

        function set.pLegacySpectrumType(this,val)
            this.pLegacySpectrumType=val;
        end

        function val=get.pLegacySpectrumType(this)
            val=this.pLegacySpectrumType;
        end

        function flag=needsBuffer(~)
            flag=true;
        end
    end

    methods(Access=protected)
        function validFlag=validateSettingsForCurrentLicense(this,suppressError)



            if this.IsSystemObjectSource||~this.SimscapeMode
                validFlag=true;
            else


                validFlag=~strcmp(getPropertyValue(this,'ViewType'),'Spectrogram');
                validFlag=validFlag&&strcmp(getPropertyValue(this,'FrequencySpan'),'Full');
                validFlag=validFlag&&strcmp(getPropertyValue(this,'FrequencyResolutionMethod'),'RBW');
                validFlag=validFlag&&any(strcmp(getPropertyValue(this,'Window'),{'Hann','Rectangular'}));
                validFlag=validFlag&&any(strcmp(this.pSpectrumUnits,{'dBm','dBV','Vrms'}));
                validFlag=validFlag&&getPropertyValue(this,'NormalTrace');
                validFlag=validFlag&&~getPropertyValue(this,'MaxHoldTrace');
                validFlag=validFlag&&~getPropertyValue(this,'MinHoldTrace');
                validFlag=validFlag&&~strcmp(getPropertyValue(this,'Method'),'Filter bank');
                maskSpec=getPropertyValue(this,'SpectralMaskProperties');
                validFlag=validFlag&&(isempty(maskSpec)||strcmp(maskSpec.EnabledMasks,'None'));
                validFlag=validFlag&&strcmp(this.pInputDomain,'Time');
                this.InvalidSettingsInSimscapeMode=~validFlag;
                if~validFlag&&~suppressError
                    throw(MException(message('dspshared:SpectrumAnalyzer:ScopeWasSavedWithDSTOnlyProperties')));
                end
            end
        end
    end

    methods(Hidden)
        cb=makeCallback(this,fcn,varargin)
        resetCCDF(this)
        resetDataBuffer(this)
        flag=resetSpectrogram(this,zeroOutSpectrogramFlag)
        loadLineProperties(this)
        refreshReadouts(this)
        refreshStyleDialog(this)
        showStyleDialog(this)
        ip=getStyleDialogInput(this)
        updateStyle(this,action)
        restoreDirtyStatus(this,dirtyFlag)
        synchronizeWithPlotter(this)
        synchronizeWithSpectrumObject(this,syncFrequencyAndTimePropsOnly)
        update(this,varargin)
        updatePlotter(this)
        updateCCDF(this,data)
        updateColorBar(this)
        updateColorMap(this)
        updateColorRange(this)
        updateControlDialog(this,dlgName)
        updateCorrectionModeMessage(this,visibleFlag,errorMsg)
        updateCurrentSpectrogram(this,data)
        updateFrequencyScale(this)
        updateFrequencySpan(this)
        updateInset(this)
        updateLegend(this)
        updateNoDataAvailableMessage(this,visibleFlag)
        updateSamplesPerUpdateMessage(this,visibleFlag)
        updateSpanReadOut(this,visibleFlag)
        updateTitle(this)
        updateTitlePosition(this)
        updateTraces(this)
        updateView(this,spectrumType,viewType)
        updateXAxisLabels(this)
        updateYAxis(this)
        updateYAxisLimits(this)
        updateYLabel(this)
        postUpdate(~)
        propertyChanged(this,eventData)
        dirtyStatus=getDirtyStatus(this)
        [xData,yData]=getAllData(this,traceIndex)
        [xData,yData]=getVisibleData(this,traceIndex)
        interpolationOrder=getInterpolationOrder(this,~)
        [Fstart,Fstop]=getCurrentFreqLimits(this,traceIndex)
        DataBuffer=getDataBuffer(this,nSignals,rate,maxNumTimeSteps,maxDimensions,isInputComplex)
        extents=getDataExtents(this,axesToBeScaled)
        [Fstart,Fstop]=getDefaultFreqLimits(~)
        [pAxes,sAxes]=getPlotNavigationAxes(this)
        limitName=getPlotNavigationLimits(this)
        lineName=getLineName(this,~,lineNum)
        string=getMsgString(this,tag)
        definition=getXDefinition(this)
        definition=getYDefinition(this)
        definition=getZDefinition(this)
        xyzExtents=getXYZExtents(this)
        color=getSpectrogramColor(this,cDataValue)
        color=getSpectrogramContrastColor(this)
        [xData,yData,zData]=getSpectrogramData(this)
        dlg=getSpectrumSettingsDialog(this)
        dlg=getSpectralMaskDialog(this)
        propsSchema=getPropsSchema(this,~)
        optionsDialogTitle=getOptionsDialogTitle(~,~)
        setCCDFGaussianReference(this,enable)
        setCCDFMode(this,enable)
        setSpectrumSettingMenus(this,val)
        toggleReduceUpdates(this)
        toggleSpectrumSettingsDialog(this,varargin)
        toggleSpectralMaskDialog(this,varargin)
        b=allowsAsynchronous(this)
        blankSpectrogram(this,removeTicksFlag)
        onDisplayChanged(this)
        onResize(this)
        onAutoscale(this,auto)
        onSourceStop(this,~,~)
        onSourceRun(this,~,~)
        onChannelNamesChanged(this)
        onChannelVisibilityChanged(this)
        onDataSourceChanged(this,~,~)
        onFigureColorChange(this)
        onFigureZoom(this,~)
        onEditOptions(this)
        flag=hasValidAxes(this)
        isFrameBased=isInputFrameBased(this)
        flag=isSourceRunning(this)
        flag=isCorrectionMode(this)
        flag=isSpectrogramMode(this)
        flag=isCCDFMode(this)
        flag=isCombinedViewMode(this)
        flag=isFrequencyInputMode(this)
        varargout=validate(this,hDlg)
        validFlag=validateCurrentSettings(this)
        varargout=validateSource(this,hSource)
        varargout=validateSpectrumSettings(this)


        setSpectralMask(this,maskSpecObj)
        value=getSpectralMask(this,varargin)
        validateSpectralMask(this)
        updateSpectralMask(this,propertyChangedFlag)

        setPeakFinder(this,peakFinderObj);
        value=getPeakFinder(this,varargin);
        updatePeakFinder(this);

        setCursorMeasurements(this,cursorMeasurementsObj);
        value=getCursorMeasurements(this,varargin);
        updateCursorMeasurements(this);

        setChannelMeasurements(this,channelMeasurementsObj);
        value=getChannelMeasurements(this,varargin);
        updateChannelMeasurements(this);

        setDistortionMeasurements(this,distortionMeasurementsObj);
        value=getDistortionMeasurements(this,varargin);
        updateDistortionMeasurements(this);

        setCCDFMeasurements(this,ccdfMeasurementsObj);
        value=getCCDFMeasuements(this,varargin);
        updateCCDFMeasurements(this);


        updateMeasurementsPropertyValues(this);

        data=getSpectrumData(obj,varargin);

        spectrumData=createEmptySpectrumDataTable(obj,numSegments);

        measurementsData=createEmptyMeasurementsDataTable(obj,~)
    end

    methods(Static)
        propSet=getPropertySet
    end

    methods(Access=protected)
        onViewMenuOpening(this,hScope,~)
        onToolsMenuOpening(this,hScope,~);
        onVisualRendered(this,hScope)
        setupDataBuffer(this)
        clearCorrectionMode(this)
        [PSD,maxHoldPSD,minHoldPSD,FVect]=scaleSpectrum(this)
        S=scaleSpectrogram(this)
        data=scaleFrequencyInputSpectrum(this,data);
        [data,minVal,maxVal]=scaleFrequencyInputSpectrogram(this,data);
        aggregatedSpectra=aggregateSpectrum(this,spectralUpdates,N,Q)
        updateOffsetReadout(this)
        localUpdate(this,reScalePSDFlag,forceUpdateFlag,refreshsamplesPerUpdate,zeroOutSpectrogram)
        [val,errid,msg]=evaluateColorMapExpression(this,mapExpression)
        prepareForPrinter(this,printFig)
        updatePrintAxes(this,inputFig)
        removeInteractiveBehaviors(~,printAxes)
        setLineProperties(this)
        synchronizeIrrelevantProperties(this)
        synchronizeSpanProperties(this)
        processDataCCDF(this,data)
        processDataNormalRate(this,data)
        processDataReducedRate(this,data)
        processFrequencyDomainData(this,data,doPlotFlag,isRescaleOnly)
        processTimeDomainData(this,data,doPlotFlag,isRescaleOnly,refreshsamplesPerUpdate)
        data=getBufferedData(this)
        newData=getUnprocessedData(this,data,i)
        value=getNumOverlapSamples(this,SL)
        [PSD,maxHoldPSD,minHoldPSD,FVect]=updatePlot(this)
        S=updateSpectrogramPlot(this)
        [PSD,S,maxHoldPSD,minHoldPSD,FVect]=updateCombinedViewPlot(this,PSD,S,maxHoldPSD,minHoldPSD,FVect)
        updateFrequencyInputPlot(this);
        updateCCDFPlot(this)
        removeLines(this)
        restoreLines(this)
        updatePlotType(this)
        removeDataAndReadoutsAndAddMessage(this)
        lclCleanupFunction(this,dirtyState)
        setReducePlotRateMenu(this,eventData)
        releaseSpectrumObject(this)
        [b,exception]=validateDisplayProps(this,hDlg,b,exception)
        [b,exception,val]=validateLimWidgetValue(this,hDlg,tag,messageTag,validator)
        [b,exception]=validateColorMapExpresion(this,hDlg,tag)
        [RBW,NENBW,spectrogramMessage]=getCurrentRBW(this,span)
        [winDuration,winLenght]=getWinDurationForAGivenRBW(this,RBW)

        computeFullScale(this);

        getCurrentSpectrumData(this,~,~)


        freqVector=computeFrequencyInputFrequencyVector(this,dims)

        computePowerColorExtents(this,minVal,maxVal)

        setupSpectralMaskSpecification(this);

        setupMeasurementsSpecification(this);
    end
end
