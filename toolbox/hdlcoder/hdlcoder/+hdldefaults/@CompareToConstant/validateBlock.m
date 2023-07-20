function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    hInSignals=hC.SLInputSignals;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    if targetmapping.mode(hInSignals)
        if hInSignals.Type.isArrayType&&hInSignals.Type.numElements>1
            if isNFPMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:VectorNotSupported'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorNotSupported'));
            end
        end
        bfp=hC.SimulinkHandle;
        outType=get_param(bfp,'OutDataTypeStr');
        if~strcmp(outType,'boolean')
            if isNFPMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:OnlyBooleanOutputSupported'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:OnlyBooleanOutputSupported'));
            end
        end
    end
