classdef ForLoop < simscape.battery.internal.sscinterface.StringItem





    properties ( Constant )
        Type = "ForLoop";
    end

    properties ( Access = private )
        SectionsContainer = simscape.battery.internal.sscinterface.SectionsContainer;
        Index
        Values
    end

    methods
        function obj = ForLoop( index, values )

            arguments
                index string{ mustBeTextScalar, mustBeNonzeroLengthText }
                values string{ mustBeTextScalar, mustBeNonzeroLengthText }
            end
            obj.Index = index;
            obj.Values = values;
        end

        function obj = addSection( obj, section )

            obj.SectionsContainer = obj.SectionsContainer.addSection( section );
        end
    end

    methods ( Access = protected )

        function children = getChildren( obj )

            children = obj.SectionsContainer.getContent;
        end

        function str = getOpenerString( obj )

            str = newline + "for " + obj.Index + " = " + obj.Values;
        end

        function str = getTerminalString( ~ )

            str = "end" + newline;
        end
    end
end

