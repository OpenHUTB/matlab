function val=getparam(this,blockPath,paramName)























    [blockPath,paramName]=slrealtime.internal.ParameterTuning.checkAndFormatArgs(blockPath,paramName);

    if~this.isConnected()
        this.connect();
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end

        try
            paramtune=slrealtime.internal.ParameterTuning(this.xcp,this.mldatxCodeDescFolder);
            val=paramtune.getParam(blockPath,paramName);
        catch ME
            if strcmp(ME.identifier,'slrealtime:connectivity:xcpMasterError')




                appName=this.tc.ModelProperties.Application;
                this.throwError('slrealtime:target:appNotResponding',...
                appName,this.TargetSettings.name);
            else
                rethrow(ME);
            end
        end

    catch ME
        this.throwError('slrealtime:target:getparamError',...
        paramName,this.TargetSettings.name,ME.message);
    end
end
