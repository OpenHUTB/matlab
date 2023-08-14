function value=allowedFunctionProperties(modelName,modelMapping,functionType,slFcnName)







    if isa(modelMapping,'Simulink.CppModelMapping.ModelMapping')

        value={'MethodName'};
    else

        value={DAStudio.message('coderdictionary:mapping:FunctionClass'),'FunctionName'};
        if~modelMapping.isFunctionPlatform

            value{end+1}='MemorySection';
        else


            executionFunctionTypes={'Periodic','PeriodicUpdate','Partition',...
            'PartitionUpdate','ExportedFunction','SimulinkFunction'};
            if any(strcmp(functionType,executionFunctionTypes))&&...
                isequal(modelMapping.DeploymentType,'Component')&&...
                strcmp(get_param(modelName,'IsExportFunctionModel'),'on')
                value{end+1}='TimerService';
            end
        end
    end

    if isequal(functionType,'SimulinkFunction')

        value{end+1}='Arguments';
    elseif isequal(functionType,'Periodic')&&...
        (isempty(slFcnName)||isequal(slFcnName,'D1'))



        if~(isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')&&...
            modelMapping.isFunctionPlatform&&...
            isequal(modelMapping.DeploymentType,'Component'))
            value{end+1}='Arguments';
        end
    end


