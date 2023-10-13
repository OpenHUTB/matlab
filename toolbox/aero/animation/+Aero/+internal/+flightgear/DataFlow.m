classdef DataFlow

    enumeration
        Send
        Receive
        SendReceive
    end

    methods ( Static )
        function obj = createDataFlow( str )
            arguments
                str( 1, 1 )string
            end


            str = erase( str, "-" );
            obj = Aero.internal.flightgear.DataFlow( str );
        end
    end
end


