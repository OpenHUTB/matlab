



function out=shouldAppBeDisabled(modelH)

    out=false;
    [rmiInstalled,rmiLicensed]=rmi.isInstalled();
    if~rmiInstalled||~rmiLicensed

        out=true;
        return;
    end

    appmgr=slreq.app.MainManager.getInstance();

    if~isempty(appmgr.perspectiveManager)
        modelHs=appmgr.perspectiveManager.getDisabledModelList();

        if any(modelHs==modelH)
            out=true;
        end
    end
end