classdef(Abstract)Target<handle






    properties(Access=protected)
tc
tcTimer
        connected=false
    end

    properties(Access=public)
TargetSettings
    end

    properties(Access=public,Hidden)
Mapping
    end

    events
Connecting
ConnectFailed
Connected
PostConnected

Disconnecting
Disconnected
PostDisconnected

Installing
InstallFailed
Installed

Loading
LoadFailed
Loaded
PostLoaded

Starting
StartFailed
Started
PostStarted

Stopping
StopFailed
Stopped
PostStopped

Rebooting
RebootFailed
RebootIssued

UpdateBegin
UpdateMessage
UpdateFailed
UpdateCompleted

SetIPAddressBegin
SetIPAddressFailed
SetIPAddressCompleted

StartupAppChanged
StopTimeChanged
ParamChanged
    end

    methods(Access=public)



        function val=isConnected(this)
            val=this.connected;
        end
    end

    methods(Abstract,Access=public)



        targetHandle=connect(obj)
        disconnect(obj)




        start(this,varargin)
        stop(this)
        [running,runningAppName]=isRunning(this,appName)




        setStopTime(this,stopTime)




        load(this,modelName,varargin)
        [loaded,loadedAppName]=isLoaded(this,appName)
    end




    methods(Access=public,Hidden)
        function out=get(this,prop)
            out=this.(prop);
        end
    end
end
