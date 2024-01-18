function out=annotationMenuState(callbackInfo)
    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    if rmiInstalled&&rmiLicenseAvailable
        out=annotationLinkState(callbackInfo);
    else
        objh=callbackInfo.getSelection();
        if length(objh)==1&&~isempty(rmi.getReqs(objh))
            out='Enabled';
        else
            out='Disabled';
        end
    end
end


function result=annotationLinkState(callbackInfo)
    objh=callbackInfo.getSelection();

    if~rmisl.isLibObject(objh)
        result='Enabled';
    else
        result='Disabled';
    end
end


