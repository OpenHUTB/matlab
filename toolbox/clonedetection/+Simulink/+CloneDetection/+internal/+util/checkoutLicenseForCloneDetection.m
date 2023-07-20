function checkoutLicenseForCloneDetection()




    if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseCheckOutFail');
    end
end