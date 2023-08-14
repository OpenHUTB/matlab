function twComp=getFFTTwiddleComp(hN,hInSignals,hOutSignals,FFTInfo,stageNum,isIFFT)











    if nargin<6
        isIFFT=false;
    end


    tw_ex=pirelab.getTypeInfoAsFi(FFTInfo.sineType,'nearest','saturate');
    tw_index=(0:(FFTInfo.totalPoint/(2^(stageNum+1))):(FFTInfo.totalPoint/2-1))/FFTInfo.totalPoint;

    if isIFFT

        tw_data=fi(exp(2*pi*1i*tw_index).',numerictype(tw_ex),fimath(tw_ex));
    else

        tw_data=fi(exp(-2*pi*1i*tw_index).',numerictype(tw_ex),fimath(tw_ex));
    end


    twiddle=hN.addSignal(FFTInfo.sineType,'twiddle');
    twComp=pirelab.getDirectLookupComp(hN,hInSignals,twiddle,tw_data,'twiddle_rom');
    twComp.addComment('Twiddle ROM');


    pirelab.getUnitDelayComp(hN,twiddle,hOutSignals,'twiddle_outc');


