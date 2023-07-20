classdef FieldOfView<handle&matlabshared.satellitescenario.ScenarioGraphic %#codegen




    properties(Constant,Hidden)
        FieldOfViewTol=optimset('TolX',1e-6)
    end

    properties(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.ConicalSensor,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
FieldOfViewGraphic
Parent
    end

    properties(Dependent)



        LineWidth(1,1)double{mustBeGreaterThanOrEqual(LineWidth,1),mustBeLessThanOrEqual(LineWidth,10)}




        LineColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
    end

    properties
















        VisibilityMode{mustBeMember(VisibilityMode,{'inherit','manual'})}='inherit'
    end

    properties(Hidden,Dependent,SetAccess=private)
Contour
ContourHistory
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic})
        pNumContourPoints=40
        pLineWidth(1,1)double{mustBeGreaterThanOrEqual(pLineWidth,1),mustBeLessThanOrEqual(pLineWidth,10)}=1
        pLineColor=matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.FieldOfViewColor
    end

    properties(Access=private)
SimulatorID
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.Viewer})
ContourAvailabilityStatus
ContourAvailabilityIntervals
NumContourAvailabilityIntervals
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.ConicalSensor})
NumContourPoints
    end

    methods(Access={?matlabshared.satellitescenario.ConicalSensor})
        function fov=FieldOfView(parent,scenario,varargin)



            fov.Parent=parent;
            fov.Scenario=scenario;



            fov.SimulatorID=...
            addFieldOfView(scenario.Simulator,parent.SimulatorID);

            parseShowInputs(fov,varargin{:});

            fov.FieldOfViewGraphic="conicalSensor"+parent.ID+"fov";
        end
    end

    methods(Hidden)
        updateVisualizations(fov,viewer)

        function ID=getGraphicID(fov)
            ID=fov.FieldOfViewGraphic;
        end

        function IDs=getChildGraphicsIDs(fov)




            IDs=strings(1,fov.NumContourAvailabilityIntervals);
            for k=1:fov.NumContourAvailabilityIntervals
                IDs(k)=fov.getGraphicID+"Interval"+k;
            end
        end

        function addCZMLGraphic(fov,writer,timeHistory,initiallyVisible)



            simulator=fov.Scenario.Simulator;




            if simulator.SimulationMode==1


                t=NaT;
                t.TimeZone='UTC';
                intervals=struct("StartTime",t,"EndTime",t);
                coder.varsize('intervals',[1,Inf],[0,1]);
                intervals(1)=[];
                numIntervals=0;


                simIdx=getIdxInSimulatorStruct(fov);
                statHistory=simulator.FieldsOfView(simIdx).StatusHistory;
                numSamples=numel(statHistory);


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
            else


                intervals=fov.ContourAvailabilityIntervals;
                numIntervals=fov.NumContourAvailabilityIntervals;
            end

            for k=1:numIntervals


                startTime=datetime(...
                intervals(k).StartTime,...
                "TimeZone","");
                endTime=datetime(...
                intervals(k).EndTime,...
                "TimeZone","");



                times=...
                timeHistory(and(timeHistory>=startTime,timeHistory<=endTime));


                contours=fov.ContourHistory(...
                :,:,and(timeHistory>=startTime,timeHistory<=endTime));


                name=fov.getGraphicID+"Interval"+k;


                addPolyline(writer,name,contours,times,...
                'Width',fov.LineWidth,...
                'CoordinateDefinition','cartesian',...
                'ReferenceFrame','fixed',...
                'Color',[fov.LineColor,1],...
                'Interpolation','lagrange',...
                'InterpolationDegree',1,...
                'ID',name,...
                'InitiallyVisible',initiallyVisible);
            end
        end

        function addGraphicToClutterMap(fov,viewer)
            parent=fov.Parent;
            while isprop(parent,'Parent')
                parent=parent.Parent;
            end
            addGraphicToClutterMap(parent,viewer);
            if~isfield(viewer.DeclutterMap.(parent.getGraphicID),fov.getGraphicID)
                viewer.DeclutterMap.(parent.getGraphicID).(fov.getGraphicID)=fov;
            end
        end
    end

    methods
        function contourLineWidth=get.LineWidth(fov)
            contourLineWidth=fov.pLineWidth;
        end

        function contourLineColor=get.LineColor(fov)
            contourLineColor=fov.pLineColor;
        end

        function set.LineWidth(fov,contourLineWidth)
            fov.pLineWidth=contourLineWidth;
            if isa(fov.Scenario,'satelliteScenario')
                updateViewers(fov,fov.Scenario.Viewers,false,true);
            end
        end

        function set.LineColor(fov,contourLineColor)
            fov.pLineColor=contourLineColor;
            if isa(fov.Scenario,'satelliteScenario')
                updateViewers(fov,fov.Scenario.Viewers,false,true);
            end
        end
    end

    methods(Static,Hidden)
        [contoursHistory,statusHistory,intervals,numIntervals]=getContour(positionHistory,...
        latitudeHistory,longitudeHistory,altitudeHistory,attitudeHistory,...
        maxViewAngle,itrf2gcrfTransforms,numContourPoints,timeHistoryArray,...
        numSamples)

        [contoursHistory,statusHistory,intervals,numIntervals]=cg_getContour(positionHistory,...
        latitudeHistory,longitudeHistory,altitudeHistory,attitudeHistory,...
        maxViewAngle,itrf2gcrfTransforms,numContourPoints,timeHistoryArray,...
        numSamples)
    end

    methods
        function intvls=get.ContourAvailabilityIntervals(fov)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            intvls=simulator.FieldsOfView(idx).Intervals;
        end

        function intvls=get.NumContourAvailabilityIntervals(fov)




            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            intvls=simulator.FieldsOfView(idx).NumIntervals;
        end

        function status=get.ContourAvailabilityStatus(fov)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            status=simulator.FieldsOfView(idx).Status;
        end

        function c=get.Contour(fov)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            c=simulator.FieldsOfView(idx).Contour;
        end

        function c=get.ContourHistory(fov)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            c=simulator.FieldsOfView(idx).ContourHistory;
        end

        function n=get.NumContourPoints(fov)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            n=simulator.FieldsOfView(idx).NumContourPoints;
        end

        function set.NumContourPoints(fov,n)



            simulator=fov.Scenario.Simulator;



            idx=getIdxInSimulatorStruct(fov);


            simulator.FieldsOfView(idx).NumContourPoints=n;
        end
    end

    methods(Access=private)
        function idx=getIdxInSimulatorStruct(fov)





            simulator=fov.Scenario.Simulator;


            simID=fov.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end
    end

    methods(Access=?matlabshared.satellitescenario.ConicalSensor)
        function parseShowInputs(fov,varargin)
            paramNames={'NumContourPoints','LineWidth','LineColor'};
            pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
            if pstruct.NumContourPoints~=0
                numContourPoints=coder.internal.getParameterValue(pstruct.NumContourPoints,fov.NumContourPoints,varargin{:});
            else
                numContourPoints=coder.internal.getParameterValue(pstruct.NumContourPoints,fov.pNumContourPoints,varargin{:});
            end
            lineWidth=coder.internal.getParameterValue(pstruct.LineWidth,fov.LineWidth,varargin{:});
            lineColor=coder.internal.getParameterValue(pstruct.LineColor,fov.LineColor,varargin{:});
            lineColor=convertColor(fov,lineColor,'LineColor','FieldOfView');



            if(pstruct.NumContourPoints>0&&~isequal(fov.pNumContourPoints,numContourPoints))||...
                (pstruct.LineWidth>0&&~isequal(fov.pLineWidth,lineWidth))||...
                (pstruct.LineColor>0&&~isequal(fov.pLineColor,lineColor))
                fov.Scenario.NeedToSimulate=true;
                fov.Scenario.Simulator.NeedToSimulate=true;
            end




            fov.pNumContourPoints=numContourPoints;
            fov.pLineWidth=lineWidth;
            fov.pLineColor=lineColor;
        end
    end

    methods(Access={?matlabshared.satellitescenario.ConicalSensor,...
        ?matlabshared.satellitescenario.internal.ConicalSensor})
        function delete(fov)

            removeGraphic(fov);
            scenario=fov.Scenario;
            if isa(scenario,'satelliteScenario')
                simulator=scenario.Simulator;
                simIndex=getIdxInSimulatorStruct(fov);
                simulator.FieldsOfView(simIndex)=[];
                simulator.NumFieldsOfView=simulator.NumFieldsOfView-1;
                simulator.NeedToMemoizeSimID=true;
            end

            if(isa(fov.Scenario,'satelliteScenario'))
                removeFromScenarioGraphics(fov.Scenario,fov);
            end
        end
    end
end
