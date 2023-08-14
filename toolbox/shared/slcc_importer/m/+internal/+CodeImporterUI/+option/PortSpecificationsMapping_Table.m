classdef PortSpecificationsMapping_Table<internal.CodeImporterUI.OptionBase




    methods
        function obj=PortSpecificationsMapping_Table(env)
            id='PortSpecificationsMapping_Table';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='functionPortWidget';
            obj.Value='';
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            env=obj.Env;
            parseInfo=env.CodeImporter.ParseInfo;

            data=struct('Name',{},'Arguments',{},'ArgumentNames',{},'Scopes',{},...
            'Labels',{},'Types',{},'Sizes',{});
            cellStruct=struct('value',{},'type',{},'allowedValues',{},'disabled',{});


            availableFcnObjectNames=[parseInfo.Functions.Name];
            selFcnIndex=ismember(availableFcnObjectNames,env.CodeImporter.FunctionsToImport);
            for idx=1:length(availableFcnObjectNames)
                if~selFcnIndex(idx)
                    continue;
                end
                fcn=parseInfo.Functions(idx);
                allArguments=[fcn.PortSpecification.ReturnArgument...
                ,fcn.PortSpecification.InputArguments...
                ,fcn.PortSpecification.GlobalArguments];
                if isempty(allArguments)
                    continue;
                end

                data(end+1).Name=struct('value',fcn.Name,'tooltip',fcn.CPrototype);
                data(end).Arguments=numel(allArguments);
                data(end).ArgumentNames=cellStruct;
                data(end).Scopes=cellStruct;
                data(end).Labels=cellStruct;
                data(end).Types=cellStruct;
                data(end).Sizes=cellStruct;
                argIndex=0;
                for arg=allArguments
                    argIndex=argIndex+1;
                    data(end).ArgumentNames(end+1)=struct('value',arg.Name,'type','textbox',...
                    'allowedValues',[],'disabled',true);
                    scopeAllowedVals=obj.structFieldValues(fcn.PortHeuristics(argIndex).validScopeValues);
                    data(end).Scopes(end+1)=struct('value',arg.Scope,'type','optionList',...
                    'allowedValues',scopeAllowedVals,...
                    'disabled',~fcn.PortHeuristics(argIndex).isScopeEditable);
                    data(end).Labels(end+1)=struct('value',arg.Label,'type','textbox',...
                    'allowedValues',[],'disabled',false);
                    typeAllowedVals=obj.structFieldValues(fcn.PortHeuristics(argIndex).validTypeValues);
                    data(end).Types(end+1)=struct('value',arg.Type,'type','combobox',...
                    'allowedValues',typeAllowedVals,...
                    'disabled',~fcn.PortHeuristics(argIndex).isTypeEditable);
                    data(end).Sizes(end+1)=struct('value',arg.Size,'type','textbox',...
                    'allowedValues',[],...
                    'disabled',~fcn.PortHeuristics(argIndex).isSizeEditable);
                end

                if(data(end).Arguments==1)
                    data(end).ArgumentNames={data(end).ArgumentNames};
                    data(end).Scopes={data(end).Scopes};
                    data(end).Labels={data(end).Labels};
                    data(end).Types={data(end).Types};
                    data(end).Sizes={data(end).Sizes};
                end
            end

            obj.Value=data;


            if isscalar(obj.Value)
                obj.Value={obj.Value};
            end

        end

        function applyOnNext(obj)
            env=obj.Env;
            parseInfo=env.CodeImporter.ParseInfo;
            lastAnswer=env.LastAnswer;
            if strcmp(lastAnswer.Value.option,obj.Id)
                choice=lastAnswer.Value.value;


                availableFcnObjectNames=[parseInfo.Functions.Name];
                selFcnIndex=ismember(availableFcnObjectNames,env.CodeImporter.FunctionsToImport);
                fcnIndex=0;
                for idx=1:length(availableFcnObjectNames)
                    if~selFcnIndex(idx)
                        continue;
                    end
                    fcn=parseInfo.Functions(idx);
                    allArguments=[fcn.PortSpecification.ReturnArgument...
                    ,fcn.PortSpecification.InputArguments...
                    ,fcn.PortSpecification.GlobalArguments];
                    if isempty(allArguments)
                        continue;
                    end

                    fcnIndex=fcnIndex+1;
                    assert(strcmp(choice(fcnIndex).Name,fcn.Name));

                    argIndex=0;
                    for arg=allArguments
                        argIndex=argIndex+1;
                        if choice(fcnIndex).Scopes(argIndex).modified
                            arg.Scope=choice(fcnIndex).Scopes(argIndex).value;
                        end
                        if choice(fcnIndex).Labels(argIndex).modified
                            arg.Label=choice(fcnIndex).Labels(argIndex).value;
                        end
                        if choice(fcnIndex).TypeNames(argIndex).modified
                            arg.Type=choice(fcnIndex).TypeNames(argIndex).value;
                        end
                        if choice(fcnIndex).Sizes(argIndex).modified
                            arg.Size=choice(fcnIndex).Sizes(argIndex).value;
                        end
                    end
                end

            end
        end

        function ret=structFieldValues(obj,validValues)
            ret=struct('value',{},'label',{});
            for i=1:length(validValues)
                ret(end+1).value=validValues{i};
                ret(end).label=validValues{i};
            end
        end

    end
end
