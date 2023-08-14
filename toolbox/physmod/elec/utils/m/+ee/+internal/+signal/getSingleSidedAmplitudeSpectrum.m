function[harmonicOrder,harmonicMagnitude]=getSingleSidedAmplitudeSpectrum(inputData,sampleTime,fundamentalFreq,nHarmonics)








    N=length(inputData);
    inputData=inputData./N;


    sampleFreq=1/sampleTime;


    harmonicOrder=0:nHarmonics;
    freqOfInterest=harmonicOrder*fundamentalFreq;
    freqIdx=round(freqOfInterest/sampleFreq*N)+1;


    harmonicMagnitude=ee.internal.signal.calculateGoertzel(inputData,freqIdx);


    harmonicMagnitude(1)=abs(harmonicMagnitude(1));

    harmonicMagnitude(2:end)=2*abs(harmonicMagnitude(2:end));
