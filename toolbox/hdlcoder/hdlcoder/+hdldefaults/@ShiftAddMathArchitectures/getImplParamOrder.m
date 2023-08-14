function orderedParams=getImplParamOrder(this,iparamInfo)




    iparams=keys(iparamInfo);
    idx=[
    find(strcmpi(iparams,'ConstrainedOutputPipeline'))
    find(strcmpi(iparams,'InputPipeline'))
    find(strcmpi(iparams,'OutputPipeline'))
    find(strcmpi(iparams,'LatencyStrategy'))
    find(strcmpi(iparams,'CustomLatency'))
    find(strcmpi(iparams,'UsePipelines'))
    ];

    sp=iparams(idx);
    iparams(idx)=[];
    orderedParams=[sp,iparams];
