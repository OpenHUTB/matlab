function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    hInSignals=hC.SLInputSignals;
    hOutSignals=hC.SLOutputSignals;

    if targetmapping.mode(hInSignals)
        if hInSignals.Type.isArrayType&&hInSignals.Type.numElements>1
            if targetcodegen.targetCodeGenerationUtils.isNFPMode()
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:VectorNotSupported'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorNotSupported'));
            end
        end
        if length(hOutSignals)>1
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultipleOutputsNotSupported'));
        end
    end

