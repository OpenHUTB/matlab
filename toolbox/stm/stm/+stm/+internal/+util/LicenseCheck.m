classdef LicenseCheck<handle



    properties
        ShouldCheckoutLicense;
    end

    methods(Access=private)
        function obj=LicenseCheck()
            obj.ShouldCheckoutLicense=true;
        end
    end

    methods(Static)

        function singleObj=getLicenseCheckoutObject()
            mlock;
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=stm.internal.util.LicenseCheck;
            end
            singleObj=localObj;
        end
    end

    methods(Access=public)
        function setShouldCheckoutLicense(obj,state)
            obj.ShouldCheckoutLicense=state;
        end
    end
end

