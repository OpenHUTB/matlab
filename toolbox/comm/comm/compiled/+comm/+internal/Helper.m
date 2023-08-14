classdef(Hidden)Helper<matlab.System





%#codegen

    methods
        function obj=Helper
            coder.allowpcode('plain');
        end
    end
    methods(Access=protected)
        function flag=isInSimulink(obj)
            flag=(getExecPlatformIndex(obj)==1);
        end
    end
end