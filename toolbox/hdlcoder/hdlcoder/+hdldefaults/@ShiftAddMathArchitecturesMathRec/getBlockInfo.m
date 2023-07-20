function blockInfo=getBlockInfo(this,hC)





    slbh=hC.SimulinkHandle;
    sat=get_param(slbh,'DoSatur');
    originalBlkPath=getfullname(slbh);
    blockInfo.OutType=get_param(originalBlkPath,'OutDataTypeStr');
    if strcmp(sat,'on')
        blockInfo.ovMode='Saturate';
    else
        blockInfo.ovMode='Wrap';
    end
    blockInfo.rndMode=get_param(slbh,'RndMeth');
    blockInfo.firstInputSignDivide=false;



    blockInfo.networkName=get_param(slbh,'Name');

    if(isempty(this.getImplParams('UsePipelines')))
        blockInfo.pipeline='on';
    else
        blockInfo.pipeline=this.getImplParams('UsePipelines');
    end

    if(isempty(this.getImplParams('CustomLatency')))
        blockInfo.customLatency=0;
    else
        blockInfo.customLatency=this.getImplParams('CustomLatency');
    end

    if(isempty(this.getImplParams('LatencyStrategy')))
        blockInfo.latencyStrategy='MAX';
    else
        blockInfo.latencyStrategy=this.getImplParams('LatencyStrategy');
    end

    in1signal=hC.PirInputSignals(1);
    outsignal=hC.PirOutputSignals(1);
    in1BaseType=getPirSignalBaseType(in1signal.Type);
    outBaseType=getPirSignalBaseType(outsignal.Type);

    if(in1BaseType.isFloatType||outBaseType.isFloatType)
        isPortTypeFloat=true;
    else
        isPortTypeFloat=false;
    end


    if(in1BaseType.isComplexType||outBaseType.isComplexType)
        isPortTypeComplex=true;
    else
        isPortTypeComplex=false;
    end

    if(~(isPortTypeFloat||isPortTypeComplex))

        Input1FractionLength=in1BaseType.Fractionlength;
        outputFractionLength=outBaseType.Fractionlength;
        blockInfo.denominatorTypeInfo.dType=in1BaseType;
        blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dType.WordLength;
        blockInfo.denominatorTypeInfo.dSign=blockInfo.denominatorTypeInfo.dType.Signed;
        fractiondiff=-Input1FractionLength-outputFractionLength;
        blockInfo.fractiondiff=fractiondiff;
        if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))
            maxWl=outBaseType.WordLength;
        else
            maxWl=blockInfo.denominatorTypeInfo.dWL;
        end
        blockInfo.numeratorTypeInfo.zWL=maxWl;
        if(~strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))

            if(blockInfo.denominatorTypeInfo.dSign)
                blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_sfixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input1FractionLength);
                blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
            else
                blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_ufixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input1FractionLength);
                blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
            end
            blockInfo.numeratorTypeInfo.zWL=maxWl+abs(fractiondiff);
        end
    end
end

