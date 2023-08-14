function lnkPercent=linkPercentage(lnks)%#codegen






















































    coder.allowpcode('plain');


    validateattributes(lnks,{'satcom.satellitescenario.Link'},...
    {'nonempty','vector'},'accessPercentage','LINK',1);
    if coder.target('MATLAB')&&sum(~isvalid(lnks))>0
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'LINK');
        error(msg);
    end


    simulator=lnks(1).Simulator;


    numLnk=numel(lnks);


    if coder.target('MATLAB')
        for idx=1:numLnk
            if~isequal(lnks(idx).Simulator,simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end
    end


    simulate(simulator);


    timeHistory=simulator.TimeHistory;
    numSamples=numel(timeHistory);


    lnkPercent=zeros(numLnk,1);


    if isempty(timeHistory)
        return
    end

    for idx1=1:numLnk
        if simulator.SimulationMode==1




            statHistory=lnks(idx1).pStatusHistory;



            coder.internal.errorIf(numSamples~=numel(statHistory),...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'link percentage','link analyses');


            t=NaT;
            if coder.target('MATLAB')
                t.TimeZone='UTC';
            end
            intervals=struct("StartTime",t,"EndTime",t);
            coder.varsize('intervals',[1,Inf],[0,1]);
            intervals(1)=[];
            numIntervals=0;


            for sampleIdx=1:numSamples


                if sampleIdx==1
                    previousStat=false;
                else
                    previousStat=statHistory(sampleIdx-1);
                end


                stat=statHistory(sampleIdx);

                if stat&&~previousStat



                    numIntervals=numIntervals+1;



                    existingIntervals=intervals;
                    newIntervalStruct=struct("StartTime",timeHistory(sampleIdx),...
                    "EndTime",t);
                    intervals=[existingIntervals,newIntervalStruct];
                elseif~stat&&previousStat



                    intervals(numIntervals).EndTime=timeHistory(sampleIdx-1);



                    intervalStartTime=intervals(numIntervals).StartTime;
                    intervalEndTime=intervals(numIntervals).EndTime;
                    if abs(seconds(intervalEndTime-intervalStartTime))<matlabshared.satellitescenario.internal.Simulator.DatetimeComparisonTolerance
                        intervals(numIntervals)=[];
                        numIntervals=numIntervals-1;
                    end
                end

                if(sampleIdx==numSamples)&&(numIntervals>0)&&isnat(intervals(end).EndTime)


                    intervalStartTime=intervals(end).StartTime;
                    intervalEndTime=timeHistory(end);
                    if abs(seconds(intervalEndTime-intervalStartTime))<matlabshared.satellitescenario.internal.Simulator.DatetimeComparisonTolerance
                        intervals(end)=[];
                        numIntervals=numIntervals-1;
                    else

                        intervals(end).EndTime=intervalEndTime;
                    end
                end
            end


            simIdx=getIdxInSimulatorStruct(lnks(idx1));
            simulator.Links(simIdx).NumIntervals=numIntervals;
            simulator.Links(simIdx).Intervals=intervals;
        end


        linkDuration=0;


        for idx2=1:lnks(idx1).pNumIntervals
            startTime=lnks(idx1).pIntervals(idx2).StartTime;
            endTime=lnks(idx1).pIntervals(idx2).EndTime;
            linkDuration=linkDuration+seconds(endTime-startTime);
        end


        analysisDuration=seconds(simulator.TimeHistory(end)-...
        simulator.TimeHistory(1));


        lnkPercent(idx1)=(linkDuration/analysisDuration)*100;
    end
end


