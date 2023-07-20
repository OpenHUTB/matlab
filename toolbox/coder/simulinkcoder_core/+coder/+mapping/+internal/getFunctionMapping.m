function[mapping,category]=getFunctionMapping(model,modelMapping,functionType,slIdentifier)






    mapping=[];


    model=char(model);
    slIdentifier=char(slIdentifier);

    switch functionType
    case 'Initialize'
        mapping=modelMapping.OneShotFunctionMappings(1);
        category='InitializeTerminate';
    case 'Terminate'
        if length(modelMapping.OneShotFunctionMappings)==2
            mapping=modelMapping.OneShotFunctionMappings(2);
        end
        category='InitializeTerminate';
    case{'Periodic','Partition'}

        mapping=getPeriodicFunctionMapping(model,...
        modelMapping.OutputFunctionMappings,functionType,slIdentifier);
        category='Execution';
    case{'PeriodicUpdate','PartitionUpdate'}

        mapping=getPeriodicFunctionMapping(model,...
        modelMapping.UpdateFunctionMappings,functionType,slIdentifier);
        category='Execution';
    case 'Reset'
        mapping=modelMapping.ResetFunctions.findobj('SimulinkFunctionName',slIdentifier);
        category='Execution';
    case 'ExportedFunction'
        mapping=modelMapping.FcnCallInports.findobj('Block',...
        [model,'/',slIdentifier]);
        category='Execution';
    case 'SimulinkFunction'
        mapping=modelMapping.SimulinkFunctionCallerMappings.findobj('SimulinkFunctionName',slIdentifier);
        category='Execution';
    end


    function mapping=getPeriodicFunctionMapping(model,periodicMappings,functionType,slIdentifier)
        mapping=[];

        if isempty(slIdentifier)

            if isempty(periodicMappings)

                return;
            elseif length(periodicMappings)>1
                DAStudio.error('coderdictionary:api:InsufficientSpecificationMultitasking',model,functionType);
            end
            mapping=periodicMappings(1);
        elseif contains(functionType,'Partition')

            mapping=periodicMappings.findobj('PartitionName',slIdentifier);
        else


            if~coder.mapping.internal.doPeriodicFunctionMappingsHaveId(periodicMappings)

                DAStudio.error('coderdictionary:api:InvalidPeriodicFunctionId',model);
            end

            tcg=sltp.TaskConnectivityGraph(model);
            if~tcg.hasTask(slIdentifier)


                return;
            end

            id=tcg.getTaskIdentifier(slIdentifier);
            mapping=periodicMappings.findobj('Id',id);
            if~isempty(mapping)&&~isempty(mapping.PartitionName)


                mapping=[];
            end
        end
    end

end


