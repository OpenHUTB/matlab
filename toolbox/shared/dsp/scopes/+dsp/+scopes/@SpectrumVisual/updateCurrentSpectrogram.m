function updateCurrentSpectrogram(this,data)






    N=this.NumSpectralUpdatesPerLine;

    K=size(this.CurrentSpectrogram,1);

    numSpectralUpdateCols=size(data,2);
    P=numSpectralUpdateCols/N;




    minIdx=min(P,K);
    offsetVal=0;
    if this.ReduceUpdates&&(P>K)




        offsetVal=-1;
    end





    if strcmpi(getPropertyValue(this,'AveragingMethod'),'Exponential')
        dataStartIdx=1;
        offsetVal=0;
    else
        dataStartIdx=numSpectralUpdateCols-minIdx*N+1+offsetVal;
    end
    dataEndIdx=numSpectralUpdateCols;
    [spectralUpdates,maxHoldPSD,minHoldPSD,Fvect]=step(this.SpectrumObject,...
    data(:,dataStartIdx:dataEndIdx,:));

    if isCombinedViewMode(this)||strcmp(this.pMethod,'Filter bank')

        currentPSDTemp=spectralUpdates(:,1,:);
        if~isempty(maxHoldPSD)
            maxHoldPSDTemp=maxHoldPSD(:,1,:);
        else
            maxHoldPSDTemp=[];
        end
        if~isempty(minHoldPSD)
            minHoldPSDTemp=minHoldPSD(:,1,:);
        else
            minHoldPSDTemp=[];
        end
        this.CurrentMaxHoldPSD=[];
        this.CurrentMinHoldPSD=[];
        this.CurrentPSD=squeeze(currentPSDTemp);
        this.CurrentMaxHoldPSD=squeeze(maxHoldPSDTemp);
        this.CurrentMinHoldPSD=squeeze(minHoldPSDTemp);


        channelNumber=this.pChannelNumber;
        spectralUpdates=spectralUpdates(:,:,channelNumber);
    end

    if offsetVal==-1
        this.LastSpectrumUpdate=spectralUpdates(:,1);
        spectralUpdates=spectralUpdates(:,2:end);
    end

    if N>1
        aggregatedSpectra=aggregateSpectrum(this,spectralUpdates,N,minIdx);
    else
        aggregatedSpectra=spectralUpdates.';
    end






    this.CurrentSpectrogram=circshift(this.CurrentSpectrogram,minIdx);
    this.CurrentSpectrogram(1:minIdx,:)=aggregatedSpectra(1:minIdx,:);
    this.CurrentFVector=Fvect;





    this.SpectrogramLineCounter=min(K,this.SpectrogramLineCounter+minIdx);

    updateOffsetReadout(this);
end