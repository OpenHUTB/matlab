function processTimeDomainData(this,data,doPlotFlag,isRescaleOnly,refreshsamplesPerUpdate)





    if~isempty(data)&&isCCDFMode(this)

        processDataCCDF(this,data);
    elseif~isempty(data)&&~isRescaleOnly


        if~isLocked(this.SpectrumObject)
            computeFullScale(this);
        end

        this.pRawInputFrameSize=double(getLastFrameSize(this.DataBuffer));
        this.pRawInputTotalSimTime=this.pRawInputFrameSize/this.pSampleRate;

        if(this.IsNotInCorrectionMode)&&doPlotFlag
            if(isSpectrogramMode(this)||isCombinedViewMode(this))&&getDataSkippedFlag(this.DataBuffer)


                updateView(this);
                setDataSkippedFlag(this.DataBuffer,false);
            end
            if~this.ReduceUpdates

                processDataNormalRate(this,data);
            else

                processDataReducedRate(this,data);
            end
        end
    elseif isRescaleOnly&&~isSpectrogramMode(this)&&~isCombinedViewMode(this)&&~isCCDFMode(this)&&~isempty(this.CurrentPSD)&&~isempty(this.CurrentFVector)

        this.IsUpdateReady=true;
        [this.ScaledPSD{1,1},...
        this.ScaledMaxHoldTrace{1,1},...
        this.ScaledMinHoldTrace{1,1},~]=updatePlot(this);

        notify(this,'SpectrumDataUpdated');
    elseif isRescaleOnly&&~isSpectrogramMode(this)&&isCombinedViewMode(this)&&~isCCDFMode(this)&&~isempty(this.CurrentPSD)&&~isempty(this.CurrentFVector)


        this.IsUpdateReady=true;
        [this.ScaledPSD{1,1},...
        this.ScaledSpectrogram{1,1},...
        this.ScaledMaxHoldTrace{1,1},...
        this.ScaledMinHoldTrace{1,1},~]=updateCombinedViewPlot(this);

        notify(this,'SpectrumDataUpdated');
    elseif isRescaleOnly&&isSpectrogramMode(this)&&~isempty(this.CurrentSpectrogram)&&~isempty(this.CurrentFVector)

        this.IsUpdateReady=true;
        this.ScaledSpectrogram{1,1}=updateSpectrogramPlot(this);

        notify(this,'SpectrumDataUpdated');
    else
        if refreshsamplesPerUpdate



            reset(this);
            updateSamplesPerUpdateMessage(this,true);
            this.IsNewDataReady=false;
        end
    end

end