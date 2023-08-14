function orderedParams=getImplParamOrder(this,iparamInfo)




    iparams=keys(iparamInfo);
    idx=[
    find(strcmpi(iparams,'CoeffMultipliers'))
    find(strcmpi(iparams,'AddPipelineRegisters'))
    find(strcmpi(iparams,'MultiplierInputPipeline'))
    find(strcmpi(iparams,'MultiplierOutputPipeline'))
    find(strcmpi(iparams,'ChannelSharing'))
    ];

    sp=iparams(idx);
    iparams(idx)=[];
    orderedParams=[sp,iparams];
