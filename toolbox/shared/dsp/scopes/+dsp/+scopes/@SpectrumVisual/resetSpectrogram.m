function flag=resetSpectrogram(this,zeroOutSpectrogramFlag)






    flag=false;
    if~(isSpectrogramMode(this)||isCombinedViewMode(this))
        return
    end
    this.SpectrogramLineCounter=0;
    extraTimeIncrement=0;
    this.PowerColorExtents=[NaN,NaN];
    if nargin==1


        zeroOutSpectrogramFlag=false;
    end
    maxDims=this.Plotter.MaxDimensions;

    if~isFrequencyInputMode(this)
        hSpectrum=this.SpectrumObject;
        if~isLocked(hSpectrum)
            setup(this.SpectrumObject,zeros(maxDims));
            c=onCleanup(@()releaseSpectrumObject(this));
        end
        Fs=hSpectrum.SampleRate;



        currentRBW=getActualRBW(hSpectrum);
        numSamplesPerUpdate=getInputSamplesPerUpdate(hSpectrum);
    else
        Fs=this.pSampleRate;
        currentRBW=this.pRBW;
        numSamplesPerUpdate=maxDims(1);
    end


    this.LastSpectrumPowerWeight=0;

    minTimeResolution=1/currentRBW;
    if strcmp(getPropertyValue(this,'TimeResolutionSource'),'Auto')
        N=1;
        this.NumSpectralUpdatesPerLine=N;
        this.ActualTimeResolution=minTimeResolution;
    else
        timeResolution=evalPropertyValue(this,'TimeResolution');
        N=max(1,floor(timeResolution/minTimeResolution));
        this.NumSpectralUpdatesPerLine=N;



        this.LastSpectrumPowerWeight=abs((timeResolution-N*minTimeResolution))/minTimeResolution;
        this.ActualTimeResolution=timeResolution;
        extraTimeIncrement=this.LastSpectrumPowerWeight*numSamplesPerUpdate/Fs;
    end


    this.DataBuffer.SegmentsPerBlock=N;





    this.TimeIncrementNoExtraIncrement=N*numSamplesPerUpdate/Fs;
    timeIncrement=this.TimeIncrementNoExtraIncrement+extraTimeIncrement;
    this.TimeIncrement=timeIncrement;
    if strcmp(getPropertyValue(this,'TimeSpanSource'),'Auto')
        K=100;
        timeSpan=K*timeIncrement;
    else


        timeSpan=evalPropertyValue(this,'TimeSpan');
        K=max(2,ceil(timeSpan/timeIncrement));
    end

    this.TimeVector=-1.*fliplr((0:K-1)*timeIncrement);
    if~strcmp(getPropertyValue(this,'TimeSpanSource'),'Auto')&&abs(this.TimeVector(1))<timeSpan
        K=K+1;
        this.TimeVector=-1.*fliplr((0:K-1)*timeIncrement);
    end
    this.Plotter.TimeVector=this.TimeVector;
    this.Plotter.TimeSpan=timeSpan;
    if~isFrequencyInputMode(this)
        fv=getFrequencyVector(hSpectrum);
        this.FrequencyVector=fv;
    else
        fv=computeFrequencyInputFrequencyVector(this,maxDims);
    end
    L=length(fv);



    this.LastSpectrumUpdate=zeros(L,1);


    if~isequal(size(this.CurrentSpectrogram),[K,L])||zeroOutSpectrogramFlag
        this.CurrentSpectrogram=zeros(K,L);
        flag=true;
    end
    if~isempty(this.Plotter)

        if~isFrequencyInputMode(this)
            cData=scaleSpectrogram(this);
        else
            [cData,minVal,maxVal]=scaleFrequencyInputSpectrogram(this,this.CurrentSpectrogram);
            computePowerColorExtents(this,minVal,maxVal);
        end
        if strcmpi(this.Plotter.FrequencyScale,'log')||strcmpi(this.pInputDomain,'Frequency')
            set(this.Plotter.hImage,'ZData',zeros(size(cData)));
        end

        set(this.Plotter.hImage,'XData',fv);
        set(this.Plotter.hImage,'YData',fliplr(this.TimeVector));
        set(this.Plotter.hImage,'Cdata',cData);

        updateTimeSpan(this.Plotter);

        updateFrequencySpan(this.Plotter);

        updateColorBar(this)
    end
end
