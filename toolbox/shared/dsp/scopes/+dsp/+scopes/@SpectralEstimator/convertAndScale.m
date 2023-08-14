function P=convertAndScale(obj,P)





    scaleFlag=false;
    if~obj.TwoSidedSpectrum&&~obj.pIsDownConverterEnabled



        P=computeOneSidedSpectrum(obj,P);
    elseif~obj.TwoSidedSpectrum&&obj.pIsDownConverterEnabled




        scaleFlag=true;
    elseif obj.TwoSidedSpectrum&&obj.pIsDownConverterEnabled


        P=0.5*P;


    end

    if obj.pIsCurrentSpectrumTwoSided
        P=centerDC(obj,P);
    end

    if strcmp(obj.Method,'Filter bank')
        P=P./(obj.pActualSampleRate./obj.pNFFT);
    else
        P=P/obj.pActualSampleRate;
    end


    P=P(obj.pIdxFreqVect,:);
    if scaleFlag&&obj.pActualFstart==0
        P(1)=P(1)*0.5;
    end
    if scaleFlag&&obj.pActualFstop==obj.SampleRate/2
        P(end)=P(end)*0.5;
    end
end
