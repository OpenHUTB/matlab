function code2req(sid,reqId)





    persistent rmiInstalled;
    if isempty(rmiInstalled)
        [isInstalled,isLicensed]=rmi.isInstalled();
        rmiInstalled=isInstalled&&isLicensed;
    end

    narginchk(2,2);

    if~rmiInstalled
        DAStudio.error('RTW:utility:VnVLicenseUnavailable');
    end

    model=strtok(sid,'/:');

    if exist(model,'file')==4
        open_system(model);
    end

    rmi('view',sid,reqId);

