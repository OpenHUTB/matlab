function NFFT=getNFFT(obj)




    NFFT=[];
    if obj.pIsLockedFlag
        NFFT=obj.pNFFT;
    elseif strcmp(obj.FrequencyResolutionMethod,'WindowLength')


        if strcmp(obj.FFTLengthSource,'Auto')
            NFFT=max(obj.WindowLength,1024);
        else
            NFFT=obj.FFTLength;
        end
    elseif strcmp(obj.FrequencyResolutionMethod,'NumFrequencyBands')
        if strcmp(obj.FFTLengthSource,'Auto')
            NFFT=obj.pInputFrameLength;
        else
            NFFT=obj.FFTLength;
        end
    end
end
