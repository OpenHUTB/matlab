function ENBW=getWindowENBW(obj,L,Win,sideLobeAttn)




    if nargin==1
        if strcmp(obj.FrequencyResolutionMethod,'WindowLength')


            segLen=obj.WindowLength;
        else
            segLen=obj.pSegmentLength;
        end
    else
        segLen=L;
    end
    if nargin<3

        ENBW=getENBW(obj,segLen);
    elseif nargin<4
        ENBW=getENBW(obj,segLen,Win);
    else
        ENBW=getENBW(obj,segLen,Win,sideLobeAttn);
    end
end
