classdef DataModel<handle


    properties(Dependent,Transient)
CurrentPlatform
CurrentSensor
CurrentWaypoint
SensorCanvasCenter
SensorCanvasUnitsPerPixel
    end

    properties(SetAccess=protected)
        PlatformSpecifications=fusion.internal.scenarioApp.dataModel.PlatformSpecification.empty
        SensorSpecifications=fusion.internal.scenarioApp.dataModel.SensorSpecification.empty
PlatformClassSpecifications
SensorClassSpecifications
SimulatorSpecification
    end

    properties(Access=protected)



pCurrentPlatform
pCurrentSensor
        pCurrentWaypoint=0
    end

    events
PlatformsChanged
PlatformAdded
PlatformDeleted
NewPlatformSelected
SensorsChanged
SensorAdded
SensorDeleted
CurrentWaypointChanged
TrajectoryChanged
    end

    methods
        function this=DataModel()
            this.PlatformClassSpecifications=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications;
            this.SensorClassSpecifications=fusion.internal.scenarioApp.dataModel.SensorClassSpecifications;
            this.SimulatorSpecification=fusion.internal.scenarioApp.dataModel.SimulatorSpecification;
        end
    end


    methods
        function set.CurrentSensor(this,p)
            this.pCurrentSensor=p;
            notify(this,'SensorsChanged');
        end

        function sensor=get.CurrentSensor(this)
            sensor=this.pCurrentSensor;
        end

        function reset=resetCurrentSensor(this)


            newSensors=getSensorsByPlatform(this);
            oldSensor=this.CurrentSensor;
            if isempty([oldSensor,newSensors])
                reset=false;
            else
                reset=true;
                if isempty(newSensors)
                    this.pCurrentSensor=[];
                else
                    this.pCurrentSensor=newSensors(1);
                end
            end
        end

        function[specs,indices]=getSensorsByPlatform(this,id)

            if nargin==1
                current=this.CurrentPlatform;
                if~isempty(current)
                    id=this.CurrentPlatform.ID;
                else
                    id=nan;
                end
            end
            allSpecs=this.SensorSpecifications;
            indices=find([allSpecs.PlatformID]==id);
            specs=allSpecs(indices);
        end


        function addSensorSpecification(this,spec,index)
            allSpecs=this.SensorSpecifications;



            spec.Name=getUniqueName(allSpecs,spec.Name);
            spec.ID=getUniqueID(allSpecs,spec.ID);


            spec.PlatformID=this.CurrentPlatform.ID;
            if nargin<3
                this.SensorSpecifications(end+1)=spec;
            else
                this.SensorSpecifications=[allSpecs(1:index-1),spec,allSpecs(index:end)];
            end
            this.pCurrentSensor=spec;
            notify(this,'SensorAdded');
        end

        function addSensor(this,varargin)
            if nargin>1&&isa(varargin{1},'fusion.internal.scenarioApp.dataModel.SensorSpecification')
                spec=varargin{1};
            else
                spec=fusion.internal.scenarioApp.dataModel.RadarSensorSpecification(this.CurrentPlatform.ID,varargin{:});
            end
            addSensorSpecification(this,spec);
        end

        function hSpecification=deleteSensor(this,index)
            allSpecs=this.SensorSpecifications;
            if~isnumeric(index)
                index=find(allSpecs==index,1,'first');
            end
            hSpecification=allSpecs(index);
            allSpecs(index)=[];
            this.SensorSpecifications=allSpecs;
            newSpecs=getSensorsByPlatform(this);
            if isempty(newSpecs)
                this.pCurrentSensor=[];
            else
                this.pCurrentSensor=newSpecs(1);
            end
            data=fusion.internal.scenarioApp.GenericEventData(hSpecification.ID);
            notify(this,'SensorDeleted',data);
        end
    end


    methods
        function set.CurrentPlatform(this,p)
            this.pCurrentPlatform=p;
            this.pCurrentWaypoint=0;
            notify(this,'NewPlatformSelected');
        end

        function platform=get.CurrentPlatform(this)
            platform=this.pCurrentPlatform;
        end

        function platform=getPlatformByID(this,id)
            narginchk(2,2);
            allSpecs=this.PlatformSpecifications;
            platform=allSpecs(find([allSpecs.ID]==id,1));
        end

        function idx=get.CurrentWaypoint(this)
            idx=this.pCurrentWaypoint;
        end

        function set.CurrentWaypoint(this,idx)
            this.pCurrentWaypoint=idx;
            notify(this,'CurrentWaypointChanged');
        end

        function clearCurrentWaypoint(this)

            this.CurrentWaypoint=0;
        end

        function addPlatform(this,varargin)
            if nargin>1&&isa(varargin{1},'fusion.internal.scenarioApp.dataModel.PlatformSpecification')
                spec=varargin{1};
            else
                spec=fusion.internal.scenarioApp.dataModel.PlatformSpecification(varargin{:});
            end
            addPlatformSpecification(this,spec);
        end

        function hSpecification=deletePlatform(this,index)
            allSpecs=this.PlatformSpecifications;
            if~isnumeric(index)
                index=find(allSpecs==index,1,'first');
            end
            hSpecification=allSpecs(index);


            sensorsToDelete=getSensorsByPlatform(this,hSpecification.ID);
            sensorSpecs=this.SensorSpecifications;
            sensorSpecs(arrayfun(@(x)find(sensorSpecs==x,1),sensorsToDelete))=[];
            this.SensorSpecifications=sensorSpecs;


            allSpecs(index)=[];
            if isempty(allSpecs)
                this.pCurrentPlatform=[];
            else
                this.pCurrentPlatform=allSpecs(1);
            end

            newSensorSpecs=getSensorsByPlatform(this);
            if isempty(newSensorSpecs)
                this.pCurrentSensor=[];
            else
                this.pCurrentSensor=newSensorSpecs(1);
            end

            this.PlatformSpecifications=allSpecs;
            notify(this,'SensorsChanged');
            notify(this,'PlatformDeleted');
        end

        function addPlatformSpecification(this,spec,index)
            allSpecs=this.PlatformSpecifications;



            spec.Name=getUniqueName(allSpecs,spec.Name);
            spec.ID=getUniqueID(allSpecs,spec.ID);
            if nargin<3
                this.PlatformSpecifications(end+1)=spec;
            else
                this.PlatformSpecifications=[allSpecs(1:index-1),spec,allSpecs(index:end)];
            end
            this.pCurrentPlatform=spec;
            notify(this,'PlatformAdded');
        end


        function[classStrings,classValue]=getSensorClassStrings(this)
            classSpecs=this.SensorClassSpecifications;
            allIds=getAllIds(classSpecs);
            classStrings=cell(1,numel(allIds));
            for i=1:numel(allIds)
                classStrings{i}=getProperty(classSpecs,allIds(i),'name');
            end

            currentSensor=this.CurrentSensor;
            classSpec=classSpecs.getSpecification(currentSensor.ClassID);
            classValue=find(strcmp(classSpec.name,classStrings),1,'first');
            if isempty(classValue)
                classStrings=[classStrings,{'Undefined Class'}];
                classValue=numel(classStrings);
            end
        end

        function time=getLastFiniteTime(this)
            time=0;
            platSpecs=this.PlatformSpecifications;
            for i=1:numel(platSpecs)
                endTime=platSpecs(i).EndTime;
                if isfinite(endTime)
                    time=max(endTime,time);
                end
            end
        end

        function time=getLastTrajectoryTime(this)
            time=getLastFiniteTime(this);



            if time==0
                time=inf;
            end
        end

        function totalTime=lastSensorTime(this)



            maxTime=getLastTrajectoryTime(this);

            totalTime=NaN;
            platSpecs=this.PlatformSpecifications;
            for i=1:numel(platSpecs)
                plat=platSpecs(i);
                sensorSpecs=getSensorsByPlatform(this,plat.ID);
                for j=1:numel(sensorSpecs)
                    sensor=sensorSpecs(j);
                    updateRate=sensor.UpdateRate;
                    toa=plat.TrajectorySpecification.TimeOfArrival;
                    if isscalar(toa)

                        sensorEndTime=toa(1)+floor((maxTime-toa(1))*updateRate)/updateRate;
                    else

                        sensorEndTime=toa(1)+floor((toa(end)-toa(1))*updateRate)/updateRate;
                    end
                    totalTime=max(sensorEndTime,totalTime);
                end
            end
        end

        function initTotalTime(this)

            totalTime=getLastTrajectoryTime(this);


            rate=getScenarioUpdateRate(this);

            if rate>0

                totalTime=floor(totalTime*rate)/rate;
            else

                totalTime=lastSensorTime(this);
            end

            initTotalTime(this.SimulatorSpecification,totalTime);
        end


        function deleteCurrentTrajectory(this)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                deleteTrajectory(currentPlatform);
                notify(this,'TrajectoryChanged');
            end
        end


        function setCurrentPositionXY(this,newXY)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                currentPlatform.Position(1:2)=newXY;
                notify(this,'TrajectoryChanged');
            end
        end


        function setCurrentPositionZ(this,newZ)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                currentPlatform.Position(3)=newZ;
                notify(this,'TrajectoryChanged');
            end
        end


        function setCurrentWaypointXY(this,newXY)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                idx=this.CurrentWaypoint;
                traj=currentPlatform.TrajectorySpecification;
                traj.Position(idx,1:2)=newXY(1:2);
                autoAdjust(traj);
                notify(this,'TrajectoryChanged');
            end
        end


        function setCurrentWaypointTZ(this,newTZ)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                idx=this.CurrentWaypoint;
                traj=currentPlatform.TrajectorySpecification;
                traj.Position(idx,3)=newTZ(2);
                this.pCurrentWaypoint=reassignTimeIndex(traj,idx,newTZ(1));
                notify(this,'TrajectoryChanged');
            end
        end


        function moveCurrentTrajectory(this,template,offset)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                newTraj=copy(template);
                newTraj.Position=newTraj.Position+offset;
                autoAdjust(newTraj);
                currentPlatform.TrajectorySpecification=newTraj;
                notify(this,'TrajectoryChanged');
            end
        end


        function extendCurrentTrajectory(this,template,newXY)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                newTraj=extend(template,newXY);
                currentPlatform.TrajectorySpecification=newTraj;
                notify(this,'TrajectoryChanged');
            end
        end

        function replaceCurrentTrajectory(this,replacement)
            currentPlatform=this.CurrentPlatform;
            if~isempty(currentPlatform)
                currentPlatform.TrajectorySpecification=replacement;
                notify(this,'TrajectoryChanged');
            end
        end


        function updateRadarSpecification(this)
            for i=1:numel(this.SensorSpecifications)
                updateRadarSpecification(this.SensorSpecifications(i));
            end
        end
    end


    methods
        function importScenario(this,hScenario,warningHandler)
            importScenario(this.SimulatorSpecification,hScenario,warningHandler);


            sensorID=0;


            for platformID=1:numel(hScenario.Platforms)

                hPlatform=hScenario.Platforms{platformID};
                platSpec=fusion.internal.scenarioApp.dataModel.PlatformSpecification;
                platSpec.Name=strcat('Platform',num2str(platformID));

                importPlatform(platSpec,hPlatform,platformID,warningHandler)
                this.PlatformSpecifications(platformID)=platSpec;

                if~isequal(platformID,hPlatform.PlatformID)
                    warningHandler.addMessage('PlatformIDRenumbered',platformID);
                end

                cid=hPlatform.ClassID;
                if isscalar(cid)&&isnumeric(cid)&&isKey(this.PlatformClassSpecifications.Map,cid)
                    platSpec.ClassID=cid;
                elseif~isequal(cid,0)

                    warningHandler.addMessage('UndefinedClassID',platformID);
                end


                for j=1:numel(hPlatform.Sensors)
                    hSensor=hPlatform.Sensors{j};
                    if isa(hSensor,'monostaticRadarSensor')
                        sensorID=sensorID+1;
                        sensorSpec=fusion.internal.scenarioApp.dataModel.RadarSensorSpecification(platSpec.ID,...
                        'Name',strcat('Sensor',num2str(sensorID)),...
                        'ID',sensorID);
                        importMonostaticRadarSensor(sensorSpec,hSensor,warningHandler)
                        this.SensorSpecifications(sensorID)=sensorSpec;
                        if~isequal(hSensor.SensorIndex,sensorID)
                            warningHandler.addMessage('SensorIndexRenumbered',sensorID);
                        end
                    elseif isa(hSensor,'fusionRadarSensor')
                        if~strcmp(hSensor.DetectionMode,'Monostatic')
                            warningHandler.addMessage('NotMonoSensorIgnored',platformID);
                        elseif strcmp(hSensor.TargetReportFormat,'Tracks')
                            warningHandler.addMessage('TrackSensorIgnored',platformID);
                        else

                            sensorID=sensorID+1;
                            sensorSpec=fusion.internal.scenarioApp.dataModel.RadarSensorSpecification(platSpec.ID,...
                            'Name',strcat('Sensor',num2str(sensorID)),...
                            'ID',sensorID);
                            importFusionRadarSensor(sensorSpec,hSensor,warningHandler)
                            this.SensorSpecifications(sensorID)=sensorSpec;
                            if~isequal(hSensor.SensorIndex,0)&&~isequal(hSensor.SensorIndex,sensorID)
                                warningHandler.addMessage('SensorIndexRenumbered',sensorID);
                            end
                        end
                    else
                        warningHandler.addMessage('NotMonoSensorIgnored',platformID);
                    end
                end

                if~isempty(hPlatform.Emitters)
                    warningHandler.addMessage('EmitterIgnored',platformID);
                end
            end


            if~isempty(this.PlatformSpecifications)
                this.pCurrentPlatform=this.PlatformSpecifications(1);
                resetCurrentSensor(this);
            end
        end
    end


    methods
        function hScenario=generateScenario(this,simMode)
            hScenario=trackingScenario;
            applyToScenario(this.SimulatorSpecification,hScenario);


            platSpecs=this.PlatformSpecifications;
            for iPlat=1:numel(platSpecs)
                applyToScenario(platSpecs(iPlat),hScenario);
            end


            if strcmp(simMode,'detections')
                sensorSpecs=this.SensorSpecifications;
                if~isempty(sensorSpecs)

                    sensors=cell(numel(sensorSpecs),1);
                    for iSensor=1:numel(sensors)
                        sensors{iSensor}=generateSensor(sensorSpecs(iSensor));
                    end


                    SIDs=vertcat(sensorSpecs(:).PlatformID);
                    PIDs=vertcat(platSpecs(:).ID);
                    for iPlat=1:numel(platSpecs)
                        hScenario.Platforms{iPlat}.Sensors=sensors(ismember(SIDs,PIDs(iPlat)));
                    end
                end
                updateRate=getScenarioUpdateRate(this);
            else
                updateRate=getScenarioUpdateRate(this,true);
                value=lastSensorTime(this);
                if value>0
                    hScenario.StopTime=value;
                end
            end


            hScenario.UpdateRate=updateRate;
        end

        function rate=getScenarioUpdateRate(this,noDetMode)

            if nargin==1
                noDetMode=false;
            end

            if isempty(this.SensorSpecifications)||noDetMode


                endTime=inf;
                platSpecs=this.PlatformSpecifications;
                for iPlat=1:numel(platSpecs)
                    traj=platSpecs(iPlat).TrajectorySpecification;
                    if~isscalar(traj.TimeOfArrival)
                        endTime=min(endTime,traj.TimeOfArrival(end));
                    end
                end
                if isfinite(endTime)

                    rate=10.^(floor(log10(1000/endTime)));
                else

                    rate=10;
                end
            else

                rate=0;
            end
        end
    end


    methods
        function str=generateMatlabCode(this,viewOpts)
            hasSensors=~isempty(this.SensorSpecifications);


            header=generateHeader(this);


            mainLoopCode=generateMainLoopCode(this,hasSensors,viewOpts);


            [sceneCall,sceneFunction]=generateScenarioCode(this,hasSensors);


            readDataFunction=generateReadDataCode(this,hasSensors);


            [plotterCall,plotterFunction]=generatePlotterCode(this,hasSensors,viewOpts);


            str=sprintf('%s\n',vertcat(...
            header,...
            sceneCall,...
            plotterCall,...
            mainLoopCode,...
            readDataFunction,...
            plotterFunction,...
            sceneFunction));
        end
    end

    methods(Access=private)

        function code=generateMainLoopCode(this,hasSensors,viewOpts)

            sceneName=this.SimulatorSpecification.ScenarioName;
            code=vertcat("% Configure your tracker here:","",...
            "% Add a trackPlotter here:","",...
            "% Main simulation loop");

            code=vertcat(code,"while advance("+sceneName+") && ishghandle(tp.Parent)");

            if hasSensors
                loopCode=vertcat("% generate sensor data",...
                "[dets, configs, sensorConfigPIDs] = detect("+sceneName+");",...
                "",...
                "[truePosition, meas, measCov] = readData(scenario, dets);",...
                "");
            else
                loopCode=vertcat("% get positions",...
                "truePosition = readData(scenario);",...
                "");
            end

            loopCode=vertcat(loopCode,"% update your tracker here:","");
            loopCode=vertcat(loopCode,"% update plots");
            loopCode=vertcat(loopCode,"plotPlatform(platp,truePosition);");
            if hasSensors
                loopCode=vertcat(loopCode,"plotDetection(detp,meas,measCov);");
                if viewOpts.EnableCoverage
                    loopCode=vertcat(loopCode,"plotCoverage(covp,coverageConfig("+sceneName+"));");
                end
            end

            loopCode=vertcat(loopCode,"","% Update the trackPlotter here:","");
            loopCode=vertcat(loopCode,"drawnow");

            code=vertcat(code,"    "+loopCode,"end","","");
        end

        function code=generatePlatCode(this)
            code=vertcat("","% Create platforms");
            platSpecs=this.PlatformSpecifications;
            for iPlat=1:numel(platSpecs)
                code=vertcat(code,generateMatlabCode(platSpecs(iPlat),'scenario'),"");%#ok<AGROW>
            end
        end

        function code=generateSensorCode(this)
            code=string.empty;
            sensorSpecs=this.SensorSpecifications;
            if~isempty(sensorSpecs)
                code=vertcat("","% Create sensors");
                for iSensor=1:numel(sensorSpecs)
                    code=vertcat(code,generateMatlabCode(sensorSpecs(iSensor)),"");%#ok<AGROW>
                end
            end
        end

        function code=generateSensorAssignmentCode(this)
            sensorSpecs=this.SensorSpecifications;
            if isempty(sensorSpecs)
                code=string.empty;
            else
                platSpecs=this.PlatformSpecifications;

                code=vertcat("","% Assign sensors to platforms");
                SIDs=vertcat(sensorSpecs(:).PlatformID);
                PIDs=vertcat(platSpecs(:).ID);
                for iPlat=1:numel(platSpecs)
                    iSensors=find(ismember(SIDs,PIDs(iPlat)));
                    platName=matlab.lang.makeValidName(platSpecs(iPlat).Name);
                    if~isempty(iSensors)
                        if isscalar(iSensors)
                            assignmentStr=strcat(platName,".Sensors = ",matlab.lang.makeValidName(sensorSpecs(iSensors).Name),";");
                        else
                            assignmentStr=strcat(platName,".Sensors = {");
                            for iSensor=1:numel(iSensors)-1
                                assignmentStr=strcat(assignmentStr,matlab.lang.makeValidName(sensorSpecs(iSensors(iSensor)).Name),', ');
                            end
                            assignmentStr=strcat(assignmentStr,matlab.lang.makeValidName(sensorSpecs(iSensors(end)).Name),'};');
                        end
                        code=vertcat(code,assignmentStr);%#ok<AGROW>
                    end
                end
            end
        end

        function code=generateReadDataCode(~,hasSensors)
            if hasSensors
                code=vertcat(...
                "function [position, meas, measCov] = readData(scenario,dets)",...
                "allDets = [dets{:}];",...
                "",...
                "if ~isempty(allDets)",...
                "    % extract column vector of measurement positions",...
                "    meas = cat(2,allDets.Measurement)';",...
                "",...
                "    % extract measurement noise",...
                "    measCov = cat(3,allDets.MeasurementNoise);",...
                "else",...
                "    meas = zeros(0,3);",...
                "    measCov = zeros(3,3,0);",...
                "end","");
            else
                code=vertcat("function position = readData(scenario)","");
            end
            code=vertcat(code,...
            "truePoses = platformPoses(scenario);",...
            "position = vertcat(truePoses(:).Position);",...
            "end","","");
        end

        function[plotCall,plotFunction]=generatePlotterCode(~,hasSensors,viewOpts)


            function s=scaleStr(x)
                s=mat2str(1.1*(x-mean(x))+mean(x));
            end

            outArgs="[tp, platp";

            if hasSensors
                outArgs=outArgs+", detp";
            end

            if hasSensors&&viewOpts.EnableCoverage
                outArgs=outArgs+", covp";
            end

            outArgs=outArgs+"]";

            plotCall=vertcat(outArgs+" = createPlotters();","");

            tp="tp = theaterPlot('XLim', "+scaleStr(viewOpts.XLimits)...
            +", 'YLim', "+scaleStr(viewOpts.YLimits)...
            +", 'ZLim', "+scaleStr(viewOpts.ZLimits)+");";

            tp=vertcat(tp,...
            "set(tp.Parent,'YDir','reverse', 'ZDir','reverse');",...
            "view(tp.Parent, "+num2str(viewOpts.ViewAngles(1))+", "+num2str(viewOpts.ViewAngles(2))+");");

            platp="platp = platformPlotter(tp,'DisplayName','Platforms','MarkerFaceColor','k');";

            if hasSensors
                detp="detp = detectionPlotter(tp,'DisplayName','Detections','MarkerSize',6,'MarkerFaceColor',[0.85 0.325 0.098],'MarkerEdgeColor','k','History',10000);";
            else
                detp=string.empty;
            end

            if hasSensors&&viewOpts.EnableCoverage
                covp="covp = coveragePlotter(tp,'DisplayName','Sensor Coverage');";
            else
                covp=string.empty;
            end


            plotFunction=vertcat("function "+outArgs+" = createPlotters",...
            "% Create plotters",...
            tp,...
            platp,...
            detp,...
            covp,...
            "end",...
            "",...
            "");
        end

        function[sceneCall,sceneFunction]=generateScenarioCode(this,hasSensors)

            sceneName=this.SimulatorSpecification.ScenarioName;


            sceneCall=sceneName+" = createScenario();";


            scenarioCode=generateMatlabCode(this.SimulatorSpecification,hasSensors);


            platCode=generatePlatCode(this);


            sensorCode=generateSensorCode(this);


            assignCode=generateSensorAssignmentCode(this);


            sceneFunction=vertcat("function "+sceneName+" = createScenario",...
            scenarioCode,...
            platCode,...
            sensorCode,...
            assignCode,...
            "end");
        end

        function str=generateHeader(~)
            str=string(matlabshared.application.getFileHeader('','fusion'));
            str=vertcat(str,"");
        end

    end

    methods
        function new(this)


            this.pCurrentPlatform=[];
            this.pCurrentSensor=[];


            this.PlatformSpecifications=fusion.internal.scenarioApp.dataModel.PlatformSpecification.empty;
            this.SensorSpecifications=fusion.internal.scenarioApp.dataModel.SensorSpecification.empty;
            notify(this,'PlatformsChanged');
            notify(this,'SensorsChanged');


            reset(this.SimulatorSpecification);


            delete(this.PlatformClassSpecifications);
            delete(this.SensorClassSpecifications);
            this.PlatformClassSpecifications=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications;
            this.SensorClassSpecifications=fusion.internal.scenarioApp.dataModel.SensorClassSpecifications;
        end
    end
end

function name=getUniqueName(specs,name)

    if isempty(specs)
        return;
    end

    rawName=name;


    rawName(regexp(rawName,'(\d+)$'):end)=[];
    indx=1;
    allNames={specs.Name};
    while any(strcmp(allNames,name))
        name=sprintf('%s%d',rawName,indx);
        indx=indx+1;
    end

end

function id=getUniqueID(specs,id)

    if isempty(specs)
        return;
    end

    indx=1;
    allIDs=[specs.ID];
    while any(allIDs==id)
        id=id+1;
        indx=indx+1;
    end
end


