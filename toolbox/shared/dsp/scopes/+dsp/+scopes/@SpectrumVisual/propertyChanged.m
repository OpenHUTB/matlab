function propertyChanged(this,propName)




    if~ischar(propName)
        propName=propName.AffectedProperty;
    end
    dlgObject=getSpectrumSettingsDialog(this);
    isRefreshDlg=~isempty(dlgObject)&&~this.IsPropertyChangedFromSettingsDlg;
    spectrum=this.SpectrumObject;
    isScopeLocked=isSourceRunning(this);
    this.ForceAutoScaleOnUpdate=false;
    if isScopeLocked&&~isLocked(spectrum)&&~isFrequencyInputMode(this)

        maxDims=this.Plotter.MaxDimensions;
        setup(spectrum,zeros(maxDims));
        c=onCleanup(@()releaseSpectrumObject(this));
    end






    switch propName
    case 'SpectrumType'
        newType=getPropertyValue(this,'SpectrumType');
        oldType=this.pSpectrumType;


        this.pSpectrumType=newType;


        if~strcmp(newType,oldType)&&~isCCDFMode(this)
            if~(any(strcmp({'Power','Power density','RMS'},newType))&&...
                any(strcmp({'Power','Power density','RMS'},oldType)))



                this.pViewType=newType;
                this.pSpectrumType='Power';

                setPropertyValue(this,'SpectrumType','Power');
                setPropertyValue(this,'ViewType','Spectrogram');
                updateView(this,this.pSpectrumType,this.pViewType);

                if isScopeLocked
                    validFlag=validateCurrentSettings(this);
                    if validFlag
                        localUpdate(this,false,false,true);
                    end
                else
                    removeDataAndReadoutsAndAddMessage(this);
                end
            else


                this.ForceAutoScaleOnUpdate=true;
                localUpdate(this,true,true);
            end
            updateYAxis(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);

            spectralMaskDlg=getSpectralMaskDialog(this);
            if~isempty(spectralMaskDlg)
                refreshSpectralMaskPanels(spectralMaskDlg)
            end



            if any(strcmpi(newType,{'Power','Power density'}))&&strcmpi(oldType,'RMS')
                this.ForceAutoScaleOnUpdate=true;
                this.pSpectrumUnits=getPropertyValue(this,'PowerUnits');
                updateSpectralMask(this);
                updateYLabel(this);
                localUpdate(this,true,true);
                updateYLabel(this);
            elseif any(strcmpi(oldType,{'Power','Power density'}))&&strcmpi(newType,'RMS')
                this.ForceAutoScaleOnUpdate=true;
                this.pSpectrumUnits=getPropertyValue(this,'RMSUnits');
                updateSpectralMask(this);
                updateYLabel(this);
                localUpdate(this,true,true);
                updateYLabel(this);
            end
        end

    case 'ViewType'
        newType=getPropertyValue(this,'ViewType');
        oldType=this.pViewType;
        spectrumType=this.pSpectrumType;


        this.pViewType=newType;
        if~strcmp(newType,oldType)&&(~isCCDFMode(this)||isFrequencyInputMode(this))
            updateView(this,spectrumType,newType)
            if isScopeLocked
                validFlag=validateCurrentSettings(this);
                if validFlag
                    localUpdate(this,false,false,true);
                end
            else
                removeDataAndReadoutsAndAddMessage(this);
            end
        end

        spectralMaskDlg=getSpectralMaskDialog(this);
        if~isempty(spectralMaskDlg)
            refreshSpectralMaskPanels(spectralMaskDlg)
        end
        updateYAxis(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);

    case 'AxesLayout'
        if strcmp(this.Plotter.PlotMode,'SpectrumAndSpectrogram')
            newLayout=getPropertyValue(this,'AxesLayout');
            oldLayout=this.pAxesLayout;


            this.pAxesLayout=newLayout;
            this.ForceAutoScaleOnUpdate=true;
            if~strcmp(newLayout,oldLayout)
                sendEvent(this.Application,'VisualChanged')

                updateYAxis(this);
                this.Plotter.AxesLayout=this.pAxesLayout;

                this.Plotter.PlotMode='SpectrumAndSpectrogram';


                if~isScopeLocked
                    blankSpectrogram(this);
                    updateColorBar(this);
                    updateInset(this);
                else
                    updateInset(this);
                end


                updateLegend(this);

                updateTitlePosition(this);
                updateInset(this);

                refreshStyleDialog(this);

                updateFrequencyScale(this);
                if isScopeLocked
                    validFlag=validateCurrentSettings(this);
                    if validFlag




                        synchronizeWithSpectrumObject(this,true);
                    end
                end
            end
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'FrequencySpan'
        if isScopeLocked
            if strcmp(getPropertyValue(this,'FrequencySpan'),'Full')



                spectrum.FrequencySpan='Full';


                validFlag=validateCurrentSettings(this);
                if validFlag








                    syncFrequencyAndTimePropsOnly=true;
                    synchronizeWithSpectrumObject(this,syncFrequencyAndTimePropsOnly);
                end
            else
                if strcmp(getPropertyValue(this,'FrequencySpan'),'Span and center frequency')



                    spectrum.FrequencySpan='Span and center frequency';



                    setPropertyValue(this,'IsSpanCFSettingDirty',true);
                    validFlag=validateCurrentSettings(this);
                    if validFlag




                        synchronizeWithSpectrumObject(this,true);
                    end
                else



                    spectrum.FrequencySpan='Start and stop frequencies';



                    setPropertyValue(this,'IsFstartFstopSettingDirty',true);
                    validFlag=validateCurrentSettings(this);
                    if validFlag




                        synchronizeWithSpectrumObject(this,true);
                    end
                end
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);

            if validFlag
                updateFrequencySpan(this);
            end
        else

            if strcmp(getPropertyValue(this,'FrequencySpan'),'Span and center frequency')
                setPropertyValue(this,'IsSpanCFSettingDirty',true);
            end
            if strcmp(getPropertyValue(this,'FrequencySpan'),'Start and stop frequencies')
                setPropertyValue(this,'IsFstartFstopSettingDirty',true);
            end


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case{'Span','CenterFrequency'}
        setPropertyValue(this,'IsSpanCFSettingDirty',true);
        if strcmp(getPropertyValue(this,'FrequencySpan'),'Span and center frequency')


            if~this.IsPropertyChangedFromSettingsDlg
                if strcmp(propName,'Span')
                    setPropertyValue(this,'SpanEditBoxDirtyState',false);
                else
                    setPropertyValue(this,'CFEditBoxDirtyState',false);
                end
            end
            if isScopeLocked





                validFlag=validateCurrentSettings(this);
                if validFlag




                    synchronizeWithSpectrumObject(this,true);
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                if validFlag
                    updateFrequencySpan(this);
                end
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        end
    case{'StartFrequency','StopFrequency'}
        setPropertyValue(this,'IsFstartFstopSettingDirty',true);
        if strcmp(getPropertyValue(this,'FrequencySpan'),'Start and stop frequencies')


            if~this.IsPropertyChangedFromSettingsDlg
                if strcmp(propName,'StartFrequency')
                    setPropertyValue(this,'SpanEditBoxDirtyState',false);
                else
                    setPropertyValue(this,'CFEditBoxDirtyState',false);
                end
            end
            if isScopeLocked



                validFlag=validateCurrentSettings(this);
                if validFlag




                    synchronizeWithSpectrumObject(this,true);
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                if validFlag
                    updateFrequencySpan(this);
                end
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        end

    case{'FrequencyResolutionMethod','FrequencyResolutionMethodWelch','FrequencyResolutionMethodFilterBank'}


        this.pFrequencyResolutionMethod=getPropertyValue(this,propName);
        if strcmp(propName,'FrequencyResolutionMethod')
            if strcmp(this.pMethod,'Welch')
                setPropertyValue(this,'FrequencyResolutionMethodWelch',this.pFrequencyResolutionMethod)
            else
                setPropertyValue(this,'FrequencyResolutionMethodFilterBank',this.pFrequencyResolutionMethod)
            end
        else
            setPropertyValue(this,'FrequencyResolutionMethod',this.pFrequencyResolutionMethod)
        end
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag
                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'RBWSource'
        if any(strcmp(this.pFrequencyResolutionMethod,{'WindowLength','NumFrequencyBands'}))




            setPropertyValue(this,'IsRBWSettingDirty',true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            return
        end
        if isScopeLocked

            if strcmp(getPropertyValue(this,propName),'Property')&&...
                ~getPropertyValue(this,'IsRBWSettingDirty')


                RBW=getRBW(spectrum);
                setPropertyValue(this,'RBW',mat2str(RBW));
            end


            validFlag=validateCurrentSettings(this);




            if validFlag
                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
        if strcmp(getPropertyValue(this,propName),'Property')


            setPropertyValue(this,'IsRBWSettingDirty',true);
        end
    case 'RBW'
        setPropertyValue(this,'IsRBWSettingDirty',true);
        if strcmp(this.pInputDomain,'Time')
            if any(strcmp(this.pFrequencyResolutionMethod,{'WindowLength','NumFrequencyBands'}))


                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                return
            end
        end
        if~this.IsPropertyChangedFromSettingsDlg
            setPropertyValue(this,'RBWEditBoxDirtyState',false);
        end

        if strcmp(getPropertyValue(this,'RBWSource'),'Property')||...
            strcmp(getPropertyValue(this,'FrequencyInputRBWSource'),'Property')


            if isScopeLocked

                validFlag=validateCurrentSettings(this);




                if~isFrequencyInputMode(this)
                    if validFlag




                        synchronizeWithSpectrumObject(this,true);
                    end
                    localUpdate(this,false,false,true,true);
                    refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                else
                    if validFlag
                        this.pRBW=evalPropertyValue(this,'RBW');
                    end
                end

                updateSpanReadOut(this);
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end

        elseif strcmp(getPropertyValue(this,'FrequencyInputRBWSource'),'Auto')&&isFrequencyInputMode(this)
            if isScopeLocked

                this.pRBW=min(diff(this.CurrentFVector));
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        end
    case 'WindowLength'
        if any(strcmp(this.pFrequencyResolutionMethod,{'RBW','NumFrequencyBands'}))


            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            return
        end
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag




                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'FFTLengthSource'
        if strcmp(this.pFrequencyResolutionMethod','RBW')



            setPropertyValue(this,'IsNFFTSettingDirty',true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            return
        end
        isSetToProperty=strcmp(getPropertyValue(this,'FFTLengthSource'),'Property');

        if isSetToProperty&&~getPropertyValue(this,'IsNFFTSettingDirty')

            [val,~,errMsg]=evalPropertyValue(this,'WindowLength');
            if isempty(errMsg)
                NFFT=2^nextpow2(val);
                setPropertyValue(this,'FFTLength',mat2str(NFFT));
            end
        end
        if isScopeLocked


            validFlag=validateCurrentSettings(this);
            if validFlag
                synchronizeWithSpectrumObject(this,true);
            end
            spectrum.FFTLengthSource=getPropertyValue(this,'FFTLengthSource');
            localUpdate(this,false,false,false,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else
            reset(this);
            updateNoDataAvailableMessage(this,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
        if strcmp(getPropertyValue(this,propName),'Property')


            setPropertyValue(this,'IsNFFTSettingDirty',true);
        end
    case 'FFTLength'
        setPropertyValue(this,'IsNFFTSettingDirty',true);
        if strcmp(this.pFrequencyResolutionMethod,'RBW')


            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            return
        end
        if strcmp(getPropertyValue(this,'FFTLengthSource'),'Property')


            if isScopeLocked
                validFlag=validateCurrentSettings(this);
                if validFlag




                    synchronizeWithSpectrumObject(this,true);
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                updateSpanReadOut(this);
            else
                reset(this);
                updateNoDataAvailableMessage(this,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        end
    case 'NumTapsPerBand'

        this.pNumTapsPerBand=evalPropertyValue(this,propName);
        if strcmp(getPropertyValue(this,'Method'),'Welch')


            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            return
        end
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag




                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else
            reset(this);
            updateNoDataAvailableMessage(this,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

    case 'TimeSpanSource'
        isSetToProperty=strcmp(getPropertyValue(this,'TimeSpanSource'),'Property');
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            if isScopeLocked


                if isSetToProperty&&~getPropertyValue(this,'IsTimeSpanSettingDirty')


                    if~isFrequencyInputMode(this)
                        minTimeIncrement=getInputSamplesPerUpdate(spectrum)/spectrum.SampleRate;
                        currentRBW=getActualRBW(spectrum);
                        minTimeResolution=1/currentRBW;

                    else
                        minTimeIncrement=this.Plotter.MaxDimensions/spectrum.SampleRate;
                        currentRBW=this.pRBW;
                        minTimeResolution=1/currentRBW;
                    end
                    if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Auto')
                        N=1;
                    else
                        [timeRes,~,errStr]=evaluateVariable(this.Application,...
                        getPropertyValue(this,'TimeResolution'));
                        if isempty(errStr)
                            N=max(1,ceil(timeRes/minTimeResolution));
                        else
                            N=1;
                        end
                    end
                    timeSpan=N*100*minTimeIncrement;
                    setPropertyValue(this,'TimeSpan',mat2str(timeSpan))
                end


                validFlag=validateCurrentSettings(this);
                if isSetToProperty&&validFlag




                    this.pTimeSpan=evalPropertyValue(this,'TimeSpan');
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        else


            this.NeedToUpdateTimeSpan=true;
        end
        if isSetToProperty




            setPropertyValue(this,'IsTimeSpanSettingDirty',true);
        end
    case 'TimeSpan'
        setPropertyValue(this,'IsTimeSpanSettingDirty',true);
        if~this.IsPropertyChangedFromSettingsDlg
            setPropertyValue(this,'TimeSpanEditBoxDirtyState',false);
        end
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            if strcmp(getPropertyValue(this,'TimeSpanSource'),'Property')


                if isScopeLocked


                    validFlag=validateCurrentSettings(this);







                    if validFlag
                        this.pTimeSpan=evalPropertyValue(this,'TimeSpan');
                    end
                    localUpdate(this,false,false,true,true);
                    refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                else


                    removeDataAndReadoutsAndAddMessage(this);
                    refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                end
            end
        else


            this.NeedToUpdateTimeSpan=true;
        end
    case 'TimeResolutionSource'
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            if isScopeLocked
                isSetToProperty=strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property');


                if isSetToProperty&&~getPropertyValue(this,'IsTimeResolutionSettingDirty')


                    timeResolution=1/getActualRBW(spectrum);
                    setPropertyValue(this,'TimeResolution',mat2str(timeResolution));
                end


                validFlag=validateCurrentSettings(this);



                if validFlag
                    this.pTimeResolution=evalPropertyValue(this,'TimeResolution');
                    synchronizeWithSpectrumObject(this,true);
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                updateSpanReadOut(this);
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        else


            this.NeedToUpdateTimeResolution=true;
        end
        if strcmp(getPropertyValue(this,propName),'Property')




            setPropertyValue(this,'IsTimeResolutionSettingDirty',true);
        end
    case 'TimeResolution'
        setPropertyValue(this,'IsTimeResolutionSettingDirty',true);
        if~this.IsPropertyChangedFromSettingsDlg
            setPropertyValue(this,'TimeResolutionEditBoxDirtyState',false);
        end
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')


                if isScopeLocked
                    validFlag=validateCurrentSettings(this);








                    if validFlag
                        this.pTimeResolution=evalPropertyValue(this,'TimeResolution');
                        synchronizeWithSpectrumObject(this,true);
                    end
                    localUpdate(this,false,false,true,true);
                    refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                    updateSpanReadOut(this);
                else


                    removeDataAndReadoutsAndAddMessage(this);
                    refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                end
            end
        else


            this.NeedToUpdateTimeResolution=true;
        end
    case 'OverlapPercent'
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag




                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'Window'



        winName=getPropertyValue(this,'Window');
        if~this.IsPropertyChangedFromSettingsDlg


            spectrum.Window=winName;


            if strcmp(winName,'Custom')
                spectrum.CustomWindow=getPropertyValue(this,'CustomWindow');
            end
        else



            if isValidWindowName(winName)
                spectrum.Window=winName;
            else
                spectrum.Window='Custom';
                spectrum.CustomWindow=getPropertyValue(this,'CustomWindow');
            end
        end
        if isScopeLocked

            validFlag=validateCurrentSettings(this);
            if validFlag


                synchronizeWithSpectrumObject(this,true);
            end


            if isValidWindowName(winName)||(strcmp(winName,'Custom')&&~isempty(spectrum.CustomWindow))
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                updateSpanReadOut(this);
            end
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

    case 'CustomWindow'
        spectrum.Window='Custom';
        spectrum.CustomWindow=getPropertyValue(this,'CustomWindow');
        if isScopeLocked

            validFlag=validateCurrentSettings(this);
            if validFlag
                synchronizeWithSpectrumObject(this,true);
            end
            localUpdate(this,false,false,true,true);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            updateSpanReadOut(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'SidelobeAttenuation'
        winName=getPropertyValue(this,'Window');
        if any(strcmp({'Chebyshev','Kaiser'},winName))




            if isScopeLocked
                spectrum.SidelobeAttenuation=evalPropertyValue(this,'SidelobeAttenuation');


                validFlag=validateCurrentSettings(this);
                if validFlag


                    synchronizeWithSpectrumObject(this,true);
                end
                localUpdate(this,false,false,true,true);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
                updateSpanReadOut(this);
            else


                removeDataAndReadoutsAndAddMessage(this);
                refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            end
        end

    case 'AveragingMethod'
        spectrum.AveragingMethod=getPropertyValue(this,propName);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
    case{'SpectralAverages','ForgettingFactor'}
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        if isScopeLocked&&~strcmp(this.pViewType,'Spectrogram')||strcmp(this.pViewType,'Spectrum and spectrogram')
            spectrum.(propName)=evalPropertyValue(this,propName);
            localUpdate(this,false);
        end

    case{'MaxHoldTrace','MinHoldTrace'}





        if~strcmp(this.pViewType,'Spectrogram')
            if~getPropertyValue(this,propName)
                if strcmp(propName,'MaxHoldTrace')
                    propName='MaxHoldTrace';
                else
                    propName='MinHoldTrace';
                end
                this.Lines=[this.Plotter.Lines,this.Plotter.([propName,'Lines'])];
            else
                if strcmp(propName,'MaxHoldTrace')
                    this.CurrentMaxHoldPSD=this.CurrentPSD;
                else
                    this.CurrentMinHoldPSD=this.CurrentPSD;
                end
            end
            val=getPropertyValue(this,propName);
            spectrum.(propName)=logical(val);
            this.Plotter.([propName,'Flag'])=val;
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            setLineProperties(this);
            lineVisual_updatePropertyDb(this);
            updateLineProperties(this);
            synchronizeWithPlotter(this);
            if getPropertyValue(this,propName)
                localUpdate(this,true,true);
            end
        else
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            this.(['NeedToUpdate',propName])=true;
        end
    case 'NormalTrace'




        if~any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            if~getPropertyValue(this,propName)
                this.Lines=[this.Plotter.MaxHoldTraceLines,this.Plotter.MinHoldTraceLines];
            end
            this.Plotter.([propName,'Flag'])=getPropertyValue(this,propName);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            setLineProperties(this);
            lineVisual_updatePropertyDb(this);
            updateLineProperties(this);
            synchronizeWithPlotter(this);
            if getPropertyValue(this,propName)
                localUpdate(this,true,true);
            end
        else
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            this.NeedToUpdateNormalTrace=true;
        end

    case 'ReferenceLoad'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.ForceAutoScaleOnUpdate=true;
            this.pReferenceLoad=val;
            localUpdate(this,true,true);
            updateYLabel(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

    case 'FullScaleSource'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        isSetToProperty=strcmp(getPropertyValue(this,'FullScaleSource'),'Property');
        if isScopeLocked
            if isSetToProperty


                validFlag=validateCurrentSettings(this);



                if validFlag
                    this.pFullScale=evalPropertyValue(this,'FullScale');
                    synchronizeWithSpectrumObject(this,true);
                end
            else

                if any(strcmp(this.pInputDataType,{'double','float'}))
                    this.pFullScale=this.pInputPeakValue;
                else
                    this.pFullScale=this.pInputRange;
                end
            end
            this.ForceAutoScaleOnUpdate=true;
            localUpdate(this,true,true);
            updateYLabel(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

    case 'FullScale'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.ForceAutoScaleOnUpdate=true;
            this.pFullScale=val;
            localUpdate(this,true,true);
            updateYLabel(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

    case{'PowerUnits','RMSUnits','FrequencyInputSpectrumUnits'}
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);


        this.ForceAutoScaleOnUpdate=true;
        units=getPropertyValue(this,propName);
        if strcmp(units,'Auto')
            this.pSpectrumUnits=this.pInputUnits;
        else
            this.pSpectrumUnits=units;
        end
        updateSpectralMask(this);
        updateYLabel(this);
        localUpdate(this,true,true);
        updateYLabel(this);

        spectralMaskDlg=getSpectralMaskDialog(this);
        if~isempty(spectralMaskDlg)
            refreshSpectralMaskPanels(spectralMaskDlg)
        end

    case 'FrequencyOffset'
        if isScopeLocked
            validFlag=validateCurrentSettings(this);
            if validFlag




                synchronizeWithSpectrumObject(this,true);
                synchronizeSpanProperties(this);
            end
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
            if validFlag
                updateFrequencySpan(this);
                validateSpectralMask(this);
                localUpdate(this,true);
                sendEvent(this.Application,'VisualLimitsChanged');
            end
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'SampleRate'
        if strcmp(getPropertyValue(this,'SampleRateSource'),'Property')||this.IsSystemObjectSource
            if~this.IsPropertyChangedFromSettingsDlg
                setPropertyValue(this,'FsEditBoxDirtyState',false);
            end
            [val,~,errMsg]=evalPropertyValue(this,propName);
            if isScopeLocked||isempty(errMsg)
                this.pSampleRate=val;
            end


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end
    case 'FrequencyInputSampleRate'
        if~this.IsPropertyChangedFromSettingsDlg
            setPropertyValue(this,'FsEditBoxDirtyState',false);
        end
        this.pSampleRate=evalPropertyValue(this,propName);


        removeDataAndReadoutsAndAddMessage(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);

    case 'Method'
        if this.IsSystemObjectSource&&~this.IsPropertyChangedFromSettingsDlg
            setPropertyValue(this,'MethodEditBoxDirtyState',false);
        end


        this.pMethod=getPropertyValue(this,'Method');
        if strcmp(this.pMethod,'Welch')
            this.pFrequencyResolutionMethod=getPropertyValue(this,'FrequencyResolutionMethodWelch');
        else
            this.pFrequencyResolutionMethod=getPropertyValue(this,'FrequencyResolutionMethodFilterBank');
        end

        setPropertyValue(this,'FrequencyResolutionMethod',this.pFrequencyResolutionMethod);


        removeDataAndReadoutsAndAddMessage(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);

    case 'InputDomain'

        if~this.IsPropertyChangedFromSettingsDlg
            syncCommonProperties(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,true);
        end


        this.pInputDomain=getPropertyValue(this,'InputDomain');
        this.Plotter.InputDomain=this.pInputDomain;


        if~this.IsSystemObjectSource
            if isFrequencyInputMode(this)
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'IsFrequencyInputMode','1');
            else
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'IsFrequencyInputMode','0');
            end
        end

        updateSpanReadOut(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        removeDataAndReadoutsAndAddMessage(this);

        notify(this,'InvalidateMeasurements');

        notify(this,'AxesDefinitionChanged');

        if isCCDFMode(this)&&~isFrequencyInputMode(this)
            setCCDFMode(this,true)
        else
            this.Plotter.CCDFMode=false;
            updateView(this,this.pSpectrumType,this.pViewType)
        end

    case 'FrequencyInputRBWSource'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        this.pFrequencyInputRBWSource=getPropertyValue(this,propName);
        isSetToProperty=strcmp(this.pFrequencyInputRBWSource,'Property');

        if isScopeLocked
            if isSetToProperty


                validFlag=validateCurrentSettings(this);



                if validFlag
                    this.pRBW=evalPropertyValue(this,'FrequencyInputRBW');
                end
            else

                this.pRBW=min(diff(this.CurrentFVector));
            end

            updateSpanReadOut(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

        if~this.IsSystemObjectSource
            numInputPorts=str2double(getPropValue(this.Application.Specification.Block,'NumInputPorts'));
            if strcmp(this.pFrequencyInputRBWSource,'InputPort')
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts+1));
            elseif any(strcmp(this.pFrequencyInputRBWSource,{'Auto','Property'}))
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts-1));
            end
        end

    case 'FrequencyVectorSource'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        this.pFrequencyVectorSource=getPropertyValue(this,propName);
        isSetToProperty=strcmp(this.pFrequencyVectorSource,'Property');
        if isScopeLocked
            if isSetToProperty


                validFlag=validateCurrentSettings(this);



                if validFlag
                    this.CurrentFVector=evalPropertyValue(this,'FrequencyVector');
                end
            else

                maxDims=this.Plotter.MaxDimensions;
                this.CurrentFVector=computeFrequencyInputFrequencyVector(this,maxDims);
            end

            updateFrequencySpan(this);
        else


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

        if~this.IsSystemObjectSource
            numInputPorts=str2double(getPropValue(this.Application.Specification.Block,'NumInputPorts'));
            if strcmp(this.pFrequencyVectorSource,'InputPort')
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyVectorPort',num2str(numInputPorts+1));
            elseif any(strcmp(this.pFrequencyVectorSource,{'Auto','Property'}))
                Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyVectorPort',num2str(numInputPorts-1));
            end
        end

    case 'FrequencyVector'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked
            if isempty(errMsg)
                validFlag=validateCurrentSettings(this);
                if validFlag
                    this.CurrentFVector=val;
                end
            end
        else
            if isempty(errMsg)
                this.CurrentFVector=val;
                this.pRBW=min(diff(this.CurrentFVector));
            end


            removeDataAndReadoutsAndAddMessage(this);
            refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        end

        updateFrequencySpan(this);

    case 'SampleRateSource'
        removeDataAndReadoutsAndAddMessage(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
    case 'TwoSidedSpectrum'
        val=getPropertyValue(this,propName);
        spectrum.(propName)=logical(val);
        this.pTwoSidedSpectrum=val;


        removeDataAndReadoutsAndAddMessage(this);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
    case 'InputUnits'
        this.pInputUnits=getPropertyValue(this,propName);
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        updateYLabel(this);
        this.ForceAutoScaleOnUpdate=true;
    case 'FrequencyScale'
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        if isScopeLocked
            updateFrequencyScale(this);
        elseif getPropertyValue(this,'IsSpanValuesValid')
            updateFrequencyScale(this);
        else
            reset(this);
            updateNoDataAvailableMessage(this,true);
            updateFrequencyScale(this);
        end
    case 'Title'


        updateInset(this);
        updateTitle(this);
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))
            updateColorBar(this);
        else
            updateTitlePosition(this);
        end
    case 'FrequencyAxisLabel'
        updateXAxisLabels(this);
    case 'ReduceUpdates'
        setReducePlotRateMenu(this,propName);
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))




            this.SpectrumObject.ReduceUpdates=false;
        end
    case 'ChannelNumber'
        this.pChannelNumber=evalPropertyValue(this,'ChannelNumber');
        refreshSpectrumSettingsDlgProp(this,propName,dlgObject,isRefreshDlg);
        if any(strcmp(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}))

            spectrum.ChannelNumber=this.pChannelNumber;
            if isScopeLocked
                validFlag=validateCurrentSettings(this);
                if validFlag
                    localUpdate(this,false,true,true,true);
                    updateFrequencySpan(this);
                end
            else
                reset(this);
                updateNoDataAvailableMessage(this,true);
            end
        end
    case 'MeasurementChannelNumber'
        channelNum=evalPropertyValue(this,'MeasurementChannelNumber');
        if this.PeakFinderObject.Enable
            this.PeakFinderObject.Line=channelNum;
        elseif this.CursorMeasurementsObject.Enable
            this.CursorMeasurementsObject.Line=channelNum;
        elseif this.ChannelMeasurementsObject.Enable
            this.ChannelMeasurementsObject.Line=channelNum;
        elseif this.DistortionMeasurementsObject.Enable
            this.DistortionMeasurementsObject.Line=channelNum;
        end
    case{'MinYLim','MaxYLim'}
        if~isSpectrogramMode(this)&&~isCCDFMode(this)
            propertyChanged@dsp.scopes.LineVisual(this,propName);
        else
            this.NeedToUpdateYLimits=true;
        end
    case 'ColorMap'
        evaluateColorMapExpression(this,getPropertyValue(this,'ColorMap'));
        updateColorMap(this);
    case 'ColorRange'
        updateColorRange(this);
    case{'MaxColorLim','MinColorLim'}
        updateColorRange(this);
        updateInset(this);
        updateColorBar(this);
    case 'PlotType'
        updatePlotType(this);

    case 'EnabledMasks'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg);
        this.MaskTesterObject.pEnabledMasks=getPropertyValue(this,'EnabledMasks');
        if this.IsPropertyChangedFromSettingsDlg
            updateSpectralMask(this,true);
        end
    case 'UpperMask'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg)
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.MaskTesterObject.pUpperMask=val;
            if this.IsPropertyChangedFromSettingsDlg
                updateSpectralMask(this,true);
            end
        end

    case 'LowerMask'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg)
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.MaskTesterObject.pLowerMask=val;
            if this.IsPropertyChangedFromSettingsDlg
                updateSpectralMask(this,true);
            end
        end
    case 'ReferenceLevel'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg);
        this.MaskTesterObject.pReferenceLevel=getPropertyValue(this,'ReferenceLevel');
        if this.IsPropertyChangedFromSettingsDlg
            updateSpectralMask(this,true);
        end
    case 'CustomReferenceLevel'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg)
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.MaskTesterObject.pCustomReferenceLevel=val;
            if this.IsPropertyChangedFromSettingsDlg
                updateSpectralMask(this,true);
            end
        end
    case 'SelectedChannel'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg);
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.MaskTesterObject.pSelectedChannel=val;
            if this.IsPropertyChangedFromSettingsDlg
                updateSpectralMask(this,true);
            end
        end

    case 'MaskFrequencyOffset'
        dlgSpectralMaskObject=getSpectralMaskDialog(this);
        isRefreshSpectralMaskDlg=~isempty(dlgSpectralMaskObject)&&~this.IsPropertyChangedFromSettingsDlg;
        refreshSpectralMaskDlgProp(this,propName,dlgSpectralMaskObject,isRefreshSpectralMaskDlg)
        [val,~,errMsg]=evalPropertyValue(this,propName);
        if isScopeLocked||isempty(errMsg)


            this.MaskTesterObject.pMaskFrequencyOffset=val;
            if this.IsPropertyChangedFromSettingsDlg
                updateSpectralMask(this,true);
            end
        end
    otherwise
        propertyChanged@dsp.scopes.LineVisual(this,propName);
    end
