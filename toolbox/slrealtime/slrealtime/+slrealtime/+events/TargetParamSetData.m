classdef TargetParamSetData<event.EventData




    properties
BlockPath
ParamName
Value
Page
    end

    methods
        function data=TargetParamSetData(blockPath,paramName,value,page)
            data.BlockPath=blockPath;
            data.ParamName=paramName;
            data.Value=value;
            data.Page=page;
        end
    end
end
