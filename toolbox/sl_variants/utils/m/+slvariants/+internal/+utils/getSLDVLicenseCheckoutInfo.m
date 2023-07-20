function[isSLDVLicenseCheckedOut,err]=getSLDVLicenseCheckoutInfo()






    [isSLDVLicenseCheckedOut,licenseCheckoutErrorMsg]=license('checkout','Simulink_Design_Verifier');
    err='';
    if~isSLDVLicenseCheckedOut
        err=MException('Simulink:Variants:SLDVLicenseCheckoutFailed','%s',licenseCheckoutErrorMsg);
    end
end
