function exportParamSet(this,paramSet,appName)










    if(nargin<3)
        if~this.isLoaded
            this.throwError('slrealtime:paramSet:emptyAppName');
            return;
        end
        appName=this.ModelStatus.Application;
    end

    try

        if~isa(paramSet,'slrealtime.ParameterSet')
            this.throwError('slrealtime:paramSet:paramSetNotValid');
        end

        fileName=paramSet.filename;


        dl=locGetAppsDirListing(this);
        if isempty(dl(cellfun(@(x)contains(x,this.appsDirOnTarget),dl)))

            this.throwError('slrealtime:paramSet:appIsNotInstalled');
            return;
        end

        installedApps=locGetAppsName(this.appsDirOnTarget,dl);
        if~any(strcmp(installedApps,appName))
            this.throwError('slrealtime:paramSet:appIsNotInstalled');
        end

        tmpDir=tempname;
        mkdir(tmpDir);
        currDir=pwd;
        cdCleanup=onCleanup(@()cd(currDir));
        dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));
        cd(tmpDir);


        srcFile=paramSet.saveAsJSON(tmpDir,fileName);
        destFile=strcat(this.appsDirOnTarget,'/',appName,'/paramSet/',fileName,'.json');
        this.sendFile(srcFile,destFile);

    catch ME
        throwAsCaller(ME);
    end

end

function dl=locGetAppsDirListing(this)



    sshCmd=strcat("find ",this.appsDirOnTarget);
    res=this.executeCommand(sshCmd);
    res=split(res.Output);
    dl=res(~cellfun('isempty',res));
end

function al=locGetAppsName(appDirs,dl)

    dl=extractAfter(dl,appDirs);
    dl=dl(~cellfun('isempty',dl));
    dl=extractAfter(dl,"/");
    al=dl(~cellfun(@(x)contains(x,"/"),dl));
end
