classdef(Abstract)IPoolValidator<handle




    methods(Abstract)
        isValid=validate(this,pool,mdl,requiredLicenses);
        result=isPCTLicensedAndInstalled(~)
    end
end

