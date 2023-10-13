classdef ( CompatibleInexactProperties = true, ConstructOnLoad = true )FlightGearAnimation <  ...
        Aero.animation.internal.Animation & Aero.animation.internal.TimeSeries

    properties ( SetAccess = protected, Transient, SetObservable, Hidden )
        FGIdx = 4;
        FGSocket matlabshared.network.internal.UDP = matlabshared.network.internal.UDP.empty(  );
    end


    properties ( Dependent, SetAccess = protected, Transient, SetObservable, Hidden )
        FGTimer;
    end

    methods
        function set.FGTimer( h, value )
            h.AnimationTimer = value;
        end
        function value = get.FGTimer( h )
            value = h.AnimationTimer;
        end
    end


    properties ( Transient, SetObservable, Hidden )
        FlightGearVersion = '2019.1';
    end

    properties ( Transient, SetObservable )
        OutputFileName = 'runfg.bat';
        FlightGearBaseDirectory = 'C:\Program Files\FlightGear';
        GeometryModelName = 'HL20';
        DestinationIpAddress = '127.0.0.1';
        DestinationPort = '5502';
        AirportId = 'KSFO';
        RunwayId = '10L';
        InitialAltitude{ validateattributes( InitialAltitude, { 'numeric' }, { 'scalar' }, '', 'InitialAltitude' ) } = 7224;
        InitialHeading{ validateattributes( InitialHeading, { 'numeric' }, { 'scalar' }, '', 'InitialHeading' ) } = 113;
        OffsetDistance{ validateattributes( OffsetDistance, { 'numeric' }, { 'scalar' }, '', 'OffsetDistance' ) } = 4.72;
        OffsetAzimuth{ validateattributes( OffsetAzimuth, { 'numeric' }, { 'scalar' }, '', 'OffsetAzimuth' ) } = 0;
        InstallScenery( 1, 1 )matlab.lang.OnOffSwitchState = false;
        DisableShaders( 1, 1 )matlab.lang.OnOffSwitchState = false;

        Architecture Aero.internal.flightgear.Architecture = 'Default';
    end


    properties ( Hidden )
        DataFlow = "Send";
        OriginIPAddress = "127.0.0.1";
        OriginPort = "5505";
        CallSource = "matlab"

        Multiplayer( 1, 1 )matlab.lang.OnOffSwitchState = "off";
        Callsign( 1, 1 )string{ Aero.internal.validation.mustBeStringLengthLessThanOrEqual( Callsign, 7, "Callsign" ) } = ""
        MultiplayerOutboundIpAddress( 1, 1 )string
        MultiplayerOutboundPort( 1, 1 )string
        MultiplayerInboundIpAddress( 1, 1 )string
        MultiplayerInboundPort( 1, 1 )string
        CollisionDetection( 1, 1 )matlab.lang.OnOffSwitchState = "off";
        CustomCommandLineOptions( 1, : )string = ""
    end


    methods
        function set.DataFlow( h, value )
            h.DataFlow = string( Aero.internal.flightgear.DataFlow.createDataFlow( value ) );
        end
    end


    methods
        function h = FlightGearAnimation( n, NameValues )
            arguments( Repeating )
                n{ mustBeInteger, mustBeGreaterThanOrEqual( n, 0 ) }
            end
            arguments
                NameValues.?Aero.FlightGearAnimation
            end

            if ~builtin( 'license', 'test', 'Aerospace_Toolbox' )
                error( message( 'aero:licensing:noLicenseFGA' ) );
            end

            if ~builtin( 'license', 'checkout', 'Aerospace_Toolbox' )
                return ;
            end

            [ h.TimeSeriesReadFcn ] = deal( @Array6DoFRead );

            h = Aero.internal.namevalues.applyNameValuesAndCopyObject( h, NameValues, n );
        end

    end


    methods
        function value = get.Architecture( obj )
            value = char( obj.Architecture );
        end


        function value = get.InstallScenery( obj )
            value = logical( obj.InstallScenery );
        end


        function value = get.DisableShaders( obj )
            value = logical( obj.DisableShaders );
        end
    end


    methods
        ClearTimer( h )
        delete( h )
        GenerateRunScript( h )
        initialize( h )
        play( h, timername )
        SetTimer( h, timerName )
        update( h, t )
    end


    methods ( Hidden )
        function throwError( h, errormsg, titlemsg )
            if h( 1 ).CallSource == "matlab"
                error( errormsg );
            else
                errordlg( getString( errormsg ), getString( titlemsg ), "modal" )
            end
        end


        function throwWarning( h, warnmsg, titlemsg )
            if h( 1 ).CallSource == "matlab"
                warning( warnmsg );
            else
                warndlg( getString( warnmsg ), getString( titlemsg ), "modal" )
            end
        end


        function setTimeSeriesSourceTypeImpl( obj, value )
            switch value
                case Aero.animation.internal.TimeSeriesSourceType.Custom

                case Aero.animation.internal.TimeSeriesSourceType.Timeseries
                    obj.TimeSeriesReadFcn = @TimeseriesRead;
                case Aero.animation.internal.TimeSeriesSourceType.Timetable
                    obj.TimeSeriesReadFcn = @TimetableRead;
                case Aero.animation.internal.TimeSeriesSourceType.StructureWithTime
                    obj.TimeSeriesReadFcn = @StructTimeRead;
                case Aero.animation.internal.TimeSeriesSourceType.Array3DoF
                    obj.TimeSeriesReadFcn = @Array3DoFRead;
                case Aero.animation.internal.TimeSeriesSourceType.Array6DoF
                    obj.TimeSeriesReadFcn = @Array6DoFRead;
            end
        end


        function legacyDelete( h )
            h.ClearTimer(  );
        end


        function clearSocket( h )
            if ~isempty( h.FGSocket )
                if h.FGSocket.Connected
                    disconnect( h.FGSocket );
                end
                h.FGSocket = matlabshared.network.internal.UDP.empty(  );
            end

        end


        function timerCallbackFcn( h, timerObj, event, timeAdvance )

            switch event.Type
                case 'StartFcn'
                    h.update( h.TStart );

                case 'TimerFcn'
                    h.update( h.TStart + timerObj.TasksExecuted * timeAdvance );

                case 'StopFcn'
                    delete( timerObj )

                    h.update( h.TFinal );

                    h.clearSocket(  );
            end

        end

    end

end


function [ lla, ptp ] = Array3DoFRead( varargin )
if nargin == 1
    varargin = [ inf, varargin ];
end
[ lla, ptp ] = Aero.animation.interp3DoFArrayWithTime( varargin{ : } );
end

function [ lla, ptp ] = Array6DoFRead( varargin )
if nargin == 1
    varargin = [ inf, varargin ];
end
[ lla, ptp ] = Aero.animation.interp6DoFArrayWithTime( varargin{ : } );
end

function [ lla, ptp ] = StructTimeRead( varargin )
if nargin == 1
    varargin = [ inf, varargin ];
end
[ lla, ptp ] = Aero.animation.interpStructWithTime( varargin{ : } );
end

function [ lla, ptp ] = TimeseriesRead( varargin )
if nargin == 1
    varargin = [ inf, varargin ];
end
[ lla, ptp ] = Aero.animation.interpTimeseries( varargin{ : } );
end

function [ lla, ptp ] = TimetableRead( varargin )
if nargin == 1
    varargin = [ inf, varargin ];
end
[ lla, ptp ] = Aero.animation.interpTimetable( varargin{ : } );
end


