function[totalMemoryConsumption,T]=inlineParamMetric






    codeDesc=coder.getCodeDescriptor('rtwgen_tlc');
    params=codeDesc.getMF0FullModel.InlinedParameterInfo.toArray;

    totalMemoryConsumption=0;
    M=containers.Map;
    for paramIdx=1:numel(params)
        [memoryConsumption,blockName]=designcostestimation.internal.util.paramMemoryConsumption(params(paramIdx),true);
        totalMemoryConsumption=totalMemoryConsumption+memoryConsumption;
        if(isKey(M,blockName))
            M(blockName)=M(blockName)+memoryConsumption;
        else
            M(blockName)=memoryConsumption;
        end
    end
    C=[M.keys',M.values'];
    T=cell2table(C,'VariableNames',{'BlockName','Memory Consumption (in bytes)'});

end


