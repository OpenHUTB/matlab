


classdef fft<handle

    methods(Static)




        hNewNet=getFFTButterflyDIF(hN,FFTInfo,inputRate,isSimpleArch)
        hC=getFFTShuffleComp(hN,hInSignals,hOutSignals,FFTInfo,sr1Delay,stageNum)
        hC=getFFTTwiddleComp(hN,hInSignals,hOutSignals,FFTInfo,stageNum,isIFFT)
        hC=getFFTPulseDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName)
        [hC,RamNet]...
        =getFFTBitReverseComp(hN,hInSignals,hOutSignals,FFTInfo,RamInitNet)
        [hC,RamNet]...
        =getFFTInputAdaptation(hN,hInSignals,hOutSignals,FFTInfo,RamInitNet)
        hC=getFFTOutputAdaptation(hN,hInSignals,hOutSignals,FFTInfo)




        [hNewNet,RamNet]...
        =getFFTStageInitial(hN,hInSignals,FFTInfo)
        hNewNet=getFFTStageMiddle(hN,hInSignals,FFTInfo,butterflyNet,stageNum)
        hNewNet=getFFTStageEnd(hN,hInSignals,FFTInfo,RamInitNet)




        hNewNet=getFFTDIFNetwork(hN,hInSignals,FFTInfo)

    end
end

