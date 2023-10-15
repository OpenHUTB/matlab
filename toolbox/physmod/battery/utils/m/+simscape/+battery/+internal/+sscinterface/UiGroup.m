classdef ( Sealed, Hidden )UiGroup < simscape.battery.internal.sscinterface.StringItem




    properties ( Constant )
        Type = "UiGroup";
    end

    properties ( SetAccess = immutable, GetAccess = public )
        Title
    end

    properties ( Access = private )
        Parameters
    end

    methods
        function obj = UiGroup( title, parameters )

            arguments
                title string{ mustBeTextScalar, mustBeNonzeroLengthText }
                parameters( 1, : )string{ mustBeNonzeroLengthText }
            end

            obj.Title = title;
            obj.Parameters = parameters;
        end

        function mergedUiGroup = merge( uiGroups )

            arguments
                uiGroups{ mustBeNonempty, mustBeVector }
            end
            assert( all( uiGroups( 1 ).Title == [ uiGroups.Title ] ), message( "physmod:battery:sscinterface:IncompatibleUiGroupMerge" ) );
            mergedUiGroup = uiGroups( 1 );
            mergedUiGroup.Parameters = [ uiGroups.Parameters ];
        end
    end

    methods ( Access = protected )

        function children = getChildren( ~ )

            children = [  ];
        end

        function str = getOpenerString( obj )



            parameterString = obj.Parameters.join( "," );
            str = "UIGroup(" + char( 34 ) + obj.Title + char( 34 ) + "," + parameterString + ")";
        end

        function str = getTerminalString( ~ )

            str = "";
        end
    end
end

