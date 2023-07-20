function[loaded,loadedAppName]=isLoaded(this,appName)

















    loaded=false;
    loadedAppName='';

    if~this.isConnected()
        this.throwError('slrealtime:target:notConnectedError',this.TargetSettings.name,mfilename);
    end

    narginchk(1,2);
    if nargin<2
        appName=[];
    elseif~isempty(appName)
        validateattributes(appName,{'char','string'},{'scalartext'});
        appName=convertStringsToChars(appName);
    end

    [running,runningAppName]=this.isRunning(appName);
    if running
        loaded=running;
        loadedAppName=runningAppName;
    else
        if startsWith(this.stateChartGetActiveState(),'Status.Connected.Loaded')&&...
            (isempty(appName)||strcmp(appName,this.tc.ModelProperties.Application))
            loaded=true;
            loadedAppName=this.tc.ModelProperties.Application;
        end
    end
end
