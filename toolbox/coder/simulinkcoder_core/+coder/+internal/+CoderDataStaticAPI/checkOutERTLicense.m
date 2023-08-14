function checkOutERTLicense()




    licenses={'MATLAB_Coder','Real-Time_Workshop','RTW_Embedded_Coder','SIMULINK'};
    for i=1:length(licenses)
        if(builtin('_license_checkout',licenses{i},'quiet')~=0)
            DAStudio.error('coderdictionary:api:CoderLicenseNotAvailable',licenses{i});
        end
    end
end


