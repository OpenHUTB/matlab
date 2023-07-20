function setStopTime(this,stopTime)












    validateattributes(stopTime,{'numeric'},{'nonnegative','scalar'})

    if~this.isConnected()
        this.connect;
    end

    try
        if~this.isLoaded()
            this.throwError('slrealtime:target:setStopTimeFailNoAppLoaded');
        end

        this.tc.setStopTime(stopTime);
        notify(this,'StopTimeChanged',slrealtime.events.TargetStopTimeData(stopTime));

    catch ME
        this.throwError('slrealtime:target:setStopTimeError',this.TargetSettings.name,ME.message);
    end
end
