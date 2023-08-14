function paramSet=importParamSet(this,fileName,appName)










    if(nargin<3)
        if~this.isLoaded
            this.throwError('slrealtime:paramSet:emptyAppName');
            return;
        end
        appName=this.ModelStatus.Application;
    end

    validateattributes(fileName,{'char','string'},{'scalartext'});
    fileName=convertStringsToChars(fileName);

    validateattributes(appName,{'char','string'},{'scalartext'});
    appName=convertStringsToChars(appName);

    try
        tmpDir=tempname;
        mkdir(tmpDir);
        currDir=pwd;
        cdCleanup=onCleanup(@()cd(currDir));
        dirCleanup=onCleanup(@()rmdir(tmpDir,'s'));
        cd(tmpDir);


        srcFile=strcat(this.appsDirOnTarget,'/',appName,'/paramSet/',fileName,'.json');
        destFile=strcat(fileName,'.json');
        this.receiveFile(srcFile,destFile);


        paramSet=slrealtime.ParameterSet(fileName);

    catch ME
        throw(ME);
    end

end
