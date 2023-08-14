classdef Asset<handle&matlabshared.satellitescenario.internal.ScenarioGraphicBase %#codegen




    properties(Dependent,SetAccess=private)



ID
    end

    properties(Access={?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AssetWrapper})
pName
    end

    properties(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satcom.satellitescenario.Link,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.coder.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG})

Simulator
        SimulatorID=0
Type
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.coder.internal.AssetWrapper})
pPosition
pPositionHistory
pVelocity
pVelocityHistory
pPositionITRF
pPositionITRFHistory
pVelocityITRF
pVelocityITRFHistory
pLatitude
pLatitudeHistory
pLongitude
pLongitudeHistory
pAltitude
pAltitudeHistory
pAttitude
pAttitudeHistory
pItrf2BodyTransform
pItrf2BodyTransformHistory
    end

    methods
        function id=get.ID(obj)


            coder.allowpcode('plain');

            id=obj.SimulatorID;
        end

        function position=get.pPosition(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                position=simulator.Satellites(idx).Position;
            case 2
                position=simulator.GroundStations(idx).Position;
            case 3
                position=simulator.ConicalSensors(idx).Position;
            case 4
                position=simulator.Gimbals(idx).Position;
            case 5
                position=simulator.Transmitters(idx).Position;
            otherwise
                position=simulator.Receivers(idx).Position;
            end
        end

        function positionHistory=get.pPositionHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                positionHistory=...
                simulator.Satellites(idx).PositionHistory;
            case 2
                positionHistory=...
                simulator.GroundStations(idx).PositionHistory;
            case 3
                positionHistory=...
                simulator.ConicalSensors(idx).PositionHistory;
            case 4
                positionHistory=...
                simulator.Gimbals(idx).PositionHistory;
            case 5
                positionHistory=...
                simulator.Transmitters(idx).PositionHistory;
            otherwise
                positionHistory=...
                simulator.Receivers(idx).PositionHistory;
            end
        end

        function velocity=get.pVelocity(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                velocity=simulator.Satellites(idx).Velocity;
            case 2
                velocity=simulator.GroundStations(idx).Velocity;
            case 3
                velocity=simulator.ConicalSensors(idx).Velocity;
            case 4
                velocity=simulator.Gimbals(idx).Velocity;
            case 5
                velocity=simulator.Transmitters(idx).Velocity;
            otherwise
                velocity=simulator.Receivers(idx).Velocity;
            end
        end

        function velocityHistory=get.pVelocityHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                velocityHistory=...
                simulator.Satellites(idx).VelocityHistory;
            case 2
                velocityHistory=...
                simulator.GroundStations(idx).VelocityHistory;
            case 3
                velocityHistory=...
                simulator.ConicalSensors(idx).VelocityHistory;
            case 4
                velocityHistory=...
                simulator.Gimbals(idx).VelocityHistory;
            case 5
                velocityHistory=...
                simulator.Transmitters(idx).VelocityHistory;
            otherwise
                velocityHistory=...
                simulator.Receivers(idx).VelocityHistory;
            end
        end

        function positionITRF=get.pPositionITRF(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                positionITRF=simulator.Satellites(idx).PositionITRF;
            case 2
                positionITRF=...
                simulator.GroundStations(idx).PositionITRF;
            case 3
                positionITRF=...
                simulator.ConicalSensors(idx).PositionITRF;
            case 4
                positionITRF=...
                simulator.Gimbals(idx).PositionITRF;
            case 5
                positionITRF=...
                simulator.Transmitters(idx).PositionITRF;
            otherwise
                positionITRF=...
                simulator.Receivers(idx).PositionITRF;
            end
        end

        function positionITRFHistory=get.pPositionITRFHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                positionITRFHistory=...
                simulator.Satellites(idx).PositionITRFHistory;
            case 2
                positionITRFHistory=...
                simulator.GroundStations(idx).PositionITRFHistory;
            case 3
                positionITRFHistory=...
                simulator.ConicalSensors(idx).PositionITRFHistory;
            case 4
                positionITRFHistory=...
                simulator.Gimbals(idx).PositionITRFHistory;
            case 5
                positionITRFHistory=...
                simulator.Transmitters(idx).PositionITRFHistory;
            otherwise
                positionITRFHistory=...
                simulator.Receivers(idx).PositionITRFHistory;
            end
        end

        function velocityITRF=get.pVelocityITRF(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                velocityITRF=simulator.Satellites(idx).VelocityITRF;
            case 2
                velocityITRF=...
                simulator.GroundStations(idx).VelocityITRF;
            case 3
                velocityITRF=...
                simulator.ConicalSensors(idx).VelocityITRF;
            case 4
                velocityITRF=...
                simulator.Gimbals(idx).VelocityITRF;
            case 5
                velocityITRF=...
                simulator.Transmitters(idx).VelocityITRF;
            otherwise
                velocityITRF=...
                simulator.Receivers(idx).VelocityITRF;
            end
        end

        function velocityITRFHistory=get.pVelocityITRFHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                velocityITRFHistory=...
                simulator.Satellites(idx).VelocityITRFHistory;
            case 2
                velocityITRFHistory=...
                simulator.GroundStations(idx).VelocityITRFHistory;
            case 3
                velocityITRFHistory=...
                simulator.ConicalSensors(idx).VelocityITRFHistory;
            case 4
                velocityITRFHistory=...
                simulator.Gimbals(idx).VelocityITRFHistory;
            case 5
                velocityITRFHistory=...
                simulator.Transmitters(idx).VelocityITRFHistory;
            otherwise
                velocityITRFHistory=...
                simulator.Receivers(idx).VelocityITRFHistory;
            end
        end

        function latitude=get.pLatitude(obj)


            coder.allowpcode('plain');

            latitude=0;

            if~isempty(obj)&&isprop(obj,'Simulator')


                simulator=obj.Simulator;


                idx=getIdxInSimulatorStruct(obj);


                switch obj.Type
                case 1
                    latitude=simulator.Satellites(idx).Latitude;
                case 2
                    latitude=simulator.GroundStations(idx).Latitude;
                case 3
                    latitude=simulator.ConicalSensors(idx).Latitude;
                case 4
                    latitude=simulator.Gimbals(idx).Latitude;
                case 5
                    latitude=simulator.Transmitters(idx).Latitude;
                otherwise
                    latitude=simulator.Receivers(idx).Latitude;
                end
            end
        end

        function latitudeHistory=get.pLatitudeHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                latitudeHistory=...
                simulator.Satellites(idx).LatitudeHistory;
            case 2
                latitudeHistory=...
                simulator.GroundStations(idx).LatitudeHistory;
            case 3
                latitudeHistory=...
                simulator.ConicalSensors(idx).LatitudeHistory;
            case 4
                latitudeHistory=...
                simulator.Gimbals(idx).LatitudeHistory;
            case 5
                latitudeHistory=...
                simulator.Transmitters(idx).LatitudeHistory;
            otherwise
                latitudeHistory=...
                simulator.Receivers(idx).LatitudeHistory;
            end
        end

        function longitude=get.pLongitude(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                longitude=simulator.Satellites(idx).Longitude;
            case 2
                longitude=simulator.GroundStations(idx).Longitude;
            case 3
                longitude=simulator.ConicalSensors(idx).Longitude;
            case 4
                longitude=simulator.Gimbals(idx).Longitude;
            case 5
                longitude=simulator.Transmitters(idx).Longitude;
            otherwise
                longitude=simulator.Receivers(idx).Longitude;
            end
        end

        function longitudeHistory=get.pLongitudeHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                longitudeHistory=...
                simulator.Satellites(idx).LongitudeHistory;
            case 2
                longitudeHistory=...
                simulator.GroundStations(idx).LongitudeHistory;
            case 3
                longitudeHistory=...
                simulator.ConicalSensors(idx).LongitudeHistory;
            case 4
                longitudeHistory=...
                simulator.Gimbals(idx).LongitudeHistory;
            case 5
                longitudeHistory=...
                simulator.Transmitters(idx).LongitudeHistory;
            otherwise
                longitudeHistory=...
                simulator.Receivers(idx).LongitudeHistory;
            end
        end

        function altitude=get.pAltitude(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                altitude=simulator.Satellites(idx).Altitude;
            case 2
                altitude=simulator.GroundStations(idx).Altitude;
            case 3
                altitude=simulator.ConicalSensors(idx).Altitude;
            case 4
                altitude=simulator.Gimbals(idx).Altitude;
            case 5
                altitude=simulator.Transmitters(idx).Altitude;
            otherwise
                altitude=simulator.Receivers(idx).Altitude;
            end
        end

        function altitudeHistory=get.pAltitudeHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                altitudeHistory=...
                simulator.Satellites(idx).AltitudeHistory;
            case 2
                altitudeHistory=...
                simulator.GroundStations(idx).AltitudeHistory;
            case 3
                altitudeHistory=...
                simulator.ConicalSensors(idx).AltitudeHistory;
            case 4
                altitudeHistory=...
                simulator.Gimbals(idx).AltitudeHistory;
            case 5
                altitudeHistory=...
                simulator.Transmitters(idx).AltitudeHistory;
            otherwise
                altitudeHistory=...
                simulator.Receivers(idx).AltitudeHistory;
            end
        end

        function attitude=get.pAttitude(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                attitude=simulator.Satellites(idx).Attitude;
            case 2
                attitude=simulator.GroundStations(idx).Attitude;
            case 3
                attitude=simulator.ConicalSensors(idx).Attitude;
            case 4
                attitude=simulator.Gimbals(idx).Attitude;
            case 5
                attitude=simulator.Transmitters(idx).Attitude;
            otherwise
                attitude=simulator.Receivers(idx).Attitude;
            end
        end

        function attitudeHistory=get.pAttitudeHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                attitudeHistory=...
                simulator.Satellites(idx).AttitudeHistory;
            case 2
                attitudeHistory=...
                simulator.GroundStations(idx).AttitudeHistory;
            case 3
                attitudeHistory=...
                simulator.ConicalSensors(idx).AttitudeHistory;
            case 4
                attitudeHistory=...
                simulator.Gimbals(idx).AttitudeHistory;
            case 5
                attitudeHistory=...
                simulator.Transmitters(idx).AttitudeHistory;
            otherwise
                attitudeHistory=...
                simulator.Receivers(idx).AttitudeHistory;
            end
        end

        function itrf2bodyTransform=get.pItrf2BodyTransform(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                itrf2bodyTransform=...
                simulator.Satellites(idx).Itrf2BodyTransform;
            case 2
                itrf2bodyTransform=...
                simulator.GroundStations(idx).Itrf2BodyTransform;
            case 3
                itrf2bodyTransform=...
                simulator.ConicalSensors(idx).Itrf2BodyTransform;
            case 4
                itrf2bodyTransform=...
                simulator.Gimbals(idx).Itrf2BodyTransform;
            case 5
                itrf2bodyTransform=...
                simulator.Transmitters(idx).Itrf2BodyTransform;
            otherwise
                itrf2bodyTransform=...
                simulator.Receivers(idx).Itrf2BodyTransform;
            end
        end

        function itrf2bodyTransformHistory=get.pItrf2BodyTransformHistory(obj)


            coder.allowpcode('plain');


            simulator=obj.Simulator;


            idx=getIdxInSimulatorStruct(obj);


            switch obj.Type
            case 1
                itrf2bodyTransformHistory=...
                simulator.Satellites(idx).Itrf2BodyTransformHistory;
            case 2
                itrf2bodyTransformHistory=...
                simulator.GroundStations(idx).Itrf2BodyTransformHistory;
            case 3
                itrf2bodyTransformHistory=...
                simulator.ConicalSensors(idx).Itrf2BodyTransformHistory;
            case 4
                itrf2bodyTransformHistory=...
                simulator.Gimbals(idx).Itrf2BodyTransformHistory;
            case 5
                itrf2bodyTransformHistory=...
                simulator.Transmitters(idx).Itrf2BodyTransformHistory;
            otherwise
                itrf2bodyTransformHistory=...
                simulator.Receivers(idx).Itrf2BodyTransformHistory;
            end
        end
    end

    methods(Hidden)
        function idx=getIdxInSimulatorStruct(obj)



            coder.allowpcode('plain');


            simulator=obj.Simulator;


            simID=obj.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end
    end
end

