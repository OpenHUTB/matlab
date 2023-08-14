function[flag,MissingLicense]=checkOutLicenseForTraceability()
    flag=true;
    MissingLicense={};
    lics={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
    licenseNames={'MATLAB Coder','Simulink Coder','Embedded Coder'};
    for i=1:length(lics)
        [lic,~]=builtin('license','checkout',lics{i});
        if~lic
            flag=false;
            MissingLicense{end+1}=licenseNames{i};%#ok<AGROW>
        end
    end
end