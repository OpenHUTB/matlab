function v=validateBlock(this,hC)



    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;
    valstruct=get_param(slbh,'MaskWSVariables');
    if~isempty(valstruct)
        val_loc=strcmp('gainValue',{valstruct.Name});
        if isempty(val_loc)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:internalgainparametererror'));
        end
    end

    rto=get_param(slbh,'RuntimeObject');
    gainloc=0;
    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,'Gain')
            gainloc=n;
        end
    end
    if gainloc==0
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:gainparameternotfound'));
    end

    cval=rto.RuntimePrm(gainloc).Data;
    if isempty(cval)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:gainparameterempty'));
    end

    inSig=hC.PirInputSignals(1);
    inType=inSig.Type;
    floatGain=isfloat(cval);
    floatIn=hdlsignalisdouble(inSig);
    if floatGain&&~floatIn&&~inType.isRecordType
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:doublegainparam'));
    elseif~floatGain&&floatIn
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:fixedgainparam'));
    end

    v=[v,this.validateDSPStyle(hC)];

    CSDParam=getImplParams(this,'ConstMultiplierOptimization');
    if~isempty(CSDParam)&&~strcmpi(CSDParam,'none')

        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
        if nfpMode&&inType.BaseType.isFloatType
            parentName=get_param(hC.simulinkHandle,'Parent');
            blockName=get_param(hC.simulinkHandle,'Name');
            subsysPath=[parentName,'/',blockName];
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcommon:nativefloatingpoint:NfpCsdMulOptWarn',subsysPath));
        end


        multMode=get_param(slbh,'Multiplication');
        if~strcmpi(multMode,'Element-wise(K.*u)')&&...
            (inType.isMatrix||hC.PirOutputSignals(1).Type.isMatrix)
            parentName=get_param(hC.simulinkHandle,'Parent');
            blockName=get_param(hC.simulinkHandle,'Name');
            subsysPath=[parentName,'/',blockName];
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:matrix:CsdMulOptWarn',subsysPath));
        end
    end


    [gainFactor,nfpOptions,~,~]=this.getBlockDialogValue(slbh);
    gfVal=double(gainFactor);



    if targetcodegen.targetCodeGenerationUtils.isNFPMode
        multMode=get_param(slbh,'Multiplication');
        if~strcmpi(multMode,'Element-wise(K.*u)')&&isHalfType(inType.getLeafType)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcommon:nativefloatingpoint:UnsupportedHalfMatrixMultiply'));
        end
    end

    if nfpOptions.Latency~=int8(0)&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
        out=hC.SLOutputSignals(1);
        if targetmapping.mode(out)
            out1=hC.PirOutputSignals;
            outType=out1.Type.getLeafType;
            if outType.isSingleType
                dataType='SINGLE';
            elseif outType.isHalfType
                dataType='HALF';
            else
                dataType='DOUBLE';
            end
            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            ipSettings=fc.IPConfig.getIPSettings('Mul',dataType);

            if(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                dataType,'Mul'));
            end
            if(nfpOptions.Latency==int8(4))&&(nfpOptions.CustomLatency>ipSettings.MaxLatency)
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
                hC.getBlockPath,num2str(ipSettings.MaxLatency)));
            end
        end
    end




    if targetcodegen.targetCodeGenerationUtils.isNFPMode()&&~hdlispowerof2(gfVal)


        outType=hC.SLOutputSignals(1).Type.BaseType;
        if isHalfType(outType)
            localMultiplyStrategyCheck=nfpOptions.MantMul==uint8(2);
        else
            localMultiplyStrategyCheck=((nfpOptions.MantMul==uint8(2)||nfpOptions.MantMul==uint8(3)));
        end


        fc=hdlgetparameter('FloatingPointTargetConfiguration');
        mantissaMultiplyStrategy=fc.LibrarySettings.MantissaMultiplyStrategy;


        if isHalfType(outType)
            globalMutliplyStrategyCheck=strcmpi(mantissaMultiplyStrategy,'PartMultiplierPartAddShift');
        else
            globalMutliplyStrategyCheck=strcmpi(mantissaMultiplyStrategy,'PartMultiplierPartAddShift')||...
            strcmpi(mantissaMultiplyStrategy,'NoMultiplierFullAddShift');
        end

        if isDoubleType(outType)



            if((nfpOptions.MantMul==uint8(0)&&globalMutliplyStrategyCheck)||localMultiplyStrategyCheck)
                v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:InvalidMantissaMultiplyStrategyForDouble'));
            end


        elseif isHalfType(outType)



            if((nfpOptions.MantMul==uint8(0)&&globalMutliplyStrategyCheck)||localMultiplyStrategyCheck)
                v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:InvalidMantissaMultiplyStrategyForHalf'));
            end
        end
    end
end


