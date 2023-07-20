classdef ParsimInputParser




    properties(Access=private)
parser
    end

    properties
        AllowParallelSimulations=true
    end

    properties(Dependent)
Results
Unmatched
UsingDefaults
    end

    methods
        function obj=ParsimInputParser(configureForBatchsim)
            if nargin==0
                configureForBatchsim=false;
            end

            p=inputParser;
            p.KeepUnmatched=true;
            p.StructExpand=true;
            addParameter(p,'SetupFcn',[],@(x)validateFunctionHandle(x,'SetupFcn'));
            addParameter(p,'CleanupFcn',[],@(x)validateFunctionHandle(x,'CleanupFcn'));
            addParameter(p,'UseParallel',false,@(x)validateLogicalOnOff(x,'UseParallel'));
            addParameter(p,'UseFastRestart',false,@(x)validateLogicalOnOff(x,'UseFastRestart'));
            addParameter(p,'ShowProgress',true,@(x)validateLogicalOnOff(x,'ShowProgress'));
            addParameter(p,'AttachedFiles',{},@validateAttachedFiles);
            addParameter(p,'TransferBaseWorkspaceVariables',false,@(x)validateLogicalOnOff(x,'TransferBaseWorkspaceVariables'));
            addParameter(p,'ManageDependencies',true,@(x)validateLogicalOnOff(x,'ManageDependencies'));
            addParameter(p,'StopOnError',false,@(x)validateLogicalOnOff(x,'StopOnError'));
            addParameter(p,'AllowMultipleModels',false,@(x)validateLogicalOnOff(x,'AllowMultipleModels'));
            addParameter(p,'UseThreadWorkers',false,@(x)validateLogicalOnOff(x,'UseThreadWorkers'));


            if~configureForBatchsim
                addParameter(p,'RunInBackground',false,@(x)validateLogicalOnOff(x,'RunInBackground'));
                addParameter(p,'ShowSimulationManager',false,@(x)validateLogicalOnOff(x,'ShowSimulationManager'));
            end
            obj.parser=p;
        end

        function results=get.Results(obj)








            logicalParams={'UseParallel','UseFastRestart','ShowProgress',...
            'RunInBackground','TransferBaseWorkspaceVariables',...
            'ShowSimulationManager','ManageDependencies','StopOnError',...
            'AllowMultipleModels','UseThreadWorkers'};
            results=obj.parser.Results;
            for i=1:numel(logicalParams)
                if isfield(results,logicalParams{i})
                    results.(logicalParams{i})=convertToLogical(results.(logicalParams{i}));
                end
            end
        end

        function out=get.Unmatched(obj)




            out=obj.parser.Unmatched;
        end

        function out=get.UsingDefaults(obj)




            out=obj.parser.UsingDefaults;
        end

        function parse(obj,varargin)


            parse(obj.parser,varargin{:});
            obj.validateParallelOnlyOptions();
        end
    end

    methods(Access=private)
        function validateParallelOnlyOptions(obj)



            if~obj.AllowParallelSimulations
                parallelOptions={'UseParallel','RunInBackground',...
                'AttachedFiles','TransferBaseWorkspaceVariables',...
                'ManageDependencies','UseThreadWorkers'};


                usingDefaults=obj.parser.UsingDefaults;
                nonDefaultValues=setdiff(fieldnames(obj.parser.Results),usingDefaults);



                for i=1:numel(nonDefaultValues)
                    if any(strcmpi(nonDefaultValues{i},parallelOptions))
                        error(message('Simulink:Commands:OptionNotSupportedUseParsim',nonDefaultValues{i}));
                    end
                end
            end
        end
    end
end

function TF=validateLogicalOnOff(paramVal,paramName)
    TF=islogical(paramVal)||any(strcmpi(paramVal,["on","off"]));
    if~TF
        error(message('Simulink:Commands:InvalidLogical',paramName));
    end
end

function TF=validateFunctionHandle(paramVal,paramName)
    TF=true;
    if~(isempty(paramVal)||isa(paramVal,'function_handle'))
        error(message('Simulink:Commands:InvalidFcnHandle',paramName));
    end
end

function TF=validateAttachedFiles(x)
    TF=true;
    try
        validateattributes(x,{'cell','char','string'},{});
    catch
        error(message('Simulink:Commands:InvalidAttachedFiles'));
    end
end

function val=convertToLogical(paramVal)
    onoff=struct('on',true,'off',false);
    if islogical(paramVal)
        val=paramVal;
    else
        val=onoff.(lower(paramVal));
    end
end