function checkLicense()




    licChk=stm.internal.util.LicenseCheck.getLicenseCheckoutObject();



    if licChk.ShouldCheckoutLicense
        lic=license('checkout','Simulink_Test');

        if~lic
            error(message('stm:general:LicenseCheck'));
        end
    end
end

