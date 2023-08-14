function[powerLossesCell,switchingLossesCell]=getPowerLossTimeSeries(simlog,tStart,tEnd,tInterval)























    if~isa(simlog,'simscape.logging.Node')
        pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidSimscapeLoggingNodeSeries')
    end


    if~exist('tStart','var')
        tStart=[];
    else
        validateattributes(tStart,{'numeric'},{'scalar'},mfilename,'tStart',2);
        if~isfloat(tStart)
            tStart=double(tStart);
        end
    end
    if~exist('tEnd','var')
        tEnd=[];
    else
        validateattributes(tEnd,{'numeric'},{'scalar'},mfilename,'tEnd',3);
        if~isfloat(tEnd)
            tEnd=double(tEnd);
        end
    end
    if~exist('tInterval','var')
        tInterval=0;
    else
        validateattributes(tInterval,{'numeric'},{'scalar'},mfilename,'tInterval',4);
        if~isfloat(tInterval)
            tInterval=double(tInterval);
        end
    end
    if tInterval<0
        pm_error('physmod:simscape:compiler:patterns:checks:GreaterThanOrEqualZero',getString(message('physmod:simscape:simscape:internal:powerDissipated:IntervalTime')));
    end


    powerLosses=simscape.internal.getSimlogPowerSeries(simlog);


    if~isempty(powerLosses)
        groupedLosses=simscape.internal.gatherPowerSeries(powerLosses);
        powerLossesCell=simscape.internal.averagePowerSeries(groupedLosses,tStart,tEnd,tInterval);
    else
        powerLossesCell={};
    end


    switchingLossesTimeseriesCell=simscape.internal.getSimlogSwitchingLossSeries(simlog);


    if~isempty(switchingLossesTimeseriesCell)
        switchingLossesCell=simscape.internal.calculateSwitchingLossesTimeSeries(switchingLossesTimeseriesCell);
        switchingLossesCell=simscape.internal.gatherSwitchingLosses(switchingLossesCell);
    else
        switchingLossesCell={};
    end

end
