function removeAllApplications(this)










    if~this.isConnected()
        this.connect();
    end

    try
        if this.isLoaded()
            this.throwError('slrealtime:target:removeAppsLoaded');
        end

        apps=this.getInstalledApplications();
        for i=1:length(apps)
            this.removeApplication(apps{i});
        end

    catch ME
        this.throwErrorWithCause('slrealtime:target:removeAllAppsError',ME,...
        this.TargetSettings.name,ME.message);
    end
end
