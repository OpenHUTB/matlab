function list=listParamSet(this,appName)










    if(nargin<2)
        if~this.isLoaded
            this.throwError('slrealtime:paramSet:emptyAppName');
            return;
        end
        appName=this.ModelStatus.Application;
    end

    try
        list={};
        validateattributes(appName,{'char','string'},{'scalartext'});
        appName=convertStringsToChars(appName);


        dl=locGetAppsDirListing(this);
        if isempty(dl(cellfun(@(x)contains(x,this.appsDirOnTarget),dl)))

            return;
        end

        installedApps=locGetAppsName(this.appsDirOnTarget,dl);
        if~any(strcmp(installedApps,appName))
            this.throwError('slrealtime:paramSet:appIsNotInstalled');
        end

        list=locGetParamSet(this,dl,appName);

    catch ME
        throw(ME);
    end
end

function files=locGetParamSet(this,dl,appName)

    files=dl(cellfun(@(x)contains(x,[appName,"/paramSet"]),dl));

    files=extractAfter(files,"paramSet/");

    files=files(~cellfun(@(x)contains(x,"paramInfo"),files));

    files=files(~cellfun('isempty',files));

    files=extractBefore(files,".json");
end

function dl=locGetAppsDirListing(this)



    sshCmd=strcat("find ",this.appsDirOnTarget);
    res=this.executeCommand(sshCmd);
    res=splitlines(res.Output);
    dl=res(~cellfun('isempty',res));
end

function al=locGetAppsName(appDirs,dl)

    dl=extractAfter(dl,appDirs);
    dl=dl(~cellfun('isempty',dl));
    dl=extractAfter(dl,"/");
    al=dl(~cellfun(@(x)contains(x,"/"),dl));
end
