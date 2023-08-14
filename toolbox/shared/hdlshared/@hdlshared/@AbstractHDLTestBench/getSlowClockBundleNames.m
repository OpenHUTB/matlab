function[slowClock,slowReset,slowEnable]=getSlowClockBundleNames(this)



    slowClock=this.ClockName;
    slowReset=this.ResetName;
    slowEnable=this.ClockEnableName;
    slowestRatio=1;

    for ii=1:length(this.clockTable)
        if this.clockTable(ii).Ratio>=slowestRatio
            slowestRatio=this.clockTable(ii).Ratio;
            if this.clockTable(ii).Kind==0
                slowClock=this.clockTable(ii).Name;
            elseif this.clockTable(ii).Kind==1
                slowReset=this.clockTable(ii).Name;
            elseif this.clockTable(ii).Kind==2
                slowEnable=this.clockTable(ii).Name;
            end
        end
    end
