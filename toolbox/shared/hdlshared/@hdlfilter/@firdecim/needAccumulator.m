function success=needAccumulator(this)











    lensummary=this.summaryofCoeffs;
    pfls=lensummary(:,end);
    effpfl=max(pfls);
    success=~(effpfl==1&&length(find(pfls))==1);


