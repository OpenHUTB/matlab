function checkoutLicenses(requiredLicenses)




    for lic=requiredLicenses
        if builtin('_license_checkout',lic{1},'quiet')~=0
            DAStudio.error('Simulink:slbuild:ParBuildLicenseNotAvailable',lic{1});
        end
    end
end

