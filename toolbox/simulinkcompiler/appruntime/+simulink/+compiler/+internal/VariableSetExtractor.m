classdef VariableSetExtractor<handle








    properties(Constant,Access=private)
        SupportedVariableTypes=[
"Simulink.SimulationData.Dataset"
"Simulink.Simulation.ModelParameter"
"Simulink.Simulation.Variable"
"Simulink.op.ModelOperatingPoint"
"struct"
        ]

        Extractors={
        @addToExternalInputs
        @addToModelParameters
        @addToWSVariables
        @addModelOperatingPointToInitialStates
        @addStructToInitialStates
        }

        SetLabels=[
"externalInputs"
"modelParameters"
"wkspVariables"
"initialStates"
"initialStates"
        ]

        DefaultSetName="DefaultSet"
    end

    properties(Access=private)
Variables
VarTypesToExtractors
VarTypesToSetLabels
        ExtractedSets;
    end

    methods
        function obj=VariableSetExtractor(variables)


            obj.Variables=variables;

            obj.VarTypesToExtractors=...
            containers.Map(obj.SupportedVariableTypes,obj.Extractors);

            obj.VarTypesToSetLabels=...
            containers.Map(obj.SupportedVariableTypes,obj.SetLabels);
        end

        function variableSets=extractSets(obj)
            obj.initExtractedSets();

            if~isempty(obj.Variables)
                varNames=fieldnames(obj.Variables);

                for idx=1:numel(varNames)
                    varName=varNames{idx};
                    var=obj.Variables.(varName);
                    obj.extract(varName,var);
                end
            end

            variableSets=obj.ExtractedSets;
        end
    end

    methods(Access=private)
        function initExtractedSets(obj)
            obj.ExtractedSets.externalInputs=[];
            obj.ExtractedSets.modelParameters.(obj.DefaultSetName)=[];
            obj.ExtractedSets.wkspVariables=[];
            obj.ExtractedSets.initialStates=[];
        end

        function extract(obj,varName,var)
            varType=class(var);

            if obj.VarTypesToExtractors.isKey(varType)
                extractor=obj.VarTypesToExtractors(varType);
                extractor(obj,varName,var);
            end
        end

        function addToExternalInputs(obj,varName,var)
            varType=class(var);

            if obj.VarTypesToSetLabels.isKey(varType)
                setLabel=obj.VarTypesToSetLabels(varType);

                varLen=length(var);
                if varLen>1
                    for el=1:varLen
                        fn=[varName,num2str(el)];
                        var(el).Name=fn;
                        obj.ExtractedSets.(setLabel).(fn)=var(el);
                    end
                else
                    var.Name=varName;
                    obj.ExtractedSets.(setLabel).(varName)=var;
                end
            end
        end

        function addToWSVariables(obj,varName,var)
            varType=class(var);

            if obj.VarTypesToSetLabels.isKey(varType)
                setLabel=obj.VarTypesToSetLabels(varType);

                obj.ExtractedSets.(setLabel).(varName)=var;
            end
        end

        function addToModelParameters(obj,~,var)
            varType=class(var);

            if obj.VarTypesToSetLabels.isKey(varType)
                setLabel=obj.VarTypesToSetLabels(varType);

                for param=var
                    if modelParameterExists(param,obj.ExtractedSets.(setLabel).(obj.DefaultSetName))
                        error(message('simulinkcompiler:genapp:DuplicateModelParametersInMATFile'));
                    end
                    obj.ExtractedSets.(setLabel).(obj.DefaultSetName)=...
                    [obj.ExtractedSets.(setLabel).(obj.DefaultSetName),param];
                end
            end
        end

        function addModelOperatingPointToInitialStates(obj,varName,var)
            varType=class(var);

            if obj.VarTypesToSetLabels.isKey(varType)
                setLabel=obj.VarTypesToSetLabels(varType);

                varLen=length(var);
                if varLen>1
                    for el=1:varLen
                        fn=[varName,num2str(el)];
                        obj.ExtractedSets.(setLabel).(fn)=var(el);
                    end
                else
                    obj.ExtractedSets.(setLabel).(varName)=var;
                end
            end
        end

        function addStructToInitialStates(obj,varName,var)
            varType=class(var);

            if obj.VarTypesToSetLabels.isKey(varType)
                setLabel=obj.VarTypesToSetLabels(varType);

                if(isstruct(var)&&...
                    isfield(var,'signals')&&...
                    isfield(var,'description')&&...
                    isstruct(var.signals)&&...
                    isfield(var.signals,'values'))

                    varLen=length(var);
                    if varLen>1
                        for el=1:varLen
                            fn=[varName,num2str(el)];
                            if~isequal(var(el).description,'InitialState')
                                continue;
                            end
                            obj.ExtractedSets.(setLabel).(fn)=var(el);
                        end
                    elseif isequal(var.description,'InitialState')
                        obj.ExtractedSets.(setLabel).(varName)=var;
                    end
                end
            end
        end
    end
end

function TF=modelParameterExists(modelParam,paramSet)
    TF=false;
    if isempty(paramSet),return;end
    paramNames=string({paramSet.Name});
    TF=ismember(modelParam.Name,paramNames);
end


