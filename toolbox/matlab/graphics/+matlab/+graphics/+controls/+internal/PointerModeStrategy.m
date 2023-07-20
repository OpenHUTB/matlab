classdef PointerModeStrategy<handle




    methods(Abstract)
        handleModeChange(obj,sourceObj,eventData)

        result=isModeEnabled(obj,sourceObj,eventData)

        createModeListener(obj,sourceObj,eventData)
    end
end

