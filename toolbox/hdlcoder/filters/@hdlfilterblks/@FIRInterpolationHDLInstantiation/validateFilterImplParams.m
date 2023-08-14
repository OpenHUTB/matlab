function v=validateFilterImplParams(this,hC)





    fparams=lower(this.filterImplParamNames);

    v=hdlvalidatestruct;



    if any(strncmp('coeffmultipliers',fparams,16))&&~isempty(this.getImplParams('CoeffMultipliers'))
        v=validateEnumParam(this,hC,'CoeffMultipliers',...
        {'Multiplier','csd','factored-csd'});
    end

    if any([v.Status])
        return;
    end

    v=[v,validateParallel(this,hC)];
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];


