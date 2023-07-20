function value=getNumOverlapSamples(this,SL)




    value=0;
    if strcmpi(this.pMethod,'Welch')
        OP=this.SpectrumObject.DataBuffer.OverlapPercent;
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
    end
end
