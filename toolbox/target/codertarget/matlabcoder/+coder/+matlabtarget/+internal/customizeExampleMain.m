classdef customizeExampleMain<handle


    properties(SetAccess=private,GetAccess=public)

cfg

funcName

hardwareName
    end

    properties

        IncludeFiles={}

        TargetInitializationCalls={}

        TargetTerminationCalls={}
    end

    methods
        function obj=customizeExampleMain(varargin)

            p=inputParser;
            addRequired(p,'cfg');
            addOptional(p,'funcName',@obj.validate);
            parse(p,varargin{:});


            obj.cfg=p.Results.cfg;
            obj.hardwareName=obj.cfg.Hardware.Name;
            obj.funcName=p.Results.funcName;


            attributes=codertarget.attributes.getTargetHardwareAttributesForHardwareName(obj.hardwareName);
            if~isempty(attributes.IncludeFiles)
                obj.IncludeFiles=attributes.IncludeFiles;
            end
            if~isempty(attributes.TargetInitializationCalls)
                obj.TargetInitializationCalls=attributes.TargetInitializationCalls;
            end
            if~isempty(attributes.TargetTerminationCalls)
                obj.TargetTerminationCalls=attributes.TargetTerminationCalls;
            end
        end
    end

    methods(Static)
        function validate(funcname)
            validateattributes(funcname,{'char','string'},{'nonempty'},...
            'validate','funcName');
        end
    end


    methods
        function set.IncludeFiles(obj,value)
            if~iscell(value)
                error('svd:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.IncludeFiles=value;
        end

        function set.TargetInitializationCalls(obj,value)
            if~iscell(value)
                error('svd:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.TargetInitializationCalls=value;
        end

        function set.TargetTerminationCalls(obj,value)
            if~iscell(value)
                error('svd:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.TargetTerminationCalls=value;
        end

        function includeList=getIncludeList(obj)

            includeList=[];
            if~isempty(obj.IncludeFiles)
                for i=1:numel(obj.IncludeFiles)
                    include=sprintf('#include "%s"\n',char(obj.IncludeFiles{i}));
                    includeList=[includeList,include];%#ok<AGROW>
                end
            end
        end

        function functionList=getTargetInitFunc(obj)

            functionList=[];
            if~isempty(obj.TargetInitializationCalls)
                for i=1:numel(obj.TargetInitializationCalls)
                    functionName=sprintf('%s;',char(obj.TargetInitializationCalls{i}));
                    functionList=[functionList,functionName];%#ok<AGROW>
                end
            end
        end

        function functionList=getTargetTerminateFunc(obj)

            functionList=[];
            if~isempty(obj.TargetTerminationCalls)
                for i=1:numel(obj.TargetTerminationCalls)
                    functionName=sprintf('%s;',char(obj.TargetTerminationCalls{i}));
                    functionList=[functionList,functionName];%#ok<AGROW>
                end
            end
        end
    end
end


