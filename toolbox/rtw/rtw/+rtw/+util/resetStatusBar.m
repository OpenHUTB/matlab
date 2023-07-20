classdef resetStatusBar<handle
    properties
modelHandle
    end

    methods
        function obj=resetStatusBar(aModelHandle)
            obj.modelHandle=aModelHandle;
        end

        function delete(obj)
            set_param(obj.modelHandle,'StatusString','');
        end
    end
end
