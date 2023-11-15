% 参与者工厂
classdef ActorFactory < handle

    methods ( Static )

        function actor = create(other)
            if nargin == 0
                actor = sim3d.ActorFactory.createSim3dActor();
                return ;
            end
            if ischar(other) || isstring(other)
                actor = sim3d.ActorFactory.createActorViaType(other);
            elseif isa( other, 'sim3d.AbstractActor' )
                actor = sim3d.ActorFactory.createActorViaObject(other);
            else
                actor = sim3d.ActorFactory.createSim3dActor();
            end
        end


        function actor = createAndCopy( other )
            if isa( other, 'sim3d.AbstractActor' )
                actor = sim3d.ActorFactory.createActorViaObject(other);
            end
            actor.copy(other);
        end


        % 根据类型创建参与者
        function actor = createActorViaType( actorType )
            switch actorType
                case { 'Sim3dPassVeh', sim3d.utils.ActorTypes.PassVehicle }
                    % 增加肌肉车
                    actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'PassengerVehicle', 'MuscleCar' );
                case { 'Sim3dPhysVehicle', sim3d.utils.ActorTypes.PhysVehicle }
                    vehicleProperties = sim3d.auto.PhysVehicle.getPhysVehicleProperties();
                    actor = sim3d.auto.PhysVehicle( strcat( actorType, num2str( sim3d.ActorFactory.getUniqueActorID ) ), 'MuscleCar', vehicleProperties );
                case { 'Sim3dMotorcycle', sim3d.utils.ActorTypes.Motorcycle }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Motorcycle', 'SportsBike' );
                case { 'Sim3dTractor', sim3d.utils.ActorTypes.Tractor }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Tractor', 'ConventionalTractor' );
                case { 'Sim3dTrailer', sim3d.utils.ActorTypes.Trailer }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Trailer', 'ThreeAxleTrailer' );
                case { 'Sim3dDolly', sim3d.utils.ActorTypes.Dolly }
                    actor = sim3d.ActorFactory.createVehicleUtil('auto', 'Dolly', 'OneAxleDolly');
                case { 'Sim3dPedestrian', sim3d.utils.ActorTypes.Pedestrian }
                    actor = sim3d.ActorFactory.createVehicleUtil('pedestrians', 'Pedestrian', 'Male1');
                case { 'Sim3dBicyclist', sim3d.utils.ActorTypes.Bicyclist }
                    actor = sim3d.pedestrians.Bicyclist( strcat( 'Bicyclist', num2str( sim3d.ActorFactory.getUniqueActorID ) ) );
                case { 'Sim3dQuadRotor', sim3d.utils.ActorTypes.QuadRotorUAV }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'uav', 'QuadrotorUAV' );
                case { 'Sim3dFixedWing', sim3d.utils.ActorTypes.FixedWingUAV }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'uav', 'FixedWingUAV' );
                case { 'Sim3dSkyHogg', sim3d.utils.ActorTypes.SkyHogg }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'SkyHoggAircraft' );
                case { 'Sim3dMWAirliner', sim3d.utils.ActorTypes.MWAirliner }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'AirlinerAircraft' );
                case { 'Sim3dAircraft', sim3d.utils.ActorTypes.FixedWing }
                    actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'FixedWingAircraft' );
                case { 'Sim3dMainCamera', sim3d.utils.ActorTypes.MainCamera }
                    cameraProperties = sim3d.sensors.MainCamera.getMainCameraProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'MainCamera', cameraProperties );
                case { 'Sim3dCamera', sim3d.utils.ActorTypes.Camera }
                    cameraVisionSensorProperties = sim3d.sensors.VisionSensor.getVisionSensorProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'CameraVisionSensor', cameraVisionSensorProperties );
                case { 'Sim3dFisheyeCamera', sim3d.utils.ActorTypes.FisheyeCamera }
                    fisheyeCameraProperties = sim3d.sensors.FisheyeCamera.getFisheyeCameraProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'FisheyeCamera', fisheyeCameraProperties );
                case { 'Sim3dLidar', sim3d.utils.ActorTypes.Lidar }
                    lidarSensorProperties = sim3d.sensors.LidarSensor.getLidarSensorProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'LidarSensor', lidarSensorProperties );
                case { 'Sim3dDepth', sim3d.utils.ActorTypes.DepthSensor }
                    depthSensorProperties = sim3d.sensors.VisionSensor.getVisionSensorProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'DepthVisionSensor', depthSensorProperties );
                case { 'Sim3dGroundTruth', sim3d.utils.ActorTypes.GroundTruth }
                    actor = sim3d.ActorFactory.createSensorUtil( 'GroundTruth', ';ASim3dActor' );
                case { 'Sim3dRayTraceSensor', sim3d.utils.ActorTypes.RayTraceSensor }
                    rayTraceSensorProperties = sim3d.sensors.RayTraceSensor.getRayTraceSensorProperties();
                    actor = sim3d.ActorFactory.createSensorUtil( 'RayTraceSensor', rayTraceSensorProperties );
                case { 'Sim3dGenericActor', sim3d.utils.ActorTypes.BaseDynamic }
                    actor = sim3d.ActorFactory.createSim3dActor();
                otherwise
                    error( 'sim3d:ActorFactory:invalidActorType', 'Invalid Actor type. Please check help and select a valid Actor Type.' );

            end
        end


        function actor = createActorViaObject( other )
            arguments
                other( 1, 1 )sim3d.AbstractActor
            end
            if isa( other, 'sim3d.sensors.Sensor' )
                actor = sim3d.ActorFactory.createSensor( other );
            elseif isa( other, 'sim3d.auto.WheeledVehicle')
                actor = sim3d.ActorFactory.createWheeledVehicle( other );
            elseif isa( other, 'sim3d.aircraft.Aircraft' )
                actor = sim3d.ActorFactory.createAircraft( other );
            elseif isa( other, 'sim3d.uav.UAV' )
                actor = sim3d.ActorFactory.createUAV( other );
            else
                actor = sim3d.ActorFactory.createSim3dActor();
                return ;
            end
        end


        function actor = createSim3dActor()
            actor = sim3d.Actor();
        end


        function actor = createSensor(other)
            if isa( other, 'sim3d.sensors.MainCamera')
                cameraProperties = sim3d.sensors.MainCamera.getMainCameraProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'MainCamera', cameraProperties );
            elseif isa( other, 'sim3d.sensors.FisheyeCamera')
                fisheyeCameraProperties = sim3d.sensors.FisheyeCamera.getFisheyeCameraProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'FisheyeCamera', fisheyeCameraProperties);
            elseif isa( other, 'sim3d.sensors.LidarSensor' )
                lidarSensorProperties = sim3d.sensors.LidarSensor.getLidarSensorProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'LidarSensor', lidarSensorProperties );
            elseif isa( other, 'sim3d.sensors.CameraVisionSensor' )
                cameraVisionSensorProperties = sim3d.sensors.VisionSensor.getVisionSensorProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'CameraVisionSensor', cameraVisionSensorProperties );
            elseif isa( other, 'sim3d.sensors.DepthVisionSensor' )
                depthSensorProperties = sim3d.sensors.VisionSensor.getVisionSensorProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'DepthVisionSensor', depthSensorProperties );
            elseif isa( other, 'sim3d.sensors.GroundTruth' )
                actor = sim3d.ActorFactory.createSensorUtil( 'GroundTruth', ';ASim3dActor' );
            elseif isa( other, 'sim3d.sensors.RayTraceSensor' )
                rayTraceSensorProperties = sim3d.sensors.RayTraceSensor.getRayTraceSensorProperties();
                actor = sim3d.ActorFactory.createSensorUtil( 'RayTraceSensor', rayTraceSensorProperties );
            end
        end


        function actor = createWheeledVehicle( other )
            if isa( other, 'sim3d.auto.Dolly' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Dolly', other.DollyType );
            elseif isa( other, 'sim3d.auto.Motorcycle' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Motorcycle', 'SportsBike' );
            elseif isa( other, 'sim3d.auto.PassengerVehicle' )
                switch other.PassengerVehicleType
                    case 0
                        PassengerVehicleType = 'MuscleCar';
                    case 1
                        PassengerVehicleType = 'Sedan';
                    case 2
                        PassengerVehicleType = 'SportUtilityVehicle';
                    case 3
                        PassengerVehicleType = 'SmallPickupTruck';
                    case 4
                        PassengerVehicleType = 'Hatchback';
                    case 5
                        PassengerVehicleType = 'BoxTruck';
                end
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'PassengerVehicle', PassengerVehicleType );

            elseif isa( other, 'sim3d.auto.Trailer' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Trailer', other.TrailerType );

            elseif isa( other, 'sim3d.auto.Tractor' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Tractor', other.TractorType );

            elseif isa( other, 'sim3d.auto.PhysVehicle' )
                switch other.PhysVehicleType
                    case 0
                        PhysVehicleType = 'MuscleCar';
                    case 1
                        PhysVehicleType = 'Sedan';
                    case 2
                        PhysVehicleType = 'SportUtilityVehicle';
                    case 3
                        PhysVehicleType = 'SmallPickupTruck';
                    case 4
                        PhysVehicleType = 'Hatchback';
                    case 5
                        PhysVehicleType = 'BoxTruck';
                end
                vehicleProperties = sim3d.auto.PhysVehicle.getPhysVehicleProperties();
                actor = sim3d.auto.PhysVehicle( strcat( 'PassengerVehicle', num2str( sim3d.ActorFactory.getUniqueActorID ) ), PhysVehicleType, vehicleProperties );

            elseif isa( other, 'sim3d.pedestrians.Pedestrian' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'auto', 'Pedestrian', other.PedestrianType );

            elseif isa( other, 'sim3d.pedestrians.Bicyclist' )
                actor = sim3d.pedestrians.Bicyclist( strcat( 'Bicyclist', num2str( sim3d.ActorFactory.getUniqueActorID ) ) );
            end
        end


        function actor = createAircraft(other)
            if isa( other, 'sim3d.aircraft.AirlinerAircraft' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'AirlinerAircraft' );
            elseif isa( other, 'sim3d.aircraft.FixedWingAircraft' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'FixedWingAircraft' );
            elseif isa( other, 'sim3d.aircraft.SkyHoggAircraft' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'aircraft', 'SkyHoggAircraft' );
            end
        end


        function actor = createUAV(other)
            if isa( other, 'sim3d.uav.FixedWingUAV' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'uav', 'FixedWingUAV' );
            elseif isa( other, 'sim3d.uav.QuadrotorUAV' )
                actor = sim3d.ActorFactory.createVehicleUtil( 'uav', 'QuadrotorUAV' );
            end
        end


        % 创建车辆的工具：('auto', 'PassengerVehicle', 'MuscleCar')
        function actor = createVehicleUtil( actorNameSpace, vehicleID, actorType, defaultActorType )
            if ( nargin == 2 )
                actor = sim3d.(actorNameSpace).( actorType )( strcat( actorType, num2str( vehicleID ) ), actorType );
            else
                actor = sim3d.(actorNameSpace ).( actorType )( strcat( actorType, num2str( vehicleID ) ), defaultActorType );
            end
        end


        function actor = createSensorUtil( actorType, actorProperties )
            defaultTransform = sim3d.utils.Transform( zeros( 1, 3, 'single' ),  ...
                rad2deg( zeros( 1, 3, 'single' ) ), ones( 1, 3, 'single' ) );
            actor = sim3d.sensors.( actorType )( sim3d.ActorFactory.getUniqueActorID, 'Scene Origin', actorProperties, defaultTransform );
        end


        function actorID = getUniqueActorID()
            persistent actorNum
            if isempty( actorNum )
                actorNum = 1;
            else
                actorNum = actorNum + 1;
            end
            actorID = actorNum;
        end
    end
end


