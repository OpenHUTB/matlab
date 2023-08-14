function[result,maxFreq,maxValue]=ispassivecore(fit)





















    validateattributes(fit,{'rfmodel.rational'},{'square'})

    [maxFreq,maxValue]=normPeaks(fit);
    result=maxValue<=1;
end
