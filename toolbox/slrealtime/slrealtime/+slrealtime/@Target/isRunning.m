function[running,runningAppName]=isRunning(this,appName)

















    running=false;
    runningAppName='';

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

    if startsWith(this.stateChartGetActiveState(),'Status.Connected.Loaded.Running')&&...
        (isempty(appName)||strcmp(appName,this.tc.ModelProperties.Application))
        running=true;
        runningAppName=this.tc.ModelProperties.Application;
    end
end
