function v=validateFilterImplParams(this,hC)




    if isempty(this.getImplParams('DALUTPartition'))
        v=hdlvalidatestruct(3,message('hdlcoder:filters:firinterp:validate:dapartnotset'));
    else
        v=hdlvalidatestruct;
    end

    v=[v,validateDA(this,hC)];

    fparams=lower(this.filterImplParamNames);
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];
