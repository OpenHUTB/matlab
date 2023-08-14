function functionName=constructPeriodicOrPartitionFunctionName(modelName,periodicFcnMapping,isUpdateFcn,forAPI)





    partitionName=periodicFcnMapping.PartitionName;
    isCppModelMapping=isa(periodicFcnMapping.ParentMapping,'Simulink.CppModelMapping.ModelMapping');
    hasCppPeriod=isCppModelMapping&&(periodicFcnMapping.Period>0);
    if isempty(partitionName)

        functionName='Periodic';
        if isUpdateFcn
            if forAPI
                functionName=[functionName,'Update'];
            else
                functionName=[functionName,' Update'];
            end
        end
        if coder.mapping.internal.doPeriodicFunctionMappingsHaveId(...
            periodicFcnMapping)

            tcg=sltp.TaskConnectivityGraph(modelName);
            functionName=[functionName,':',tcg.getTask(periodicFcnMapping.Id)];
        end
        if~isCppModelMapping||hasCppPeriod
            if~forAPI
                functionName=[functionName,' [Sample Time: ',num2str(periodicFcnMapping.Period),'s]'];
            end
        end
    else

        functionName='Partition';
        if isUpdateFcn
            functionName=[functionName,' Update'];
        end
        functionName=[functionName,':',partitionName];
    end
end
