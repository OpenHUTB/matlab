function setup(this,hVisParent)




    this.IsInitModeFlag=true;


    setup@dsp.scopes.LineVisual(this,hVisParent);


    this.AxesContainerSpectrum=dsp.scopes.AxesContainer(this.Axes(1),'Spectrum',this);
    this.AxesContainerSpectrogram=dsp.scopes.AxesContainer(this.Axes(2),'Spectrogram',this);


    this.FigureColorListener=uiservices.addlistener(...
    getVisualizationParent(this.Application),'BackgroundColor',...
    'PostSet',makeCallback(this,@onFigureColorChange));


    validateSettingsForCurrentLicense(this,true);


    this.DataBuffer=scopesutil.SpectrumBuffer;


    this.MaskTesterObject=dsp.scopes.SpectralMaskTester(this);



    this.SpectrumObject=dsp.scopes.SpectralEstimator(...
    'DataBuffer',this.DataBuffer,'MaskTester',this.MaskTesterObject);


    hParent=get(this.Axes(1,1),'Parent');
    set(this.Axes,'Layer','top');
    hFigPanel=uipanel(hParent,'BorderType','none');
    set(this.Axes,'Parent',hFigPanel);
    onResize(this);
    set(hFigPanel,'ResizeFcn',makeCallback(this,@onResize));
    set(hFigPanel,'BackgroundColor',get(hParent,'BackgroundColor'));




    updateNoDataAvailableMessage(this,true);

    hPlotter=dsp.scopes.SpectrumPlotter(this.Axes);
    this.Plotter=hPlotter;
    hPlotter.SpectrumObject=this.SpectrumObject;
    hPlotter.ChannelNamesChangedListener=@()onChannelNamesChanged(this);
    hPlotter.ChannelVisibilityChangedListener=@()onChannelVisibilityChanged(this);

    setupSpectralMaskSpecification(this);

    setupMeasurementsSpecification(this);

    hPlotter.FrameProcessing=true;
    updatePlotter(this);


    hPlotter.UserDefinedChannelNames=getPropertyValue(this,'UserDefinedChannelNames');
    if~isempty(this.Application.DataSource)
        onDataSourceChanged(this);
    end
    this.ReduceUpdates=getPropertyValue(this,'ReduceUpdates');
    this.DrawNowTimer=scopesutil.OneShotTimer;
    this.DrawNowTimer.TimeoutDuration=0.25;
    this.DrawNowTimer.start;


    this.OffsetLabel=getString(message('Spcuilib:scopes:TimeOffsetStatusLabel'));







    this.pInputDomain=getPropertyValue(this,'InputDomain');

    this.pSpectrumType=getPropertyValue(this,'SpectrumType');
    if strcmpi(this.pSpectrumType,'Spectrogram')
        this.pSpectrumType='Power';
        this.pViewType='Spectrogram';
        setPropertyValue(this,'SpectrumType',this.pSpectrumType);
        setPropertyValue(this,'ViewType',this.pViewType);
    else
        this.pViewType=getPropertyValue(this,'ViewType');
    end

    if strcmpi(this.pSpectrumType,'RMS')
        this.pSpectrumUnits=getPropertyValue(this,'RMSUnits');
    else
        this.pSpectrumUnits=getPropertyValue(this,'PowerUnits');
    end



    this.pTwoSidedSpectrum=getPropertyValue(this,'TwoSidedSpectrum');
    this.pAxesLayout=getPropertyValue(this,'AxesLayout');
    this.pCustomWindow=getPropertyValue(this,'CustomWindow');
    this.pMethod=getPropertyValue(this,'Method');
    this.pNumTapsPerBand=getPropertyValue(this,'NumTapsPerBand');
    this.pFrequencyResolutionMethod=getPropertyValue(this,'FrequencyResolutionMethod');



    if strcmp(this.pMethod,'Welch')
        setPropertyValue(this,'FrequencyResolutionMethodWelch',this.pFrequencyResolutionMethod);
    else
        setPropertyValue(this,'FrequencyResolutionMethodFilterBank',this.pFrequencyResolutionMethod);
    end
    [val,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'ReferenceLoad'));
    if isempty(errStr)
        this.pReferenceLoad=val;
    end

    if strcmp(getPropertyValue(this,'FullScaleSource'),'Property')
        [val,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'FullScale'));
        if isempty(errStr)
            this.pFullScale=val;
        end
    end

    if strcmp(getPropertyValue(this,'TimeSpanSource'),'Property')
        [val,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'TimeSpan'));
        if isempty(errStr)
            this.pTimeSpan=val;
        end
    end

    if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')
        [val,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'TimeResolution'));
        if isempty(errStr)
            this.pTimeResolution=val;
        end
    end

    if strcmp(getPropertyValue(this,'FrequencyInputRBWSource'),'Property')
        [val,~,errStr]=evaluateVariable(this.Application,getPropertyValue(this,'RBW'));
        if isempty(errStr)
            this.pRBW=val;
        end
    end


    this.SpectrumData=struct('SimulationTime',[],...
    'Spectrum',[],...
    'Spectrogram',[],...
    'MinHoldTrace',[],...
    'MaxHoldTrace',[],...
    'FrequencyVector',[],...
    'SpectrumUnits',[]);
end
