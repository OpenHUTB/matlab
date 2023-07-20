function onSourceRun(this,~,~)





    dirtyState=getDirtyStatus(this);
    c=onCleanup(@()lclCleanupFunction(this,dirtyState));
    this.IsInitModeFlag=false;
    this.IsVisualStartingUp=true;

    sampleRate=evalPropertyValue(this,'SampleRate');
    if~isfinite(sampleRate)||(sampleRate==0)
        return
    end


    source=this.Application.DataSource;
    if isempty(source)||source.State.isInRapidAcceleratorAndNotRunning||isDataEmpty(source)
        return
    end


    this.IsValidSettingsDialogReadouts=true;



    this.pSpectrumType=getPropertyValue(this,'SpectrumType');
    this.pViewType=getPropertyValue(this,'ViewType');
    this.pAxesLayout=getPropertyValue(this,'AxesLayout');

    if~isFrequencyInputMode(this)
        this.pMethod=getPropertyValue(this,'Method');
        this.pNumTapsPerBand=evalPropertyValue(this,'NumTapsPerBand');
        synchronizeWithSpectrumObject(this);
        synchronizeSpanProperties(this);



        this.pReferenceLoad=evalPropertyValue(this,'ReferenceLoad');

        if strcmpi(this.pSpectrumType,'RMS')
            this.pSpectrumUnits=getPropertyValue(this,'RMSUnits');
        else
            this.pSpectrumUnits=getPropertyValue(this,'PowerUnits');
        end

        if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')
            this.pTimeResolution=evalPropertyValue(this,'TimeResolution');
        end

        if strcmp(getPropertyValue(this,'FullScaleSource'),'Property')
            this.pFullScale=evalPropertyValue(this,'FullScale');
        end
    else


        if strcmp(this.pFrequencyInputRBWSource,'Property')
            this.pRBW=evalPropertyValue(this,'RBW');
        end


        if strcmp(this.pFrequencyVectorSource,'Property')
            this.CurrentFVector=evalPropertyValue(this,'FrequencyVector');
        end
        maxDims=this.Plotter.MaxDimensions;

        this.DataBuffer.SegmentLength=maxDims(1);
        this.DataBuffer.OverlapPercent=0;
        this.DataBuffer.NumChannels=maxDims(2);

        this.pInputUnits=getPropertyValue(this,'InputUnits');
        units=getPropertyValue(this,'FrequencyInputSpectrumUnits');
        if strcmp(units,'Auto')
            this.pSpectrumUnits=this.pInputUnits;
        else
            this.pSpectrumUnits=units;
        end
    end

    if strcmp(getPropertyValue(this,'TimeSpanSource'),'Property')
        this.pTimeSpan=evalPropertyValue(this,'TimeSpan');
    end

    this.pTwoSidedSpectrum=getPropertyValue(this,'TwoSidedSpectrum');





    if this.IsSourceValid
        if~this.IsSystemObjectSource

            validateSettingsForCurrentLicense(this,false);
        end
        validateSpectrumSettings(this);
    end


    updateNoDataAvailableMessage(this,false);


    setPropertyValue(this,'IsSpanValuesValid',true)
    updateFrequencySpan(this);
    updateFrequencyScale(this);



    if~isFrequencyInputMode(this)
        setupDataBuffer(this);
    end
    setLineProperties(this);
    lineVisual_updatePropertyDb(this);
    updateLineProperties(this);
    synchronizeWithPlotter(this);

    maskProps=get(this.MaskSpecificationObject);
    if~isempty(maskProps)
        this.MaskTesterObject.pEnabledMasks=getPropertyValue(this,'EnabledMasks');
        this.MaskTesterObject.pUpperMask=evalPropertyValue(this,'UpperMask');
        this.MaskTesterObject.pLowerMask=evalPropertyValue(this,'LowerMask');
        this.MaskTesterObject.pReferenceLevel=getPropertyValue(this,'ReferenceLevel');
        this.MaskTesterObject.pCustomReferenceLevel=evalPropertyValue(this,'CustomReferenceLevel');
        this.MaskTesterObject.pSelectedChannel=evalPropertyValue(this,'SelectedChannel');
        this.MaskTesterObject.pMaskFrequencyOffset=evalPropertyValue(this,'MaskFrequencyOffset');
    end
    validateSpectralMask(this);


    updateView(this);

    dlgObject=getSpectrumSettingsDialog(this);
    if~isempty(dlgObject)


        refreshDlgProp(dlgObject,'SampleRate',false);
        refreshDlgProp(dlgObject,'ChannelNumber');
    end
    this.IsVisualStartingUp=false;
    updateXAxisLabels(this.Plotter,true);
    hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
    if~isempty(hPlotNav)
        this.pAutoScaleListenerState=enableLimitListeners(hPlotNav,false);
    end
    updateYAxisLabels(this.Plotter,true);
    if~isempty(hPlotNav)
        enableLimitListeners(hPlotNav,this.pAutoScaleListenerState);
    end
    updateInset(this);
    refreshReadouts(this)
    updateSamplesPerUpdateMessage(this);
    updateNoDataAvailableMessage(this);
    updateCorrectionModeMessage(this);
    updateColorBar(this);
end