end


function flag=isValidWindowName(winName)
    flag=any(strcmp(winName,{'Rectangular',...
    'Blackman-Harris',...
    'Chebyshev',...
    'Flat Top',...
    'Hamming',...
    'Hann',...
    'Kaiser'}));
end

function syncCommonProperties(this)
    if isFrequencyInputMode(this)



        if any(strcmpi(this.pFrequencyInputRBWSource,{'Auto','Property'}))
            setPropertyValue(this,'RBWSource',this.pFrequencyInputRBWSource);
        elseif strcmpi(this.pFrequencyInputRBWSource,'InputPort')&&~this.IsSystemObjectSource
            numInputPorts=str2double(getPropValue(this.Application.Specification.Block,'NumInputPorts'));
            Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts-1));
        end

        if any(strcmpi(getPropertyValue(this,'FrequencyInputSpectrumUnits'),{'dBm','dBW','Watts'}))
            setPropertyValue(this,'PowerUnits',getPropertyValue(this,'FrequencyInputSpectrumUnits'));
        end

        if this.IsSystemObjectSource||(~this.IsSystemObjectSource&&...
            ~strcmpi(getPropertyValue(this,'SampleRateSource'),'Auto'))
            setPropertyValue(this,'SampleRate',getPropertyValue(this,'FrequencyInputSampleRate'));
        end
    else


        if~strcmpi(this.pFrequencyInputRBWSource,'InputPort')
            rbwSource=getPropertyValue(this,'RBWSource');
            setPropertyValue(this,'FrequencyInputRBWSource',rbwSource);
            this.pFrequencyInputRBWSource=rbwSource;
        elseif strcmpi(this.pFrequencyInputRBWSource,'InputPort')&&~this.IsSystemObjectSource
            numInputPorts=str2double(getPropValue(this.Application.Specification.Block,'NumInputPorts'));
            Simulink.scopes.setBlockParam(this.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts+1));
        end

        if any(strcmpi(getPropertyValue(this,'PowerUnits'),{'dBm','dBW','Watts'}))&&...
            ~strcmpi(getPropertyValue(this,'FrequencyInputSpectrumUnits'),'Auto')
            setPropertyValue(this,'FrequencyInputSpectrumUnits',getPropertyValue(this,'PowerUnits'));
        end

        if this.IsSystemObjectSource||(~this.IsSystemObjectSource&&...
            ~strcmpi(getPropertyValue(this,'SampleRateSource'),'Auto'))
            setPropertyValue(this,'FrequencyInputSampleRate',getPropertyValue(this,'SampleRate'));
        end
    end
end
