function ret=isFirmwareUpdateAvailable(spPkgObj)








    checkForSingleSp=false;
    if exist('spPkgObj','var')
        validateattributes(spPkgObj,{'hwconnectinstaller.SupportPackage'},...
        {'scalar'},'isFirmwareUpdateAvailable','spPkgObj');
        checkForSingleSp=true;
    end

    if~checkForSingleSp


        fwUpdate=hwconnectinstaller.FirmwareUpdater;
        [~,list,~]=fwUpdate.getFirmwareUpdateList;


        ret=~isempty(list);
    else
        fileExist=which(spPkgObj.FwUpdate);
        ret=~isempty(fileExist);

    end
end