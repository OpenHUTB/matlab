classdef ScenarioDataBuilder<driving.internal.scenarioApp.ScenarioBuilder



    properties
Scenario
    end

    methods
        function this=ScenarioDataBuilder

            this@driving.internal.scenarioApp.ScenarioBuilder;
            this.Scenario=drivingScenario;
        end

        function generateCompiledScenarioData(this,roadSpecs,actorSpecs,...
            barrierSpecs,egoCarId,sampleTime,stopTime,verticalAxis,sessionFilePath)



            for kndx=1:length(roadSpecs)
                this.addRoadSpecification(roadSpecs(kndx),kndx);
            end

            for kndx=1:length(actorSpecs)
                this.addActorSpecification(actorSpecs(kndx),kndx);
            end

            for kndx=1:length(barrierSpecs)
                this.addBarrierSpecification(barrierSpecs(kndx),kndx);
            end
            this.Scenario.SampleTime=sampleTime;
            this.Scenario.StopTime=stopTime;
            this.Scenario.VerticalAxis=verticalAxis;
            cacheCompiledScenarioData(this,sessionFilePath,egoCarId);
        end

        function updateCompiledScenarioData(this,sd,actorSpecs,sampleTime,...
            stopTime,verticalAxis,sessionFilePath)


            for kndx=1:length(actorSpecs)
                this.addActorSpecification(actorSpecs(kndx),kndx);
            end
            this.Scenario.SampleTime=sampleTime;
            this.Scenario.StopTime=stopTime;
            [sd.vehiclePoses,sd.vehicleStates,sd.isSmoothTrajectory]=getVehiclePoses(this);
            sd.StopTime=stopTime;
            sd.SampleTime=sampleTime;
            sd.VerticalAxis=verticalAxis;

            driving.scenario.internal.setGetCompiledScenarioData(sessionFilePath,sd);
        end

        function cacheCompiledScenarioData(this,key,varargin)

            sd=this.getScenarioData(varargin{:});

            driving.scenario.internal.setGetCompiledScenarioData(key,sd);

        end

        function[vehiclePoses,vehicleStates,isSmoothTrajectory]=getVehiclePoses(this)

            scenario=this.Scenario;
            stopTime=scenario.StopTime;
            if isempty(scenario.Actors)
                vehiclePoses=[];
                vehicleStates=[];
                isSmoothTrajectory=[];
            else
                time=0;
                vehiclePoses.SimulationTime=time;
                vehiclePoses.ActorPoses=actorPoses(scenario);
                vehicleStates.SimulationTime=time;
                vehicleStates.ActorStates=actorStates(scenario);
                isMoving=false;
                numActors=numel(scenario.Actors);
                isSmoothTrajectory=false(numActors,1);
                for indx=1:numActors
                    isMoving(indx)=~isa(scenario.Actors(indx).MotionStrategy,'driving.scenario.Stationary');
                    isSmoothTrajectory(indx)=isa(scenario.Actors(indx).MotionStrategy,'driving.scenario.SmoothTrajectory');
                end
                isRunning=isMoving;
                while any(isRunning)&&(time<=stopTime)
                    time=time+scenario.SampleTime;
                    vehiclePoses(end+1).SimulationTime=time;%#ok<AGROW>
                    vehicleStates(end+1).SimulationTime=time;%#ok<AGROW>


                    isRunning=move(scenario.Actors,time)&isMoving;
                    vehiclePoses(end).ActorPoses=actorPoses(scenario);
                    vehicleStates(end).ActorStates=actorStates(scenario);
                end
            end
        end

        function sd=getScenarioData(this,varargin)

            scenario=this.Scenario;
            [vehiclePoses,vehicleStates,isSmoothTrajectory]=getVehiclePoses(this);


            roads=roadBoundaries(scenario);
            catRoads=[];
            for kndx=1:numel(roads)
                catRoads=[catRoads;roads{kndx};NaN,NaN,NaN];%#ok<AGROW>
            end
            if~isempty(catRoads)
                catRoads(end,:)=[];
            end
            RoadBoundaries=struct('RoadBoundaries',catRoads);


            RoadNetwork=driving.scenario.internal.getRoadNetwork(scenario);


            [LaneMarkingVertices,LaneMarkingFaces]=laneMarkingVertices(scenario);%#ok<*ASGLU>


            sd.vehiclePoses=vehiclePoses;
            sd.vehicleStates=vehicleStates;
            sd.isSmoothTrajectory=isSmoothTrajectory;
            sd.RoadBoundaries=RoadBoundaries;
            sd.RoadNetwork=RoadNetwork;
            sd.LaneMarkingVertices=LaneMarkingVertices;
            sd.LaneMarkingFaces=LaneMarkingFaces;
            if nargin>1
                sd.EgoCarId=varargin{1};
            end
            if isempty(scenario.Actors)
                sd.ActorProfiles=[];
            else
                ap=actorProfiles(scenario);




                maxVertSize=1;
                maxFaceSize=1;
                for apndx=1:length(ap)
                    maxVertSize=max(maxVertSize,size(ap(apndx).MeshVertices,1));
                    maxFaceSize=max(maxFaceSize,size(ap(apndx).MeshFaces,1));
                end

                a=scenario.Actors;
                for indx=1:numel(a)

                    ap(indx).Color=round(255*a(indx).PlotColor);
                    ap(indx).MeshVertices(end+1:maxVertSize,:)=NaN;
                    ap(indx).MeshFaces(end+1:maxFaceSize,:)=NaN;
                end
                b=scenario.Barriers;
                for indx=1:numel(b)

                    ap(indx+numel(a)).Color=round(255*b(indx).BarrierSegments(1).PlotColor);
                    ap(indx+numel(a)).MeshVertices(end+1:maxVertSize,:)=NaN;
                    ap(indx+numel(a)).MeshFaces(end+1:maxFaceSize,:)=NaN;
                end
                sd.ActorProfiles=ap;
            end
            sd.StopTime=scenario.StopTime;
            sd.SampleTime=scenario.SampleTime;
            sd.VerticalAxis=scenario.VerticalAxis;
        end
    end

end


