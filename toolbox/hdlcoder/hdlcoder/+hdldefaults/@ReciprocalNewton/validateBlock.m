function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    din=hC.PirInputSignals;
    inputType=din.Type;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    isInputFloat=inputType.BaseType.isFloatType();

    blkName=get_param(hC.SimulinkHandle,'Name');
    if~isNFPMode||...
        (isNFPMode&&~isInputFloat)
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
        if~isInputFloat
            inputBaseType=inputType.getLeafType;
            inputFL=inputBaseType.FractionLength;
            if(inputFL>0)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedNegativeInputFLRecip',blkName));
            end
        end
    end

    if isInputFloat
        if isNFPMode


            if~inputType.BaseType.isDoubleType()
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfpmrnewtonrecip'));
            end
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvector_double_unsupported'));
        end
        return
    end

    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:ValidationNumericMismatch',blkName));


    invectsize=max(hdlsignalvector(din));
    if(invectsize>1)&&~isInputFloat
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorin'));
        return;
    end


    isOverLimit=false;
    isSigned=inputType.Signed;
    inputWL=inputType.WordLength;
    inputFL=abs(inputType.FractionLength);
    inputIntL=inputWL-inputFL;
    if(inputIntL>0)
        if(mod(inputIntL,2)==0)
            if isSigned
                if inputWL>127
                    isOverLimit=true;
                end
            end

        else
            if inputWL>127
                isOverLimit=true;
            end
        end
    else
        if isSigned
            if inputWL>127
                isOverLimit=true;
            end

            if inputFL>128
                isOverLimit=true;
            end
        else
            if inputFL>128
                isOverLimit=true;
            end
        end
    end

    if isOverLimit
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipoverlimit','ReciprocalNewtonSingleRate'));
    end


