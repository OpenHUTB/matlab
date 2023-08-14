function[tf,msg]=isSlreqInstalledAndLicensed(mode)








    [isInstalled,isLicensed]=rmi.isInstalled();

    tf=isInstalled&&isLicensed;

    if~tf
        msg=getString(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
    elseif strcmp(mode,'checkout')
        msg='Unexpected ''checkout'' request for Requirements Toolbox';
    else
        msg='';
    end

end
