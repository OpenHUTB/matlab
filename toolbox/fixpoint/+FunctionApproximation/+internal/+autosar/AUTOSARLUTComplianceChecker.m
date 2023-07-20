classdef AUTOSARLUTComplianceChecker<matlab.mixin.Heterogeneous





    methods(Abstract,Access=public)
        diagnostic=check(this,context);
    end
end