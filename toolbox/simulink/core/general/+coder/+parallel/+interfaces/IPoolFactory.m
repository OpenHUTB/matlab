classdef(Abstract)IPoolFactory<handle




    methods(Abstract)
        [success,pool]=createPool(this,errorOnValidationFailure,requiredLicenses)
    end
end


