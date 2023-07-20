


classdef parameterStack<handle




    properties(SetAccess=private,GetAccess=private)
model
        paramNameList={};
        paramValueList={};
    end

    methods
        function obj=parameterStack(modelName,varargin)
            obj.model=modelName;
            for k=1:length(varargin)
                push(obj,varargin{k});
            end
        end

        function push(obj,paramName)
            obj.paramNameList{end+1}=paramName;
            obj.paramValueList{end+1}=get_param(obj.model,paramName);
        end

        function delete(obj)
            for k=length(obj.paramNameList):-1:1
                set_param(obj.model,obj.paramNameList{k},obj.paramValueList{k});
            end
        end
    end

end

