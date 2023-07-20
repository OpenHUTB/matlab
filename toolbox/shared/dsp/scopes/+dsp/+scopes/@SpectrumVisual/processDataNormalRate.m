function processDataNormalRate(this,data)



    this.IsUpdateReady=true;

    if~this.ProcessLastSegmentOnly
        startInd=1;
    else
        startInd=size(data,2);
    end

    N=this.NumSpectralUpdatesPerLine;
    isSpectrogram=strcmp(this.pViewType,'Spectrogram');
    this.TimeOffsetShiftIndex=size(data,2)/N;

    this.NumSegments=size(data,2);
    for index=startInd:N:size(data,2)




        if(this.PropChanged)
            this.PropChanged=false;


            if(index~=1)

                new_data=getUnprocessedData(this,data,index);


                processedSamples=getNumProcessedSamples(this.DataBuffer);
                this.SpectrumObject.DataBuffer.addValue(new_data);
                setNumProcessedSamples(this.DataBuffer,processedSamples);


                this.SpectrumObject.DataBuffer.rebuffer;

                if this.SpectrumObject.DataBuffer.IsReady
                    processDataNormalRate(this,getBufferedData(this));
                else




                    reset(this);
                    updateSamplesPerUpdateMessage(this,true)
                end

                break
            end
        end
        if isSpectrogram

            updateCurrentSpectrogram(this,data(:,index:index+N-1,:));
            this.ScaledSpectrogram{index}=updateSpectrogramPlot(this);
            this.TimeOffsetShiftIndex=this.TimeOffsetShiftIndex-1;
        elseif isCombinedViewMode(this)

            updateCurrentSpectrogram(this,data(:,index:index+N-1,:));
            [this.ScaledPSD{index},...
            this.ScaledSpectrogram{index,1},...
            this.ScaledMaxHoldTrace{index,1},...
            this.ScaledMinHoldTrace{index,1},~]=updateCombinedViewPlot(this);
            this.TimeOffsetShiftIndex=this.TimeOffsetShiftIndex-1;
        else

            [PSD,maxHoldPSD,minHoldPSD,FVector]=step(this.SpectrumObject,...
            data(:,index:index+N-1,:));
            this.CurrentFVector=FVector;
            this.CurrentPSD=PSD;
            this.CurrentMaxHoldPSD=maxHoldPSD;
            this.CurrentMinHoldPSD=minHoldPSD;

            [this.ScaledPSD{index,1},...
            this.ScaledMaxHoldTrace{index,1},...
            this.ScaledMinHoldTrace{index,1},~]=updatePlot(this);
        end
    end

    if(this.IsUpdateReady&&isvalid(this.DataBuffer))||this.IsRescaleOnly
        notify(this,'SpectrumDataUpdated');
    end
end
