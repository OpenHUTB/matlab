function v=validateBlock(this,hC)



    v=this.validateMaskParams(hC);

    outType=hC.PirOutputSignals(1).Type;
    inType=hC.PirInputSignals(1).Type;
    isFloatType=any([outType.getLeafType.isFloatType,inType.getLeafType.isFloatType]);
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;

    blkName=get_param(hC.SimulinkHandle,'Name');

    if strcmpi(hdlget_param(hC.getBlockPath,'Architecture'),'Cascade')


        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:DeprecateCascade',blkName));
    end

    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));

    if isFloatType&&isNFPMode
        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:CascadeArchNotSupported'));
    else

        if numel(hC.PirInputSignals)==1&&inType.isMatrix
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:CascadeArchNotSupported',blkName));
        end
    end

end


