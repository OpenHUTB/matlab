function v=validateFilterImplParams(this,hC)




    if isempty(this.getImplParams('SerialPartition'))
        v=hdlvalidatestruct(3,message('hdlcoder:filters:firinterp:validate:serialpartnotset'));
    else
        v=hdlvalidatestruct;
    end

    v=[v,validateSerialPartition(this,hC)];

    fparams=lower(this.filterImplParamNames);
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];
