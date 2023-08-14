function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    hInSignals=hC.PirInputSignals;

    if(~targetcodegen.targetCodeGenerationUtils.isNFPMode())
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedNfpModRemTargetType'));
    end

    if~(hInSignals(1).Type.BaseType.isSingleType()&&hInSignals(2).Type.BaseType.isSingleType())
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedNfpModRemInputType'));
    end
end
