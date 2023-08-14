function displayStructArray=getUpdatablePackages(installedPkgs,latestPkgs)


















    displayStructArray=repmat(struct(...
    'DisplayName','',...
    'InstalledVersion','',...
    'LatestVersion','',...
    'BaseCode','',...
    'BaseProduct',''),1,length(installedPkgs));


    for i=1:length(installedPkgs)


        currentInstalledSp=installedPkgs(i);
        latestSp=localGetSpPkgObjectByBaseCode(currentInstalledSp.BaseCode,latestPkgs);
        displayStruct=createDisplayStruct(currentInstalledSp);
        if isempty(latestSp)


            displayStruct.LatestVersion='';
        else

            displayStruct.LatestVersion=latestSp.Version;
        end
        displayStructArray(i)=displayStruct;
    end
end


function foundSpPkg=localGetSpPkgObjectByBaseCode(baseCode,pkgList)


    foundSpPkg=[];
    for i=1:numel(pkgList)
        if strcmp(baseCode,pkgList(i).BaseCode)
            foundSpPkg=pkgList(i);
            break;
        end
    end
end

function displayStruct=createDisplayStruct(installedSpPkg)


    displayStruct.DisplayName=installedSpPkg.DisplayName;
    displayStruct.BaseCode=installedSpPkg.BaseCode;
    displayStruct.BaseProduct=installedSpPkg.BaseProduct;
    displayStruct.InstalledVersion=installedSpPkg.Version;
end