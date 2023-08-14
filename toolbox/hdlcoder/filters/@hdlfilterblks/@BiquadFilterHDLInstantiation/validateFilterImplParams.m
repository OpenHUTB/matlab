function v=validateFilterImplParams(this,hC)





    fparams=lower(this.filterImplParamNames);

    v=hdlvalidatestruct;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if~isSysObj


        if any(strncmp('coeffmultipliers',fparams,16))
            v=validateEnumParam(this,hC,'CoeffMultipliers',...
            {'Multiplier','csd','factored-csd'});
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            if strcmp(block.FilterSource,'Input port(s)')&&...
                (strcmp(this.getImplParams('coeffmultipliers'),'csd')||strcmp(this.getImplParams('coeffmultipliers'),'factored-csd'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:csdnotsupported'));
            end
        end
    end

    if any([v.Status])
        return;
    end

    if strcmp(this.class,'hdlfilterblks.BiquadFilterFullySerial')||strcmp(this.class,'hdlfilterblks.BiquadFilterPartlySerial')
        v=[v,validateSerialPartition(this,hC)];
    end

    if any([v.Status]==1)
        return;
    end

    v=[v,validateParallel(this,hC)];

    if~isSysObj
        v=[v,this.validateMulticlockFilterParams(fparams,hC)];
    end