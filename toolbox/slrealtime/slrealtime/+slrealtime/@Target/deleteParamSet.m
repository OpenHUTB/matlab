function deleteParamSet(this,fileName,appName)










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
        srcFile=strcat(this.appsDirOnTarget,'/',appName,'/paramSet/',fileName,'.json');
        if this.isfile(srcFile)
            this.deletefile(srcFile);
        else
            this.throwError('slrealtime:paramSet:paramSetNotExist',fileName);
            return;
        end

    catch ME
        throw(ME);
    end


end