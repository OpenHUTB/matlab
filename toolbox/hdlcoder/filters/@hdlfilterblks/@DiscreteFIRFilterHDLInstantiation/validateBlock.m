function v=validateBlock(this,hC)





    v=hdlvalidatestruct;


    if isa(this,'hdlfilterblks.DiscreteFIRFullyParallel')&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
        if~strcmpi(hdlget_param(getfullname(hC.SimulinkHandle),'CoeffMultipliers'),'multiplier')
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:UnsupportedBiquadFilterMode',hC.getBlockPath()));
            return;
        end
    end

    if targetcodegen.targetCodeGenerationUtils.isNFPMode()&&...
        ~isa(this,'hdlfilterblks.DiscreteFIRFullyParallel')&&...
        isFloatType(hC.PirInputSignals(1).Type.BaseType)
        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:DiscreteFIROnlyParallel',hC.getBlockPath()));
    end

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        FirFiltStruct=sysObjHandle.Structure;
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        FirFiltStruct=block.FirFiltStruct;
    end

    switch FirFiltStruct
    case{'Direct form',...
        'Direct form symmetric',...
        'Direct form antisymmetric',...
        'Direct form transposed'}
    otherwise
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:UnsupportedFIRFilterStructure'));
    end

    if~isSysObj
        cpdt=get_param(bfp,'CompiledPortDataTypes');
        in_sltype=char(cpdt.Inport(1));
        if~isempty(regexp(in_sltype,'^flts','once'))||~isempty(regexp(in_sltype,'^fltu','once'))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:ScaledDoublesNotSupported'));
            return;
        end
    end

    if isSysObj
        v(end+1)=validateFrames(this,hC);
    end

    if isSysObj
        inputWL=hC.PIRInputSignals(1).Type.getLeafType.WordLength;
        inputSign=hC.PIRInputSignals(1).Type.getLeafType.Signed;
    else
        [inputWL,~,inputSign]=hdlgetsizesfromtype(in_sltype);
    end

    if~inputSign
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:UnsignedInputsNotSupported'));
    end
    if inputWL>0

        if(strcmpi(FirFiltStruct,'Direct form symmetric'))||...
            (strcmpi(FirFiltStruct,'Direct form antisymmetric'))
            v(end+1)=checkFixptSetting(hC,'TapSumDataTypeName','Tap sum');
        end

        v(end+1)=checkFixptSetting(hC,'CoefDataTypeName','Coefficient');

        v(end+1)=checkFixptSetting(hC,'ProductDataTypeName','Product');

        v(end+1)=checkFixptSetting(hC,'AccumDataTypeName','Accumulator');

        v(end+1)=checkFixptSetting(hC,'OutDataTypeName','Output');
    end

    if any([v.Status])
        return;
    end


    v=[v,validateInitialCondition(this,hC)];






    v=[v,validateFilterImplParams(this,hC)];


    function v=checkFixptSetting(hC,dataTypeStr,msgStr)



        v=hdlvalidatestruct;

        isSysObj=isa(hC,'hdlcoder.sysobj_comp');
        if isSysObj
            sysObjHandle=hC.getSysObjImpl;
            sltype=getBlockParam(sysObjHandle,dataTypeStr);
        else
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            sltype=get(block,dataTypeStr);
        end
        try
            hdlwordsize(sltype);

        catch me
            msg=[msgStr,': ',me.message];
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:FixedpointSetting',msg));
        end





