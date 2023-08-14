function v=validateFilterImplParams(this,hC)





    v=hdlvalidatestruct;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj

        return;
    end


    fparams=lower(this.filterImplParamNames);



    if any(strncmp('coeffmultipliers',fparams,16))
        v=[v,validateEnumParam(this,hC,'CoeffMultiplier',...
        {'Multiplier','csd','factored-csd'})];
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        if strcmp(block.CoefSource,'Input port')&&...
            (strcmp(this.getImplParams('coeffmultipliers'),'csd')||strcmp(this.getImplParams('coeffmultipliers'),'factored-csd'))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:csdnotsupported'));
        end
    end

    if any(strncmp('dalutpartition',fparams,14))&&~isempty(this.getImplParams('DALUTPartition'))...
        ||any(strncmp('daradix',fparams,7))&&~isempty(this.getImplParams('DARadix'))...
        ||strcmp(this.class,'hdlfilterblks.DiscreteFIRDA')
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');


        switch block.CoefSource
        case 'Input port'
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:danotsupportedCoeffPorts'));
        case 'Dialog parameters'
            switch block.FirFiltStruct
            case{'Direct form',...
                'Direct form symmetric',...
                'Direct form antisymmetric',...
                'Direct form transposed'}
                v=[v,validateDA(this,hC)];
            otherwise

            end
        end
    end

    if any(strncmp('serialpartition',fparams,15))&&~isempty(this.getImplParams('SerialPartition'))...
        ||any(strncmp('reuseaccum',fparams,10))&&~isempty(this.getImplParams('ReuseAccum'))...
        ||strcmp(this.class,'hdlfilterblks.DiscreteFIRCascadeSerial')...
        ||strcmp(this.class,'hdlfilterblks.DiscreteFIRFullySerial')...
        ||strcmp(this.class,'hdlfilterblks.DiscreteFIRPartlySerial')

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');


        switch block.FirFiltStruct
        case{'Direct form',...
            'Direct form symmetric',...
            'Direct form antisymmetric',...
            'Direct form transposed'}
            v=[v,validateSerialPartition(this,hC)];
        otherwise

        end
    end

    if any([v.Status]==1)
        return;
    end

    v=[v,validateParallel(this,hC)];
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];
    v=[v,validateMultichannel(this,hC)];
    v=[v,validateControlPorts(this,hC)];
    v=[v,validateEnableSubsys(this,hC)];
    v=[v,validateResetSubsys(this,hC)];
    v=[v,validateCoefficients(this,hC)];

