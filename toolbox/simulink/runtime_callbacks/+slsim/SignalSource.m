classdef SignalSource

    properties ( SetAccess = private, GetAccess = public )

        BlockPath( 1, 1 )Simulink.SimulationData.BlockPath

        UserData

        BusElement( 1, : )char
    end

    methods
        function obj = SignalSource( propArgs )
            arguments
                propArgs.BlockPath
                propArgs.UserData
                propArgs.BusElement
            end

            obj.BlockPath = propArgs.BlockPath;
            obj.UserData = propArgs.UserData;
            obj.BusElement = propArgs.BusElement;
        end

    end

    methods ( Static, Hidden )
        function validateBlockPath( blockPath )

            mustBeText( blockPath );
        end

        function validateUserData( userData )

        end

        function validateBusElement( busElement )

            mustBeTextScalar( busElement );
        end
    end
end

