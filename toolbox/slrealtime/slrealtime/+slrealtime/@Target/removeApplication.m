function removeApplication(this,appName)











    if~this.isConnected()
        this.connect();
    end

    try
        validateattributes(appName,{'char','string'},{'scalartext'});
        appName=convertStringsToChars(appName);

        if this.isLoaded(appName)
            this.throwError('slrealtime:target:appLoaded',appName);
        end

        appDir=strcat(this.appsDirOnTarget,"/",appName);

        if~this.isfolder(appDir)
            this.throwError('slrealtime:target:appDoesNotExistOnTarget',appName);
        end

        this.deletefolder(appDir);

        if strcmp(appName,this.getStartupApp())
            this.clearStartupApp();
        end

    catch ME
        this.throwErrorWithCause('slrealtime:target:removeAppError',ME,...
        appName,this.TargetSettings.name,ME.message);
    end
end
