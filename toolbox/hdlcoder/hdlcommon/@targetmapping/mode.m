
function flag=mode(hSignals,platform)



    if nargin<2
        platform=[];
    end

    flag=false;
    if(isempty(hSignals))
        return;
    end


    alteraMegaFunctionMode=targetcodegen.targetCodeGenerationUtils.isAlteraMode();
    xilinxCoregenMode=targetcodegen.targetCodeGenerationUtils.isXilinxMode();
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    if targetmapping.isValidDataType(hSignals(1).Type)
        if nfpMode
            flag=true;
        elseif isempty(platform)&&(alteraMegaFunctionMode||xilinxCoregenMode)
            flag=true;
        elseif strcmpi(platform,'Xilinx')&&xilinxCoregenMode
            flag=true;
        elseif strcmpi(platform,'Altera')&&alteraMegaFunctionMode
            flag=true;
        end
    end
end

