classdef(Abstract)EventRunnableFinder<handle







    methods(Abstract,Access=public)
        find(obj,runnableName,m3iComp);
    end

    methods(Abstract,Static,Access=public)
        isSupported=supportedEvent(m3iEvent);
    end
end
