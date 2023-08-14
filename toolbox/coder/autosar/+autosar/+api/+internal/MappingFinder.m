classdef MappingFinder<handle




    methods(Static,Access=public)

        function blockMappings=getFunctionCallerBlockMappings(modelName,fcnName)


            blkPaths=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelName,fcnName,true);

            modelMapping=autosar.api.Utils.modelMapping(modelName);
            blockMappings=Simulink.AutosarTarget.BlockMapping.empty();
            for ii=1:length(blkPaths)

                blkPath=strrep(blkPaths{ii},newline,' ');
                blockMappings=[blockMappings,modelMapping.FunctionCallers.findobj('Block',blkPath)];%#ok<AGROW>
            end

        end

        function slIdentifier=getSlIdentifierForSlEntryPointFunction(slEntryPointFunction,functionType)

            slIdentifier=extractAfter(slEntryPointFunction,':');

            if isequal(functionType,'Periodic')&&isequal(slEntryPointFunction,'Periodic')
                slIdentifier='D1';
            elseif~isequal(functionType,'ExportedFunction')




                slIdentifier=strtrim(slIdentifier);
            end
        end

        function entryPointMapping=getPeriodicEntryPointMapping(modelName,slEntryPointFunction,functionType)

            isExportStyle=autosar.validation.ExportFcnValidator.isTopModelExportFcn(modelName);
            if isExportStyle
                DAStudio.error('autosarstandard:validation:invalidMappingFcnForExportFcnModel',slEntryPointFunction);
            end


            modelMapping=autosar.api.Utils.modelMapping(modelName);
            if strcmp(slEntryPointFunction,'Periodic')
                entryPointMapping=modelMapping.StepFunctions(1);
                return
            end


            if~coder.mapping.internal.doPeriodicFunctionMappingsHaveId(...
                modelMapping.StepFunctions)
                DAStudio.error('coderdictionary:api:InvalidPeriodicFunctionId',modelName);
            end


            taskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
            slIdentifier=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(slEntryPointFunction,functionType);
            if~taskConnectivityGraph.hasTask(slIdentifier)

                DAStudio.error('autosarstandard:validation:invalidMappingFcnForRateBasedModel',slEntryPointFunction);
            end


            id=taskConnectivityGraph.getTaskIdentifier(slIdentifier);
            entryPointMapping=modelMapping.StepFunctions.findobj('Id',id);
        end

        function entryPointMapping=getStepFunctionEntryPointMapping(modelName,slEntryPointFunction)



            isExportStyle=autosar.validation.ExportFcnValidator.isTopModelExportFcn(modelName);
            if isExportStyle
                DAStudio.error('autosarstandard:validation:invalidMappingFcnForExportFcnModel',slEntryPointFunction);
            end

            modelMapping=autosar.api.Utils.modelMapping(modelName);
            if strcmp(slEntryPointFunction,'StepFunction')

                entryPointMapping=modelMapping.StepFunctions(1);
                return
            end




            N=regexp(slEntryPointFunction,'^StepFunction(\d+)','tokens');
            if isempty(N)
                DAStudio.error('autosarstandard:validation:invalidMappingFcnForRateBasedModel',slEntryPointFunction);
            end


            N=str2double(N{1});
            if(N<1)||N>=length(modelMapping.StepFunctions)
                DAStudio.error('autosarstandard:validation:invalidMappingFcnForRateBasedModel',slEntryPointFunction);
            end

            entryPointMapping=modelMapping.StepFunctions(N+1);
        end

        function entryPointMapping=getExportedFunctionEntryPointMapping(modelName,slEntryPointFunction)
            modelMapping=autosar.api.Utils.modelMapping(modelName);
            functionType=strtrim(extractBefore(slEntryPointFunction,':'));
            if isequal(functionType,'ExportedFunction')

                SlIdentifier=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(slEntryPointFunction,'ExportedFunction');
                entryPointMapping=modelMapping.FcnCallInports.findobj('Block',[modelName,'/',SlIdentifier]);
                return
            end


            entryPointMapping=modelMapping.FcnCallInports.findobj('Block',[modelName,'/',slEntryPointFunction]);
        end

        function entryPointMapping=getResetFunctionEntryPointMapping(modelName,slEntryPointFunction)
            modelMapping=autosar.api.Utils.modelMapping(modelName);
            functionType=strtrim(extractBefore(slEntryPointFunction,':'));
            if isequal(functionType,'Reset')

                SlIdentifier=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(slEntryPointFunction,'Reset');
                entryPointMapping=modelMapping.ResetFunctions.findobj('Name',SlIdentifier);
                return
            end


            entryPointMapping=modelMapping.ResetFunctions.findobj('Name',slEntryPointFunction);
        end

        function blockMappings=getServerFunctionBlockMappings(modelName,slEntryPointFunction)

            functionType=strtrim(extractBefore(slEntryPointFunction,':'));
            if isequal(functionType,'SimulinkFunction')

                slEntryPointFunction=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(slEntryPointFunction,'SimulinkFunction');
            end

            blkPaths=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelName,slEntryPointFunction,false);
            modelMapping=autosar.api.Utils.modelMapping(modelName);
            blockMappings=Simulink.AutosarTarget.BlockMapping.empty();
            for ii=1:length(blkPaths)

                blkPath=strrep(blkPaths{ii},newline,' ');
                blockMappings=[blockMappings,modelMapping.ServerFunctions.findobj('Block',blkPath)];%#ok<AGROW>
            end
        end

        function slEntryPointFunction=getSlEntryPointFunctionForRunnable(modelName,ARRunnableName)


            mapping=autosar.api.Utils.modelMapping(modelName);


            for i=1:length(mapping.FcnCallInports)
                fcnCallInport=mapping.FcnCallInports(i);
                if~strcmp(fcnCallInport.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                slIdentifier=get_param(fcnCallInport.Block,'Name');
                slEntryPointFunction=['ExportedFunction:',slIdentifier];
                return
            end


            for i=1:length(mapping.ServerFunctions)
                serverFcn=mapping.ServerFunctions(i);
                if~strcmp(serverFcn.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                triggerPort=find_system(serverFcn.Block,'SearchDepth',1,'Blocktype','TriggerPort');
                slIdentifier=get_param(triggerPort{1},'FunctionName');
                slEntryPointFunction=['SimulinkFunction:',slIdentifier];
                return
            end


            for i=1:length(mapping.InitializeFunctions)
                initFcn=mapping.InitializeFunctions(i);
                if~strcmp(initFcn.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                slEntryPointFunction='Initialize';
                return
            end


            for i=1:length(mapping.ResetFunctions)
                resetFcn=mapping.ResetFunctions(i);
                if~strcmp(resetFcn.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                slEntryPointFunction=['Reset:',resetFcn.Name];
                return
            end


            for i=1:length(mapping.TerminateFunctions)
                terminateFcn=mapping.TerminateFunctions(i);
                if~strcmp(terminateFcn.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                slEntryPointFunction='Terminate';
                return
            end


            if length(mapping.StepFunctions)==1&&...
                strcmp(mapping.StepFunctions(1).MappedTo.Runnable,ARRunnableName)
                slEntryPointFunction='Periodic';
                return
            end



            if length(mapping.StepFunctions)>1&&...
                ~coder.mapping.internal.doPeriodicFunctionMappingsHaveId(...
                mapping.StepFunctions)
                DAStudio.error('coderdictionary:api:InvalidPeriodicFunctionId',modelName);
            end


            for i=1:length(mapping.StepFunctions)
                stepFcn=mapping.StepFunctions(i);
                if~strcmp(stepFcn.MappedTo.Runnable,ARRunnableName)
                    continue
                end

                id=stepFcn.Id;
                taskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
                task=taskConnectivityGraph.getTask(id);
                if taskConnectivityGraph.isExplicitTask(task)
                    slEntryPointFunction=['Partition:',task];
                    return
                end

                slEntryPointFunction=['Periodic:',task];
                return
            end

            assert(false,'Could not find mapping from Runnable %s to slFunction',ARRunnableName);
        end

        function blkPaths=getBlockPathsByFunctionName(modelName,slFcnName,isCallerBlock)



            modelName=get_param(modelName,'Name');
            slFcnName=convertStringsToChars(slFcnName);





            fcnPrototypeRegExpSearchPattern=['\<',slFcnName,'\>\s*\('];

            blkPaths={};
            if isCallerBlock
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    blkPaths=find_system(modelName,'Regexp','on','FollowLinks','on',...
                    'MatchFilter',@Simulink.match.allVariants,...
                    'LookUnderMasks','all','BlockType','FunctionCaller','FunctionPrototype',fcnPrototypeRegExpSearchPattern);
                else
                    blkPaths=find_system(modelName,'Regexp','on','Variants','ActivePlusCodeVariants','FollowLinks','on',...
                    'LookUnderMasks','all','BlockType','FunctionCaller','FunctionPrototype',fcnPrototypeRegExpSearchPattern);
                end
            else
                searchOptions={};
                if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                    functionVisibilities={'port'};


                    tokens=strsplit(slFcnName,'.');
                    portName=tokens{1};
                    methodName=tokens{2};
                    fcnPrototypeRegExpSearchPattern=['\<',methodName,'\>\s*\('];
                    searchOptions={'ScopeName',portName};
                else
                    functionVisibilities={'global'};
                end


                serverFcnBlocks=find_system(modelName,'Regexp','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','LookUnderMasks','all','BlockType','SubSystem',...
                'IsSimulinkFunction','on','FunctionPrototype',fcnPrototypeRegExpSearchPattern);

                for ii=1:length(serverFcnBlocks)
                    for functionVisibility=functionVisibilities
                        trigPort=find_system(serverFcnBlocks{ii},...
                        'SearchDepth',1,'FollowLinks','on',...
                        'BlockType','TriggerPort','FunctionVisibility',functionVisibility{1},...
                        searchOptions{:});
                        if~isempty(trigPort)
                            blkPaths{end+1}=serverFcnBlocks{ii};%#ok<AGROW>
                        end
                    end
                end
            end
        end

    end

end


