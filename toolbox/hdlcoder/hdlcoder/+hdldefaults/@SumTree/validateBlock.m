function v=validateBlock(this,hC)



    v=this.validateMaskParams(hC);


    blkName=get_param(hC.SimulinkHandle,'Name');

    inType=hC.PirInputSignals(1).Type;
    outType=hC.PirOutputSignals(1).Type;

    inLeafType=getPirSignalLeafType(inType);
    outLeafType=getPirSignalLeafType(outType);

    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    if xor(outLeafType.isSingleType(),inLeafType.isSingleType())||xor(outLeafType.isDoubleType(),inLeafType.isDoubleType())

        if isNFPMode
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:IOTypeMismatch',blkName));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IOTypeMismatch',blkName));
        end
    else
        if~isNFPMode||...
            (isNFPMode&&~inLeafType.isFloatType())
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
        end
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatchForArch',blkName,'Tree'));
    end

    numInputPorts=hC.NumberOfPirInputPorts;
    if(numInputPorts==1&&inType.isMatrix)
        ndims=inType.NumberOfDimensions;

        if(~inType.is2DMatrix&&outType.isArrayType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:toomanydimsforblock',...
            blkName,ndims,hC.PirInputSignals(1).Name));
        end
    end
