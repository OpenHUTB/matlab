classdef BirdsEyePlot<matlabshared.application.Component&...
    driving.internal.scenarioApp.Zoom&...
    driving.internal.scenarioApp.FillAxes&...
    matlabshared.application.ComponentBanner&...
    driving.internal.scenarioApp.UITools&...
    matlabshared.application.AxesTooltip




    properties
        ShowRoadBoundaries=true;
        ShowLaneDetections=true;
        ShowLaneMarkings=true;
        ShowCoverageAreas=true;
        ShowActorOutlines=true;
        ShowObjectDetections=true;
        ShowPointCloud=true;
        ShowTooltip=false;
        ShowActorMeshes=false;
        RoadBoundaryColor=[0,0,0];
        OutlineFaceAlpha=.25;
        Center=[16,0]
        UnitsPerPixel=0.12
    end

    properties(Dependent)
        ShowLegend;
    end

    properties(Hidden)
        IsCoverageStale=true;
hShowRoadBoundaries
hShowLaneDetections
hShowLaneMarkings
hShowCoverageAreas
hShowActorOutlines
hShowObjectDetections
hShowPointCloud
hShowLegend
hShowTooltip
hShowActorMeshes
        hSettingsButton;
    end

    properties(SetAccess=protected,Hidden)
        Axes;
        Panel;
        RoadBoundaryLine;
        LaneDetectionsLine;
        LaneMarkingsPatch;
        ActorPatches;
        BarrierPatches;
        CoverageAreaPatches;
        DetectionLines;
        VelocityLines;
        Legend;
        PointCloudLines;
        SimulatorListener;
        EgoCarIdListener;
        SensorData;
        SettingsMenu;

        GroundTruthCache;
    end

    methods
        function this=BirdsEyePlot(varargin)
            this@matlabshared.application.Component(varargin{:});
            this.Legend=driving.internal.scenarioApp.BirdsEyePlotLegend(this);
            initializeZoom(this);
            this.SimulatorListener=addSampleChangedListener(this.Application.Simulator,...
            @this.onPlayerSampleChanged);
            this.EgoCarIdListener=addPropertyListener(this.Application,...
            'EgoCarId',@this.onEgoCarIdChanged);
            contribute(this.Application.Toolstrip,this,'DisplayProperties','BirdsEyePlot',...
            {'ShowRoadBoundaries','ShowLaneMarkings','ShowActorOutlines',...
            'ShowLaneDetections','ShowObjectDetections','ShowCoverageAreas','ShowLegend','ShowTooltip','ShowPointCloud','ShowActorMeshes'});
            this.Legend.Visible=true;
        end

        function set.ShowRoadBoundaries(this,newValue)
            this.ShowRoadBoundaries=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowRoadBoundaries',newValue);
            update(this);
        end
        function set.ShowLaneMarkings(this,newValue)
            this.ShowLaneMarkings=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowLaneMarkings',newValue);
            update(this);
        end
        function set.ShowCoverageAreas(this,newValue)
            this.ShowCoverageAreas=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowCoverageAreas',newValue);
            update(this);
        end
        function set.ShowActorOutlines(this,newValue)
            this.ShowActorOutlines=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowActorOutlines',newValue);
            update(this);
        end
        function set.ShowObjectDetections(this,newValue)
            this.ShowObjectDetections=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowObjectDetections',newValue);
            update(this);
        end
        function set.ShowLaneDetections(this,newValue)
            this.ShowLaneDetections=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowLaneDetections',newValue);
            update(this);
        end

        function set.ShowLegend(this,newValue)
            setCheckBoxProperty(this.Application.Toolstrip,'ShowLegend',newValue);
            update(this.Legend);
            this.Legend.Visible=newValue;
            resize(this);
        end

        function vis=get.ShowLegend(this)
            leg=this.Legend;
            vis=~isempty(leg)&&logical(leg.Visible);
        end

        function set.ShowPointCloud(this,newValue)
            this.ShowPointCloud=newValue;
            update(this);
        end

        function set.ShowActorMeshes(this,newValue)
            this.ShowActorMeshes=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowActorMeshes',newValue);
            update(this);
        end

        function data=getSensorDataForExport(this)
            data=this.SensorData;

            indx=1;
            while indx<=numel(data)


                objectDets=data(indx).ObjectDetections;
                if numel(objectDets)==1
                    objectDets=objectDets{1};
                else
                    objectDets=vertcat(objectDets{:});
                end
                laneDets=data(indx).LaneDetections;
                ptClouds=data(indx).PointClouds;

                ptClouds(cellfun(@isempty,ptClouds))=[];
                data(indx).PointClouds=ptClouds;
                insMeas=data(indx).INSMeasurements;

                insMeas(cellfun(@isempty,insMeas))=[];
                data(indx).INSMeasurements=insMeas;

                if isempty(objectDets)&&isempty(laneDets)&&isempty(ptClouds)&&isempty(insMeas)
                    data(indx)=[];
                else
                    data(indx).ObjectDetections=objectDets;
                    indx=indx+1;
                end
            end
        end

        function clear(this)

            set(this.ActorPatches,'Visible','off');
            set(this.BarrierPatches,'Visible','off');
            set([this.RoadBoundaryLine,this.CoverageAreaPatches,this.DetectionLines...
            ,this.VelocityLines,validPointCloudLines(this)],'Visible','off');
        end

        function update(this)
            hDesigner=this.Application;
            scenario=hDesigner.Scenario;
            egoCarId=hDesigner.EgoCarId;
            sensorSpecs=hDesigner.SensorSpecifications;
            hAxes=this.Axes;


            sensorSpecs(~[sensorSpecs.Enabled])=[];
            nSensors=numel(sensorSpecs);

            coveragePatches=this.CoverageAreaPatches;



            if this.IsCoverageStale

                for sensorIndex=1:nSensors
                    sensor=sensorSpecs(sensorIndex);
                    if sensorIndex>numel(coveragePatches)
                        coveragePatches(sensorIndex)=patch(hAxes,...
                        'Tag',sprintf('CoverageAreaPatch%d',sensorIndex));
                    end
                    set(coveragePatches(sensorIndex),...
                    'EdgeColor',sensor.CoverageEdgeColor,...
                    'FaceColor',sensor.CoverageFaceColor,...
                    'FaceAlpha',sensor.CoverageFaceAlpha);

                    generator=sensor.Sensor;
                    yaw=sensor.Yaw;
                    if isa(generator,'lidarPointCloudGenerator')
                        fov=diff(generator.AzimuthLimits);
                        yaw=mean(generator.AzimuthLimits)+yaw;
                    elseif isa(generator,'insSensor')
                        fov=360;
                    else
                        fov=generator.FieldOfView(1);
                    end
                    driving.birdsEyePlot.internal.plotCoverageArea(coveragePatches(sensorIndex),...
                    sensor.SensorLocation,...
                    sensor.MaxRange,...
                    yaw,...
                    fov);
                end
                delete(coveragePatches(nSensors+1:end));
                coveragePatches(nSensors+1:end)=[];
                this.CoverageAreaPatches=coveragePatches;
                update(this.Legend);
            end

            if isempty(egoCarId)
                toHide={'RoadBoundaryLine','ActorPatches','BarrierPatches','LaneDetectionsLine',...
                'LaneMarkingsPatch','DetectionLines','VelocityLines'};
                for indx=1:numel(toHide)
                    set(this.(toHide{indx}),'Visible','off');
                end
                set(validPointCloudLines(this),'Visible','off');
                this.warningMessage(getString(message('driving:scenarioApp:BirdsEyePlotNoEgoCar')),'BirdsEyePlotNoEgoCar');
                return;
            end
            this.removeMessage('BirdsEyePlotNoEgoCar');

            allData=this.SensorData;
            time=getCurrentTime(hDesigner.Simulator);

            dir=driving.scenario.internal.AxesOrientation.getAxesDir(hDesigner.AxesOrientation);
            set(hAxes,'YDir',dir,'ZDir',dir);

            if isempty(allData)



                steppingBack=false;
            else
                sensorTime=allData(end).Time;
                if time>=sensorTime

                    steppingBack=false;
                else

                    while sensorTime>time
                        allData(end)=[];
                        sensorTime=allData(end).Time;
                    end
                    steppingBack=true;
                end
            end



            if isempty(egoCarId)||isempty(scenario.Actors)||egoCarId>numel(scenario.Actors)
                egoCar=[];
            else
                egoCar=scenario.Actors(egoCarId);
            end

            roadLine=this.RoadBoundaryLine;
            laneLine=this.LaneDetectionsLine;
            markingPatch=this.LaneMarkingsPatch;
            actorPatches=this.ActorPatches;
            barrierPatches=this.BarrierPatches;
            haveBarriers=~isempty(scenario.Barriers);


            barrierSegments=[];

            if steppingBack
                sensorTime=inf;
                isValidTime=false;
                allGroundTruth=this.GroundTruthCache;
                while~isValidTime&&sensorTime>time
                    groundTruth=allGroundTruth(end);
                    allGroundTruth(end)=[];
                    sensorTime=groundTruth.Time;
                    isValidTime=time>sensorTime;
                end
                boundaries=groundTruth.LaneBoundaries;
                markingVertices=groundTruth.MarkingVertices;
                markingFaces=groundTruth.MarkingFaces;

                numActors=sum(visibleActors(scenario.Actors));
                p=groundTruth.Position(1:numActors,:);
                y=groundTruth.Yaw(1:numActors);
                l=groundTruth.Length(1:numActors);
                w=groundTruth.Width(1:numActors);
                o=groundTruth.Offset(1:numActors,:);
                c=groundTruth.Color(1:numActors,:);
                if size(groundTruth.Position,1)>numActors&&haveBarriers
                    bp=groundTruth.Position(numActors+1:end,:);
                    by=groundTruth.Yaw(numActors+1:end);
                    bl=groundTruth.Length(numActors+1:end);
                    bw=groundTruth.Width(numActors+1:end);
                    bo=groundTruth.Offset(numActors+1:end,:);
                    bc=groundTruth.Color(numActors+1:end,:);
                    barrierSegments=arrayfun(@(x)numel(x.BarrierSegments),scenario.Barriers);
                end
            else
                if isempty(egoCar)
                    boundaries=roadBoundaries(scenario);
                    [markingVertices,markingFaces]=laneMarkingVertices(scenario);
                    actors=scenario.Actors;
                    if isempty(actors)
                        y=[];
                    else

                        [p,y,l,w,~,c]=targetOutlines(actors(1));
                        o=repmat([0,0],size(p,1),1);

                        if haveBarriers
                            [bp,by,bl,bw,~,bc,barrierSegments]=targetOutlines(actors(1),'Barriers');
                            bo=repmat([0,0],size(bp,1),1);
                        end
                    end
                else
                    [markingVertices,markingFaces]=laneMarkingVertices(egoCar);
                    boundaries=roadBoundaries(egoCar);
                    [p,y,l,w,o,c]=targetOutlines(egoCar);
                    if haveBarriers
                        [bp,by,bl,bw,bo,bc,barrierSegments]=targetOutlines(egoCar,'Barriers');
                    end
                end
                if~isempty(y)
                    if haveBarriers
                        gtc=struct('Time',time,...
                        'LaneBoundaries',{boundaries},...
                        'MarkingVertices',markingVertices,...
                        'MarkingFaces',markingFaces,...
                        'Position',[p;bp],...
                        'Yaw',[y;by],...
                        'Length',[l;bl],...
                        'Width',[w;bw],...
                        'Offset',[o;bo],...
                        'Color',[c;bc]);
                    else
                        gtc=struct('Time',time,...
                        'LaneBoundaries',{boundaries},...
                        'MarkingVertices',markingVertices,...
                        'MarkingFaces',markingFaces,...
                        'Position',p,...
                        'Yaw',y,...
                        'Length',l,...
                        'Width',w,...
                        'Offset',o,...
                        'Color',c);
                    end
                    if isempty(this.GroundTruthCache)
                        this.GroundTruthCache=gtc;
                    else
                        this.GroundTruthCache(end+1)=gtc;
                    end
                end
            end
            driving.birdsEyePlot.internal.drawLaneBoundaries(roadLine,boundaries);

            set(markingPatch,'Vertices',markingVertices,...
            'Faces',markingFaces);

            if~isempty(y)
                if this.ShowActorMeshes


                    if isempty(egoCar)
                        refCar=scenario.Actors(1);
                    else
                        refCar=egoCar;
                    end
                    actorPatches=driving.birdsEyePlot.internal.plotActorMeshes(hAxes,...
                    actorPatches,scenario,refCar,this.OutlineFaceAlpha);
                else
                    actorPatches=driving.birdsEyePlot.internal.plotActorPatches(hAxes,...
                    actorPatches,1,this.OutlineFaceAlpha,p,y,l,w,o,c);
                end
                if haveBarriers

                    barrierPatches=driving.birdsEyePlot.internal.plotBarrierPatches(hAxes,...
                    barrierPatches,1,this.OutlineFaceAlpha,barrierSegments,bp,by,bl,bw,bo,bc);
                end
            end
            delete(actorPatches(numel(y)+1:end));
            actorPatches(numel(y)+1:end)=[];
            this.ActorPatches=actorPatches;

            delete(barrierPatches(numel(barrierSegments)+1:end));
            barrierPatches(numel(barrierSegments)+1:end)=[];
            this.BarrierPatches=barrierPatches;

            detectionLines=this.DetectionLines;
            velocityLines=this.VelocityLines;
            pointCloudLines=this.PointCloudLines;

            maxXLim=hAxes.XLim(2);
            lanes={};
            for sensorIndex=1:nSensors

                sensor=sensorSpecs(sensorIndex);
                isLidar=strcmp(sensor.Type,'lidar');
                isINS=strcmp(sensor.Type,'ins');
                isUltrasonic=strcmp(sensor.Type,'ultrasonic');

                if sensorIndex>numel(detectionLines)
                    detectionLines(sensorIndex)=line(hAxes,...
                    'LineStyle','none');
                    velocityLines(sensorIndex)=line(hAxes);
                end
                set(detectionLines(sensorIndex),...
                'Marker',sensor.DetectionMarker,...
                'MarkerSize',sensor.DetectionMarkerSize,...
                'MarkerEdgeColor',sensor.DetectionMarkerEdgeColor,...
                'MarkerFaceColor',sensor.DetectionMarkerFaceColor);
                set(velocityLines(sensorIndex),'Color',sensor.DetectionMarkerEdgeColor);

                if sensorIndex>numel(pointCloudLines)
                    if isLidar
                        pointCloudLines(sensorIndex)=scatter(hAxes,[],[],'filled');
                    else
                        pointCloudLines(sensorIndex)=-1;
                    end
                end
                isLidarPointCloudLineValid=ishghandle(pointCloudLines(sensorIndex));
                if isLidar
                    if isLidarPointCloudLineValid
                        set(pointCloudLines(sensorIndex),...
                        'Marker','o',...
                        'LineWidth',0.5,...
                        'SizeData',1);
                    else
                        pointCloudLines(sensorIndex)=scatter(hAxes,[],[],'filled');
                    end
                else
                    if isLidarPointCloudLineValid
                        delete(pointCloudLines(sensorIndex));
                    end
                    pointCloudLines(sensorIndex)=-1;
                end

                detections={};
                if~isempty(allData)
                    indx=numel(allData);
                    interval=sensor.UpdateInterval/1000;
                    while indx>0&&abs(allData(indx).Time-time)<=interval&&isempty(detections)
                        if numel(allData(indx).ObjectDetections)>=sensorIndex
                            detections=allData(indx).ObjectDetections{sensorIndex};
                        end
                        indx=indx-1;
                    end
                end
                laneDets=[];
                if~isempty(allData)&&isa(sensor,'driving.internal.scenarioApp.VisionSensorSpecification')&&~strcmp(sensor.DetectionType,'objects')
                    indx=numel(allData);
                    interval=sensor.LaneUpdateInterval/1000;
                    while indx>0&&allData(indx).Time-time<=interval&&(isempty(laneDets)||isempty(laneDets(end).LaneBoundaries))
                        for jndx=1:numel(allData(indx).LaneDetections)
                            if any(~isnan([allData(indx).LaneDetections(jndx).LaneBoundaries.Curvature]))
                                laneDets=[laneDets,allData(indx).LaneDetections(jndx)];%#ok<AGROW>
                            end
                        end
                        indx=indx-1;
                    end
                end

                pointCloud={};
                if isLidar&&~isempty(allData)
                    indx=numel(allData);
                    interval=sensor.UpdateInterval/1000;
                    while indx>0&&abs(allData(indx).Time-time)<=interval&&isempty(pointCloud)
                        if numel(allData(indx).PointClouds)>=sensorIndex
                            pointCloud=allData(indx).PointClouds{sensorIndex};
                        end
                        indx=indx-1;
                    end
                end

                posRotate=[1,0;0,1];

                velRotate=[1,0;0,1];

                if~isINS
                    if strcmp(sensor.DetectionCoordinates,'Sensor spherical')
                        yaw=deg2rad(-sensor.Yaw);
                        posRotate=[cos(yaw),-sin(yaw);sin(yaw),cos(yaw)];
                        velRotate=posRotate;
                        offset=sensor.SensorLocation;
                        if sensor.HasElevation
                            posFcn=@(d)sphericalToCartesian(d.Measurement(1),d.Measurement(2),d.Measurement(3));
                            if sensor.HasRangeRate
                                velFcn=@(d)sphericalToCartesian(d.Measurement(1),d.Measurement(2),d.Measurement(4));
                            else
                                velFcn=@(d)[];
                            end
                        else
                            posFcn=@(d)sphericalToCartesian(d.Measurement(1),0,d.Measurement(2));
                            if sensor.HasRangeRate
                                velFcn=@(d)sphericalToCartesian(d.Measurement(1),0,d.Measurement(3));
                            else
                                velFcn=@(d)[];
                            end
                        end
                    else
                        if isUltrasonic
                            posFcn=@(d)d.ObjectAttributes{1}.PointOnTarget(1:2);
                            velFcn=@(d)[];
                        else
                            posFcn=@(d)d.Measurement(1:2);
                            if strcmp(sensor.Type,'vision')||(~strcmp(sensor.Type,'lidar')&&sensor.HasRangeRate)
                                velFcn=@(d)d.Measurement(4:5);
                            else
                                velFcn=@(d)[];
                            end
                        end
                        if strcmp(sensor.DetectionCoordinates,'Sensor Cartesian')
                            yaw=deg2rad(-sensor.Yaw);
                            posRotate=[cos(yaw),-sin(yaw);sin(yaw),cos(yaw)];
                            offset=sensor.SensorLocation;
                        else
                            offset=0;
                        end
                    end
                end



                if isempty(detections)
                    set(detectionLines(sensorIndex),'XData',[],'YData',[]);
                    set(velocityLines(sensorIndex),'XData',[],'YData',[]);
                else





                    dataPos=cellfun(posFcn,detections,'UniformOutput',false);
                    dataPos=cell2mat(dataPos')';
                    dataPos=dataPos*posRotate;
                    dataPos=dataPos+offset;
                    dataVel=cellfun(velFcn,detections,'UniformOutput',false);
                    dataVel=cell2mat(dataVel')';
                    if~isempty(dataVel)
                        dataVel=dataVel*velRotate;
                    end
                    if isUltrasonic

                        dataPos=getArcForPlottingRange(sensor,detections{1});
                        set(detectionLines(sensorIndex),...
                        'XData',dataPos(:,1),'YData',dataPos(:,2),...
                        'Marker','none','LineWidth',0.5,'LineStyle','--');
                    else
                        set(detectionLines(sensorIndex),...
                        'XData',dataPos(:,1),'YData',dataPos(:,2));
                    end

                    driving.birdsEyePlot.internal.drawVelocities(velocityLines(sensorIndex),...
                    sensor.DetectionVelocityScaling,dataPos,dataVel);
                end
                if isempty(laneDets)
                    set(laneLine,'XData',[],'YData',[]);
                else
                    boundaries=[laneDets.LaneBoundaries];
                    for laneIndex=1:numel(boundaries)
                        xValues=linspace(0,min(maxXLim,boundaries(laneIndex).CurveLength),100)';
                        lanes{end+1}=[xValues,computeBoundaryModel(boundaries(laneIndex),xValues)]*posRotate+offset;%#ok<AGROW>
                    end
                end



                if~isempty(pointCloud)
                    location=pointCloud.Location;
                    lidarDataPos=[];
                    if length(size(location))>2
                        lidarDataPos(:,1)=reshape(location(:,:,1),1,[]);
                        lidarDataPos(:,2)=reshape(location(:,:,2),1,[]);
                    else
                        lidarDataPos=[location(:,1),location(:,2)];
                    end
                    lidarDataPos=lidarDataPos*posRotate;
                    lidarDataPos=lidarDataPos+offset;

                    [distSorted,distIndx]=sort(sum(lidarDataPos.^2,2),1);
                    sortXPos=lidarDataPos(distIndx,1);
                    sortYPos=lidarDataPos(distIndx,2);
                    parulaColors=getParulaColors(distSorted,sensor.MaxRange);
                    set(pointCloudLines(sensorIndex),...
                    'XData',sortXPos,'YData',sortYPos,'CData',parulaColors);
                end
            end
            delete(detectionLines(nSensors+1:end));
            delete(velocityLines(nSensors+1:end));
            ptLinestoDelete=pointCloudLines(nSensors+1:end);
            ptLinestoDelete(ptLinestoDelete==-1)=[];
            delete(ptLinestoDelete);

            this.DetectionLines=detectionLines(1:nSensors);
            this.VelocityLines=velocityLines(1:nSensors);
            this.PointCloudLines=pointCloudLines(1:nSensors);

            driving.birdsEyePlot.internal.drawLaneBoundaries(laneLine,lanes);

            set(markingPatch,'Visible',matlabshared.application.logicalToOnOff(this.ShowLaneMarkings));
            set(roadLine,'Visible',matlabshared.application.logicalToOnOff(this.ShowRoadBoundaries));
            set(laneLine,'Visible',matlabshared.application.logicalToOnOff(this.ShowLaneDetections));
            set(actorPatches,'Visible',matlabshared.application.logicalToOnOff(this.ShowActorOutlines&&~isempty(egoCar)));
            set(barrierPatches,'Visible',matlabshared.application.logicalToOnOff(this.ShowActorOutlines&&~isempty(egoCar)));
            set([this.DetectionLines,this.VelocityLines],'Visible',...
            matlabshared.application.logicalToOnOff(this.ShowObjectDetections&&~isempty(allData)));
            set(coveragePatches,'Visible',...
            matlabshared.application.logicalToOnOff(this.ShowCoverageAreas));
            set(validPointCloudLines(this),'Visible',...
            matlabshared.application.logicalToOnOff(this.ShowPointCloud&&~isempty(allData)));

            drawnow limitrate
        end

        function res=validPointCloudLines(this)
            res=this.PointCloudLines(this.PointCloudLines~=-1);
        end

        function resize(this)
            figpos=getpixelposition(this.Figure);
            if~isempty(this.Banner)
                resize(this.Banner);
            end
            if this.ShowLegend
                update(this.Legend);
                panelPos=[1,1,figpos(3),figpos(4)-getHeight(this.Legend)+2];
            else
                panelPos=[1,1,figpos(3:4)];
            end
            set(this.Panel,'Position',panelPos);
            updateLimits(this);
        end

        function isValidTime=calculateSensorData(this)
            designer=this.Application;
            scenario=designer.Scenario;
            egoId=designer.EgoCarId;
            actors=scenario.Actors;
            nActors=numel(actors);


            if isempty(egoId)||isempty(scenario.Actors)||egoId>nActors
                this.GroundTruthCache=struct('Time',{},...
                'LaneBoundaries',{},...
                'Position',{},...
                'Yaw',{},...
                'Length',{},...
                'Width',{},...
                'Offset',{},...
                'Color',{});
                this.SensorData=struct('Time',{},'ActorPoses',{},...
                'ObjectDetections',{},'LaneDetections',{},...
                'PointClouds',{},'INSMeasurements',{});
                isValidTime=false;
                return;
            end

            egoCar=actors(egoId);
            sensors=designer.SensorSpecifications;
            player=designer.Simulator;
            time=getCurrentTime(player);
            sample=getCurrentSample(player);


            sensors(~[sensors.Enabled])=[];
            nSensors=numel(sensors);



            poses=targetPoses(egoCar,inf);

            if any(string({sensors.Type})=='ins')
                if isa(egoCar.MotionStrategy,'driving.scenario.SmoothTrajectory')
                    actorState=state(egoCar);
                elseif isa(egoCar.MotionStrategy,'driving.scenario.Path')

                    return;
                else

                    actorState=struct('Position',[0,0,0],...
                    'Velocity',[0,0,0],...
                    'Orientation',[0,0,0],...
                    'AngularVelocity',[0,0,0],...
                    'Acceleration',[0,0,0]);
                end
            end

            isFirstStep=sample==1||isempty(this.SensorData);
            if isFirstStep
                seed=designer.CustomSeed;
                if~isempty(seed)
                    rng(seed);
                end
                allData=struct('Time',{},'ActorPoses',{},'ObjectDetections',{},...
                'LaneDetections',{},'PointClouds',{},'INSMeasurements',{});
                this.GroundTruthCache=struct('Time',{},...
                'LaneBoundaries',{},...
                'Position',{},...
                'Yaw',{},...
                'Length',{},...
                'Width',{},...
                'Offset',{},...
                'Color',{});
                actorProfs=actorProfiles(scenario);
                for sensorIndex=1:nSensors
                    sensor=sensors(sensorIndex).Sensor;
                    release(sensor);
                    configureForFirstStep(sensors(sensorIndex),sensorIndex,actorProfs,egoId);
                end
            else
                allData=this.SensorData;
            end
            isValidTime=false(1,nSensors);
            isValidLaneTime=isValidTime;
            isValidPointCloudTime=isValidTime;
            isValidINSTime=isValidTime;
            objectDets=repmat({zeros(1,0)},nSensors,1);
            allLaneDets=[];
            lanes=[];
            ptClouds=repmat({pointCloud.empty},nSensors,1);
            insMeas=repmat({struct.empty},nSensors,1);

            iw=matlabshared.application.IgnoreWarnings(...
            'driving:abstractDetectionGenerator:sensorInsideActor',...
            'shared_tracking:targetTruth:insideEntity');%#ok<NASGU>


            for sensorIndex=1:nSensors

                sensor=sensors(sensorIndex).Sensor;
                isVision=isa(sensor,'visionDetectionGenerator');
                isLidar=isa(sensor,'lidarPointCloudGenerator');
                isINS=isa(sensor,'insSensor');
                isUltrasonic=isa(sensor,'ultrasonicDetectionGenerator');
                nDetections=0;
                isValidLaneTime=false;
                if isVision
                    detectionType=sensors(sensorIndex).DetectionType;
                end
                if isVision&&strcmp(detectionType,'lanes&objects')
                    if isempty(lanes)






                        maxLaneDetectionRange=min(500,sensor.MaxRange);
                        lanes=laneBoundaries(egoCar,'XDistance',linspace(-maxLaneDetectionRange,maxLaneDetectionRange,101));
                    end
                    [objectDets{sensorIndex},nDetections,isValidTime(sensorIndex),...
                    laneDets,~,isValidLaneTime(sensorIndex)]=sensor(poses,lanes,time);
                    allLaneDets=[allLaneDets,laneDets];%#ok<AGROW>
                elseif isVision&&strcmp(detectionType,'lanes')



                    if isempty(lanes)




                        maxLaneDetectionRange=min(500,sensor.MaxRange);
                        lanes=laneBoundaries(egoCar,'XDistance',linspace(-maxLaneDetectionRange,maxLaneDetectionRange,101));
                    end

                    if isempty(poses)
                        if isFirstStep
                            sensor.DetectorOutput='Lanes only';
                        end
                        [laneDets,~,isValidLaneTime(sensorIndex)]=sensor(lanes,time);
                    else
                        if isFirstStep
                            sensor.DetectorOutput='Lanes with occlusion';
                        end
                        [laneDets,~,isValidLaneTime(sensorIndex)]=sensor(poses,lanes,time);
                    end
                    allLaneDets=[allLaneDets,laneDets];%#ok<AGROW>
                elseif isLidar
                    if sensor.HasRoadsInputPort
                        rdmesh=roadMesh(egoCar,min(500,sensor.MaxRange));
                        [ptClouds{sensorIndex},isValidPointCloudTime(sensorIndex)]=sensor(poses,rdmesh,time);
                    else
                        [ptClouds{sensorIndex},isValidPointCloudTime(sensorIndex)]=sensor(poses,time);
                    end
                elseif isINS
                    insMeas{sensorIndex}=sensor(actorState,time);
                    isValidINSTime(sensorIndex)=true;
                elseif isUltrasonic
                    [objectDets{sensorIndex},isValidTime(sensorIndex)]=sensor(poses,time);
                    nDetections=length(objectDets{sensorIndex});
                else
                    [objectDets{sensorIndex},nDetections,isValidTime(sensorIndex)]=sensor(poses,time);
                end

                objectDets{sensorIndex}(nDetections+1:end)=[];
            end
            if any(isValidTime)||any(isValidLaneTime)||...
                any(isValidPointCloudTime)||any(isValidINSTime)
                if all(cellfun(@isempty,objectDets))
                    objectDets={};
                end


                allData(end+1)=struct('Time',time,...
                'ActorPoses',actorPoses(scenario),...
                'ObjectDetections',{objectDets},...
                'LaneDetections',allLaneDets,...
                'PointClouds',{ptClouds},...
                'INSMeasurements',{insMeas});
            end
            this.SensorData=allData;
        end

        function clearData(this,index)
            if nargin<2
                this.SensorData=struct('Time',{},'ActorPoses',{},...
                'ObjectDetections',{},'LaneDetections',{},...
                'PointClouds',{},'INSMeasurements',{});
            else
                data=this.SensorData;
                if isempty(data)
                    return;
                end
                if numel(data(1).ObjectDetections)>=index
                    for timeIndex=1:numel(data)
                        if numel(data(timeIndex).ObjectDetections)>=index
                            data(timeIndex).ObjectDetections(index)=[];
                        end
                    end
                end
                this.SensorData=data;
            end
        end
    end

    methods(Hidden)

        function hAxes=getAxes(this)
            hAxes=this.Axes;
        end
        function hFig=getFigure(this)
            hFig=this.Figure;
        end
        function tag=getTag(~)
            tag='BirdsEyePlot';
        end

        function b=isCloseable(~)
            b=false;
        end

        function b=isIntrinsic(~)
            b=false;
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:BirdsEyePlotTitle'));
        end

        function[min,max]=getAxesSpan(~)
            min=0.001;
            max=10e3;
        end

        function applyAxesLimits(this,varargin)
            applyAxesLimits@matlabshared.application.FillAxes(this,varargin{:});
        end

        function onMouseMotion(this,~,~)
            if~(this.ShowTooltip&&isOverAxes(this))
                this.setTooltipString('');
                return;
            end
            cp=getCurrentPoint(this);

            a=this.ActorPatches;
            app=this.Application;
            try
                for indx=1:numel(a)
                    if inpolygon(cp(1),cp(2),get(a(indx),'XData'),get(a(indx),'YData'))
                        tooltip=app.ActorSpecifications(indx).Name;
                        this.setTooltipString(tooltip);
                        return;
                    end
                end
            catch E %#ok<NASGU>

            end

            b=this.BarrierPatches;
            app=this.Application;
            try
                for indx=1:numel(b)
                    if inpolygon(cp(1),cp(2),get(b(indx),'XData'),get(b(indx),'YData'))
                        tooltip=app.BarrierSpecifications(indx).Name;
                        this.setTooltipString(tooltip);
                        return;
                    end
                end
            catch E %#ok<NASGU>

            end

            c=this.CoverageAreaPatches;



            s=app.SensorSpecifications;

            isINS=string({s.Type})=='ins';
            s(isINS)=[];
            c(isINS)=[];
            isLidar=string({s.Type})=='lidar';
            s(isLidar)=[];
            c(isLidar)=[];
            if isempty(s)
                return;
            end
            fov=vertcat(s.FieldOfView);
            fov=fov(:,1);
            [~,indx]=sort(fov);
            s=s(indx);
            c=c(indx);
            for indx=1:numel(c)
                if inpolygon(cp(1),cp(2),get(c(indx),'XData'),get(c(indx),'YData'))
                    tooltip=s(indx).Name;
                    this.setTooltipString(tooltip);
                    return;
                end
            end
            this.setTooltipString('');
        end
    end

    methods(Access='protected')

        function options=getAddToApplicationOptions(this)

            app=this.Application;



            tile=getComponentTileIndex(app,app.EgoCentricView);
            if isempty(tile)
                tile=3;
            end
            options=struct(...
            'Title',getName(this),...
            'Tag',getTag(this),...
            'Closable',isCloseable(this),...
            'Tile',tile);
        end

        function onPlayerSampleChanged(this,~,~)

            calculateSensorData(this);


            if strcmp(this.Figure.Visible,'on')
                update(this);
            end
        end

        function onEgoCarIdChanged(this,~,~)
            onPlayerSampleChanged(this);
        end

        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            set(hFig,'WindowButtonMotionFcn',@this.onMouseMotion);
            hPanel=uipanel('BorderType','none',...
            'Parent',hFig,...
            'AutoResizeChildren','off',...
            'Units','pixels');
            hAxes=axes('Parent',hPanel,...
            'ZLim',[-.1,.1],...
            'Box','on',...
            'NextPlot','add',...
            'LooseInset',[0.07,0.06,0.03,0.03],...
            'CameraPositionMode','auto',...
            'CameraTargetMode','auto',...
            'DataAspectRatio',[1,1,1],...
            'CameraUpVectorMode','auto',...
            'CameraViewAngleMode','auto',...
            'Tag',[getTag(this),'Axes']);

            xlabel(hAxes,getString(message('driving:scenarioApp:BirdsEyeXLabel')));
            ylabel(hAxes,getString(message('driving:scenarioApp:BirdsEyeYLabel')));
            box(hAxes,'on');
            set(hAxes,'DataAspectRatio',[1,1,1]);
            view(hAxes,-90,90);

            this.Panel=hPanel;
            this.Axes=hAxes;
            this.RoadBoundaryLine=line(hAxes,'Visible','off','Tag','RoadBoundary');
            this.LaneMarkingsPatch=patch(hAxes,...
            'FaceColor',[0.6,0.6,0.6],...
            'EdgeColor','none',...
            'Visible','off','Tag','LaneMarkings');
            this.LaneDetectionsLine=line(hAxes,'Visible','off','Tag','LaneDetections',...
            'Color',[1,0,0]);
            createPushButton(this,hFig,'SettingsButton',@this.settingsCallback,...
            'TooltipString',getString(message('driving:scenarioApp:BirdsEyePlotSettingsDescription')),...
            'CData',getIcon(this.Application,'settings'),...
            'Position',[5,5,20,20]);
        end

        function settingsCallback(this,h,~)
            hMenu=this.SettingsMenu;
            menuTags={'ShowRoadBoundaries','ShowLaneMarkings','ShowActorOutlines',...
            'ShowLaneDetections','ShowObjectDetections','ShowCoverageAreas',...
            'ShowTooltip','ShowPointCloud','ShowLegend','ShowActorMeshes'};

            if isempty(hMenu)
                hMenu=uicontextmenu(this.Figure,'Tag','BirdsEyePlotSettingsMenu');
                createToggleMenu(this,hMenu,menuTags);
                this.SettingsMenu=hMenu;
            end
            updateToggleMenu(this,menuTags);
            drawnow;
            set(hMenu,...
            'Position',h.Position(1:2)+[1,0],...
            'Visible','on');
        end

        function windowMotionCallback(varargin)

        end
    end
end

function xy=sphericalToCartesian(az,el,r)
    [x,y]=sph2cart(deg2rad(az),deg2rad(el),r);
    xy=[x;y];

end

function col=getParulaColors(distSorted,maxRange)


    segDist=floor((maxRange-30).^2/5);
    if segDist<900
        segDist=900;
    end
    parulaColors=[62,38,168
    52,122,253
    18,190,185
    200,193,41
    249,251,20]/255;
    col=[];
    edge1=0;
    for kndx=1:5
        edge2=floor(segDist*kndx);
        segSize=length(distSorted(distSorted>edge1&distSorted<=edge2));
        edge1=edge2;
        col=[col;repmat(parulaColors(kndx,:),segSize,1)];%#ok<AGROW>
    end
    remToAdd=length(distSorted)-size(col,1);
    col=[col;repmat(parulaColors(end,:),remToAdd,1)];

end

function thisPos=getArcForPlottingRange(sensor,det)
    angs=zeros(2,100);
    hfov=sensor.FieldOfView(1)/2;
    angs(1,:)=linspace(-hfov,hfov,100);
    angs(2,:)=0;
    rg=ones(1,100)*det.Measurement(1);
    angs=deg2rad(angs);
    [x,y,z]=sph2cart(angs(1,:),angs(2,:),rg);
    state=[x(:),y(:),z(:)]';
    for m=1:numel(det.MeasurementParameters)
        measParam=det.MeasurementParameters(m);
        T=measParam.OriginPosition(:);
        orient=driving.internal.rotChildToParent(sensor.Roll,sensor.Pitch,sensor.Yaw);
        if~measParam.IsParentToChild
            orient=orient';
        end
        state=bsxfun(@plus,orient'*state,T);
    end
    thisPos=state(1:3,:);
    thisPos=thisPos';

end


