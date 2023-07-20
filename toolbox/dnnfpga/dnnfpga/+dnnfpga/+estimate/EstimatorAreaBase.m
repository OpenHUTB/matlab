classdef EstimatorAreaBase<handle


    methods(Abstract)
        Area=getprocessorArea(this);
        module=getHWparams(this);
    end

end

