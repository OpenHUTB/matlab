




classdef SimulinkFunctionBlockSpecification<handle
    properties
        modelHandle=[];
        logger=[];
        dataDictionary=[];
        openDataDictionary=[];
        variablesInBaseWorkspace=[];
copyStrategy
    end

    methods(Access=public)
        function this=SimulinkFunctionBlockSpecification(modelHandle,logger,copyStrategy)
            this.modelHandle=modelHandle;
            this.logger=logger;
            this.copyStrategy=copyStrategy;

            this.dataDictionary=get_param(modelHandle,'DataDictionary');
            if~isempty(this.dataDictionary)
                this.openDataDictionary=Simulink.dd.open(this.dataDictionary);
            end
            this.variablesInBaseWorkspace=evalin('base','who()');
        end

    end

    methods(Access=private)


        function funcName=getFunctionNameFromPrototType(this,functionProtoType)
            functionProtoType=functionProtoType(~isspace(functionProtoType));
            eqPos=strfind(functionProtoType,'=');
            if isempty(eqPos)
                eqPos=0;
            end
            funcWithParam=functionProtoType(eqPos+1:end);
            leftParents=strfind(funcWithParam,'(');
            funcName=funcWithParam(1:leftParents-1);
        end

        function varsInMaskWorkspace=collectVarsInMaskWorkspace(this,currentSubsystem)


            allSubsystems=find_system(currentSubsystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','SubSystem');
            varsInMaskWorkspace=[];
            if numel(allSubsystems)==1
                q=Simulink.Mask.get(allSubsystems);
                curvarsInMaskWorkspace=[];
                if~isempty(q)
                    curvarsInMaskWorkspace=q.getWorkspaceVariables;
                end
                if~isempty(curvarsInMaskWorkspace)
                    varsInMaskWorkspace=[varsInMaskWorkspace,curvarsInMaskWorkspace];
                end
            else
                allSubsystems=allSubsystems(arrayfun(@slreportgen.utils.isMaskedSystem,allSubsystems));
                for ii=1:numel(allSubsystems)
                    q=Simulink.Mask.get(allSubsystems(ii));
                    curvarsInMaskWorkspace=[];
                    if~isempty(q)
                        curvarsInMaskWorkspace=q.getWorkspaceVariables;
                    end
                    if~isempty(curvarsInMaskWorkspace)
                        varsInMaskWorkspace=[varsInMaskWorkspace,curvarsInMaskWorkspace];
                    end
                end
            end
        end





        function simParamName=genAUniqueSimulinkParameter(this,simParamName,handleOfMWS,varsInMaskWorkspace)
            idx=0;

            existInBWS=true;
            existInKWS=true;
            existInMWS=true;
            existInDD=true;
            origParamName=simParamName;
            while existInBWS||existInKWS||existInMWS||existInDD
                simParamName=[origParamName,num2str(idx)];

                existInBWS=false;
                for bwsIdx=1:numel(this.variablesInBaseWorkspace)
                    if strcmp(simParamName,this.variablesInBaseWorkspace{bwsIdx})
                        existInBWS=true;
                        break;
                    end
                end
                if existInBWS
                    idx=idx+1;
                    continue;
                end


                existInMWS=handleOfMWS.hasVariable(simParamName);
                if existInMWS
                    idx=idx+1;
                    continue;
                end


                existInKWS=false;
                for kwsIdx=1:numel(varsInMaskWorkspace)
                    if strcmp(simParamName,varsInMaskWorkspace(kwsIdx))
                        existInKWS=true;
                        break;
                    end
                end
                if existInKWS
                    idx=idx+1;
                    continue;
                end


                existInDD=false;
                if~isempty(this.dataDictionary)
                    if this.openDataDictionary.entryExists(['Global.',simParamName])
                        existInDD=true;
                        idx=idx+1;
                        continue;
                    end
                end
            end
        end





        function argSpecifications=createSimulinkParametersForSimulinkFunctionBlocks(this,isInput,inArgs,functionName,currentSubsystem,handleOfMWS)
            argSpecifications='';
            varsInMaskWorkspace=this.collectVarsInMaskWorkspace(currentSubsystem);
            for argIdx=1:numel(inArgs)
                arg=inArgs(argIdx);
                if isInput
                    SimulinkParamName=[functionName,'InArg',num2str(argIdx)];
                else
                    SimulinkParamName=[functionName,'OutArg',num2str(argIdx)];
                end

                SimulinkParamName(strfind(SimulinkParamName,'.'))='_';
                SimulinkParamName=this.genAUniqueSimulinkParameter(SimulinkParamName,handleOfMWS,...
                varsInMaskWorkspace);

                dataTypeToSet=arg.dataType.dataTypeName;
                if arg.dataType.dataClass=='Bus'
                    eval([SimulinkParamName,'= Simulink.Parameter;']);
                    dataTypeToSet=['Bus: ',dataTypeToSet];
                    valueToSet=['Simulink.Bus.createMATLABStruct(''',arg.dataType.dataTypeName,''')'];
                    eval([SimulinkParamName,'.DataType = ''',dataTypeToSet,''';']);
                    eval([SimulinkParamName,'.Value = ',valueToSet,';']);
                    eval(['assignin(handleOfMWS, ''',SimulinkParamName,''', ',SimulinkParamName,');']);
                elseif arg.dataType.dataClass=='Numeric'
                    eval([SimulinkParamName,'= Simulink.Parameter;']);
                    valueToSet='0';
                    eval([SimulinkParamName,'.DataType = arg.dataType.dataTypeName;']);
                    eval([SimulinkParamName,'.Value = ',valueToSet,';']);
                    eval(['assignin(handleOfMWS, ''',SimulinkParamName,''', ',SimulinkParamName,');']);
                elseif arg.dataType.dataClass=='Enum'
                    SimulinkParamName=[arg.dataType.dataTypeName,'(0)'];
                elseif arg.dataType.dataClass=='Alias'

                    eval([SimulinkParamName,'= Simulink.Parameter;']);
                    valueToSet='0';
                    eval([SimulinkParamName,'.DataType = arg.dataType.dataTypeName;']);
                    eval([SimulinkParamName,'.Value = ',valueToSet,';']);
                    eval(['assignin(handleOfMWS, ''',SimulinkParamName,''', ',SimulinkParamName,');']);
                end

                argSpecifications=[argSpecifications,SimulinkParamName,','];
            end
            if~isempty(argSpecifications)
                argSpecifications=argSpecifications(1:end-1);
            end
        end


        function setupInputOutputSpecificationsForFunctionCaller(this,funcCaller,functionName,compFunction,handleOfMWS,currentSubsystem)
            fcnArgs=compFunction.fcnArgs;

            if isempty(get_param(funcCaller,'InputArgumentSpecifications'))||strcmpi(get_param(funcCaller,'InputArgumentSpecifications'),'<Enter example>')
                inArgs=toArray(fcnArgs.inArgs);
                inputArgumentSpecification=this.createSimulinkParametersForSimulinkFunctionBlocks(true,inArgs,functionName,currentSubsystem,handleOfMWS);
                if~isempty(inputArgumentSpecification)
                    set_param(funcCaller,'InputArgumentSpecifications',inputArgumentSpecification);
                end
            end

            if isempty(get_param(funcCaller,'OutputArgumentSpecifications'))||strcmpi(get_param(funcCaller,'OutputArgumentSpecifications'),'<Enter example>')
                outArgs=toArray(fcnArgs.outArgs);
                outputArgumentSpecification=this.createSimulinkParametersForSimulinkFunctionBlocks(false,outArgs,functionName,currentSubsystem,handleOfMWS);
                if~isempty(outputArgumentSpecification)
                    set_param(funcCaller,'OutputArgumentSpecifications',outputArgumentSpecification);
                end
            end
        end



        function[compFuncInsideCurSubsys,compFuncOutsideCurSubsys]=getCompiledSimulinkFunctions(this,currentSubsystem)
            compiledSimulinkFunctions=get_param(this.modelHandle,'CompiledSimulinkFunctions');
            compFunctions=toArray(compiledSimulinkFunctions.compFunctions);

            subObj=get_param(currentSubsystem,'Object');
            subsystemPath=subObj.getFullName;

            insideBoolean=arrayfun(@(x)startsWith(x.functionBlock,subsystemPath),compFunctions);
            compFuncInsideCurSubsys=compFunctions(insideBoolean==true);
            compFuncOutsideCurSubsys=compFunctions(insideBoolean==false);
        end

        function isSimFuncInsideSubsystem=getIsSimulinkFunctionAndItsCallerBothInsideCurSubsys(this,curSubsystemFullName,...
            modelRefName,...
            funcCaller,...
            simFuncInsideCurSub)

            callerObj=get_param(funcCaller,'Object');
            newModelCallerFullPath=callerObj.getFullName;
            newModelCallerFullPath=newModelCallerFullPath(length(modelRefName)+1:end);
            isSimFuncInsideSubsystem=false;
            for ii=1:numel(simFuncInsideCurSub)
                simFuncInside=simFuncInsideCurSub(ii);
                simFuncCallers=toArray(simFuncInside.callerBlocks);
                for jj=1:numel(simFuncCallers)
                    simFuncCaller=simFuncCallers{jj};
                    simFuncCaller=simFuncCaller(length(curSubsystemFullName)+1:end);
                    if strcmp(simFuncCaller,newModelCallerFullPath)
                        isSimFuncInsideSubsystem=true;
                        return;
                    end
                end
            end
        end

        function setupSpecificationsOnFunctionCaller(this,funcCaller,functionCallerName,handleOfMWS,...
            simFuncOutsideCurSub,currentSubsystem,modelRefName,curSubsystemFullName)

            callerObj=get_param(funcCaller,'Object');
            newModelCallerFullPath=callerObj.getFullName;
            if this.copyStrategy==Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Content
                newModelCallerFullPath=newModelCallerFullPath(length(modelRefName)+1:end);
            else
                newModelCallerFullPath=newModelCallerFullPath(length([modelRefName,get_param(currentSubsystem,'Name'),'/'])+1:end);
            end


            findSpecification=false;

            for compFcnIdx=1:numel(simFuncOutsideCurSub)
                compFunction=simFuncOutsideCurSub(compFcnIdx);
                simFuncCallers=toArray(compFunction.callerBlocks);
                for callerIdx=1:numel(simFuncCallers)
                    simFuncCaller=simFuncCallers{callerIdx};
                    simFuncCaller=simFuncCaller(length(curSubsystemFullName)+1:end);
                    if strcmp(simFuncCaller,newModelCallerFullPath)
                        if strcmpi(compFunction.visibility,'Scoped Local')



                            this.logger.addWarning(message('Simulink:modelReference:convertToModelReference_localScopedSimulinkFunctionUsed',...
                            compFunction.functionBlock,functionCallerName,get_param(this.modelHandle,'Name')));
                        end


                        this.setupInputOutputSpecificationsForFunctionCaller(funcCaller,functionCallerName,compFunction,handleOfMWS,currentSubsystem);
                        findSpecification=true;
                        return;
                    end
                end
            end
            assert(findSpecification);
        end
    end

    methods(Access=public)

        function setupSpecifications(this,modelRefHandle,currentSubsystem)



            [simFuncInsideCurSub,simFuncOutsideCurSub]=this.getCompiledSimulinkFunctions(currentSubsystem);


            functionCallers=find_system(modelRefHandle,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','FunctionCaller');
            handleOfMWS=get_param(modelRefHandle,'ModelWorkSpace');

            curSubsystemObj=get_param(currentSubsystem,'Object');
            curSubsystemFullName=[curSubsystemObj.getFullName,'/'];
            modelRefName=[get_param(modelRefHandle,'Name'),'/'];



            for fcnCallerIdx=1:numel(functionCallers)
                funcCaller=functionCallers(fcnCallerIdx);




                isSimulinkFunctionBlockInsideCurSubsystem=this.getIsSimulinkFunctionAndItsCallerBothInsideCurSubsys(...
                curSubsystemFullName,...
                modelRefName,...
                funcCaller,simFuncInsideCurSub);
                if~isSimulinkFunctionBlockInsideCurSubsystem

                    functionCallerName=this.getFunctionNameFromPrototType(get_param(funcCaller,'FunctionProtoType'));
                    if contains(functionCallerName,'.')


                        throw(MException(message('Simulink:modelReference:convertToModelReference_ScopedFuncCallCannotConverted',...
                        functionCallerName,getfullname(funcCaller))));
                    end

                    this.setupSpecificationsOnFunctionCaller(funcCaller,functionCallerName,handleOfMWS,...
                    simFuncOutsideCurSub,currentSubsystem,modelRefName,curSubsystemFullName);
                end
            end
        end
    end
end
