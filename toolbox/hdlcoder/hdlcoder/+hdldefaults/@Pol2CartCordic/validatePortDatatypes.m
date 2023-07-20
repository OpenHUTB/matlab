function v=validatePortDatatypes(~,hC)


    v=hdlvalidatestruct;
    blkName=regexprep(get_param(hC.SimulinkHandle,'Name'),'\n',' ');
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    for idx=1:numel(hC.PirInputSignals)
        dinType=hC.PirInputSignals(idx).Type;
        if dinType.isArrayType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:Pol2CartArray',blkName));%#ok<*AGROW>
        end

        inType=dinType.getLeafType;
        if~isNFPMode||~inType.isFloatType
            v(end+1)=hdlvalidatestruct(3,...
            message('hdlcoder:validate:LatencyMismatch',blkName));
        end


        if inType.isFloatType
            if~isNFPMode
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:Pol2CartFloat',blkName));
                return;
            elseif~inType.isSingleType
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:Pol2CartFloatNFP',blkName));
            end
        end


        if~inType.isFloatType
            if inType.Signed
                maxLength=125;
            else
                maxLength=124;
            end

            if inType.Wordlength>maxLength
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:Pol2CartWordlen',...
                int2str(maxLength),blkName));
            end
        end
    end


