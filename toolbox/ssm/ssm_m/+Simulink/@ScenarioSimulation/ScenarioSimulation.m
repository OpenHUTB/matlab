classdef ScenarioSimulation < handle



















    properties ( Access = private )
        ssMCOS;
        connectedToSSE = true;
        rrObject;
        apiPort;
        coSimPort;
        ssfAgent;
        isBootstrap = false;
    end

    methods ( Access = { ?roadrunner, ?Simulink.BootstrapWorkflow } )

        function obj = ScenarioSimulation( varargin )


            if length( varargin ) ~= 2










                if ( length( varargin ) == 5 )
                    p = inputParser;
                    p.addRequired( "address", @ischar );
                    p.addRequired( "apiPort", @isnumeric );
                    p.addRequired( "coSimPort", @isnumeric );
                    p.addParameter( "requestedClientID", [  ], @( a )( ischar( a ) ) );
                    p.parse( varargin{ : } );
                    results = p.Results;
                    address = results.address;
                    obj.apiPort = results.apiPort;
                    obj.coSimPort = results.coSimPort;
                    requested_client_id = results.requestedClientID;
                    if ( ~strcmp( requested_client_id, 'BootstrapMatlabClient' ) )
                        error( message( 'ssm:scenariosimulation:InternalErrorScenarioSim' ) );
                    else
                        obj.isBootstrap = true;
                    end
                    obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
                    if ( obj.connectedToSSE == false )
                        error( message( 'ssm:scenariosimulation:UnableToConnectToRR', obj.apiPort, obj.coSimPort ) );
                    end
                    obj.ssMCOS = Simulink.ScenarioSimulationMcos( strcat( "localhost:", num2str( obj.coSimPort ) ) );
                    obj.ssMCOS.register( address, num2str( obj.coSimPort ), obj, requested_client_id );
                else
                    error( message( 'ssm:scenariosimulation:InternalErrorScenarioSim' ) );
                end
            else
                p = inputParser;
                p.addParameter( 'App', [  ], @( a )( isobject( a ) && isa( a, 'roadrunner' ) ) );
                try
                    p.parse( varargin{ : } );
                catch ex
                    error( message( 'ssm:scenariosimulation:InternalErrorScenarioSim' ) );
                end
                results = p.Results;
                obj.rrObject = results.App;
                obj.apiPort = obj.rrObject.getAPIPort;
                obj.coSimPort = obj.rrObject.getCoSimPort;
                obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
                if ( obj.connectedToSSE == false )
                    error( message( 'ssm:scenariosimulation:UnableToConnectToRR', obj.apiPort, obj.coSimPort ) );
                end
                obj.ssMCOS = Simulink.ScenarioSimulationMcos( strcat( "localhost:", num2str( obj.coSimPort ) ) );
                obj.ssMCOS.register( "localhost", num2str( obj.coSimPort ), obj );
            end

            obj.ssfAgent = matlabshared.scenario.internal.SSFAgent( strcat( 'localhost:', num2str( obj.coSimPort ) ) );
        end
    end

    methods ( Access = public )

        function set( obj, parameter, value )






























            obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
            if ( obj.connectedToSSE == false )
                error( message( 'ssm:scenariosimulation:DisconnectedFromRR' ) );
            end

            if ~( ischar( parameter ) || isstring( parameter ) )
                error( message( 'ssm:scenariosimulation:ParameterTypeError', 'set' ) );
            end

            if ~( ischar( value ) || isstring( value ) || isnumeric( value ) )
                error( "Invalid format for value" );
            end

            switch lower( parameter )
                case 'simulationcommand'
                    if ~( ischar( value ) || isstring( value ) )
                        error( message( 'ssm:scenariosimulation:ValueTypeCharError', parameter ) );
                    end

                    switch lower( value )
                        case 'start'
                            pace = obj.ssMCOS.get( 'SimulationPace' );
                            obj.rrObject.prepareSimulation;
                            obj.rrObject.simulateScenario( 'Pacing', pace, 'IsBlocking', false );
                        case 'blockingstart'
                            pace = obj.ssMCOS.get( 'SimulationPace' );
                            obj.rrObject.prepareSimulation;
                            obj.rrObject.simulateScenario( 'Pacing', pace, 'IsBlocking', false );
                            pause( 0.1 );
                            while ( ~isequal( obj.get( 'SimulationStatus' ), 'Stopped' ) )
                                pause( 0.1 );
                            end
                        case 'stop'
                            obj.ssMCOS.set( 'SimulationCommand', 'Stop' );
                        case 'pause'
                            obj.ssMCOS.set( 'SimulationCommand', 'Pause' );
                        case 'step'
                            obj.ssMCOS.set( 'SimulationCommand', 'Step' );
                        case 'continue'
                            obj.ssMCOS.set( 'SimulationCommand', 'Continue' );
                        otherwise
                            error( "Invalid Command" );
                    end
                case 'pacerstatus'
                    if ~( ischar( value ) || isstring( value ) )
                        error( message( 'ssm:scenariosimulation:ValueTypeCharError', parameter ) );
                    end

                    switch lower( value )
                        case 'on'
                            obj.ssMCOS.set( 'PacerStatus', 'on' );
                        case 'off'
                            obj.ssMCOS.set( 'PacerStatus', 'off' );
                    end

                case 'stepsize'
                    if ~isnumeric( value )
                        error( message( 'ssm:scenariosimulation:ValueTypeNumericError', parameter ) );
                    end
                    obj.ssMCOS.set( 'StepSize', value );

                case 'maxsimulationtime'
                    if ~isnumeric( value )
                        error( message( 'ssm:scenariosimulation:ValueTypeNumericError', parameter ) );
                    end

                    if value < 0.0
                        error( message( 'ssm:scenariosimulation:MaxSimTimeValueError' ) );
                    end

                    obj.ssMCOS.set( 'MaxSimulationTime', value );

                case 'simulationpace'
                    if ~isnumeric( value )
                        error( message( 'ssm:scenariosimulation:ValueTypeNumericError', parameter ) );
                    end

                    obj.ssMCOS.set( 'SimulationPace', value );


                case 'logging'
                    if ( ~( isequal( lower( value ), 'on' ) || isequal( lower( value ), 'off' ) ) )
                        error( message( 'ssm:scenariosimulation:LoggingValueError', parameter ) );
                    end

                    status = obj.ssMCOS.get( 'SimulationStatus' );






                    if ( status == 1 || status == 0 || obj.isBootstrap == true )
                        obj.ssMCOS.set( 'Logging', strcmpi( value, 'On' ) );
                    else
                        error( message( 'ssm:scenariosimulation:LoggingToggleError' ) );
                    end

                otherwise
                    error( message( 'ssm:scenariosimulation:InvalidParameterPassed', parameter, 'set' ) );
            end

        end

        function out = getMap( obj )
            obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
            if ( obj.connectedToSSE == false )
                error( message( 'ssm:scenariosimulation:DisconnectedFromRR' ) );
            end
            obj.rrObject.prepareSimulation;
            out = obj.ssMCOS.getMap;
        end

        function out = get( obj, param, varargin )






















































            if ~( ischar( param ) || isstring( param ) )
                error( message( 'ssm:scenariosimulation:ParameterTypeError', 'get' ) );
            end

            obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
            if ( obj.connectedToSSE == false )
                error( message( 'ssm:scenariosimulation:DisconnectedFromRR' ) );
            end

            if isempty( varargin )
                switch lower( param )
                    case 'stepsize'
                        out = obj.ssMCOS.get( 'StepSize' );
                    case 'maxsimulationtime'
                        out = obj.ssMCOS.get( 'MaxSimulationTime' );
                    case 'simulationpace'
                        out = obj.ssMCOS.get( 'SimulationPace' );
                    case 'simulationstatus'
                        status = obj.ssMCOS.get( 'SimulationStatus' );
                        switch status
                            case 0
                                out = 'Unspecified';
                            case 1
                                out = 'Stopped';
                            case 2
                                out = 'Running';
                            case 3
                                out = 'Paused';
                        end
                    case 'actorstatus'
                        status = obj.ssMCOS.get( 'ActorStatus' );
                        switch status
                            case 0
                                out = 'Unspecified';
                            case 1
                                out = 'Stopped';
                            case 2
                                out = 'Running';
                        end
                    case 'pacerstatus'
                        switch obj.ssMCOS.get( 'PacerStatus' )
                            case 1
                                out = 'on';
                            case 0
                                out = 'off';
                        end
                    case 'actorsimulation'
                        cellObject = obj.ssMCOS.get( 'ActorSimulation' );
                        out = [ cellObject{ : } ];


                    case 'logging'
                        switch obj.ssMCOS.get( 'Logging' )
                            case 1
                                out = 'on';
                            case 0
                                out = 'off';
                        end


                    case 'simulationlog'
                        out = [  ];

                        status = obj.ssMCOS.get( 'SimulationStatus' );






                        if ( status == 1 || status == 0 || obj.isBootstrap == true )
                            log = obj.ssMCOS.get( 'SimulationLog' );

                            if ( isempty( log.SimulationData ) && isequal( obj.ssMCOS.get( 'Logging' ), 0 ) )
                                error( message( 'ssm:scenariosimulation:ScenarioLoggingOff' ) );
                            end

                            out = Simulink.ScenarioLog( 'Log', log );
                        else
                            error( message( 'ssm:scenariosimulation:SimulationLogUnavailable' ) );
                        end


                    case 'observers'
                        out = obj.ssMCOS.ListObserverActors(  );

                    otherwise
                        error( message( 'ssm:scenariosimulation:InvalidParameterPassed', param, 'get' ) );
                end
            else
                if ( lower( param ) ~= "actorsimulation" )
                    error( message( 'ssm:scenariosimulation:VarArgWithInvalidParam', param ) );
                end

                if length( varargin ) ~= 2
                    error( message( 'ssm:scenariosimulation:NumParameterError', param, 'get' ) );
                end

                switch lower( varargin{ 1 } )
                    case 'systemobject'
                        if ~isobject( varargin{ 2 } ) && ~isa( varargin{ 2 }, 'matlab.System' )
                            error( message( 'ssm:scenariosimulation:ValueTypeSysObjectError', 'get', varargin{ 1 } ) );
                        end

                        if Simulink.ScenarioSimulationMcos.isInMLSysBlock( varargin{ 2 } )
                            modelName = get_param( gcs, 'Name' );
                            cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SimulinkModel', modelName );
                            out = [ cellObject{ : } ];
                        else
                            cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SystemObject', varargin{ 2 } );
                            out = [ cellObject{ : } ];
                        end
                    case 'simulinkmodel'
                        if ~isfloat( varargin{ 2 } )
                            error( message( 'ssm:scenariosimulation:ValueTypeFloatError', 'get', varargin{ 1 } ) );
                        end

                        modelName = get_param( varargin{ 2 }, 'Name' );
                        cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SimulinkModel', modelName );
                        out = [ cellObject{ : } ];
                    case 'actormodel'
                        out = obj.ssMCOS.get( 'ActorSimulation', 'ActorModel', varargin{ 2 } );
                    otherwise
                        error( message( 'ssm:scenariosimulation:InvalidParameterPassed', varargin{ 1 }, 'get' ) );
                end

            end

        end


        function ret = addObserver( obj, uniqueName, SysObj )




















            arguments
                obj;
                uniqueName string;
                SysObj string;
            end

            if ( isempty( uniqueName ) )
                error( message( 'ssm:scenariosimulation:InvalidFirstArgToAddObs' ) );
            end

            if ( isempty( SysObj ) )
                error( message( 'ssm:scenariosimulation:InvalidSecondArgToAddObs' ) );
            end


            sysObjPath = which( SysObj );
            if ( isempty( sysObjPath ) )
                error( message( 'ssm:scenariosimulation:SysObjNotOnPath', SysObj ) );
            end

            [ ~, ~, ext ] = fileparts( sysObjPath );
            if ( ~( isequal( ext, '.m' ) || isequal( ext, '.p' ) ) )
                error( message( 'ssm:scenariosimulation:InvalidFileExtension', SysObj, sysObjPath ) );
            end

            status = obj.ssMCOS.get( 'SimulationStatus' );
            if ( status == 1 || status == 0 )
                ret = obj.ssMCOS.AddObserverActor( sysObjPath, uniqueName );
            else
                error( message( 'ssm:scenariosimulation:AddObsWhileSimActive' ) );
            end
        end


        function ret = removeObserver( obj, actorName )












            arguments
                obj;
                actorName string;
            end

            if ( isempty( actorName ) )
                error( message( 'ssm:scenariosimulation:RemoveObsNameEmpty' ) );
            end

            status = obj.ssMCOS.get( 'SimulationStatus' );
            if ( status == 1 || status == 0 )
                ret = obj.ssMCOS.RemoveObserverActor( actorName );
            else
                error( message( 'ssm:scenariosimulation:RemoveObsWhileSimActive' ) );
            end
        end


        function reportDiagnostic( obj, messageType, message )













            arguments
                obj;
                messageType EnumDiagnosticType;
                message string;
            end

            if ( messageType == "Unspecified" )
                error( message( 'ssm:scenariosimulation:UnspecifiedMessageType' ) );
            end

            obj.ssMCOS.ReportDiagnostic( string( messageType ), message );
        end

        function s = saveobj( obj )
            s.rrObject = obj.rrObject;
        end
    end




    methods ( Access = public, Hidden = true )

        function out = getScenario( obj )
            obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
            if ( obj.connectedToSSE == false )
                error( "Disconnected from SSE" );
            end
            obj.rrObject.prepareSimulation;
            out = obj.ssMCOS.getScenario;
        end

        function out = uploadScenario( obj, scenario )
            obj.connectedToSSE = matlabshared.roadrunner.waitforApiServer( obj.apiPort );
            if ( obj.connectedToSSE == false )
                error( message( 'ssm:scenariosimulation:DisconnectedFromRR' ) );
            end
            out = obj.ssMCOS.uploadScenario( scenario );
        end

        function sensors( obj, sensorObjs, hostID )































            arguments
                obj;
                sensorObjs{ mustBeA( sensorObjs, [ "cell", "string", 'char',  ...
                    "drivingRadarDataGenerator",  ...
                    "visionDetectionGenerator",  ...
                    "lidarPointCloudGenerator", "lidarSensor" ] ) };
                hostID{ mustBeA( hostID, [ "double", "uint64" ] ) };

            end
            isSensorObject = @( obj )isa( obj, "drivingRadarDataGenerator" ) ||  ...
                isa( obj, "visionDetectionGenerator" ) ||  ...
                isa( obj, "lidarPointCloudGenerator" ) ||  ...
                isa( obj, "lidarSensor" );
            function flag = isSensorBlock( blkPath )
                try
                    blkobj = get_param( blkPath, 'Object' );
                    flag = any( ( strcmpi( blkobj.Name,  ...
                        { 'Vision Detection Generator',  ...
                        'Driving Radar Data Generator',  ...
                        'Lidar Point Cloud Generator' } ) ) );
                catch

                    flag = false;
                end
            end
            isScalarSensorObj = ~iscell( sensorObjs ) && isSensorObject( sensorObjs );
            isCellOfSensorObjs = iscell( sensorObjs ) && all( cellfun( @( obj )isSensorObject( obj ), sensorObjs ) );
            isSensorBlk = ~iscell( sensorObjs ) && isSensorBlock( sensorObjs );
            isCellOfSensorBlks = iscell( sensorObjs ) && all( cellfun( @( blkPath )isSensorBlock( blkPath ), sensorObjs ) );
            if isScalarSensorObj || isCellOfSensorObjs
                if isScalarSensorObj
                    sensorObjs = { sensorObjs };
                end
                sensorConfigs = matlabshared.scenario.internal.utils. ...
                    drivingScenarioToSSF.getSensorConfigurationFromScenario( sensorObjs, hostID );
            elseif isSensorBlk || isCellOfSensorBlks
                if isSensorBlk
                    sensorObjs = { sensorObjs };
                end
                sensorConfigs = matlabshared.scenario.internal.utils. ...
                    drivingScenarioToSSF.getSensorConfigurationFromSensorBlocks( sensorObjs, hostID );
            end
            obj.ssfAgent.addSensors( sensorConfigs );
        end

        function out = getSSF( obj )
            out = obj.ssfAgent.getssf(  );
        end

        function targetPoses = targetPoses( obj, sensorIdx )




















            ssfTgtPoses = obj.getSSF(  ).getTargetPosesInRange( uint64( sensorIdx ) );
            numPoses = length( ssfTgtPoses );
            tgtPose = struct( 'ActorID', 0, 'Position', zeros( 1, 3 ), 'Velocity', zeros( 1, 3 ), 'Roll', 0, 'Pitch', 0, 'Yaw', 0, 'AngularVelocity', zeros( 1, 3 ) );
            if ~isempty( ssfTgtPoses )
                targetPoses( 1, numPoses ) = tgtPose;
                for idx = 1:numPoses
                    targetPoses( idx ) = tgtPose;
                    targetPoses( idx ).ActorID = double( ssfTgtPoses( idx ).actor_id.value );
                    targetPoses( idx ).Position = [ ssfTgtPoses( idx ).position.x,  ...
                        ssfTgtPoses( idx ).position.y,  ...
                        ssfTgtPoses( idx ).position.z ];
                    if ~isempty( ssfTgtPoses( idx ).velocity )
                        targetPoses( idx ).Velocity = [ ssfTgtPoses( idx ).velocity.x,  ...
                            ssfTgtPoses( idx ).velocity.y,  ...
                            ssfTgtPoses( idx ).velocity.z ];
                    end
                    targetPoses( idx ).Roll = ssfTgtPoses( idx ).orientation.roll;
                    targetPoses( idx ).Pitch = ssfTgtPoses( idx ).orientation.pitch;
                    targetPoses( idx ).Yaw = ssfTgtPoses( idx ).orientation.yaw;
                    if ~isempty( ssfTgtPoses( idx ).angular_velocity )
                        targetPoses( idx ).AngularVelocity = [ ssfTgtPoses( idx ).angular_velocity.roll,  ...
                            ssfTgtPoses( idx ).angular_velocity.pitch,  ...
                            ssfTgtPoses( idx ).angular_velocity.yaw ];
                    end
                end
            else
                targetPoses = [  ];
            end
        end
    end

    methods ( Static )
        function object = find( parameter, varargin )
            if ~isempty( varargin ) && length( varargin ) ~= 2
                error( message( 'ssm:scenariosimulation:NumParameterError', parameter, 'find' ) );
            end

            switch lower( parameter )
                case 'scenariosimulation'
                    if isempty( varargin )
                        cellObject = Simulink.ScenarioSimulationMcos.find( 'ScenarioSimulation' );
                        object = [ cellObject{ : } ];
                    else
                        switch lower( varargin{ 1 } )
                            case 'systemobject'
                                if ~isobject( varargin{ 2 } ) && ~isa( varargin{ 2 }, 'matlab.System' )
                                    error( message( 'ssm:scenariosimulation:ValueTypeSysObjectError', 'find', varargin{ 1 } ) );
                                end

                                if Simulink.ScenarioSimulationMcos.isInMLSysBlock( varargin{ 2 } )
                                    modelName = get_param( gcs, 'Name' );
                                    cellObject = Simulink.ScenarioSimulationMcos.find( 'ScenarioSimulation', 'SimulinkModel', modelName );
                                    object = [ cellObject{ : } ];
                                else
                                    cellObject = Simulink.ScenarioSimulationMcos.find( 'ScenarioSimulation', 'SystemObject', varargin{ 2 } );
                                    object = [ cellObject{ : } ];
                                end
                            case 'simulinkmodel'
                                if ~isfloat( varargin{ 2 } )
                                    error( message( 'ssm:scenariosimulation:ValueTypeFloatError', 'find', varargin{ 1 } ) );
                                end
                                modelName = get_param( varargin{ 2 }, 'Name' );
                                cellObject = Simulink.ScenarioSimulationMcos.find( 'ScenarioSimulation', 'SimulinkModel', modelName );
                                object = [ cellObject{ : } ];
                            otherwise
                                error( message( 'ssm:scenariosimulation:InvalidParameterPassed', varargin{ 1 }, 'find' ) );
                        end
                    end

                case 'actorsimulation'
                    if isempty( varargin )
                        error( message( 'ssm:scenariosimulation:NumParameterError', parameter, 'find' ) );
                    else
                        if length( varargin ) ~= 2
                            error( message( 'ssm:scenariosimulation:NumParameterError', parameter, 'find' ) );
                        end

                        switch lower( varargin{ 1 } )
                            case 'systemobject'
                                if ~isobject( varargin{ 2 } ) && ~isa( varargin{ 2 }, 'matlab.System' )
                                    error( message( 'ssm:scenariosimulation:ValueTypeSysObjectError', 'find', varargin{ 1 } ) );
                                end

                                if Simulink.ScenarioSimulationMcos.isInMLSysBlock( varargin{ 2 } )
                                    modelName = get_param( gcs, 'Name' );
                                    cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SimulinkModel', modelName );
                                    object = [ cellObject{ : } ];
                                else
                                    cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SystemObject', varargin{ 2 } );
                                    object = [ cellObject{ : } ];
                                end
                            case 'simulinkmodel'
                                if ~isfloat( varargin{ 2 } )
                                    error( message( 'ssm:scenariosimulation:ValueTypeFloatError', 'find', varargin{ 1 } ) );
                                end
                                modelName = get_param( varargin{ 2 }, 'Name' );
                                cellObject = Simulink.ScenarioSimulationMcos.find( 'ActorSimulation', 'SimulinkModel', modelName );
                                object = [ cellObject{ : } ];
                            otherwise
                                error( message( 'ssm:scenariosimulation:InvalidParameterPassed', varargin{ 1 }, 'find' ) );
                        end
                    end
                otherwise
                    error( message( 'ssm:scenariosimulation:InvalidParameterPassed', parameter, 'find' ) );
            end
        end

        function obj = loadobj( s )
            if isstruct( s )
                obj = s.rrObject.createSimulation;
            else
                obj = s;
            end
        end
    end
end



