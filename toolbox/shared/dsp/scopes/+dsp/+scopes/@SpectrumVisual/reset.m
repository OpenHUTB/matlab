function reset(this)




    reset(this.Plotter);
    this.CurrentPSD=[];
    this.CurrentMaxHoldPSD=[];
    this.CurrentMinHoldPSD=[];
    this.CurrentSpectrogram=[];
    this.SimulationTime=0;

    if~isFrequencyInputMode(this)
        resetCCDF(this);
        this.CurrentFVector=[];
    end




    if~isLocked(this.SpectrumObject)

        reset(this.MaskTesterObject);
        if isvalid(this.DataBuffer)
            setNumProcessedSamples(this.DataBuffer,0);
            this.ProcessedSamplesInBuffer=0;

        end
    end
    if isvalid(this.DataBuffer)
        setDataSkippedFlag(this.DataBuffer,false);
    end
    if isSourceRunning(this)
        resetSpectrogram(this);
    else
        removeTicksFlag=false;
        blankSpectrogram(this,removeTicksFlag);
    end


    notify(this,'DisplayUpdated',uiservices.DataEventData(struct('UserGenerated',false)));
    updateInset(this);
    updateColorBar(this);

    if isfield(this.Handles,'TimeOffsetStatus')
        set(this.Handles.TimeOffsetStatus,'Text',[this.OffsetLabel,'0 s']);
    end
