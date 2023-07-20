function apps=getAvailableProfile(tg,appName)
















    narginchk(2,2);

    try
        apps={};
        validateattributes(appName,{'char','string'},{'scalartext'});
        appName=convertStringsToChars(appName);


        dl=locGetAppsDirListing(tg);
        if isempty(dl(cellfun(@(x)contains(x,tg.appsDirOnTarget),dl)))

            return;
        end


        if~strcmp(appName,'-all')
            installedApps={appName};
        else
            installedApps=locGetAppsName(tg.appsDirOnTarget,dl);
        end

        for i=1:length(installedApps)
            appDir=strcat(tg.appsDirOnTarget,"/",installedApps{i});
            if isempty(dl(cellfun(@(x)contains(x,appDir),dl)))
                continue;
            end

            logFile=strcat(appDir,"/profiler/tracelog.kev");
            if isempty(dl(cellfun(@(x)contains(x,logFile),dl)))
                continue;
            else
                apps=[apps;installedApps{i}];%#ok<AGROW>
            end
        end
    catch ME
        throw(ME);
    end
end

function al=locGetAppsName(appDirs,dl)

    dl=extractAfter(dl,appDirs);
    dl=dl(~cellfun('isempty',dl));
    dl=extractAfter(dl,"/");
    al=dl(~cellfun(@(x)contains(x,"/"),dl));
end

function dl=locGetAppsDirListing(tg)



    sshCmd=strcat("find ",tg.appsDirOnTarget);
    res=tg.executeCommand(sshCmd);
    res=split(res.Output);
    dl=res(~cellfun('isempty',res));
end
