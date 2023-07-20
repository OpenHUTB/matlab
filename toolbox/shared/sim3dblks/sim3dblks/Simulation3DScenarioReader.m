classdef Simulation3DScenarioReader<Simulation3DSensor...
    &matlabshared.tracking.internal.SimulinkBusUtilities...
    &Simulation3DHandleMap



    properties(Nontunable)



        SensorConfiguration(1,:)char='APlayerStart,AStaticMeshActor,ASim3dActor,ASim3dPassVeh';
        maxNumReportedActors(1,1)int32=64;
        maxNumReportedLaneBoundaries(1,1)int32=16;
        laneSampleDistances=0:0.5:9.5;
        BusName2Source='Auto';
        BusName2=char.empty(1,0);
    end

    properties(Constant,Access=protected)
        pBusPrefix={'BusSimulation3DActors','BusSimulation3DLaneBoundaries'};

        defaultActorPose=struct(...
        "ActorID",1,...
        "Position",[0,0,0],...
        "Velocity",[0,0,0],...
        "Roll",0,...
        "Pitch",0,...
        "Yaw",0,...
        "AngularVelocity",[0,0,0]...
        );

        defaultLaneBoundaryTemplate=struct(...
        "Coordinates",[],...
        "Curvature",[],...
        "CurvatureDerivative",[],...
        "HeadingAngle",0,...
        "LateralOffset",0,...
        "BoundaryType",uint8(0),...
        "Strength",0,...
        "Width",0,...
        "Length",0,...
        "Space",0...
        );
    end

    properties(Access=protected)
        stepIndex=0;
        LaneOutputEnabled=true;
        TransformReader=[];
    end

    properties(Access=private)
        ModelName=[];
        pRoadNetwork;
        pLaneBoundariesSize=[2,1];
        pAllBoundaries=1;
        pIsInnerLaneBoundary=0;
        messageFromSceneConfig=[];
        MATFileName=[];
        OpenDRIVEFile="";
        SceneHasRoads=true;
    end

    methods(Access=protected)
        function defaultLaneBoundary=defaultLaneBoundary(self)
            defaultLaneBoundary=self.defaultLaneBoundaryTemplate;
            n=length(self.laneSampleDistances);
            defaultLaneBoundary.Coordinates=zeros(n,3);
            defaultLaneBoundary.Curvature=zeros(n,1);
            defaultLaneBoundary.CurvatureDerivative=zeros(n,1);
        end

        function convertOpenDRIVEFileToMat(self,OpenDRIVEFile,MatFileName)
            scenario=drivingScenario;
            roadNetwork(scenario,'OpenDRIVE',OpenDRIVEFile);
            data.RoadSpecifications=[driving.internal.scenarioApp.road.Arbitrary.fromScenario(scenario),...
            driving.internal.scenarioApp.road.RoadGroupArbitrary.fromScenario(scenario)];
            data.ActorSpecifications=driving.internal.scenarioApp.ActorSpecification.empty;
            data.EgoCarId=[];
            tag='session';
            self.MATFileName=MatFileName;
            save(self.MATFileName,'data','tag');
        end

        function fetchMatFile(self)

            self.OpenDRIVEFile=self.messageFromSceneConfig.OpenDRIVEFile;
            [filePath,newMatFileName,~]=fileparts(self.OpenDRIVEFile);
            newMatFileName=strcat(filePath,'\',newMatFileName,'.mat');

            if~(exist(newMatFileName,'file')==2)
                convertOpenDRIVEFileToMat(self,self.OpenDRIVEFile,newMatFileName)
            else
                dateComparison=dir(self.OpenDRIVEFile).datenum-dir(newMatFileName).datenum;
                if dateComparison>0
                    convertOpenDRIVEFileToMat(self,self.OpenDRIVEFile,newMatFileName)
                else
                    self.MATFileName=newMatFileName;
                end
            end
        end

        function setupImpl(self)
            setupImpl@Simulation3DSensor(self);
            if coder.target('MATLAB')
                cfg=self.SensorConfiguration;

                subscriber=sim3d.io.Subscriber('Sim3DVDG Lanes');
                if subscriber.has_message()
                    self.messageFromSceneConfig=subscriber.take();
                end

                if(~isempty(self.messageFromSceneConfig))
                    if(~isempty(self.messageFromSceneConfig.MatFile))
                        self.MATFileName=self.messageFromSceneConfig.MatFile;

                    elseif(self.messageFromSceneConfig.EnableOpenDRIVEFile)
                        if(~isempty(self.messageFromSceneConfig.OpenDRIVEFile))
                            fetchMatFile(self);
                        else
                            error(message("shared_sim3dblks:sim3dblkVisDetect:blkErr_missingOpenDRIVEFile"));
                        end

                    else
                        self.SceneHasRoads=false;
                    end
                else
                    error(message("shared_sim3dblks:sim3dblkVisDetect:blkErr_communicationError"));
                end
                generateScenarioDataForSimulink(self);
                if self.LaneOutputEnabled
                    if(self.SceneHasRoads)
                        readRoadNetwork(self);
                    end
                end
                transform=sim3d.utils.Transform(self.Translation,self.Rotation);
                self.Sensor=sim3d.sensors.GroundTruth(self.SensorIdentifier,self.VehicleIdentifier,char(cfg),transform);
                self.Sensor.setup();
                self.Sensor.reset();
                self.TransformReader=sim3d.io.ActorTransformReader(self.VehicleIdentifier,uint32(1));
                self.ModelName=['Simulation3DScenarioReader/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    self.Sensor.read();
                end
            end
        end

        function[posesOnBus,varargout]=stepImpl(self)
            self.stepIndex=self.stepIndex+1;

            if~coder.target('MATLAB')
                return
            end

            if isempty(self.Sensor)
                return
            end




            sensorOutput=self.Sensor.read();
            actorsMask=cellfun(@(obj)isfield(obj,"ObjectClassID"),sensorOutput);
            actorPoses=self.formatActorPoses(sensorOutput(actorsMask));

            posesOnBus=self.sendToBus(actorPoses,1);
            [translation,rotation,~]=self.TransformReader.read();
            translation(1,2)=-translation(1,2);
            rotation=-rad2deg(rotation);



            if(strcmp(self.VehicleIdentifier,"Scene Origin"))
                egoVehicle=self.defaultActorPose;
            else

                egoVehicle=struct('ActorID',1,'Position',double(translation(1,:)),...
                'Velocity',[0,0,0],'Roll',double(rotation(1,1)),'Pitch',double(rotation(1,2)),'Yaw',double(rotation(1,3)),...
                'AngularVelocity',[0,0,0]);
            end

            if self.LaneOutputEnabled
                if(self.SceneHasRoads)
                    lbStruct=driving.scenario.internal.laneBoundaries(self.pRoadNetwork,egoVehicle,self.laneSampleDistances,...
                    self.pIsInnerLaneBoundary,self.pAllBoundaries,self.pLaneBoundariesSize);
                    laneBoundary=lbStruct([lbStruct.BoundaryType]~=0);
                    laneBoundary=laneBoundary';
                else
                    if(strcmp(self.messageFromSceneConfig.ProjectFormat,"Default Scenes"))
                        warning(message("shared_sim3dblks:sim3dblkVisDetect:blkWrn_roadsNotFoundDefaultScene"))
                    else
                        warning(message("shared_sim3dblks:sim3dblkVisDetect:blkWrn_roadsNotFoundCustomScene"))
                    end
                    laneBoundary=[];
                end
                varargout{1}=self.sendToBus(laneBoundary,2);
            end
        end

        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            if self.loadflag
                self.ModelName=s.ModelName;
                self.Sensor=self.Sim3dSetGetHandle([self.ModelName,'/Sensor']);
                loadObjectImpl@matlab.System(self,s,wasInUse);
            else
                loadObjectImpl@Simulation3DSensor(self,s.sensor_s,wasInUse);
            end
            loadObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(self,s.buses_s,wasInUse);
            self.SensorConfiguration=s.SensorConfiguration;
            self.maxNumReportedActors=s.maxNumReportedActors;
            self.maxNumReportedLaneBoundaries=s.maxNumReportedLaneBoundaries;
            self.laneSampleDistances=s.laneSampleDistances;
            self.BusName2Source=s.BusName2Source;
            self.BusName2=s.BusName2;
            self.stepIndex=s.stepIndex;
            self.LaneOutputEnabled=s.LaneOutputEnabled;
            self.TransformReader=s.TransformReader;
            self.pRoadNetwork=s.pRoadNetwork;
            self.pLaneBoundariesSize=s.pLaneBoundariesSize;
            self.pAllBoundaries=s.pAllBoundaries;
            self.pIsInnerLaneBoundary=s.pIsInnerLaneBoundary;
            self.messageFromSceneConfig=s.messageFromSceneConfig;
            self.MATFileName=s.messageFromSceneConfig.MatFile;
            self.OpenDRIVEFile=s.OpenDRIVEFile;
        end

        function s=saveObjectImpl(self)


            s=struct(...
            "sensor_s",saveObjectImpl@Simulation3DSensor(self),...
            "buses_s",saveObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(self)...
            );
            s.ModelName=self.ModelName;

            s.SensorConfiguration=self.SensorConfiguration;
            s.maxNumReportedActors=self.maxNumReportedActors;
            s.maxNumReportedLaneBoundaries=self.maxNumReportedLaneBoundaries;
            s.laneSampleDistances=self.laneSampleDistances;
            s.BusName2Source=self.BusName2Source;
            s.BusName2=self.BusName2;
            s.stepIndex=self.stepIndex;
            s.LaneOutputEnabled=self.LaneOutputEnabled;
            s.TransformReader=self.TransformReader;
            s.pRoadNetwork=self.pRoadNetwork;
            s.pLaneBoundariesSize=self.pLaneBoundariesSize;
            s.pAllBoundaries=self.pAllBoundaries;
            s.pIsInnerLaneBoundary=self.pIsInnerLaneBoundary;
            s.messageFromSceneConfig=self.messageFromSceneConfig;
            s.MATFileName=self.messageFromSceneConfig.MatFile;
            s.OpenDRIVEFile=self.OpenDRIVEFile;
        end

        function generateScenarioDataForSimulink(self)
            coder.extrinsic('driving.scenario.internal.Utilities.generateCompiledScenarioData');
            coder.extrinsic('gcbh');
            blkHandle=coder.const(gcbh);
            fullName=driving.scenario.internal.ScenarioReader.getFullScenarioFileName(self.MATFileName);
            if~isempty(fullName)

                driving.scenario.internal.Utilities.generateCompiledScenarioData(fullName,blkHandle,0.1);
            end
        end

        function num=getNumOutputsImpl(self)
            num=1+self.LaneOutputEnabled;
        end

        function[sz1,varargout]=getOutputSizeImpl(self)
            sz1=[1,1];

            if self.LaneOutputEnabled
                varargout{1}=[1,1];
            end
        end

        function[fz1,varargout]=isOutputFixedSizeImpl(self)
            fz1=true;

            if self.LaneOutputEnabled
                varargout{1}=true;
            end
        end

        function[dt1,varargout]=getOutputDataTypeImpl(self)
            if~self.LaneOutputEnabled
                dt1=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(self);
                varargout={};
            else
                [dt1,varargout{1}]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(self);
            end
        end

        function[cp1,varargout]=isOutputComplexImpl(self)
            cp1=false;

            if self.LaneOutputEnabled
                varargout{1}=false;
            end
        end

        function[pn1,varargout]=getOutputNamesImpl(self)

            pn1='Actors';

            if self.LaneOutputEnabled
                varargout{1}='Lane Boundaries';
            end
        end

        function icon=getIconImpl(~)

            icon={'Simulation 3D','Scenario Reader'};
        end

        function readRoadNetwork(self)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getFullScenarioFileName(self.MATFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'RoadNetwork'};
            flag=self.checkStructForFields(s,expFields);
            if flag
                self.pRoadNetwork=s.RoadNetwork;
                if isempty(self.pRoadNetwork)
                    self.pLaneBoundariesSize=[2,1];
                else


                    mbLength=size(self.pRoadNetwork.MaxLaneBoundaryCenter,2);
                    self.pLaneBoundariesSize=[mbLength,1];
                end
            end
        end

        function[output,argsToBus]=defaultOutput(self,busIndex)
            switch busIndex
            case 1
                actors=repmat(...
                self.defaultActorPose,...
                [1,self.maxNumReportedActors]...
                );

                output=actors;
                argsToBus={};

            case 2
                lb=self.defaultLaneBoundary();
                n=length(self.laneSampleDistances);

                lb.Coordinates=zeros(n,3);
                lb.Curvature=zeros(n,1);
                lb.CurvatureDerivative=zeros(n,1);

                laneBoundaries=repmat(...
                lb,...
                [1,self.maxNumReportedLaneBoundaries]...
                );

                output=laneBoundaries;
                argsToBus={};
            end
        end

        function bus=sendToBus(self,structs,structType,varargin)
            switch structType
            case 1
                bus=self.sendItemsToBus("Actors",self.maxNumReportedActors,self.defaultActorPose,structs);
            case 2
                bus=self.sendItemsToBus("LaneBoundaries",self.maxNumReportedLaneBoundaries,self.defaultLaneBoundary(),structs);
            end
        end

        function output=sendItemsToBus(self,itemName,maxNumItems,defaultItem,items)
            numItems=min(maxNumItems,numel(items));

            if numItems==0
                items=defaultItem;
            end

            tailLength=max(0,maxNumItems-numItems);
            tail=repmat(defaultItem,[1,tailLength]);

            currentTime=self.getCurrentTime();
            if isempty(currentTime)
                currentTime=0;
            end

            output=struct(...
            sprintf("Num%s",itemName),numItems,...
            "Time",currentTime,...
            itemName,transpose([items(1:numItems),tail])...
            );
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(...
            'Title','Simulation 3D Scenario Reader');
        end

        function flag=checkStructForFields(s,expFields)


            flag=true;
            for i=1:numel(expFields)
                if~isfield(s,expFields{i})
                    flag=false;
                    return
                end
            end
        end

        function groups=getPropertyGroupsImpl
            params=matlab.system.display.Section(...
            'Title','',...
            'PropertyList',{...
            'SensorIdentifier',...
            'VehicleIdentifier',...
            'SensorConfiguration',...
            'maxNumReportedActors',...
            'maxNumReportedLaneBoundaries',...
            'laneSampleDistances',...
            'SampleTime',...
            'BusNameSource',...
            'BusName2Source',...
            }...
            );
            groups=params;
        end

        function simMode=getSimulateUsingImpl
            simMode='Interpreted execution';
        end

        function actorPoses=formatActorPoses(actorPosesAsCells)
            if isempty(actorPosesAsCells)
                actorPoses=[];
                return
            end

            actorPoses=[actorPosesAsCells{:}];


            [actorPoses.ActorID]=actorPoses.ObjectClassID;

            for i=1:length(actorPoses)
                actorPoses(i).ActorID=i;

                actorPoses(i).Position=actorPoses(i).Position.*[1,-1,1];
                actorPoses(i).Rotation=rad2deg(actorPoses(i).Rotation.*[1,1,-1]);
            end


            rotation=[actorPoses.Rotation];
            rollPitchYaw=num2cell(reshape(rotation,3,length(rotation)/3));

            [actorPoses.Roll]=rollPitchYaw{1,:};
            [actorPoses.Pitch]=rollPitchYaw{2,:};
            [actorPoses.Yaw]=rollPitchYaw{3,:};

            actorPoses=rmfield(actorPoses,...
            ["ActorName","ObjectClassID","Rotation"]);
            actorPoses=orderfields(actorPoses,...
            Simulation3DScenarioReader.defaultActorPose);
        end

    end
end
