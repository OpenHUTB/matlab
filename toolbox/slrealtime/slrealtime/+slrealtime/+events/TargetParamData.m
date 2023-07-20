classdef TargetParamData<event.EventData




    properties
blockPath
paramName
value
    end

    methods
        function data=TargetParamData(blockPath,paramName,value)
            data.blockPath=blockPath;
            data.paramName=paramName;
            data.value=value;
        end
    end
end
