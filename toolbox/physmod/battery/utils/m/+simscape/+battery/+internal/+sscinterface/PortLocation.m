classdef ( Sealed, Hidden )PortLocation < simscape.battery.internal.sscinterface.StringItem




    properties ( Constant )
        Type = "PortLocation";
    end

    properties ( Access = private )
        PortNames;
        SideSpecification
    end

    methods
        function obj = PortLocation( portNames, sideSpecification )

            arguments
                portNames( 1, : )string{ mustBeNonzeroLengthText }
                sideSpecification string{ mustBeTextScalar, mustBeMember( sideSpecification, [ "top", "bottom", "left", "right" ] ) }
            end

            obj.PortNames = string( portNames );
            obj.SideSpecification = string( sideSpecification );
        end
    end

    methods ( Access = protected )

        function children = getChildren( ~ )

            children = [  ];
        end

        function str = getOpenerString( obj )

            portNamesString = join( obj.PortNames, "," );

            str = "[" + portNamesString + "] : Side=" + obj.SideSpecification;
        end

        function str = getTerminalString( ~ )

            str = ";" + newline;
        end
    end
end



