function[SL,DF]=getSegmentLength(obj,varargin)




    if(nargin==1)
        ReadOut=obj.pIsLockedFlag;
    else
        ReadOut=true;
    end

    if ReadOut
        SL=obj.pSegmentLength;

        DF=1;
        if obj.pIsDownSamplerEnabled
            DF=obj.sDDCDecimationFactor;
        end
    elseif strcmp(obj.FrequencyResolutionMethod,'WindowLength')


        SL=obj.WindowLength;
        DF=1;
    else
        SL=[];
        DF=[];
    end
end
