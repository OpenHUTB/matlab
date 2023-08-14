classdef Access<handle&matlabshared.satellitescenario.internal.ScenarioGraphicBase %#codegen




    properties(SetAccess={?matlabshared.satellitescenario.Access,?matlabshared.satellitescenario.coder.Access})




Sequence
    end

    properties(Access={?satelliteScenario,?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG})
AccessGraphic

Simulator
        SimulatorID=0
        Parent=0
        SequenceHandle=0

NodeType
TerminalNames
    end

    properties(Dependent)



        LineWidth(1,1)double{mustBeGreaterThanOrEqual(LineWidth,1),mustBeLessThanOrEqual(LineWidth,10)}




        LineColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Access})
        pLineWidth=3
        pLineColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.AccessLineColor
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.Access,?matlabshared.satellitescenario.coder.Access})
pStatus
pStatusHistory
pIntervals
pNumIntervals
    end

    methods
        function lineWidth=get.LineWidth(ac)
            lineWidth=ac.pLineWidth;
        end

        function lineColor=get.LineColor(ac)
            lineColor=ac.pLineColor;
        end

        function set.LineWidth(ac,lineWidth)
            ac.pLineWidth=lineWidth;
            if isa(ac.Scenario,'satelliteScenario')
                updateViewers(ac,ac.Scenario.Viewers,false,true);
            end
        end

        function set.LineColor(ac,lineColor)
            ac.pLineColor=lineColor;
            if isa(ac.Scenario,'satelliteScenario')
                updateViewers(ac,ac.Scenario.Viewers,false,true);
            end
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function ac=Access(varargin)


            coder.allowpcode('plain');






            if nargin~=0

                source=varargin{1};


                nodes={varargin{2:end}};


                simulator=source(1).Simulator;


                sequence=zeros(1,1+numel(nodes));
                nodeType=zeros(1,1+numel(nodes));
                sequence(1)=source.ID;
                nodeType(1)=source.Type;
                for idx=1:numel(nodes)
                    sequence(idx+1)=nodes{idx}.ID;
                    nodeType(idx+1)=nodes{idx}.Type;
                end



                simID=addAccess(simulator,sequence,nodeType);


                ac.Sequence=sequence;
                ac.NodeType=nodeType;
                ac.Simulator=simulator;
                ac.SimulatorID=simID;
                ac.TerminalNames={source.Name,nodes{end}.Name};

                if coder.target('MATLAB')





                    ac.ZoomHeight=-1;


                    scenario=source.Scenario;


                    ac.Scenario=scenario;


                    ac.Parent=source;


                    ac.SequenceHandle=nodes;



                    ac.AccessGraphic=cell(1,numel(sequence)-1);
                    for idx=1:numel(sequence)-1
                        ac.AccessGraphic{idx}="Access"+simID+"segment"+idx;
                    end
                end
            end
        end
    end

    methods
        function delete(ac)


            coder.allowpcode('plain');

            if coder.target('MATLAB')




                scenario=ac.Scenario;



                if isa(scenario,'satelliteScenario')&&isvalid(scenario)

                    simulator=scenario.Simulator;



                    if isvalid(simulator)
                        simIndex=getIdxInSimulatorStruct(ac);
                        simulator.Accesses(simIndex)=[];
                        simulator.NumAccesses=simulator.NumAccesses-1;
                        simulator.NeedToMemoizeSimID=true;
                    end

                    acWrapper=matlabshared.satellitescenario.Access;
                    acWrapper.Handles={ac};
                    removeFromScenarioGraphics(scenario,ac);
                    removeFromAccesses(scenario,acWrapper);
                end



                parent=ac.Parent;
                if(isa(parent,'matlabshared.satellitescenario.internal.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.internal.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.internal.ConicalSensor')||...
                    isa(parent,'matlabshared.satellitescenario.Satellite')||...
                    isa(parent,'matlabshared.satellitescenario.GroundStation')||...
                    isa(parent,'matlabshared.satellitescenario.ConicalSensor'))&&...
                    ~isempty(parent.Accesses)


                    acIndex=find([parent.Accesses.SimulatorID]==...
                    ac.SimulatorID,1);

                    if~isempty(acIndex)


                        parent.Accesses(acIndex)=[];
                    end
                end
                removeGraphic(ac);
            end
        end

        function s=get.pStatus(ac)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(ac);


            s=ac.Simulator.Accesses(idx).Status;
        end

        function s=get.pStatusHistory(ac)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(ac);


            s=ac.Simulator.Accesses(idx).StatusHistory;
        end

        function intvls=get.pIntervals(ac)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(ac);


            intvls=ac.Simulator.Accesses(idx).Intervals;
        end

        function numIntvls=get.pNumIntervals(ac)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(ac);


            numIntvls=ac.Simulator.Accesses(idx).NumIntervals;
        end
    end

    methods(Access={?matlabshared.satellitescebario.Access,...
        ?matlabshared.satellitescenario.coder.Access})
        function idx=getIdxInSimulatorStruct(ac)



            coder.allowpcode('plain');


            simulator=ac.Simulator;


            simID=ac.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end
    end

    methods(Hidden)
        updateVisualizations(ac,viewer)

        function ID=getGraphicID(ac)
            ID=ac.AccessGraphic{1};
        end

        function IDs=getChildGraphicsIDs(ac)
            numAccessGraphic=numel(ac.AccessGraphic);
            if numAccessGraphic>1
                IDs=strings(1,numAccessGraphic-1);
                for idx=2:numAccessGraphic
                    IDs(idx-1)=ac.AccessGraphic{idx};
                end
            else
                IDs=[];
            end
        end

        function addCZMLGraphic(ac,writer,~,initiallyVisible)



            simulator=ac.Simulator;

            if simulator.SimulationMode==1





                t=NaT;
                t.TimeZone='UTC';
                intervals=struct("StartTime",t,"EndTime",t);
                intervals(1)=[];
                numIntervals=0;


                statHistory=ac.pStatusHistory;
                numSamples=numel(statHistory);
                timeHistory=simulator.TimeHistory;


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



                simIdx=getIdxInSimulatorStruct(ac);
                simulator.Accesses(simIdx).NumIntervals=numIntervals;
                simulator.Accesses(simIdx).Intervals=intervals;
            end


            numIntervals=ac.pNumIntervals;


            if numIntervals==0
                return;
            else
                intervals=NaT(numIntervals,2);
                for idx2=1:numIntervals
                    startTime=ac.pIntervals(idx2).StartTime;
                    startTime.TimeZone="";
                    endTime=ac.pIntervals(idx2).EndTime;
                    endTime.TimeZone="";

                    intervals(idx2,1)=startTime;
                    intervals(idx2,2)=endTime;
                end
            end


            lineWidth=ac.LineWidth;
            lineColor=[ac.LineColor,1];


            sequence=[{ac.Parent},ac.SequenceHandle];


            timeHistory=ac.Simulator.TimeHistory;

            for idx2=1:numel(sequence)-1

                sourcePosition=sequence{idx2}.pPositionHistory;
                targetPosition=sequence{idx2+1}.pPositionHistory;

                positions=zeros(2,3,numel(timeHistory));
                for idx3=1:numel(timeHistory)
                    positions(1,:,idx3)=sourcePosition(:,idx3)';
                    positions(2,:,idx3)=targetPosition(:,idx3)';
                end

                name="Access"+ac.SimulatorID+"segment"+idx2;

                addLineWithIntervals(writer,name,positions,...
                timeHistory,intervals,...
                'Width',lineWidth,...
                'Color',lineColor,...
                'Interpolation','lagrange',...
                'InterpolationDegree',5,...
                'CoordinateDefinition','cartesian',...
                'ReferenceFrame','inertial',...
                'Dashed',true,...
                'DashLength',8,...
                'InitiallyVisible',initiallyVisible);
            end
        end
    end
end

