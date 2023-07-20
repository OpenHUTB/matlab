function[isSLDVLicenseCheckedOut,err]=getRequiredLicenseCheckoutInfo()






    err='';
    [isSLDVLicenseCheckedOut,licenseCheckoutErrorMsg]=license('checkout','Simulink_Design_Verifier');

    if isSLDVLicenseCheckedOut
        return;
    end


    isVDBPresent=license('checkout','vehicle_dynamics_blockset');
    if isVDBPresent
        return;
    end


    isPBPresent=license('checkout','powertrain_blockset');
    if isPBPresent
        return;
    end

    if~isSLDVLicenseCheckedOut
        err=MException('Simulink:Variants:SLDVLicenseCheckoutFailed','%s',licenseCheckoutErrorMsg);
    end
end


