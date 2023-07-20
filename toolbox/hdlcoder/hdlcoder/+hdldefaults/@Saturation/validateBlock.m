function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    hInSignals=hC.SLInputSignals;
    hOutSignals=hC.SLOutputSignals;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    if targetmapping.mode(hInSignals)&&~isNFPMode
        if hInSignals.Type.isArrayType&&hInSignals.Type.numElements>1
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorNotSupported'));

        end
        if length(hOutSignals)>1
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultipleOutputsNotSupported'));
        end
    end
