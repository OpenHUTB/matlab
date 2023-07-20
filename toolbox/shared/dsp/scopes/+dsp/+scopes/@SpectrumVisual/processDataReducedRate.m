function processDataReducedRate(this,data)



    this.IsUpdateReady=true;

    this.NumSegments=1;

    if strcmp(this.pViewType,'Spectrogram')

        updateCurrentSpectrogram(this,data);
        this.ScaledSpectrogram{1,1}=updateSpectrogramPlot(this);
    elseif isCombinedViewMode(this)

        updateCurrentSpectrogram(this,data);
        [this.ScaledPSD{1,1},...
        this.ScaledSpectrogram{1,1},...
        this.ScaledMaxHoldTrace{1,1},...
        this.ScaledMinHoldTrace{1,1},~]=updateCombinedViewPlot(this);
    else

        [PSD,maxHoldPSD,minHoldPSD,FVector]=step(this.SpectrumObject,data);
        this.CurrentMaxHoldPSD=[];
        this.CurrentMinHoldPSD=[];
        this.CurrentPSD=PSD;
        this.CurrentMaxHoldPSD=maxHoldPSD;
        this.CurrentMinHoldPSD=minHoldPSD;
        this.CurrentFVector=FVector;

        [this.ScaledPSD{1,1},this.ScaledMaxHoldTrace{1,1},this.ScaledMinHoldTrace{1,1},~]=updatePlot(this);

    end

    if(this.IsUpdateReady&&isvalid(this.DataBuffer))||this.IsRescaleOnly
        notify(this,'SpectrumDataUpdated');
    end
end
