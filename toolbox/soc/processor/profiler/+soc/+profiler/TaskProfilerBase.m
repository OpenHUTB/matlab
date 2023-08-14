classdef(Hidden=true,Abstract=true)TaskProfilerBase<handle



    methods(Abstract)
        start(h);
        stop(h);
    end
end