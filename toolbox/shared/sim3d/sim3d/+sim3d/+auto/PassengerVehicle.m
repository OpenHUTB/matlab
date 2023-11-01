% 客车
classdef PassengerVehicle < sim3d.auto.WheeledVehicle

    properties ( SetAccess = 'private', GetAccess = 'public' )
        LightModule = {};
        PassengerVehicleType;
    end


    properties ( Access = private )
        TrackWidth = 1.9;
        WheelBase = 3;
        WheelRadius = 0.35;
        TraceStart_cache;
        TraceEnd_cache;
    end


    methods
        function self = PassengerVehicle( actorName, passVehicleType, varargin )
            narginchk( 2, inf );

            numberOfParts = uint32(5);

            r = sim3d.auto.PassengerVehicle.parseInputs( varargin{ : } );

            switch passVehicleType
                case 'Custom'
                    mesh = r.Mesh;
                otherwise
                    mesh = sim3d.auto.PassengerVehicle.getBlueprintPath( passVehicleType );
            end
            self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation,  ...
                r.Rotation, r.Scale, numberOfParts, mesh );

            self.PassengerVehicleType = self.getVehType( passVehicleType );
            switch passVehicleType
                case 'Custom'
                    self.Mesh = r.Mesh;
                otherwise
                    self.Mesh = self.getMesh();
            end
            self.Animation = self.getAnimation();
            self.Color = self.getColor( r.Color );
            self.Translation = single( r.Translation );
            self.Rotation = single( r.Rotation );
            self.Scale = single( r.Scale );
            self.ActorID = r.ActorID;
            self.RayStart = [ 0, 0, 0;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
            self.RayEnd = [ 0, 0, 10;1, 0, 20;1, 0, 20;1, 0, 20;1, 0, 20 ];
            self.TrackWidth = r.TrackWidth;
            self.WheelBase = r.WheelBase;
            self.WheelRadius = r.WheelRadius;
            if ( passVehicleType == "BoxTruck" )
                self.TrackWidth = 1.38;
                self.WheelBase = 5.5;
            end

            self.Config.MeshPath = self.Mesh;
            self.Config.AnimationPath = self.Animation;
            self.Config.ColorPath = self.Color;

            self.LightModule = sim3d.vehicle.VehicleLightingModule( r.LightConfiguration );
            self.Config.AdditionalOptions = self.LightModule.generateInitMessageString();
        end


        % 直接设置下一步车的位置和姿态
        function step(self, X, Y, Yaw)
            translation = zeros( self.NumberOfParts, 3, 'single' );
            rotation = zeros( self.NumberOfParts, 3, 'single' );
            scale = ones( self.NumberOfParts, 3, 'single' );

            [ translation, rotation ] = self.UpdateVehiclePosition( translation, rotation, X, Y, Yaw );
            self.writeTransform( translation, rotation, scale );
        end


        function write(self, translation, rotation, scale)
            self.writeTransform( translation, rotation, scale );
        end


        function [ translation, rotation, scale ] = read( self )
            [ translation, rotation, scale ] = self.readTransform();
        end


        function [ translation, rotation ] = UpdateVehiclePosition( self, translation, rotation, X, Y, Yaw )
            [ ~, traceEnd, ~ ] = self.VehicleRayTraceRead();
            [ previousTranslation, previousRotation, ~ ] = self.readTransform();
            wheelHitZ = traceEnd( 2:5, 3 );
            if ( any( wheelHitZ > self.RayTraceMaxValueLimit ) )
                error( 'sim3d:TerrainSensor:InvalidZValue', 'Check the position of vehicle to make sure vehicle did not encounter a large variation in terrain' );
            end
            Zcg = mean( wheelHitZ );
            psi = atan( ( ( wheelHitZ( 1 ) - wheelHitZ( 2 ) ) + ( wheelHitZ( 3 ) - wheelHitZ( 4 ) ) ) ./ self.TrackWidth ./ 2 );
            theta = atan( ( ( wheelHitZ( 1 ) - wheelHitZ( 3 ) ) + ( wheelHitZ( 2 ) - wheelHitZ( 4 ) ) ) ./ self.WheelBase ./ 2 );

            pX = previousTranslation( 1, 1 );
            pY = previousTranslation( 1, 2 );
            pYaw = previousRotation( 1, 3 );
            pWheelRotation = previousRotation( 2:5, 1 )';
            [ steerAngle, wheelRotation ] = self.EstimateWheelRotationAndSteerAngle( pX, pY, pYaw, pWheelRotation, X, Y, Yaw, self.WheelBase, self.TrackWidth, self.WheelRadius );

            translation( 1, 1 ) = single( X );
            translation( 1, 2 ) = single( Y );
            translation( 1, 3 ) = single( Zcg );
            rotation( 1, 1 ) = single( theta );
            rotation( 1, 2 ) = single( psi );
            rotation( 1, 3 ) = single( Yaw );

            rotation( 2:5, 1 ) = single( wheelRotation( 1:4 ) );
            rotation( 2:5, 3 ) = single( steerAngle( 1:4 ) );
        end


        function writeTransform(self, translation, rotation, scale)

            if ~isempty( self.TransformWriter )
                self.TransformWriter.write( single( translation ), single( rotation ), single( scale ) );
                self.TransformReader.read();
            end

            self.Config.AdditionalOptions = self.LightModule.generateStepMessageString(  );

            self.ConfigWriter.send( self.Config );
        end


        function [ translation, rotation, scale ] = readTransform( self )

            if ~isempty( self.TransformReader )
                sim3d.engine.EngineReturnCode.assertObject( self.TransformReader );
                [ translation, rotation, scale ] = self.TransformReader.read;
            else
                translation = [  ];
                rotation = [  ];
                scale = [  ];
            end
        end


        function [ traceStart, traceEnd, status ] = VehicleRayTraceRead( self )
            status = 0;
            if self.TerrainSensorSubscriber.has_message(  )
                terrainSensorDetections = self.TerrainSensorSubscriber.take();
                traceStart = terrainSensorDetections.TraceStart;
                traceEnd = terrainSensorDetections.TraceEnd;
                self.TraceStart_cache = traceStart;
                self.TraceEnd_cache = traceEnd;
            else
                traceStart = self.TraceStart_cache;
                traceEnd = self.TraceEnd_cache;
            end
            if ( isempty( traceStart ) || isempty( traceEnd ) )
                status = sim3d.engine.EngineReturnCode.No_Data;
            end
        end


        function ret = getVehType( ~, VType )
            switch VType
                case 'MuscleCar'
                    ret = sim3d.auto.VehicleTypes.MuscleCar;
                case 'Sedan'
                    ret = sim3d.auto.VehicleTypes.Sedan;
                case 'SportUtilityVehicle'
                    ret = sim3d.auto.VehicleTypes.SportUtilityVehicle;
                case 'SmallPickupTruck'
                    ret = sim3d.auto.VehicleTypes.SmallPickupTruck;
                case 'Hatchback'
                    ret = sim3d.auto.VehicleTypes.Hatchback;
                case 'BoxTruck'
                    ret = sim3d.auto.VehicleTypes.BoxTruck;
                case 'Custom'
                    ret = '';
                otherwise
                    error( 'sim3d:invalidVehicleType', 'Invalid Vehicle Type. Please check help and select a valid Vehicle Type' );
            end
        end


        function ret = getColor( ~, color )
            switch color
                case 'black'
                    ret = sim3d.utils.ActorColors.Black;
                case 'red'
                    ret = sim3d.utils.ActorColors.Red;
                case 'orange'
                    ret = sim3d.utils.ActorColors.Orange;
                case 'yellow'
                    ret = sim3d.utils.ActorColors.Yellow;
                case 'green'
                    ret = sim3d.utils.ActorColors.Green;
                case 'blue'
                    ret = sim3d.utils.ActorColors.Blue;
                case 'white'
                    ret = sim3d.utils.ActorColors.White;
                case 'whitepearl'
                    ret = sim3d.utils.ActorColors.WhitePearl;
                case 'grey'
                    ret = sim3d.utils.ActorColors.Grey;
                case 'darkgrey'
                    ret = sim3d.utils.ActorColors.DarkGrey;
                case 'silver'
                    ret = sim3d.utils.ActorColors.Silver;
                case 'bluesilver'
                    ret = sim3d.utils.ActorColors.BlueSilver;
                case 'darkredblack'
                    ret = sim3d.utils.ActorColors.DarkRedBlack;
                case 'redblack'
                    ret = sim3d.utils.ActorColors.RedBlack;
                otherwise
                    error( 'sim3d:invalidVehicleColor', 'Invalid Vehicle Color. Please check help and select a valid Vehicle Color.' );
            end
        end


        function ret = getMesh( self )
            switch self.PassengerVehicleType
                case sim3d.auto.VehicleTypes.MuscleCar
                    ret = '/MathWorksAutomotiveContent/Vehicles/Muscle/Meshes/SK_MuscleCar.SK_MuscleCar';
                case sim3d.auto.VehicleTypes.Sedan
                    ret = '/MathWorksAutomotiveContent/Vehicles/Sedan/Meshes/SK_SedanCar.SK_SedanCar';
                case sim3d.auto.VehicleTypes.SportUtilityVehicle
                    ret = '/MathWorksAutomotiveContent/Vehicles/SUV/Meshes/SK_SUVCar.SK_SUVCar';
                case sim3d.auto.VehicleTypes.SmallPickupTruck
                    ret = '/MathWorksAutomotiveContent/Vehicles/PickupTruck/Meshes/SK_PickupTruck.SK_PickupTruck';
                case sim3d.auto.VehicleTypes.Hatchback
                    ret = '/MathWorksAutomotiveContent/Vehicles/Hatchback/Meshes/SK_Hatchback.SK_Hatchback';
                case sim3d.auto.VehicleTypes.BoxTruck
                    ret = '/MathWorksAutomotiveContent/Vehicles/Boxtruck/Meshes/SK_BoxTruck.SK_BoxTruck';
                otherwise
                    ret = '';
            end
        end


        function ret = getAnimation( self )
            switch self.PassengerVehicleType
                case sim3d.auto.VehicleTypes.BoxTruck
                    ret = '/MathWorksAutomotiveContent/Vehicles/Boxtruck/Blueprints/Sim3dBoxTruckAnimBP.Sim3dBoxTruckAnimBP_C';
                otherwise
                    ret = '/MathWorksAutomotiveContent/VehicleCommon/Blueprints/Sim3dVehicleAnimBP.Sim3dVehicleAnimBP_C';
            end
        end


        function actorType = getActorType( ~ )
            actorType = sim3d.utils.ActorTypes.PassVehicle;
        end


        function tagName = getTagName( ~ )
            tagName = 'PassengerVehicle';
        end


        function [ steerAngle, wheelRotation ] = EstimateWheelRotationAndSteerAngle( ~, pX, pY, pYaw, pWheelRotation, X, Y, Yaw, WheelBase, TrackWidth, WheelRadius )
            dX = X - pX;
            dY = Y - pY;
            dPsi = sign( Yaw - pYaw ) * mod( Yaw - pYaw, 2 * pi );
            dx = dX * cos( Yaw ) + dY * sin( Yaw );
            dy = dX * sin( Yaw ) + dY * cos( Yaw );
            CGdisp = sqrt( dy ^ 2 + dx ^ 2 );
            if dPsi == 0
                dPsi = .001;
            end

            beta = atan2( dy, dx );
            Rest = CGdisp / 2 / sin( dPsi / 2 );
            deltaL = atan( WheelBase / ( Rest - TrackWidth / 2 ) );
            deltaR = atan( WheelBase / ( Rest + TrackWidth / 2 ) );
            steerAngle = [ deltaL, deltaR, 0, 0 ];
            if ( abs( dx ) < 0.01 )
                steerAngle = [ 0, 0, 0, 0 ];
            end

            wheelRotation = [ cos( deltaL ), cos( deltaR ), 1, 1 ] * CGdisp / WheelRadius * cos( beta );
            wheelRotation = pWheelRotation - wheelRotation;
        end


        function copy( self, other, CopyChildren, UseSourcePosition )
            arguments
                self( 1, 1 )sim3d.auto.PassengerVehicle
                other( 1, 1 )sim3d.auto.PassengerVehicle
                CopyChildren( 1, 1 )logical = true
                UseSourcePosition( 1, 1 )logical = false
            end

            self.PassengerVehicleType = other.PassengerVehicleType;
            self.LightModule = other.LightModule;

            copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );
        end


        function actorS = getAttributes( self )
            actorS = getAttributes@sim3d.auto.WheeledVehicle( self );
            actorS.PassengerVehicleType = self.PassengerVehicleType;
        end


        function setAttributes( self, actorS )
            setAttributes@sim3d.auto.WheeledVehicle( self, actorS );
            self.PassengerVehicleType = actorS.PassengerVehicleType;
        end

    end


    methods ( Access = private, Static )

        function ret = getBlueprintPath( PassengerVehicleType )
            switch PassengerVehicleType
                case sim3d.auto.VehicleTypes.MuscleCar
                    ret = '/MathWorksAutomotiveContent/Vehicles/Muscle/Meshes/SK_MuscleCar.SK_MuscleCar';
                case sim3d.auto.VehicleTypes.Sedan
                    ret = '/MathWorksAutomotiveContent/Vehicles/Sedan/Meshes/SK_SedanCar.SK_SedanCar';
                case sim3d.auto.VehicleTypes.SportUtilityVehicle
                    ret = '/MathWorksAutomotiveContent/Vehicles/SUV/Meshes/SK_SUVCar.SK_SUVCar';
                case sim3d.auto.VehicleTypes.SmallPickupTruck
                    ret = '/MathWorksAutomotiveContent/Vehicles/PickupTruck/Meshes/SK_PickupTruck.SK_PickupTruck';
                case sim3d.auto.VehicleTypes.Hatchback
                    ret = '/MathWorksAutomotiveContent/Vehicles/Hatchback/Meshes/SK_Hatchback.SK_Hatchback';
                case sim3d.auto.VehicleTypes.BoxTruck
                    ret = '/MathWorksAutomotiveContent/Vehicles/Boxtruck/Meshes/SK_BoxTruck.SK_BoxTruck';
                otherwise
                    ret = '';
            end
        end


        function r = parseInputs( varargin )

            defaultParams = struct(  ...
                'Color', 'red',  ...
                'Mesh', 'MeshText',  ...
                'Animation', 'AnimationText',  ...
                'Translation', single( zeros( 5, 3 ) ),  ...
                'Rotation', single( zeros( 5, 3 ) ),  ...
                'Scale', single( ones( 5, 3 ) ),  ...
                'ActorID', 10,  ...
                'TrackWidth', 1.9,  ...
                'WheelBase', 3,  ...
                'WheelRadius', 0.35 );

            parser = inputParser;
            parser.addParameter( 'Color', defaultParams.Color );
            parser.addParameter( 'Mesh', defaultParams.Mesh );
            parser.addParameter( 'Animation', defaultParams.Animation );
            parser.addParameter( 'Translation', defaultParams.Translation );
            parser.addParameter( 'Rotation', defaultParams.Rotation );
            parser.addParameter( 'Scale', defaultParams.Scale );
            parser.addParameter( 'ActorID', defaultParams.ActorID );
            parser.addParameter( 'LightConfiguration', {  } );
            parser.addParameter( 'TrackWidth', defaultParams.TrackWidth );
            parser.addParameter( 'WheelBase', defaultParams.WheelBase );
            parser.addParameter( 'WheelRadius', defaultParams.WheelRadius );

            parser.parse( varargin{ : } );
            r = parser.Results;
            r.Translation( 2:5, : ) = 0;
            r.Rotation( 2:5, : ) = 0;
            r.Scale( 2:5, : ) = 1;
        end
    end
end




