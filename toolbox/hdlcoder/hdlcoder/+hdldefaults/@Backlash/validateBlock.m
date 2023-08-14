function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    hInSignals=hC.SLInputSignals;
    hOutSignals=hC.SLOutputSignals;

    if(hInSignals.Type.getDimensions>1)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorInputsNotSupported'));
    end

    bfp=hC.SimulinkHandle;
    bw=get_param(bfp,'BacklashWidth');
    bio=get_param(bfp,'InitialOutput');

    if((numel(str2num(bw))>1)||(numel(str2num(bio)))>1)%#ok<ST2NM>
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedvectorparamsforbacklash'));
    end

    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    if targetmapping.mode(hInSignals)
        if hInSignals.Type.isArrayType&&hInSignals.Type.numElements>1
            if(isNFPMode)
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:VectorNotSupported'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorNotSupported'));
            end
        end
        if length(hOutSignals)>1
            if(isNFPMode)
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:MultipleOutputsNotSupported'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultipleOutputsNotSupported'));
            end
        end
    end


