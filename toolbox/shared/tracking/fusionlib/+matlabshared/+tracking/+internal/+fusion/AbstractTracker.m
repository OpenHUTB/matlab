classdef AbstractTracker<matlab.System...
    &matlabshared.tracking.internal.AbstractContainsFilters

%#codegen

    methods(Access=protected)
        function obj=AbstractTracker
            coder.allowpcode('plain');
        end


        function flag=isSimulinkBlock(obj)
            flag=obj.getExecPlatformIndex();
        end
    end
end

