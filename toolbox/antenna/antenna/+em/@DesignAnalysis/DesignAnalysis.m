classdef(Abstract)DesignAnalysis<handle


    methods

        d=design(obj,freq,varargin);

    end

    methods(Static=true,Access=?em.EmStructures)
        chkvaliddesign(class_obj)
        tune_param=tunedesign(BackingStructure,Exciter)
    end

    methods(Access=?em.EmStructures)
        designObj=designPrototypeElement(obj,freq,varargin);
        designObj=designPrototypeArray(obj,freq,elementType,designElement)
    end
end