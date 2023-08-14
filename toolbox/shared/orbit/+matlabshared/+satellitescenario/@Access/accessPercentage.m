function acPercent=accessPercentage(ac)%#codegen


















































    coder.allowpcode('plain');


    validateattributes(ac,{'matlabshared.satellitescenario.Access'},...
    {'nonempty','vector'},'accessPercentage','AC',1);
    if coder.target('MATLAB')&&sum(~isvalid(ac))>0
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'AC');
        error(msg);
    end


    simulator=ac(1).Simulator;


    numAc=numel(ac);

    if coder.target('MATLAB')

        for idx=1:numAc
            if~isequal(ac(idx).Simulator,simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end
    end


    simulate(simulator);


    timeHistory=simulator.TimeHistory;
    numSamples=numel(timeHistory);


    acPercent=zeros(numAc,1);


    if isempty(timeHistory)
        return
    end

    for idx1=1:numAc
        if simulator.SimulationMode==1




            statHistory=ac(idx1).pStatusHistory;



            coder.internal.errorIf(numSamples~=numel(statHistory),...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'access percentage','access analyses');


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



            simIdx=getIdxInSimulatorStruct(ac(idx1));
            simulator.Accesses(simIdx).NumIntervals=numIntervals;
            simulator.Accesses(simIdx).Intervals=intervals;
        end


        accessDuration=0;


        for idx2=1:ac(idx1).pNumIntervals
            startTime=ac(idx1).pIntervals(idx2).StartTime;
            endTime=ac(idx1).pIntervals(idx2).EndTime;
            accessDuration=accessDuration+seconds(endTime-startTime);
        end


        analysisDuration=seconds(simulator.TimeHistory(end)-...
        simulator.TimeHistory(1));


        acPercent(idx1)=(accessDuration/analysisDuration)*100;
    end
end


