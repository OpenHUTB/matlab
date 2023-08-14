function value=getNumOverlapSamples(obj,SL)




    value=0;

    if strcmp(obj.Method,'Welch')
        if nargin==1
            SL=obj.pSegmentLength;
        end
        OP=obj.OverlapPercent;
        numSamples=SL*OP/100;
        upperNumSamples=ceil(numSamples);
        lowerNumSamples=floor(numSamples);
        percentDiff1=abs((upperNumSamples*100/SL)-OP);
        percentDiff2=abs((lowerNumSamples*100/SL)-OP);
        if percentDiff1<percentDiff2
            value=upperNumSamples;
        else
            value=lowerNumSamples;
        end
        if(value==SL)


            value=SL-1;
        end
    end
end
