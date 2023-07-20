function v=validateBlock(this,hC)




    v=this.validateProductBlock(hC);


    vstructs=this.validateMaskParams(hC);


    v=horzcat(v,vstructs);

    outType=hC.PirOutputSignals(1).Type;
    inType=hC.PirInputSignals(1).Type;
    isFloatType=any([outType.getLeafType.isFloatType,inType.getLeafType.isFloatType]);
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    mulKind=get_param(hC.SimulinkHandle,'Multiplication');
    inputsigns=get_param(hC.SimulinkHandle,'Inputs');
    inputsigns=strrep(inputsigns,'|','');
    blkName=get_param(hC.SimulinkHandle,'Name');

    if strcmpi(hdlget_param(hC.getBlockPath,'Architecture'),'Cascade')


        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:DeprecateCascade',blkName));
    end

    if~isNFPMode||...
        (isNFPMode&&~isFloatType)
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));

    if isFloatType&&isNFPMode
        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:CascadeArchNotSupported'));
    else

        isPOE=((numel(hC.PirInputSignals)==1)&&strcmp(mulKind,'Element-wise(.*)')&&...
        (~contains(inputsigns,'/')));
        if isPOE&&inType.isMatrix
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:CascadeArchNotSupported',blkName));
        end
    end

end


