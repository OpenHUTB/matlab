classdef ScenarioBuilder<handle
    % 场景构建器
    properties(Abstract)
        Scenario
    end


    properties
        SampleTime = 0.01;           % 仿真的默认采样时间为0.01
        CustomSeed = [];
        AxesOrientation = 'ENU';     % 东北天坐标系（ENU）：X轴：指向东边；Y轴：指向北边；Z轴：指向天顶（https://blog.csdn.net/xiaojinger_123/article/details/122112843）
        Use3dSimDimensions = false;  % 是否使用三维仿真维度
    end


    properties(Dependent)
        GeographicReference
    end


    properties(SetAccess=protected, Hidden)
        RoadSpecifications=driving.internal.scenarioApp.road.Specification.empty;
        ActorSpecifications=driving.internal.scenarioApp.ActorSpecification.empty;
        BarrierSpecifications=driving.internal.scenarioApp.BarrierSpecification.empty;
        ClassSpecifications
        SensorSpecifications=driving.internal.scenarioApp.SensorSpecification.empty;
        ActorCount=0;
    end


    methods
        function this=ScenarioBuilder
            this.ClassSpecifications=driving.internal.scenarioApp.ClassSpecifications;
        end


        function set.Use3dSimDimensions(this, use3dSim)
            this.Use3dSimDimensions=use3dSim;
            nActors=numel(this.ActorSpecifications);
            for indx=1:nActors
                updateActorInScenario(this,indx);
            end
            onNewUse3dSimDimensions(this,use3dSim)
        end

        function set.AxesOrientation(this,newOrientation)
            oldOrientation=this.AxesOrientation;
            this.AxesOrientation=newOrientation;
            convertAxesOrientation(this,oldOrientation,newOrientation);
            this.Scenario=generateNewScenarioFromSpecifications(this);
        end

        function set.SampleTime(this,newSampleTime)
            this.SampleTime=newSampleTime;
            onNewSampleTime(this,newSampleTime);
        end

        function v=getVerticalAxis(~)
            v=driving.scenario.Plot.DefaultVerticalAxis;
        end

        function r=get.GeographicReference(this)
            if~isempty(this.Scenario)&&~isstruct(this.Scenario)
                r=this.Scenario.GeographicReference;
            else
                r=[];
            end
        end

        function new(this,tag)

            if nargin<2
                tag='session';
            end

            if any(strcmp(tag,{'session','scenario'}))
                this.RoadSpecifications=driving.internal.scenarioApp.road.Specification.empty;
                this.ActorSpecifications=driving.internal.scenarioApp.ActorSpecification.empty;
                this.BarrierSpecifications=driving.internal.scenarioApp.BarrierSpecification.empty;

                this.Scenario=drivingScenario;
                this.EgoCarId=[];
                this.ActorCount=0;
            end

            if any(strcmp(tag,{'session','sensors'}))
                this.SensorSpecifications=driving.internal.scenarioApp.SensorSpecification.empty;
            end
        end


        function str=generateMatlabCode(this,functionName,egoCar,stopTime)
            if nargin<3
                egoCar=[];
            end

            rngSeed = this.CustomSeed;

            roadSpecs = this.RoadSpecifications;
            actorSpecs = this.ActorSpecifications;
            barrierSpecs = this.BarrierSpecifications;
            sensorSpecs = this.SensorSpecifications;

            createSensorsH1 = "% createSensors Returns all sensor objects to generate detections";
            createScenarioH1 = "% createDrivingScenario Returns the drivingScenario defined in the Designer";
            if~isempty(ver('driving'))
                tbx='driving';
                sensorSpecs(~[sensorSpecs.Enabled])=[];
            elseif~isempty(ver('vdynblks'))
                tbx='vdynblks';
                sensorSpecs=[];
            else
                tbx='';
                sensorSpecs=[];
            end
            header=matlabshared.application.getFileHeader('',tbx);

            if~isempty(roadSpecs)||~isempty(actorSpecs)||~isempty(barrierSpecs)||isempty(sensorSpecs)
                scenarioVariableName='scenario';
                scenarioStr=sprintf("%% Construct a drivingScenario object.\n%s = drivingScenario",scenarioVariableName);
                pvPairs={};
                if nargin>3&&~isinf(stopTime)
                    pvPairs={'StopTime',stopTime};
                end
                sampleTime=this.SampleTime;
                if this.SampleTime~=0.01
                    pvPairs=[pvPairs,{'SampleTime',sampleTime}];
                end
                if~isempty(this.GeographicReference)
                    pvPairs=[pvPairs,{'GeographicReference',mat2str(this.GeographicReference)}];
                end
                if strcmp(this.AxesOrientation,'NED')
                    pvPairs=[pvPairs,{'AxesOrientation','''NED'''}];
                end
                if~strcmp(this.getVerticalAxis(),driving.scenario.Plot.DefaultVerticalAxis)
                    pvPairs=[pvPairs,{'VerticalAxis',"'"+this.getVerticalAxis()+"'"}];
                end
                if~isempty(pvPairs)
                    scenarioStr=scenarioStr+"(";
                    for indx=1:2:numel(pvPairs)
                        if indx>1
                            scenarioStr=scenarioStr+", ..."+newline+"    ";
                        end
                        scenarioStr=scenarioStr+"'"+pvPairs{indx}+"', "+pvPairs{indx+1};
                    end
                    scenarioStr=scenarioStr+")";
                end
                scenarioStr=scenarioStr+";"+newline;
            else
                scenarioStr="";
            end


            if~isempty(barrierSpecs)
                barrierRoadIDs=zeros(numel(barrierSpecs),1);
                for i=1:numel(barrierSpecs)
                    if~isempty(barrierSpecs(i).Road)
                        barrierRoadIDs(i)=barrierSpecs(i).Road.RoadID;
                    end
                end
                barrierRoadIDs(barrierRoadIDs==0)=[];
            end

            if~isempty(roadSpecs)
                scenarioStr=scenarioStr+newline+"% Add all road segments";
                for indx=1:numel(roadSpecs)
                    if~isempty(barrierSpecs)&&ismember(indx,barrierRoadIDs)
                        scenarioStr=scenarioStr+newline+roadSpecs(indx).generateMatlabCode(scenarioVariableName,indx)+newline;
                    else
                        scenarioStr=scenarioStr+newline+roadSpecs(indx).generateMatlabCode(scenarioVariableName)+newline;
                    end
                end
            end

            if~isempty(barrierSpecs)
                scenarioStr=scenarioStr+newline+"% Add the barriers";
                for indx=1:numel(barrierSpecs)
                    scenarioStr=scenarioStr+newline+barrierSpecs(indx).generateMatlabCode(scenarioVariableName)+newline;
                end
            end

            egoCarName='';

            allActorSpecs=actorSpecs;
            if~isempty(actorSpecs)
                actorCommentNeeded=true;
                if isempty(egoCar)||egoCar~=1
                    actorCommentNeeded=false;
                    scenarioStr=scenarioStr+newline+"% Add the actors";
                end
                use3dSim=this.Use3dSimDimensions;
                pvPairs=struct;
                for indx=1:numel(actorSpecs)
                    if use3dSim
                        pvPairs=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(actorSpecs(indx).AssetType);
                    end
                    if~isempty(egoCar)&&egoCar==indx
                        egoCarName='egoVehicle';
                        scenarioStr=scenarioStr+newline+"% Add the ego vehicle";
                        scenarioStr=scenarioStr+newline+actorSpecs(egoCar).generateMatlabCode(scenarioVariableName,this.ClassSpecifications,true,pvPairs)+newline;
                    else
                        if actorCommentNeeded
                            actorCommentNeeded=false;
                            scenarioStr=scenarioStr+newline+"% Add the non-ego actors";
                        end
                        scenarioStr=scenarioStr+newline+actorSpecs(indx).generateMatlabCode(scenarioVariableName,this.ClassSpecifications,false,pvPairs)+newline;
                    end
                end
            end

            if isempty(sensorSpecs)
                if isempty(egoCar)
                    outputVariables=scenarioVariableName;
                else
                    outputVariables=sprintf('[%s, %s]',scenarioVariableName,egoCarName);
                end
                if isempty(functionName)
                    functionName='createDrivingScenario';
                end
                str=scenarioStr;
                helpstr=createScenarioH1;
            else
                if isempty(egoCarName)
                    inputs={};
                    sensorStr="";
                else
                    inputs={'profiles'};
                    sensorStr="";
                    if~all(string({sensorSpecs.Type})=="ins")
                        sensorStr=sprintf("%s\n%s(%s);",...
                            "% Assign into each sensor the physical and radar profiles for all actors",...
                            "profiles = actorProfiles",scenarioVariableName);
                    end
                end

                nSensors=numel(sensorSpecs);
                if nSensors==1
                    sensorStr=sensorStr+newline+"sensor = "+generateMatlabCode(sensorSpecs,1,inputs{:});
                else
                    for indx=1:nSensors
                        sensorStr=sensorStr+newline+"sensors{"+indx+"} = "+generateMatlabCode(sensorSpecs(indx),indx,inputs{:});
                    end
                end

                str="% Create all the sensors";

                if isempty(roadSpecs)&&isempty(actorSpecs)&&isempty(egoCarName)
                    str=str+sensorStr;
                    if nSensors==1
                        if isempty(functionName)
                            functionName='createSensor';
                        end
                        outputVariables='sensor';
                    else
                        if isempty(functionName)
                            functionName='createSensors';
                        end
                        outputVariables='sensors';
                    end
                    helpstr=createSensorsH1;
                else
                    if nSensors==1
                        sensorPostfix='';
                    else
                        sensorPostfix='s';
                    end

                    if isempty(egoCarName)
                        functionLine=sprintf("function [scenario, sensor%s] = createScenario",sensorPostfix);
                        str=sprintf("%s\n%s\n\n%s\n%s\n",...
                            functionLine,createScenarioH1,scenarioStr,sensorStr);
                        return;
                    elseif isempty(functionName)
                        functionName='generateSensorData';
                    end

                    outputVariables=sprintf('[allData, %s, sensor%s]',scenarioVariableName,sensorPostfix);

                    sensorFcn=sensorStr;

                    sensorStr="% Create the drivingScenario object and ego car"+newline;
                    sensorStr=sensorStr+"["+scenarioVariableName+", "+egoCarName+"] = createDrivingScenario;"+newline+newline;

                    sensorStr=sensorStr+"% Create all the sensors"+newline;
                    if numel(sensorSpecs)==1
                        sensorStr=sensorStr+"sensor = createSensor("+scenarioVariableName+");"+newline+newline;
                    else
                        sensorStr=sensorStr+"[sensors, numSensors] = createSensors("+scenarioVariableName+");"+newline+newline;
                    end
                    if~isempty(rngSeed)
                        sensorStr=sensorStr+"% Initialize the random seed for consistent results"+newline;
                        sensorStr=sensorStr+"rng("+rngSeed+");"+newline+newline;
                    end
                    sensorStr=sensorStr+"allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {}, 'PointClouds', {}, 'INSMeasurements', {});"+newline;
                    if isempty(allActorSpecs)||all(cellfun(@isempty,{allActorSpecs.Waypoints}))
                        hasLoop=false;
                        indent='';
                        pragma='';
                    else
                        hasLoop=true;
                        indent='    ';
                        pragma=' %#ok<AGROW>';
                        sensorStr=sensorStr+"running = true;"+newline;
                        sensorStr=sensorStr+"while running"+newline;
                        sensorStr=sensorStr+newline;
                    end

                    isObjects=false(1,nSensors);
                    isLanes=isObjects;
                    isBoth=isObjects;
                    isLanesWithOcclusion=isObjects;
                    isPointClouds=isObjects;
                    isINSMeas=isObjects;
                    isUltrasonic=isObjects;
                    for indx=1:numel(sensorSpecs)
                        sensor=sensorSpecs(indx).Sensor;
                        if isa(sensor,'lidarPointCloudGenerator')
                            isPointClouds(indx)=true;
                        elseif isa(sensor,'insSensor')
                            isINSMeas(indx)=true;
                        elseif isa(sensor,'drivingRadarDataGenerator')||isa(sensor,'ultrasonicDetectionGenerator')||strcmp(sensor.DetectorOutput,'Objects only')
                            isObjects(indx)=true;
                            isUltrasonic(indx)=true;
                        elseif strcmp(sensor.DetectorOutput,'Lanes only')
                            isLanes(indx)=true;
                        elseif strcmp(sensor.DetectorOutput,'Lanes with occlusion')
                            isLanesWithOcclusion(indx)=true;
                        elseif strcmp(sensor.DetectorOutput,'Lanes and objects')
                            isBoth(indx)=true;
                        end
                    end

                    if~all(isLanes)&&~all(isINSMeas)
                        sensorStr=sensorStr+indent+"% Generate the target poses of all actors relative to the ego vehicle"+newline;
                        sensorStr=sensorStr+indent+"poses = targetPoses("+egoCarName+");"+newline;
                    end
                    if any(isINSMeas)
                        sensorStr=sensorStr+indent+"% Get the state of the ego vehicle"+newline;
                        sensorStr=sensorStr+indent+"actorState = state("+egoCarName+");"+newline;
                    end
                    sensorStr=sensorStr+indent+"time  = "+scenarioVariableName+".SimulationTime;"+newline;
                    sensorStr=sensorStr+newline;
                    addDetectorOutputHelper=false;
                    if nSensors==1
                        if~isUltrasonic&&~isINSMeas&&~isPointClouds&&~all(isObjects)
                            sensorStr=sensorStr+indent+"% Generate the ego vehicle lane boundaries"+newline;
                            sensorStr=sensorStr+indent+"if isa(sensor, 'visionDetectionGenerator')"+newline;
                            sensorStr=sensorStr+indent+"    maxLaneDetectionRange = min(500,sensor.MaxRange);"+newline;
                            sensorStr=sensorStr+indent+"    lanes = laneBoundaries("+egoCarName+", 'XDistance', linspace(-maxLaneDetectionRange, maxLaneDetectionRange, 101));"+newline;
                            sensorStr=sensorStr+indent+"end"+newline;
                        end
                        sensorStr=sensorStr+indent+"% Generate detections for the sensor"+newline;
                        if isPointClouds
                            sensorStr=sensorStr+indent+"laneDetections = [];"+newline;
                            sensorStr=sensorStr+indent+"objectDetections = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = [];"+newline;
                            sensorStr=sensorStr+indent+"if sensor.HasRoadsInputPort"+newline;
                            sensorStr=sensorStr+indent+"    rdmesh = roadMesh(egoVehicle,min(500,sensor.MaxRange));"+newline;
                            sensorStr=sensorStr+indent+"    [ptClouds, isValidPointCloudTime] = sensor(poses, rdmesh, time);"+newline;
                            sensorStr=sensorStr+indent+"else"+newline;
                            sensorStr=sensorStr+indent+"    [ptClouds, isValidPointCloudTime] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"end"+newline;
                        elseif isINSMeas
                            sensorStr=sensorStr+indent+"laneDetections = [];"+newline;
                            sensorStr=sensorStr+indent+"objectDetections = [];"+newline;
                            sensorStr=sensorStr+indent+"ptClouds = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = sensor(actorState, time);"+newline;
                        elseif isObjects
                            sensorStr=sensorStr+indent+"laneDetections = [];"+newline;
                            sensorStr=sensorStr+indent+"ptClouds = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = [];"+newline;
                            if isUltrasonic
                                sensorStr=sensorStr+indent+"[objectDetections, isValidTime] = sensor(poses, time);"+newline;
                                sensorStr=sensorStr+indent+"numObjects = length(objectDetections);"+newline;
                            else
                                sensorStr=sensorStr+indent+"[objectDetections, numObjects, isValidTime] = sensor(poses, time);"+newline;
                            end
                            sensorStr=sensorStr+indent+"objectDetections = objectDetections(1:numObjects);"+newline;
                        elseif isLanes
                            sensorStr=sensorStr+indent+"objectDetections = {};"+newline;
                            sensorStr=sensorStr+indent+"ptClouds = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = [];"+newline;
                            sensorStr=sensorStr+indent+"[laneDetections, ~, isValidLaneTime] = sensor(lanes, time);"+newline;
                        elseif isLanesWithOcclusion
                            sensorStr=sensorStr+indent+"objectDetections = {};"+newline;
                            sensorStr=sensorStr+indent+"ptClouds = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = [];"+newline;
                            sensorStr=sensorStr+indent+"[laneDetections, ~, isValidLaneTime] = sensor(poses, lanes, time);"+newline;
                        elseif isBoth
                            sensorStr=sensorStr+indent+"ptClouds = [];"+newline;
                            sensorStr=sensorStr+indent+"insMeas = [];"+newline;
                            sensorStr=sensorStr+indent+"[objectDetections, numObjects, isValidTime, laneDetections, ~, isValidLaneTime] = sensor(poses, lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"objectDetections = objectDetections(1:numObjects);"+newline;
                        end
                    else
                        sensorStr=sensorStr+indent+"objectDetections = {};"+newline;
                        sensorStr=sensorStr+indent+"laneDetections   = [];"+newline;
                        sensorStr=sensorStr+indent+"ptClouds = {};"+newline;
                        sensorStr=sensorStr+indent+"insMeas = {};"+newline;
                        if any(isObjects)||any(isBoth)||any(isINSMeas)||any(isPointClouds)
                            sensorStr=sensorStr+indent+"isValidTime = false(1, numSensors);"+newline;
                        end
                        if any(isLanes)||any(isBoth)||any(isLanesWithOcclusion)||any(isPointClouds)||any(isINSMeas)
                            sensorStr=sensorStr+indent+"isValidLaneTime = false(1, numSensors);"+newline;
                        end
                        if any(isINSMeas)||any(isPointClouds)||any(isBoth)||any(isLanesWithOcclusion)
                            sensorStr=sensorStr+indent+"isValidPointCloudTime = false(1, numSensors);"+newline;
                            sensorStr=sensorStr+indent+"isValidINSTime = false(1, numSensors);"+newline;
                        end
                        sensorStr=sensorStr+newline;
                        sensorStr=sensorStr+indent+"% Generate detections for each sensor"+newline;
                        sensorStr=sensorStr+indent+"for sensorIndex = 1:numSensors"+newline;
                        sensorStr=sensorStr+indent+"    sensor = sensors{sensorIndex};"+newline;
                        if~all(isUltrasonic)&&~all(isINSMeas)&&~all(isPointClouds)&&~all(isObjects)
                            sensorStr=sensorStr+indent+"% Generate the ego vehicle lane boundaries"+newline;
                            sensorStr=sensorStr+indent+"if isa(sensor, 'visionDetectionGenerator')"+newline;
                            sensorStr=sensorStr+indent+"    maxLaneDetectionRange = min(500,sensor.MaxRange);"+newline;
                            sensorStr=sensorStr+indent+"    lanes = laneBoundaries("+egoCarName+", 'XDistance', linspace(-maxLaneDetectionRange, maxLaneDetectionRange, 101));"+newline;
                            sensorStr=sensorStr+indent+"end"+newline;
                        end
                        if all(isPointClouds)
                            sensorStr=sensorStr+indent+"    if sensor.HasRoadsInputPort"+newline;
                            sensorStr=sensorStr+indent+"        rdmesh = roadMesh(egoVehicle,min(500,sensor.MaxRange));"+newline;
                            sensorStr=sensorStr+indent+"        [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, rdmesh, time);"+newline;
                            sensorStr=sensorStr+indent+"    else"+newline;
                            sensorStr=sensorStr+indent+"        [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"    end"+newline;
                            sensorStr=sensorStr+indent+"    ptClouds = [ptClouds; ptCloud];"+pragma+newline;
                        elseif all(isINSMeas)
                            sensorStr=sensorStr+indent+"    insMeasCurrent = sensor(actorState, time);"+newline;
                            sensorStr=sensorStr+indent+"    insMeas = [insMeas; insMeasCurrent];"+pragma+newline;
                        elseif all(isObjects)
                            if all(isUltrasonic)
                                sensorStr=sensorStr+indent+"    [objectDets, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                                sensorStr=sensorStr+indent+"    numObjects = length(objectDets);"+newline;
                            elseif any(isUltrasonic)
                                sensorStr=sensorStr+indent+"    if isa(sensor,'ultrasonicDetectionGenerator')"+newline;
                                sensorStr=sensorStr+indent+"        [objectDets, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                                sensorStr=sensorStr+indent+"        numObjects = length(objectDets);"+newline;
                                sensorStr=sensorStr+indent+"    else"+newline;
                                sensorStr=sensorStr+indent+"        [objectDets, numObjects, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                                sensorStr=sensorStr+indent+"    end"+newline;
                            else
                                sensorStr=sensorStr+indent+"    [objectDets, numObjects, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                            end
                            sensorStr=sensorStr+indent+"    objectDetections = [objectDetections; objectDets(1:numObjects)];"+pragma+newline;
                        elseif all(isLanes)
                            sensorStr=sensorStr+indent+"    [laneDets, ~, isValidTime(sensorIndex)] = sensor(lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"    laneDetections   = [laneDetections laneDets];"+pragma+newline;
                        elseif all(isLanesWithOcclusion)
                            sensorStr=sensorStr+indent+"    [laneDets, ~, isValidTime(sensorIndex)] = sensor(poses, lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"    laneDetections   = [laneDetections laneDets];"+pragma+newline;
                        elseif all(isBoth)
                            sensorStr=sensorStr+indent+"    [objectDets, numObjects, isValidTime(sensorIndex), laneDets, ~, isValidLaneTime(sensorIndex)] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"    objectDetections = [objectDetections; objectDets(1:numObjects)];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    laneDetections   = [laneDetections laneDets];"+pragma+newline;
                        else
                            sensorStr=sensorStr+indent+"    type = getDetectorOutput(sensor);"+newline;
                            sensorStr=sensorStr+indent+"    if strcmp(type, 'Objects only')"+newline;
                            sensorStr=sensorStr+indent+"        if isa(sensor,'ultrasonicDetectionGenerator')"+newline;
                            sensorStr=sensorStr+indent+"            [objectDets, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"            numObjects = length(objectDets);"+newline;
                            sensorStr=sensorStr+indent+"        else"+newline;
                            sensorStr=sensorStr+indent+"            [objectDets, numObjects, isValidTime(sensorIndex)] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"        end"+newline;
                            sensorStr=sensorStr+indent+"        objectDetections = [objectDetections; objectDets(1:numObjects)];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    elseif strcmp(type, 'Lanes only')"+newline;
                            sensorStr=sensorStr+indent+"        [laneDets, ~, isValidTime(sensorIndex)] = sensor(lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"        laneDetections   = [laneDetections laneDets];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    elseif strcmp(type, 'Lanes and objects')"+newline;
                            sensorStr=sensorStr+indent+"        [objectDets, numObjects, isValidTime(sensorIndex), laneDets, ~, isValidLaneTime(sensorIndex)] = sensor(poses, lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"        objectDetections = [objectDetections; objectDets(1:numObjects)];"+pragma+newline;
                            sensorStr=sensorStr+indent+"        laneDetections   = [laneDetections laneDets];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    elseif strcmp(type, 'Lanes with occlusion')"+newline;
                            sensorStr=sensorStr+indent+"        [laneDets, ~, isValidLaneTime(sensorIndex)] = sensor(poses, lanes, time);"+newline;
                            sensorStr=sensorStr+indent+"        laneDetections   = [laneDetections laneDets];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    elseif strcmp(type, 'PointCloud')"+newline;
                            sensorStr=sensorStr+indent+"        if sensor.HasRoadsInputPort"+newline;
                            sensorStr=sensorStr+indent+"            rdmesh = roadMesh(egoVehicle,min(500,sensor.MaxRange));"+newline;
                            sensorStr=sensorStr+indent+"            [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, rdmesh, time);"+newline;
                            sensorStr=sensorStr+indent+"        else"+newline;
                            sensorStr=sensorStr+indent+"            [ptCloud, isValidPointCloudTime(sensorIndex)] = sensor(poses, time);"+newline;
                            sensorStr=sensorStr+indent+"        end"+newline;
                            sensorStr=sensorStr+indent+"        ptClouds = [ptClouds; ptCloud];"+pragma+newline;
                            sensorStr=sensorStr+indent+"    elseif strcmp(type, 'INSMeasurement')"+newline;
                            sensorStr=sensorStr+indent+"        insMeasCurrent = sensor(actorState, time);"+newline;
                            sensorStr=sensorStr+indent+"        insMeas = [insMeas; insMeasCurrent];"+pragma+newline;
                            sensorStr=sensorStr+indent+"        isValidINSTime(sensorIndex) = true;"+newline;
                            sensorStr=sensorStr+indent+"    end"+newline;
                            addDetectorOutputHelper=true;
                        end
                        sensorStr=sensorStr+indent+"end"+newline;
                    end
                    sensorStr=sensorStr+newline+indent+"% Aggregate all detections into a structure for later use"+newline;
                    if nSensors==1
                        if isLanes||isLanesWithOcclusion
                            sensorStr=sensorStr+indent+"if isValidLaneTime"+newline;
                        elseif isObjects
                            sensorStr=sensorStr+indent+"if isValidTime"+newline;
                        elseif isBoth
                            sensorStr=sensorStr+indent+"if isValidTime || isValidLaneTime"+newline;
                        elseif isPointClouds
                            sensorStr=sensorStr+indent+"if isValidPointCloudTime"+newline;
                        end
                    else
                        if all(isLanes)||all(isLanesWithOcclusion)
                            sensorStr=sensorStr+indent+"if any(isValidLaneTime)"+newline;
                        elseif all(isObjects)
                            sensorStr=sensorStr+indent+"if any(isValidTime)"+newline;
                        elseif all(isPointClouds)
                            sensorStr=sensorStr+indent+"if any(isValidPointCloudTime)"+newline;
                        elseif all(isINSMeas)
                            sensorStr=sensorStr+indent+"if any(isValidINSTime)"+newline;
                        else
                            sensorStr=sensorStr+indent+"if any(isValidTime) || any(isValidLaneTime) || any(isValidPointCloudTime) || any(isValidINSTime)"+newline;
                        end
                    end
                    if nSensors==1&&isINSMeas
                        sensorStr=sensorStr+indent+"allData(end + 1) = struct( ..."+newline;
                        sensorStr=sensorStr+indent+"    'Time',       "+scenarioVariableName+".SimulationTime, ..."+newline;
                        sensorStr=sensorStr+indent+"    'ActorPoses', actorPoses("+scenarioVariableName+"), ..."+newline;
                        sensorStr=sensorStr+indent+"    'ObjectDetections', {objectDetections}, ..."+newline;
                        sensorStr=sensorStr+indent+"    'LaneDetections', {laneDetections}, ..."+newline;
                        sensorStr=sensorStr+indent+"    'PointClouds',   {ptClouds}, ..."+pragma+newline;
                        sensorStr=sensorStr+indent+"    'INSMeasurements',   {insMeas});"+pragma+newline;
                    else
                        sensorStr=sensorStr+indent+"    allData(end + 1) = struct( ..."+newline;
                        sensorStr=sensorStr+indent+"        'Time',       "+scenarioVariableName+".SimulationTime, ..."+newline;
                        sensorStr=sensorStr+indent+"        'ActorPoses', actorPoses("+scenarioVariableName+"), ..."+newline;
                        sensorStr=sensorStr+indent+"        'ObjectDetections', {objectDetections}, ..."+newline;
                        sensorStr=sensorStr+indent+"        'LaneDetections', {laneDetections}, ..."+newline;
                        sensorStr=sensorStr+indent+"        'PointClouds',   {ptClouds}, ..."+pragma+newline;
                        sensorStr=sensorStr+indent+"        'INSMeasurements',   {insMeas});"+pragma+newline;
                        sensorStr=sensorStr+indent+"end"+newline;
                    end
                    sensorStr=sensorStr+newline;
                    if hasLoop
                        sensorStr=sensorStr+"    % Advance the scenario one time step and exit the loop if the scenario is complete"+newline;
                        sensorStr=sensorStr+"    running = advance("+scenarioVariableName+");"+newline;
                        sensorStr=sensorStr+"end"+newline+newline;
                        sensorStr=sensorStr+"% Restart the driving scenario to return the actors to their initial positions."+newline;
                        sensorStr=sensorStr+"restart("+scenarioVariableName+");"+newline+newline;
                    end
                    if nSensors==1
                        sensorStr=sensorStr+"% Release the sensor object so it can be used again."+newline;
                        sensorStr=sensorStr+"release(sensor);"+newline+newline;
                    else
                        sensorStr=sensorStr+"% Release all the sensor objects so they can be used again."+newline;
                        sensorStr=sensorStr+"for sensorIndex = 1:numSensors"+newline;
                        sensorStr=sensorStr+"    release(sensors{sensorIndex});"+newline;
                        sensorStr=sensorStr+"end"+newline+newline;
                    end
                    sensorStr=sensorStr+"%%%%%%%%%%%%%%%%%%%%"+newline;
                    sensorStr=sensorStr+"% Helper functions %"+newline;
                    sensorStr=sensorStr+"%%%%%%%%%%%%%%%%%%%%"+newline+newline;
                    sensorStr=sensorStr+"% Units used in createSensors and createDrivingScenario"+newline;
                    sensorStr=sensorStr+"% Distance/Position - meters"+newline;
                    sensorStr=sensorStr+"% Speed             - meters/second"+newline;
                    sensorStr=sensorStr+"% Angles            - degrees"+newline;
                    sensorStr=sensorStr+"% RCS Pattern       - dBsm"+newline;

                    if nSensors==1
                        functionLine="function sensor = createSensor";
                        str=sprintf("%s\n%s(%s)\n%s\n\n%s\n",...
                            sensorStr,functionLine,scenarioVariableName,...
                            createSensorsH1,sensorFcn);
                    else
                        functionLine="function [sensors, numSensors] = createSensors";
                        str=sprintf("%s\n%s(%s)\n%s\n\n%s\nnumSensors = %d;\n",...
                            sensorStr,functionLine,scenarioVariableName,...
                            createSensorsH1,sensorFcn,nSensors);
                    end
                    str=sprintf("%s\nfunction [%s, %s] = createDrivingScenario\n%s\n\n%s",...
                        str,scenarioVariableName,egoCarName,createScenarioH1,scenarioStr);
                    if addDetectorOutputHelper
                        outputStr="function output = getDetectorOutput(sensor)"+newline+newline;
                        outputStr=outputStr+"if isa(sensor, 'visionDetectionGenerator')"+newline;
                        outputStr=outputStr+"    output = sensor.DetectorOutput;"+newline;
                        outputStr=outputStr+"elseif isa(sensor, 'lidarPointCloudGenerator')"+newline;
                        outputStr=outputStr+"    output = 'PointCloud';"+newline;
                        outputStr=outputStr+"elseif isa(sensor, 'insSensor')"+newline;
                        outputStr=outputStr+"    output = 'INSMeasurement';"+newline;
                        outputStr=outputStr+"else"+newline;
                        outputStr=outputStr+"    output = 'Objects only';"+newline;
                        outputStr=outputStr+"end"+newline;
                        str=str+newline+outputStr;
                    end
                    helpstr=sprintf('%%%s\n',...
                        sprintf('%s - Returns sensor detections',functionName),...
                        sprintf('    allData = %s returns sensor detections in a structure',functionName),...
                        '    with time for an internally defined scenario and sensor suite.',...
                        '',...
                        sprintf('    [allData, scenario, sensors] = %s optionally returns',functionName),...
                        '    the drivingScenario and detection generator objects.');
                    helpstr(end)=[];
                end
            end
            str=sprintf("function %s = %s()\n%s\n\n%s\n\n%s\n",outputVariables,functionName,helpstr,header,str);
        end


        function modelName=generateSimulinkModel(this,stopTime,scenarioFilePath)
            enabledSensors=this.SensorSpecifications([this.SensorSpecifications.Enabled]==true);
            modelName=driving.scenario.internal.generateSimulinkModel(this.Scenario,...
                enabledSensors,stopTime,scenarioFilePath,getTitle(this));
        end


        function[modelName,warnings]=generate3dSimModel(this,stopTime,scenarioFilePath,varargin)
            sensors=this.SensorSpecifications;
            sensors=sensors([sensors.Enabled]);

            sensors=sensors(string({sensors.Type})~='ins');

            sensors=sensors(string({sensors.Type})~='ultrasonic');
            actors=this.ActorSpecifications;
            [modelName,warnings]=driving.scenario.internal.generate3dSimModel(this.Scenario,...
                sensors,stopTime,scenarioFilePath,getTitle(this),actors,varargin{:});
        end


        function varargout=addRoad(this,varargin)
            if nargin>1&&isa(varargin{1},'driving.internal.scenarioApp.road.Specification')
                roadSpec=varargin{1};
            else
                roadSpec=driving.internal.scenarioApp.road.Arbitrary(varargin{:});
            end

            addRoadSpecification(this,roadSpec)
            if nargout
                varargout={roadSpec};
            end
        end


        function addRoadSpecification(this,roadSpec,index)
            roadSpec.applyToScenario(this.Scenario);
            maxIndex=numel(this.RoadSpecifications)+1;
            if nargin<3||index>maxIndex
                index=maxIndex;
            end
            allSpecs=this.RoadSpecifications;
            allSpecs=[allSpecs(1:index-1),roadSpec,allSpecs(index:end)];
            this.RoadSpecifications=allSpecs;
        end


        function varargout=deleteRoad(this,index)
            if nargout
                varargout={this.RoadSpecifications(index)};
            end
            this.RoadSpecifications(index)=[];
            generateNewScenarioFromSpecifications(this);
        end


        function varargout=deleteBarrier(this,index)
            if nargout
                varargout={this.BarrierSpecifications(index)};
            end
            this.BarrierSpecifications(index)=[];
            generateNewScenarioFromSpecifications(this);
        end


        function varargout=addBarrier(this,varargin)
            if nargin>1&&isa(varargin{1},'driving.internal.scenarioApp.BarrierSpecification')
                barrierSpec=varargin{1};
            else
                barrierSpec=driving.internal.scenarioApp.BarrierSpecification(varargin{:});
            end
            addBarrierSpecification(this,barrierSpec);
            if nargout
                varargout={barrierSpec};
            end
        end


        function addBarrierSpecification(this,barrierSpec,index)
            barrierSpec.applyToScenario(this.Scenario);
            maxIndex=numel(this.BarrierSpecifications)+1;
            if nargin<3||index>maxIndex
                index=maxIndex;
            end
            allSpecs=this.BarrierSpecifications;
            allSpecs=[allSpecs(1:index-1),barrierSpec,allSpecs(index:end)];
            this.BarrierSpecifications=allSpecs;
        end


        function varargout = addActor(this, varargin)
            actorSpec = driving.internal.scenarioApp.ActorSpecification(varargin{:});
            actor = addActorSpecification(this, actorSpec);

            if nargout
                varargout={actorSpec,actor};
            end
        end


        function varargout = addActorSpecification(this, actorSpec, index)
            maxIndex = numel(this.ActorSpecifications) + numel(actorSpec);
            applyInMiddle = true;
            if nargin<3 || all(index>maxIndex)
                index = maxIndex;
                applyInMiddle=false;
            end
            allSpecs = this.ActorSpecifications;

            if(size(actorSpec,2)<size(actorSpec,1))
                actorSpec=actorSpec';
            end

            if(numel(index)>1)
                for indx = 1:numel(index)
                    allSpecs=[allSpecs(1:(index(indx)-numel(actorSpec))),actorSpec(indx),allSpecs(index(indx):end)];
                end
            else
                allSpecs=[allSpecs(1:(index-numel(actorSpec))),actorSpec,allSpecs(index:end)];
            end

            this.ActorSpecifications=allSpecs;

            if applyInMiddle
                generateScenarioActorsFromSpecifications(this);
                actor=this.Scenario.Actors(index);
            else
                if this.Use3dSimDimensions
                    pvPairs=getActorPVPairs(actorSpec);
                else
                    pvPairs={};
                end
                for indx=1:numel(actorSpec)
                    actor=actorSpec(indx).applyToScenario(this.Scenario,this.ClassSpecifications,pvPairs{:});
                end
            end

            for i=1:numel(actorSpec)
                if any(index==maxIndex)&&isempty(getProperty(this.ClassSpecifications,actorSpec(end).ClassID,'PlotColor'))
                    this.ActorCount=this.ActorCount+1;
                end
            end

            if nargout
                varargout={actor};
            end
        end


        % 从场景中删除索引为index的参与者
        function varargout=deleteActor(this, index)
            allActors = this.ActorSpecifications;
            if nargout
                varargout={allActors(index)};
            end
            for indx=1:numel(index)
                if index(indx)==numel(allActors) && isempty(getProperty(this.ClassSpecifications,allActors(index(indx)).ClassID,'PlotColor'))
                    newCount=this.ActorCount-1;
                    if newCount<0
                        newCount=0;
                    end
                    this.ActorCount=newCount;
                end
            end
            this.ActorSpecifications(index) = [];
            generateScenarioActorsFromSpecifications(this);
            updatePlotsForActors(this);  % 目前未实现，导致画布和视图出现不一致，虚幻场景也未更新
        end


        function varargout=addSensor(this,type,varargin)
            switch type
                case 'vision'
                    hSensor=driving.internal.scenarioApp.VisionSensorSpecification(varargin{:});
                case 'radar'
                    hSensor=driving.internal.scenarioApp.RadarSensorSpecification(varargin{:});
                case 'lidar'
                    hSensor=driving.internal.scenarioApp.LidarSensorSpecification(varargin{:});
                case 'ins'
                    hSensor=driving.internal.scenarioApp.INSSensorSpecification(varargin{:});
                case 'ultrasonic'
                    rndx=find(strcmp(varargin,'FieldOfView'));
                    varargin(rndx:rndx+1)=[];
                    rndx=find(strcmp(varargin,'MaxRange'));
                    varargin(rndx:rndx+1)=[];
                    hSensor=driving.internal.scenarioApp.UltrasonicSensorSpecification(varargin{:});
            end
            addSensorSpecification(this,hSensor);
            if nargout
                varargout={hSensor};
            end
        end

        function addSensorSpecification(this,hSensor,index)
            [interval,changed]=driving.internal.scenarioApp.SensorSpecification.fixUpdateIntervals(...
                hSensor.UpdateInterval,this.SampleTime*1000);
            if changed
                hSensor.UpdateInterval=interval;
                id='driving:scenarioApp:UpdateUpdateIntervalOnNew';
                warning(id,getString(message(id)));
            end
            sensorSpecs=this.SensorSpecifications;
            maxIndex=numel(sensorSpecs)+1;
            if nargin<3||index>maxIndex
                index=maxIndex;
            end
            this.SensorSpecifications=[sensorSpecs(1:index-1),hSensor,sensorSpecs(index:end)];
        end


        function varargout=deleteSensor(this,index)
            if nargout
                varargout={this.SensorSpecifications(index)};
            end
            this.SensorSpecifications(index)=[];
        end
    end


    methods(Hidden)

        function[data,offset,span,rotation]=get3DScenarioData(this,roadSpecs,actorSpecs,egoCarId,sampleTime,fullRun,barrierSpecs)
            if nargin<2
                egoCarId=this.EgoCarId;
            end
            if nargin>3
                for kndx=1:numel(roadSpecs)
                    this.addRoadSpecification(roadSpecs(kndx),kndx);
                end
            else
                roadSpecs=this.RoadSpecifications;
            end
            if nargin>4

                for kndx=1:numel(actorSpecs)
                    this.addActorSpecification(actorSpecs(kndx),kndx);
                end
            else
                actorSpecs=this.ActorSpecifications;
            end
            if nargin>6

                for kndx=1:numel(barrierSpecs)
                    this.addBarrierSpecification(barrierSpecs(kndx),kndx);
                end
            else
                barrierSpecs=this.BarrierSpecifications;
            end

            scenario=this.Scenario;
            allXMax=-inf;
            allXMin=inf;
            allYMax=-inf;
            allYMin=inf;
            allZMax=-inf;
            allZMin=inf;
            if numel(roadSpecs)>0
                roadXYZ=vertcat(scenario.RoadTiles.Vertices);
                roadMax=max(roadXYZ);
                roadMin=min(roadXYZ);
                allXMax=roadMax(1);
                allXMin=roadMin(1);
                allYMax=roadMax(2);
                allYMin=roadMin(2);
                allZMax=roadMax(3);
                allZMin=roadMin(3);
            end
            actors=scenario.Actors;
            for indx=1:numel(actors)
                if isa(actors(indx).MotionStrategy,'driving.scenario.Stationary')
                    allXMin=min(allXMin,actors(indx).Position(1));
                    allXMax=max(allXMax,actors(indx).Position(1));
                    allYMin=min(allYMin,actors(indx).Position(2));
                    allYMax=max(allYMax,actors(indx).Position(2));
                    allZMin=min(allZMin,actors(indx).Position(3));
                    allZMax=min(allZMax,actors(indx).Position(3));
                else
                    allXMin=min(allXMin,min(actors(indx).MotionStrategy.SamplePoints(:,1)));
                    allXMax=max(allXMax,max(actors(indx).MotionStrategy.SamplePoints(:,1)));
                    allYMin=min(allYMin,min(actors(indx).MotionStrategy.SamplePoints(:,2)));
                    allYMax=max(allYMax,max(actors(indx).MotionStrategy.SamplePoints(:,2)));
                    allZMin=min(allZMin,min(actors(indx).MotionStrategy.SamplePoints(:,3)));
                    allZMax=max(allZMax,max(actors(indx).MotionStrategy.SamplePoints(:,3)));
                end
            end
            barriers=scenario.Barriers;
            for indx=1:numel(barriers)
                barrierSegmentPos=reshape([barriers(indx).BarrierSegments(:).Position],3,[])';
                allXMin=min(allXMin,min(barrierSegmentPos(:,1)));
                allXMax=max(allXMax,max(barrierSegmentPos(:,1)));
                allYMin=min(allYMin,min(barrierSegmentPos(:,2)));
                allYMax=max(allYMax,max(barrierSegmentPos(:,2)));
                allZMin=min(allZMin,min(barrierSegmentPos(:,3)));
                allZMax=max(allZMax,max(barrierSegmentPos(:,3)));
            end

            offset=[1000,0];
            if isinf(allXMin)||isinf(allXMax)
                span=50;
            else
                if allZMax-allZMin>3
                    if allZMin>0
                        allZMin=allZMin-0.1;
                    else
                        allZMin=allZMin+0.1;
                    end
                end
                offset=[offset(1)-(allXMax+allXMin)/2,offset(2)-(allYMax+allYMin)/2,-allZMin];
                span=max(allXMax-allXMin,allYMax-allYMin);
            end
            rgRoadStruct=[];
            for kndx=numel(roadSpecs):-1:1
                if isa(roadSpecs(kndx),'driving.internal.scenarioApp.road.Arbitrary')
                    rStruct=convertToStruct(roadSpecs(kndx));
                    centers=rStruct.Centers;


                    centers(all(diff(centers)==[0,0,0],2),:)=[];
                    rStruct.Centers=centers+offset;
                    roadStruct(kndx,1)=rStruct;
                elseif isa(roadSpecs(kndx),'driving.internal.scenarioApp.road.RoadGroupArbitrary')
                    rgRoads=roadSpecs(kndx).Roads;
                    for ind=1:numel(rgRoads)
                        rgRoad=rgRoads{1,ind};
                        rgRoad.Centers=rgRoad.Centers+offset;
                        rgRoad.Heading=[];
                        rgRoadStruct=[rgRoadStruct;rgRoad];%#ok<AGROW>
                    end
                end
            end
            scenario=this.Scenario;

            for kndx=numel(actorSpecs):-1:1
                s=convertToStruct(actorSpecs(kndx));
                actor=scenario.Actors(kndx);
                s.Length=actor.Length;
                s.Width=actor.Width;
                s.Height=actor.Height;
                if isprop(actor,'FrontOverhang')
                    s.FrontOverhang=actor.FrontOverhang;
                    s.RearOverhang=actor.RearOverhang;
                    s.Position=driving.scenario.internal.translateVehiclePosition(...
                        s.Position,s.RearOverhang,s.Length,s.Roll,s.Pitch,s.Yaw);
                end

                s.Position=s.Position+offset;
                if~isempty(s.Waypoints)
                    s.Waypoints=s.Waypoints+offset;
                end
                actorStruct(kndx,1)=s;
            end

            barrierStruct=struct.empty;
            for kndx=1:numel(barrierSpecs)
                s=getBarrierStruct(barrierSpecs(kndx));
                barrierStruct=[barrierStruct;s'];%#ok<AGROW>
            end

            if~isempty(actorSpecs)&&~isempty(barrierSpecs)
                numActors=numel(actorSpecs);
                barrierIDCell=num2cell(numActors+1:numActors+numel(barrierStruct));
                [barrierStruct(1:end).ActorID]=deal(barrierIDCell{:});
                actorStruct=[actorStruct;barrierStruct];
            elseif isempty(actorSpecs)&&~isempty(barrierSpecs)
                barrierIDCell=num2cell(1:numel(barrierStruct));
                [barrierStruct(1:end).ActorID]=deal(barrierIDCell{:});
                actorStruct=barrierStruct;
            end

            if nargin>2
                scenario.SampleTime=sampleTime;
            end

            if isempty(scenario.Actors)&&isempty(scenario.Barriers)
                vehiclePoses=[];
            else
                resetVisibility(scenario.Actors);

                time=0;
                vehiclePoses.SimulationTime=time;
                poses=actorPoses(scenario);
                isMoving=false;

                for indx=1:numel(scenario.Actors)
                    isMoving(indx)=~isa(scenario.Actors(indx).MotionStrategy,'driving.scenario.Stationary');
                    if isa(scenario.Actors(indx),'driving.scenario.Vehicle')
                        poses(indx).Position=driving.scenario.internal.translateVehiclePosition(...
                            poses(indx).Position,scenario.Actors(indx).RearOverhang,...
                            scenario.Actors(indx).Length,poses(indx).Roll,poses(indx).Pitch,poses(indx).Yaw);
                    end
                    poses(indx).Position=poses(indx).Position+offset;
                end

                for indx=numel(scenario.Actors)+1:numel(actorStruct)
                    isMoving(indx)=false;
                    poses(indx).Position=poses(indx).Position+offset;
                end
                vehiclePoses.ActorPoses=poses;

                isRunning=isMoving&(nargin>5&&fullRun);
                while any(isRunning)
                    time=time+sampleTime;
                    vehiclePoses(end+1).SimulationTime=time;%#ok<AGROW>

                    for indx=1:numel(scenario.Actors)
                        isRunning(indx)=move(scenario.Actors(indx),time);
                        isRunning(indx)=isRunning(indx)&&isMoving(indx);
                    end
                    vehiclePoses(end).ActorPoses=actorPoses(scenario);
                end
            end

            if~isempty(roadSpecs)
                if~isempty(rgRoadStruct)
                    roadFields=fieldnames(roadStruct);
                    if isfield(roadStruct,'IsOpenDRIVE')
                        [rgRoadStruct.IsOpenDRIVE]=deal(false);
                    end
                    for indx=1:numel(roadFields)
                        if~isfield(rgRoadStruct,roadFields{indx})
                            [rgRoadStruct.(roadFields{indx})]=deal([]);
                        end
                    end
                    roadStruct=[roadStruct;rgRoadStruct];
                end
                data.Roads=roadStruct;
            else
                data.Roads=[];
            end
            if~isempty(actorSpecs)||~isempty(barrierSpecs)
                data.Actors=actorStruct;
            else
                data.Actors=[];
            end
            data.EgoCarId=egoCarId;
            if isempty(scenario.Actors)&&isempty(scenario.Barriers)
                data.ActorProfiles=[];
            else
                data.ActorProfiles=actorProfiles(scenario);
            end
            data.VehiclePoses=vehiclePoses;
            data.HasIntersection=this.determineHasIntersection(scenario);
            if strcmpi(getVerticalAxis(this),'Y')
                rotation=90;
            else
                rotation=0;
            end
        end


        function tf=determineHasIntersection(~,scenario)
            tf=false;
            rt=scenario.RoadTiles;
            for kndx=1:length(rt)

                if rt(kndx).IsJunctionTile
                    tf=true;
                    break;
                end
            end
        end


        function updateClassSpecifications(this,classInfo)
            classSpecs=this.ClassSpecifications;
            clear(classSpecs);
            for indx=1:numel(classInfo)
                info=classInfo(indx);
                classSpecs.setSpecification(info.id,rmfield(info,'id'));
            end
        end


        function generateScenarioActorsFromSpecifications(this, s)
            if nargin<2
                s=this.Scenario;
            end
            removeAllActors(s);
            actorSpecs = this.ActorSpecifications;
            use3d = this.Use3dSimDimensions;
            pvPairs={};
            for indx=1:numel(actorSpecs)
                if use3d
                    pvPairs = getActorPVPairs(actorSpecs(indx));
                end
                actorSpecs(indx).applyToScenario(s, this.ClassSpecifications, pvPairs{:});
            end
        end


        function varargout = generateNewScenarioFromSpecifications(this)
            s=drivingScenario(...
                'SampleTime',this.SampleTime,...
                'AxesOrientation',this.AxesOrientation,...
                'GeographicReference',this.GeographicReference,...
                'VerticalAxis',this.getVerticalAxis());

            if~isempty(this.Scenario)&&this.Scenario.IsOpenDRIVERoad
                s.ShowRoadBorders=false;
                s.IsOpenDRIVERoad=true;
            end

            roadSpecs=this.RoadSpecifications;
            if~isempty(roadSpecs)
                for indx=1:numel(roadSpecs)
                    roadSpecs(indx).applyToScenario(s);
                end
            end

            generateScenarioActorsFromSpecifications(this,s);

            barrierSpecs=this.BarrierSpecifications;
            currentRoadIDs=[s.RoadSegments(:).RoadID];
            for indx=1:numel(barrierSpecs)
                if~isempty(barrierSpecs(indx).Road)
                    barrierRoadID=barrierSpecs(indx).Road.RoadID;
                    if~any(find(currentRoadIDs==barrierRoadID))||...
                            ~isequal(s.RoadSegments(barrierRoadID).RoadCenters,barrierSpecs(indx).Road.RoadCenters)

                        barrierSpecs(indx).BarrierCentersChanged=true;
                        barrierSpecs(indx).resetRoadData();
                    else
                        roadID=barrierSpecs(indx).Road.RoadID;
                        barrierSpecs(indx).Road=driving.scenario.Road(s.RoadSegments(roadID));
                    end
                end
                barrierSpecs(indx).applyToScenario(s);
            end

            if nargout>0
                varargout{1}=s;
            else
                this.Scenario=s;
            end
        end


        function updateActorInScenario(this,index)
            actorSpec=this.ActorSpecifications(index);
            if numel(this.Scenario.Actors)<index
                return
            end
            actor=this.Scenario.Actors(index);
            if isempty(actor)
                return;
            end
            for indx=1:numel(actorSpec)
                if this.Use3dSimDimensions
                    pvPairs=getActorPVPairs(actorSpec(indx));
                else
                    pvPairs={};
                end
                applyToActor(actorSpec(indx),actor(indx),this.ClassSpecifications,pvPairs{:});
            end
        end


        function name=getClassNameFromID(this,id)
            name=this.ClassSpecifications.getProperty(id,'name');
        end
    end


    methods(Access=protected)

        function onNewUse3dSimDimensions(~,~)
        end


        function onNewSampleTime(~,~)
        end


        function updatePlots(~)
        end


        function updatePlotsForActors(~)
        end


        function convertAxesOrientation(this,oldOrientation,newOrientation)
            roadSpecs = this.RoadSpecifications;%#ok<*MCSUP>
            actorSpecs=this.ActorSpecifications;
            sensorSpecs=this.SensorSpecifications;
            barrierSpecs=this.BarrierSpecifications;
            for indx=1:numel(roadSpecs)
                convertAxesOrientation(roadSpecs(indx),oldOrientation,newOrientation);
            end
            for indx=1:numel(actorSpecs)
                convertAxesOrientation(actorSpecs(indx),oldOrientation,newOrientation);
            end
            for indx=1:numel(sensorSpecs)
                convertAxesOrientation(sensorSpecs(indx),oldOrientation,newOrientation);
            end
            for indx=1:numel(barrierSpecs)
                convertAxesOrientation(barrierSpecs(indx),oldOrientation,newOrientation);
            end
        end
    end
end


function s=convertToStruct(aObj)

props=properties(aObj);
if isempty(props)
    s=[];
end
for kndx=1:length(props)
    s.(props{kndx})=aObj.(props{kndx});
end
end


function s=getBarrierStruct(barrierSpec)
numSegments=numel(barrierSpec.BarrierSegments);
fieldNames=properties(driving.internal.scenarioApp.ActorSpecification);
s=struct;
for i=1:numel(fieldNames)
    if isprop(barrierSpec,fieldNames{i})
        [s(1:numSegments).(fieldNames{i})]=deal(barrierSpec.(fieldNames{i}));
    end
end

[s(1:numSegments).Length]=deal(barrierSpec.SegmentLength);
[s(1:numSegments).FrontOverhang]=deal(0);
[s(1:numSegments).Wheelbase]=deal(0);
[s(1:numSegments).RearOverhang]=deal(0);
[s(1:numSegments).Waypoints]=deal([]);
[s(1:numSegments).Speed]=deal(1);
[s(1:numSegments).WaitTime]=deal([]);
[s(1:numSegments).WaypointsYaw]=deal([]);
[s(1:numSegments).EntryTime]=deal(0);
[s(1:numSegments).ExitTime]=deal(inf);
[s(1:numSegments).IsVisible]=deal(1);
[s(1:numSegments).IsSpawnValid]=deal(0);
[s(1:numSegments).TrajectoryFcn]=deal('');
[s(1:numSegments).IsSmoothTrajectory]=deal(0);
[s(1:numSegments).Jerk]=deal(0.6);

pos=reshape([barrierSpec.BarrierSegments(:).Position],3,[])';
posCell=num2cell(pos,2);
[s(1:numSegments).Position]=deal(posCell{:});

rollCell=num2cell([barrierSpec.BarrierSegments(:).Roll]);
[s(1:numSegments).Roll]=deal(rollCell{:});

pitchCell=num2cell([barrierSpec.BarrierSegments(:).Pitch]);
[s(1:numSegments).Pitch]=deal(pitchCell{:});

yawCell=num2cell([barrierSpec.BarrierSegments(:).Yaw]);
[s(1:numSegments).Yaw]=deal(yawCell{:});

end


% 获得参与者"参数-值（Parameter-Value）"对
function pvPairs = getActorPVPairs(spec)
    dims = driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(spec.AssetType);
    pvPairs = matlabshared.application.structToPVPairs(dims);
end



