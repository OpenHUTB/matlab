function setNFFT(obj)




    if strcmp(obj.FrequencyResolutionMethod,'WindowLength')
        if strcmp(obj.FFTLengthSource,'Auto')
            obj.pNFFT=max(obj.pSegmentLength,1024);
        else
            obj.pNFFT=obj.FFTLength;
        end
    elseif strcmp(obj.FrequencyResolutionMethod,'NumFrequencyBands')
        if strcmp(obj.FFTLengthSource,'Auto')


            obj.pNFFT=obj.pInputFrameLength;
        else

            obj.pNFFT=obj.FFTLength;
        end
    else
        obj.pNFFT=obj.pSegmentLength;
    end
    obj.pDataWrapFlag=obj.pNFFT<obj.pSegmentLength;
end
