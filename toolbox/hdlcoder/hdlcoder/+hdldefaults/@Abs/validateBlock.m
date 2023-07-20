function v=validateBlock(this,hC)



    v=hdlvalidatestruct;

    isNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    hInSignals=hC.PirInputSignals;
    [~,~,isSingleType,~,~]=targetmapping.isValidDataType(hInSignals.Type);
    [~,~,~,isComplex]=getBlockInfo(this,hC);

    if isComplex
        if(~isSingleType)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedNfpComplexAbsInputType'));
        end

        if(~isNFP)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedNfpComplexTargetType'));
        end
    end

    in1signal=hC.PirInputPorts(1).Signal;
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end

end
