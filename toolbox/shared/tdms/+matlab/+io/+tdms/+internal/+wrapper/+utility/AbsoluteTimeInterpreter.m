classdef AbsoluteTimeInterpreter



    properties ( Constant )
        AbsTimeLsbTicksPerMs = 2 ^ 64 / 1e3
        Epoch = datetime( 1904, 1, 1 )
        PosixEpoch = 2082844800;
        DateTimeFormat = 'uuuu-MM-dd HH:mm:ss.SSSSSSSSS'
    end

    methods ( Static )

        function [ absTimeMsb, absTimeLsb ] = dateTimeToAbsTime( dateTime )
            arguments
                dateTime datetime
            end
            import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter

            if isempty( dateTime.TimeZone )
                dateTime.TimeZone = "local";
            end
            dateTime.TimeZone = "UTC";


            absTimeMsb = int64( floor( posixtime( dateTime ) ) + AbsoluteTimeInterpreter.PosixEpoch );



            fractionalTimeInMs = milliseconds( dateTime - dateshift( dateTime, 'start', 'second' ) );
            absTimeLsb = uint64( AbsoluteTimeInterpreter.AbsTimeLsbTicksPerMs * fractionalTimeInMs );
        end

        function dateTime = absTimeToDateTime( absTimeMsb, absTimeLsb )
            arguments
                absTimeMsb int64
                absTimeLsb uint64
            end
            import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter

            dateTime = datetime( double( absTimeMsb ) - AbsoluteTimeInterpreter.PosixEpoch, 'ConvertFrom', 'posixtime',  ...
                'Format', AbsoluteTimeInterpreter.DateTimeFormat, 'TimeZone', 'UTC' );

            dateTime = dateTime + milliseconds( double( absTimeLsb ) / AbsoluteTimeInterpreter.AbsTimeLsbTicksPerMs );

            dateTime.TimeZone = "local";
        end
    end
end

