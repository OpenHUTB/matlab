classdef Link<handle&matlabshared.satellitescenario.internal.ScenarioGraphicBase %#codegen




    properties(SetAccess={?satcom.satellitescenario.Link,?satcom.satellitescnario.coder.Link})


Sequence
    end

    properties(Access={?satelliteScenario,?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satcom.satellitescenario.Link,?satcom.satellitescenario.coder.Link,...
        ?satcom.satellitescenario.Transmitter})
LinkGraphic

Simulator
SimulatorID
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
        ?satcom.satellitescenario.Link})
        pLineWidth=2
        pLineColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.LinkLineColor
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.Viewer,...
        ?satcom.satellitescenario.Link,?satcom.satellitescenario.coder.Link})
pStatus
pStatusHistory
pIntervals
pNumIntervals
pEbNo
pEbNoHistory
pReceivedIsotropicPower
pReceivedIsotropicPowerHistory
pPowerAtReceiverInput
pPowerAtReceiverInputHistory
    end

    methods
        function delete(lnk)


            coder.allowpcode('plain');

            if isempty(coder.target)




                scenario=lnk.Scenario;



                if isa(scenario,'satelliteScenario')&&isvalid(scenario)

                    simulator=scenario.Simulator;



                    simIndex=getIdxInSimulatorStruct(lnk);
                    simulator.Links(simIndex)=[];
                    simulator.NumLinks=simulator.NumLinks-1;
                    simulator.NeedToMemoizeSimID=true;

                    lnkWrapper=satcom.satellitescenario.Link;
                    lnkWrapper.Handles={lnk};
                    removeFromScenarioGraphics(scenario,lnk);
                    removeFromLinks(scenario,lnkWrapper);
                end



                parent=lnk.Parent;
                if(isa(parent,'satcom.satellitescenario.internal.Transmitter')||...
                    isa(parent,'satcom.satellitescenario.Transmitter'))&&...
                    ~isempty(parent.Links)


                    lnkIndex=find([parent.Links.SimulatorID]==...
                    lnk.SimulatorID,1);

                    if~isempty(lnkIndex)


                        parent.Links(lnkIndex)=[];
                    end
                end
                removeGraphic(lnk);
            end
        end

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
        function lnk=Link(varargin)


            coder.allowpcode('plain');

            lnk.Sequence=zeros(1,2);
            lnk.Sequence=zeros(1,0);
            lnk.NodeType=zeros(1,2);
            lnk.NodeType=zeros(1,0);






            if nargin>1

                source=varargin{1};


                nodes={varargin{2:end}};


                simulator=source.Simulator;


                sequence=zeros(1,1+numel(nodes));
                nodeType=zeros(1,1+numel(nodes));
                sequence(1)=source.ID;
                nodeType(1)=source.Type;
                for idx=1:numel(nodes)
                    sequence(idx+1)=nodes{idx}.ID;
                    nodeType(idx+1)=nodes{idx}.Type;
                end



                simID=addLink(simulator,sequence,nodeType);


                lnk.Sequence=sequence;
                lnk.NodeType=nodeType;
                lnk.Simulator=simulator;
                lnk.SimulatorID=simID;
                lnk.TerminalNames={source.Name,nodes{end}.Name};

                if isempty(coder.target)




                    lnk.ZoomHeight=-1;


                    scenario=source.Scenario;


                    lnk.Scenario=scenario;


                    lnk.Parent=source;


                    lnk.SequenceHandle=nodes;



                    lnk.LinkGraphic=cell(1,numel(sequence)-1);
                    for idx=1:numel(sequence)-1
                        lnk.LinkGraphic{idx}="Link"+simID+"segment"+idx;
                    end
                end
            end
        end
    end

    methods
        function s=get.pStatus(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            s=lnk.Simulator.Links(idx).Status;
        end

        function s=get.pStatusHistory(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            s=lnk.Simulator.Links(idx).StatusHistory;
        end

        function intvls=get.pIntervals(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            intvls=lnk.Simulator.Links(idx).Intervals;
        end

        function numIntvls=get.pNumIntervals(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            numIntvls=lnk.Simulator.Links(idx).NumIntervals;
        end

        function e=get.pEbNo(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).EbNo;
        end

        function e=get.pEbNoHistory(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).EbNoHistory;
        end

        function e=get.pReceivedIsotropicPower(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).ReceivedIsotropicPower;
        end

        function e=get.pReceivedIsotropicPowerHistory(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).ReceivedIsotropicPowerHistory;
        end

        function e=get.pPowerAtReceiverInput(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).PowerAtReceiverInput;
        end

        function e=get.pPowerAtReceiverInputHistory(lnk)


            coder.allowpcode('plain');



            idx=getIdxInSimulatorStruct(lnk);


            e=lnk.Simulator.Links(idx).PowerAtReceiverInputHistory;
        end
    end

    methods(Access={?satcom.satellitescenario.Link,?satcom.satellitescenario.coder.Link})
        function idx=getIdxInSimulatorStruct(lnk)



            coder.allowpcode('plain');


            simulator=lnk.Simulator;


            simID=lnk.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end
    end

    methods(Hidden)
        updateVisualizations(lnks,viewer)
    end

    methods(Hidden)
        function ID=getGraphicID(lnk)
            ID=lnk.LinkGraphic{1};
        end

        function IDs=getChildGraphicsIDs(lnk)
            numLinkGraphic=numel(lnk.LinkGraphic);
            if numLinkGraphic>1
                IDs=strings(1,numLinkGraphic-1);
                for idx=2:numLinkGraphic
                    IDs(idx-1)=lnk.LinkGraphic{idx};
                end
            else
                IDs=[];
            end
        end

        function addCZMLGraphic(lnk,writer,~,initiallyVisible)



            simulator=lnk.Simulator;

            if simulator.SimulationMode==1





                t=NaT;
                t.TimeZone='UTC';
                intervals=struct("StartTime",t,"EndTime",t);
                intervals(1)=[];
                numIntervals=0;


                statHistory=lnk.pStatusHistory;
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



                simIdx=getIdxInSimulatorStruct(lnk);
                simulator.Links(simIdx).NumIntervals=numIntervals;
                simulator.Links(simIdx).Intervals=intervals;
            end


            numIntervals=lnk.pNumIntervals;


            if numIntervals==0
                return;
            else
                intervals=NaT(numIntervals,2);
                for idx2=1:numIntervals
                    startTime=lnk.pIntervals(idx2).StartTime;
                    startTime.TimeZone="";
                    endTime=lnk.pIntervals(idx2).EndTime;
                    endTime.TimeZone="";

                    intervals(idx2,1)=startTime;
                    intervals(idx2,2)=endTime;
                end
            end


            lineWidth=lnk.LineWidth;
            lineColor=[lnk.LineColor,1];


            sequence=[{lnk.Parent},lnk.SequenceHandle];


            timeHistory=lnk.Simulator.TimeHistory;

            for idx2=1:numel(sequence)-1

                sourcePosition=sequence{idx2}.pPositionHistory;
                targetPosition=sequence{idx2+1}.pPositionHistory;

                positions=zeros(2,3,numel(timeHistory));
                for idx3=1:numel(timeHistory)
                    positions(1,:,idx3)=sourcePosition(:,idx3)';
                    positions(2,:,idx3)=targetPosition(:,idx3)';
                end

                name="Link"+lnk.SimulatorID+"segment"+idx2;

                addLineWithIntervals(writer,name,positions,...
                timeHistory,intervals,...
                'Width',lineWidth,...
                'Color',lineColor,...
                'Interpolation','lagrange',...
                'InterpolationDegree',5,...
                'CoordinateDefinition','cartesian',...
                'ReferenceFrame','inertial',...
                'Dashed',false,...
                'InitiallyVisible',initiallyVisible);
            end
        end
    end
end

