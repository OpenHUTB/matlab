function v=validateFilterImplParams(this,hC)





    v=validateSerialPartition(this,hC);

    fparams=lower(this.filterImplParamNames);
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];
