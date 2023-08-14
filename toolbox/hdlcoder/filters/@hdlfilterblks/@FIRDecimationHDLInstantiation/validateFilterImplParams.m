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
    if any(strncmp('dalutpartition',fparams,14))&&~isempty(this.getImplParams('DALUTPartition'))...
        ||any(strncmp('daradix',fparams,7))&&~isempty(this.getImplParams('DARadix'))

        v=[v,validateDA(this,hC)];
    end

    if(any(strncmp('serialpartition',fparams,15))&&~isempty(this.getImplParams('SerialPartition')))...
        ||strcmp(this.class,'hdlfilterblks.FIRDecimationFullySerial')
        v=[v,validateSerialPartition(this,hC)];
    end

    if any([v.Status]==1)
        return;
    end

    v=[v,validateParallel(this,hC)];
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];
