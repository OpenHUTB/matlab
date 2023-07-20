function[totalMemoryConsumption,T]=tunableParamMetric






    codeDesc=coder.getCodeDescriptor('rtwgen_tlc');
    params=codeDesc.getDataInterfaces('Parameters');
    totalMemoryConsumption=0;
    M=containers.Map;
    for i=1:numel(params)
        [memoryConsumption,blockName]=designcostestimation.internal.util.paramMemoryConsumption(params(i),false);
        if(isempty(blockName))

            continue;
        end
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


