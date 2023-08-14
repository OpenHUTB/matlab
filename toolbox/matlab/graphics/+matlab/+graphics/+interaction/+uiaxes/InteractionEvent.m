classdef InteractionEvent<handle

    properties
source
eventname
    end

    methods(Abstract)
        enable(hObj)
        hObj=disable(hObj)
    end
end

