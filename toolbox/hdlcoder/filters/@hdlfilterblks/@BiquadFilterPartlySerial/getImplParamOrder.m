function orderedParams=getImplParamOrder(this,iparamInfo)




    iparams=keys(iparamInfo);
    idx=[
    find(strcmpi(iparams,'architecturespecifiedby'))
    find(strcmpi(iparams,'nummultipliers'))
    find(strcmpi(iparams,'foldingfactor'))
    ];

    sp=iparams(idx);
    iparams(idx)=[];
    orderedParams=[sp,iparams];
