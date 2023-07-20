function msg=checkLicense




    msg='';
    licName=SlCov.CoverageAPI.getLicenseName;
    slvnvexist=license('test',licName);
    sldvtexist=license('test','Simulink_Design_Verifier');
    sldvcheckout=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
    slvnvcheckout=builtin('_license_checkout',licName,'quiet');

    if slvnvexist==0||slvnvcheckout==1
        msg=message('Sldv:Setup:CoverageNotLicensed');
    elseif sldvtexist==0||sldvcheckout==1
        msg=message('Sldv:RunTestCase:SimulinkDesignVerifierNotLicensed');
    end
end
