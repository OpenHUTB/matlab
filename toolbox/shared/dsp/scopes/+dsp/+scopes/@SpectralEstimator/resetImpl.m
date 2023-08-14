function resetImpl(obj)




    if strcmp(obj.ChannelMode,'All')
        nChan=obj.pNumChannels;
    else
        nChan=1;
    end
    obj.pPeriodogramMatrix=zeros(obj.pNFFT,obj.SpectralAverages,nChan);
    obj.pPreviousExpAvgSpectrum=zeros(obj.pNFFT,nChan);
    obj.pPreviousWeight=0;

    obj.pNumAvgsCounter=0;

    obj.pNewPeriodogramIdx=0;

    resetMaxMinHoldStates(obj);

    resetDDC(obj);


    flush(obj.sSegmentBuffer);
end
