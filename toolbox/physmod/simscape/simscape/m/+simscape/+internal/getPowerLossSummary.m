function lossesTable=getPowerLossSummary(simlog,tStart,tEnd)


















    if~isa(simlog,'simscape.logging.Node')
        pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidSimscapeLoggingNodeSeries')
    end


    if~exist('tStart','var')||~exist('tEnd','var')
        [tStartEnvelope,tEndEnvelope]=simscape.internal.getSimlogStartEndTimes(simlog);
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


    powerLosses=simscape.internal.getSimlogPowerSeries(simlog);


    if~isempty(powerLosses)
        groupedLosses=simscape.internal.gatherPowerSeries(powerLosses);
        powerLossesCell=simscape.internal.averagePowerSeries(groupedLosses,tStart,tEnd,[]);
        for ii=1:size(powerLossesCell,1)
            powerLossesCell{ii,2}=powerLossesCell{ii,2}(3);
        end
    end


    switchingLossesTimeseriesCell=simscape.internal.getSimlogSwitchingLossSeries(simlog);


    if~isempty(switchingLossesTimeseriesCell)
        switchingLossesCell=simscape.internal.calculateSwitchingLossesTimeSeries(switchingLossesTimeseriesCell);
        switchingLossesCell=simscape.internal.gatherSwitchingLosses(switchingLossesCell);
        if isempty(tStart)
            switchingLossesCell=simscape.internal.averageSwitchingLosses(switchingLossesCell,tStartEnvelope,tEndEnvelope);
        elseif isempty(tEnd)
            switchingLossesCell=simscape.internal.averageSwitchingLosses(switchingLossesCell,tStart,tEndEnvelope);
        else
            switchingLossesCell=simscape.internal.averageSwitchingLosses(switchingLossesCell,tStart,tEnd);
        end
    end


    if~isempty(powerLosses)
        if isempty(switchingLossesTimeseriesCell)
            lossesTable=cell2table(powerLossesCell,'VariableNames',{'LoggingNode','Power'});
            lossesTable=sortrows(lossesTable,2,'descend');
        else
            powerLossesTable=cell2table(powerLossesCell,'VariableNames',{'LoggingNode','Power'});
            switchingLossesTable=cell2table(switchingLossesCell,'VariableNames',{'LoggingNode','SwitchingLosses'});

            lossesTable=outerjoin(powerLossesTable,switchingLossesTable,'MergeKeys',true);

            lossesTable{:,2}(isnan(lossesTable{:,2}))=0;
            lossesTable{:,3}(isnan(lossesTable{:,3}))=0;
            lossesTable=sortrows(lossesTable,2,'descend');

        end
    else
        if~isempty(switchingLossesTimeseriesCell)
            lossesTable=cell2table(switchingLossesCell,'VariableNames',{'LoggingNode','SwitchingLosses'});
            lossesTable=sortrows(lossesTable,2,'descend');
        else
            lossesTable={};
        end
    end



end