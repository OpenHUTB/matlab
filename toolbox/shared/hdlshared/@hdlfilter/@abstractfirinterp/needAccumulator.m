function need=needAccumulator(this)











    need=true;
    ssi=hdlgetparameter('filter_serialsegment_inputs');
    parallelcase=isequal(ones(1,length(ssi)),ssi);

    lensummary=this.summaryofCoeffs;
    pfls=lensummary(:,end);
    effpfl=max(pfls);
    serialdegencase=(effpfl==1&&length(find(pfls))==1);
    if parallelcase||serialdegencase
        need=false;
    end



