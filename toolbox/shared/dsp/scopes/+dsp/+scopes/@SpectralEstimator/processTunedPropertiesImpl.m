function processTunedPropertiesImpl(obj)





    if checkChangedProp(obj,'FrequencySpan')||checkChangedProp(obj,'Span')...
        ||checkChangedProp(obj,'CenterFrequency')||checkChangedProp(obj,'StartFrequency')...
        ||checkChangedProp(obj,'StopFrequency')||checkChangedProp(obj,'RBWSource')...
        ||checkChangedProp(obj,'RBW')||checkChangedProp(obj,'WindowLength')...
        ||checkChangedProp(obj,'OverlapPercent')||checkChangedProp(obj,'ChannelMode')...
        ||checkChangedProp(obj,'ChannelNumber')||checkChangedProp(obj,'FrequencyResolutionMethod')...
        ||checkChangedProp(obj,'Method')...
        ||checkChangedProp(obj,'NumTapsPerBand')||checkChangedProp(obj,'AveragingMethod')


        x=getSegments(obj.DataBuffer);
        thisSetup(obj,x);
        reset(obj);
        syncOldProperties(obj);


        return
    end
    if strcmp(obj.ChannelMode,'All')
        nChan=obj.pNumChannels;
    else
        nChan=1;
    end



    if checkChangedProp(obj,'Window')||checkChangedProp(obj,'CustomWindow')||...
        checkChangedProp(obj,'SidelobeAttenuation')
        setWindow(obj);
        setNFFT(obj);
        computeFrequencyVector(obj);
        reset(obj);
    end


    if checkChangedProp(obj,'AveragingMethod')
        obj.pPeriodogramMatrix=zeros(obj.pNFFT,obj.SpectralAverages,nChan);
        obj.pPreviousExpAvgSpectrum=zeros(obj.pNFFT,nChan);
        obj.pPreviousWeight=0;
    end


    cachedOldValue=obj.pSpectralAveragesOld;
    if checkChangedProp(obj,'SpectralAverages')


        obj.pPeriodogramMatrix=circshift(obj.pPeriodogramMatrix,[0,cachedOldValue-obj.pNewPeriodogramIdx]);
        if cachedOldValue>obj.SpectralAverages

            obj.pPeriodogramMatrix=obj.pPeriodogramMatrix(:,end-obj.SpectralAverages+1:end,:);
            obj.pNewPeriodogramIdx=0;
        else
            extraCols=obj.SpectralAverages-cachedOldValue;
            obj.pNewPeriodogramIdx=cachedOldValue;

            obj.pPeriodogramMatrix=[obj.pPeriodogramMatrix,zeros(obj.pNFFT,extraCols,nChan)];
        end
    end



    if(checkChangedProp(obj,'FFTLengthSource')||checkChangedProp(obj,'FFTLength'))
        if strcmp(obj.Method,'Welch')
            setNFFT(obj);
            obj.pPeriodogramMatrix=zeros(obj.pNFFT,obj.SpectralAverages,nChan);
            obj.pNewPeriodogramIdx=0;
            obj.pNumAvgsCounter=0;


            computeFrequencyVector(obj);
            resetMaxMinHoldStates(obj);
        else
            x=getSegments(obj.DataBuffer);
            thisSetup(obj,x);
            reset(obj);
            syncOldProperties(obj);
        end
    end


    if checkChangedProp(obj,'MaxHoldTrace')
        resetMaxMinHoldStates(obj,'MaxHoldTrace')
    end
    if checkChangedProp(obj,'MinHoldTrace')
        resetMaxMinHoldStates(obj,'MinHoldTrace')
    end
end
