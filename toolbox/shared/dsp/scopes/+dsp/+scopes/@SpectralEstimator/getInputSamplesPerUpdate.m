function ispu=getInputSamplesPerUpdate(obj,varargin)




    if(nargin==1)
        ReadOut=obj.pIsLockedFlag;
    else
        ReadOut=true;
    end

    if ReadOut


        spls=obj.pSegmentLength-getNumOverlapSamples(obj);

        DF=1;
        if obj.pIsDownSamplerEnabled
            DF=obj.sDDCDecimationFactor;
        end


        ispu=spls*DF;
    elseif strcmp(obj.FrequencyResolutionMethod,'WindowLength')


        SL=obj.WindowLength;
        ispu=SL-getNumOverlapSamples(obj,SL);
    else
        ispu=[];
    end
end
