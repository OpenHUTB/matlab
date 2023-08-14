function releaseInfo=getRegisteredReleases()




    installedMatlabs=filterDuplicatePaths(Simulink.CoSimServiceUtils.listInstalledMatlabs);
    releaseInfo=struct(...
    'name',{installedMatlabs.MatlabRelease},...
    'location',{installedMatlabs.MatlabPath},...
    'isCurrent',{installedMatlabs.isCurrent},...
    'checked',{installedMatlabs.isChecked});


    currReleaseName=getString(message('stm:MultipleReleaseTesting:CurrentRelease'));
    foundCurrentRelease=any(strcmp({releaseInfo.name},currReleaseName));
    if~foundCurrentRelease
        currentReleaseInfo=struct('name',currReleaseName,...
        'location',matlabroot,'isCurrent',true,'checked',true);
        releaseInfo=[currentReleaseInfo,releaseInfo];
    end

end

function installedMatlabs=filterDuplicatePaths(installedMatlabs)
    warnState=warning('off','backtrace');
    oc=onCleanup(@()warning(warnState));

    pathMap=Simulink.sdi.Map(char('?'),char('?'));
    idxToFilter=[];
    for idx=1:length(installedMatlabs)
        if pathMap.isKey(installedMatlabs(idx).MatlabPath)
            warning(message('stm:MultipleReleaseTesting:IgnoringDuplicatePathsInReleaseMgr',...
            installedMatlabs(idx).MatlabPath,...
            pathMap.getDataByKey(installedMatlabs(idx).MatlabPath),...
            installedMatlabs(idx).MatlabRelease));
            idxToFilter(end+1)=idx;%#ok<AGROW>
            continue;
        end
        pathMap.insert(installedMatlabs(idx).MatlabPath,installedMatlabs(idx).MatlabRelease);
    end
    installedMatlabs(idxToFilter)=[];
end