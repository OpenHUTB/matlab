function v=validateBlock(this,hC)



    v=hdlvalidatestruct;

    if~targetcodegen.targetCodeGenerationUtils.isNFPMode()

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TrigTargetInvalidarch'));
    else
        hInSignals=hC.PirInputSignals;
        [~,dataType]=targetmapping.isValidDataType(hInSignals(1).Type);
    end

