classdef BatchsimInputParser




    properties(Access=private)
ParsimInputParser
BatchInputParser
ExplicitBatchInputParser
    end

    properties(Dependent)
Results
UsingDefaults
    end

    methods
        function obj=BatchsimInputParser
            obj.ParsimInputParser=MultiSim.internal.ParsimInputParser(true);





            p=inputParser;
            p.KeepUnmatched=false;
            p.StructExpand=true;
            p.FunctionName='batchsim';

            addParameter(p,'AdditionalPaths',{},@(x)ischar(x)||isstring(x)||iscellstr(x));
            addParameter(p,'AttachedFiles',{},@validateAttachedFiles);
            addParameter(p,'AutoAddClientPath',true,@(x)true);
            addParameter(p,'AutoAttachFiles',true,@(x)true);
            addParameter(p,'BatchOptions',struct,@(x)(isstruct(x)&&isscalar(x))||iscell(x));
            addParameter(p,'CaptureDiary',true,@(x)true);
            addParameter(p,'CurrentFolder',pwd,@(x)true);
            addParameter(p,'EnvironmentVariables',{},@(x)true);
            addParameter(p,'Pool',0,@(x)true);
            addParameter(p,'Profile',parallel.defaultProfile,...
            @(x)validateProfile(x));
            obj.BatchInputParser=p;
            obj.ExplicitBatchInputParser=copy(p);
        end

        function results=get.Results(obj)







            parsimOptions=obj.ParsimInputParser.Results;
            batchOptions=obj.BatchInputParser.Results;


            batchOptions.AttachedFiles=parsimOptions.AttachedFiles;
            parsimOptions=rmfield(parsimOptions,'AttachedFiles');


            batchOptions=obj.mergeBatchOptions(batchOptions);


            batchOptions.AttachedFiles=reshape(batchOptions.AttachedFiles,...
            1,numel(batchOptions.AttachedFiles));

            results.ParsimOptions=parsimOptions;
            results.BatchOptions=batchOptions;
        end

        function usingDefaults=get.UsingDefaults(obj)
            explicitBatchOptions=setdiff(fieldnames(obj.ExplicitBatchInputParser.Results),...
            obj.ExplicitBatchInputParser.UsingDefaults);
            usingDefaults=[obj.ParsimInputParser.UsingDefaults,...
            setdiff(obj.BatchInputParser.UsingDefaults,explicitBatchOptions)];
        end

        function parse(obj,varargin)

            parse(obj.ParsimInputParser,varargin{:});

            parse(obj.BatchInputParser,obj.ParsimInputParser.Unmatched);
        end
    end

    methods(Access=private)
        function options=mergeBatchOptions(obj,batchOptions)

            explicitBatchOptionsStruct=batchOptions.BatchOptions;
            options=rmfield(batchOptions,'BatchOptions');
            parse(obj.ExplicitBatchInputParser,explicitBatchOptionsStruct);


            explicitBatchOptions=setdiff(fieldnames(obj.ExplicitBatchInputParser.Results),...
            obj.ExplicitBatchInputParser.UsingDefaults);
            nondefaultBatchOptions=setdiff(fieldnames(obj.BatchInputParser.Results),...
            obj.BatchInputParser.UsingDefaults);




            for i=1:numel(explicitBatchOptions)
                optionName=explicitBatchOptions{i};
                if any(strcmpi(optionName,nondefaultBatchOptions))
                    error(message('Simulink:batchsim:MultipleParameterSpecification',...
                    optionName));
                end
                options.(optionName)=explicitBatchOptionsStruct.(optionName);
            end
        end
    end
end

function TF=validateProfile(x)

    if~matlab.internal.datatypes.isScalarText(x)&&~isa(x,'parallel.Cluster')
        error(message('Simulink:batchsim:InvalidProfile'));
    else
        TF=true;
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
