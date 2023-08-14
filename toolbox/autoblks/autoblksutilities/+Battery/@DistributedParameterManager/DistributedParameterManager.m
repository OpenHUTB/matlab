classdef DistributedParameterManager<handle
































    properties(Access=private)
modelName
params
    end



    methods
        function obj=DistributedParameterManager(modelName)
            if nargin
                obj.modelName=modelName;
            end
        end
    end



    methods
        function setParameter(obj,paramName,paramValue)
            obj.params.(paramName)=paramValue;
        end

        function deleteParameter(obj,paramName)
            obj.params=rmfield(obj.params,paramName);
        end

        function distributeParameters(obj)
            if~isempty(gcp('nocreate'))
                assignParametersInBaseWorkspace(obj)
                parfevalOnAll(@assignParametersInBaseWorkspace,0,obj)
            else
                assignParametersInBaseWorkspace(obj)
            end
        end

        function assignParametersInBaseWorkspace(obj)
            ParamNames=fieldnames(obj.params);
            for pIdx=1:numel(ParamNames)
                ThisName=ParamNames{pIdx};
                assignin('base',ThisName,obj.params.(ThisName));
            end
        end

    end

end