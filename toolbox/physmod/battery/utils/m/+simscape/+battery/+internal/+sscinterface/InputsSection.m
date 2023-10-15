classdef ( Sealed, Hidden )InputsSection < simscape.battery.internal.sscinterface.Section




    properties ( Constant )
        Type = "InputsSection";
    end

    properties ( Constant, Access = protected )
        SectionIdentifier = "inputs"
    end

    methods
        function obj = InputsSection( attributeArguments )

            arguments
                attributeArguments.Access string{ mustBeTextScalar, mustBeMember( attributeArguments.Access, [ "public", "private", "protected", "" ] ) } = ""
                attributeArguments.ExternalAccess string{ mustBeTextScalar, mustBeMember( attributeArguments.ExternalAccess, [ "modify", "observe", "none", "" ] ) } = ""
            end
            obj = obj.setAttribute( "Access", attributeArguments.Access );
            obj = obj.setAttribute( "ExternalAccess", attributeArguments.ExternalAccess );
        end

        function obj = addInput( obj, name, value, unit, visualization )

            arguments
                obj
                name string{ mustBeTextScalar, mustBeNonzeroLengthText }
                value string{ mustBeTextScalar, mustBeNonzeroLengthText }
                unit.Unit string{ mustBeTextScalar } = ""
                visualization.Label string{ mustBeTextScalar } = ""
                visualization.Location string{ mustBeTextScalar, mustBeMember( visualization.Location, [ "", "left", "right", "top", "bottom" ] ) } = ""
            end



            if unit.Unit ~= ""
                definition = "{" + value + ",'" + unit.Unit + "'}";
            else
                definition = value;
            end


            if visualization.Location == ""
                portAppearance = visualization.Label;
            else
                portAppearance = visualization.Label.append( ":", visualization.Location );
            end


            obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.EqualityStatement( name, definition, "Comment", portAppearance );
        end
    end
end



