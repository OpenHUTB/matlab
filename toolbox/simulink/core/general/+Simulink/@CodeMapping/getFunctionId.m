function[functionType,functionId]=getFunctionId(mapping,functionCategory)




    functionId='';
    switch(functionCategory)
    case 'OneShotFunctionMappings'

        functionType=mapping.SimulinkFunctionName;
    case 'OutputFunctionMappings'
        if startsWith(mapping.SimulinkFunctionName,'Step')
            functionType='Step';
            tid=regexp(mapping.SimulinkFunctionName,'Step(\d+)','tokens');
        elseif startsWith(mapping.SimulinkFunctionName,'Output')
            functionType='Output';
            tid=regexp(mapping.SimulinkFunctionName,'Output(\d+)','tokens');
        else
            assert(false,'Invalid mapping for OutputFunctionMappings category');
        end
        if~isempty(tid)
            functionId=tid{1}{1};
        end
    case 'UpdateFunctionMappings'
        functionType='Update';
        tid=regexp(mapping.SimulinkFunctionName,'Update(\d+)','tokens');
        if~isempty(tid)
            functionId=tid{1}{1};
        end
    case 'FcnCallInports'
        functionType='FcnCallInport';
        functionId=get_param(mapping.Block,'Name');
    case 'ResetFunctions'
        functionType='Reset';
        functionId=mapping.SimulinkFunctionName;
    case 'ServerFunctions'
        functionType='SimulinkFunction';
        functionId=mapping.SimulinkFunctionName;
    case 'subsystem_step'

        functionType=functionCategory;
    case 'subsystem_initialize'

        functionType=functionCategory;
    otherwise
        error(['Unknown function category:',functionCategory]);
    end
end
