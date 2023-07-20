function intvls=linkIntervals(lnks)%#codegen



































































    coder.allowpcode('plain');


    validateattributes(lnks,{'satcom.satellitescenario.Link'},...
    {'nonempty','vector'},'linkIntervals','LINK',1);
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


    numRows=0;
    for idx=1:numLnk
        if simulator.SimulationMode==1




            statHistory=lnks(idx).pStatusHistory;



            coder.internal.errorIf(numSamples~=numel(statHistory),...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'link intervals','link analyses');


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


            simIdx=getIdxInSimulatorStruct(lnks(idx));
            simulator.Links(simIdx).NumIntervals=numIntervals;
            simulator.Links(simIdx).Intervals=intervals;
        end



        numRows=numRows+lnks(idx).pNumIntervals;
    end


    varNames=...
    {'Source','Target','IntervalNumber','StartTime','EndTime',...
    'Duration','StartOrbit','EndOrbit'};
    if coder.target('MATLAB')
        varTypes={'string','string','double','datetime','datetime',...
        'double','double','double'};
    else
        varTypes={'char','char','double','datetime','datetime',...
        'double','double','double'};
    end
    numCols=8;


    intvls=table('Size',[numRows,numCols],'VariableTypes',varTypes,...
    'VariableNames',varNames);

    if coder.target('MATLAB')

        intvls.StartTime.TimeZone="UTC";
        intvls.EndTime.TimeZone="UTC";
    end


    numRowsAdded=0;
    for idx1=1:numLnk
        lnk=lnks(idx1);
        numIntervals=lnk.pNumIntervals;

        if numIntervals~=0

            source=lnk.Sequence(1);
            target=lnk.Sequence(end);
            intervals=lnk.pIntervals;


            sourceIndex=simulator.SimIDMemo(source);
            switch lnk.NodeType(1)
            case 5
                sourceStruct=simulator.Transmitters(sourceIndex);
                sourceGrandParentType=sourceStruct.GrandParentType;
                sourceGrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
            otherwise
                sourceStruct=simulator.Receivers(sourceIndex);
                sourceGrandParentType=sourceStruct.GrandParentType;
                sourceGrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
            end


            targetIndex=simulator.SimIDMemo(target);
            switch lnk.NodeType(end)
            case 5
                targetStruct=simulator.Transmitters(targetIndex);
                targetGrandParentType=targetStruct.GrandParentType;
                targetGrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
            otherwise
                targetStruct=simulator.Receivers(targetIndex);
                targetGrandParentType=targetStruct.GrandParentType;
                targetGrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
            end


            for idx2=1:numIntervals
                numRowsAdded=numRowsAdded+1;


                intvls.Source{numRowsAdded}=char(lnk.TerminalNames{1});
                intvls.Target{numRowsAdded}=char(lnk.TerminalNames{2});


                intvls.IntervalNumber(numRowsAdded)=idx2;
                startTime=intervals(idx2).StartTime;
                intvls.StartTime(numRowsAdded)=startTime;
                endTime=intervals(idx2).EndTime;
                intvls.EndTime(numRowsAdded)=endTime;
                intvls.Duration(numRowsAdded)=seconds(endTime-startTime);


                if(sourceGrandParentType~=1)&&(targetGrandParentType~=1)


                    startOrbit=NaN;
                    endOrbit=NaN;
                else

                    standardGravitationalParameter=...
                    matlabshared.orbit.internal.OrbitPropagationModel.StandardGravitationalParameter;


                    if sourceGrandParentType==1



                        sourceGrandParentIndex=simulator.SimIDMemo(sourceGrandParentSimulatorID);
                        sourceGrandParent=simulator.Satellites(sourceGrandParentIndex);


                        switch sourceGrandParent.PropagatorType
                        case 1
                            elements=info(sourceGrandParent.PropagatorTBK);
                            if isfield(elements,'SemiMajorAxis')
                                semiMajorAxis=elements.SemiMajorAxis;
                            else
                                semiMajorAxis=10000000;
                            end
                            period=2*pi*sqrt((semiMajorAxis^3)/standardGravitationalParameter);
                        case 2
                            elements=info(sourceGrandParent.PropagatorSGP4);

                            if isfield(elements,'Period')
                                period=elements.Period;
                            else
                                period=7200;
                            end
                        case 3
                            elements=info(sourceGrandParent.PropagatorSDP4);

                            if isfield(elements,'Period')
                                period=elements.Period;
                            else
                                period=7200;
                            end
                        otherwise
                            period=-1;
                        end
                    else


                        targetGrandParentIndex=simulator.SimIDMemo(targetGrandParentSimulatorID);
                        targetGrandParent=simulator.Satellites(targetGrandParentIndex);


                        switch targetGrandParent.PropagatorType
                        case 1
                            elements=info(targetGrandParent.PropagatorTBK);
                            if isfield(elements,'SemiMajorAxis')
                                semiMajorAxis=elements.SemiMajorAxis;
                            else
                                semiMajorAxis=10000000;
                            end
                            period=2*pi*sqrt((semiMajorAxis^3)/standardGravitationalParameter);
                        case 2
                            elements=info(targetGrandParent.PropagatorSGP4);

                            if isfield(elements,'Period')
                                period=elements.Period;
                            else
                                period=7200;
                            end
                        case 3
                            elements=info(targetGrandParent.PropagatorSDP4);

                            if isfield(elements,'Period')
                                period=elements.Period;
                            else
                                period=7200;
                            end
                        otherwise
                            period=-1;
                        end
                    end


                    if period>0

                        if seconds(startTime-simulator.StartTime)==0
                            startOrbit=1;
                        else
                            startOrbit=ceil(seconds(startTime...
                            -simulator.StartTime)/period);
                        end


                        endOrbit=ceil(seconds(endTime...
                        -simulator.StartTime)/period);
                    else


                        startOrbit=nan;
                        endOrbit=nan;
                    end
                end

                intvls.StartOrbit(numRowsAdded)=startOrbit;
                intvls.EndOrbit(numRowsAdded)=endOrbit;
            end
        end
    end
end


