




classdef RuntimeFcns

    properties
        InputFcns slsim.InputFcn{mustBeVectorOrEmpty(InputFcns)}
        OutputFcns slsim.OutputFcn{mustBeVectorOrEmpty(OutputFcns)}
        PostStepFcn{mustBeScalarOrEmpty}
        SimStatusChangeFcn{mustBeScalarOrEmpty}
    end

    properties(Hidden)


        PostStepFcnDecimation(1,1)double{mustBePositive,mustBeInteger}=1

    end

    methods
        function obj=setInputFcn(obj,inputFcn,varargin)
            obj.InputFcns(end+1)=slsim.InputFcn(inputFcn,varargin{:});
        end

        function obj=setOutputFcn(obj,outputFcn,varargin)
            obj.OutputFcns(end+1)=slsim.OutputFcn(outputFcn,varargin{:});
        end

        function obj=setPostStepFcn(obj,postStepFcn)
            obj.PostStepFcn=postStepFcn;
        end

        function obj=set.PostStepFcn(obj,value)
            if isempty(value)
                obj.PostStepFcn=[];
                return;
            end
            mustBeUnderlyingType(value,'function_handle');
            obj.PostStepFcn=value;
        end

        function obj=setSimStatusChangeFcn(obj,simStatusChangeFcn)
            obj.SimStatusChangeFcn=simStatusChangeFcn;
        end

        function obj=set.SimStatusChangeFcn(obj,value)
            if isempty(value)
                obj.SimStatusChangeFcn=[];
                return;
            end
            mustBeUnderlyingType(value,'function_handle');
            obj.SimStatusChangeFcn=value;
        end
    end

    methods(Static,Hidden)
        function mustBeVectorOrEmpty(val)
            if~isempty(val)
                mustBeVector(val);
            end
        end
    end
end

function mustBeVectorOrEmpty(val)
    if~isempty(val)
        mustBeVector(val);
    end
end
