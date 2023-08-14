classdef SLTestLicenseCheckoutPreventer<handle

    properties(SetAccess=private)
OldValue
    end

    methods
        function h=SLTestLicenseCheckoutPreventer()
            licChk=stm.internal.util.LicenseCheck.getLicenseCheckoutObject();
            h.OldValue=licChk.ShouldCheckoutLicense;
            licChk.setShouldCheckoutLicense(false);
        end

        function delete(h)
            licChk=stm.internal.util.LicenseCheck.getLicenseCheckoutObject();
            licChk.setShouldCheckoutLicense(h.OldValue);
        end
    end
end