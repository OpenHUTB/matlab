function orderedParams=getImplParamOrder(this,iparamInfo)




    iparams=keys(iparamInfo);
    idx=[
    find(strcmpi(iparams,'MultiplierInputPipeline'))
    find(strcmpi(iparams,'MultiplierOutputPipeline'))
    find(strcmpi(iparams,'AdderTreePipeline'))
    ];

    sp=iparams(idx);
    iparams(idx)=[];
    orderedParams=[sp,iparams];
