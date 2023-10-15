classdef ( Sealed, Hidden )VariablesSection < simscape.battery.internal.sscinterface.Section

    properties ( Constant )
        Type = "VariablesSection";
    end

    properties ( Constant, Access = protected )
        SectionIdentifier = "variables"
    end

    methods
        function obj = VariablesSection( attributeArguments )

            arguments
                attributeArguments.Access string{ mustBeTextScalar, mustBeMember( attributeArguments.Access, [ "public", "private", "protected", "" ] ) } = ""
                attributeArguments.ExternalAccess string{ mustBeTextScalar, mustBeMember( attributeArguments.ExternalAccess, [ "modify", "observe", "none", "" ] ) } = ""
            end
            obj = obj.setAttribute( "Access", attributeArguments.Access );
            obj = obj.setAttribute( "ExternalAccess", attributeArguments.ExternalAccess );
        end

        function obj = addVariable( obj, name, value, unit, label, details )



            arguments
                obj
                name string{ mustBeTextScalar, mustBeNonzeroLengthText }
                value string{ mustBeTextScalar, mustBeNonzeroLengthText }
                unit string{ mustBeTextScalar, mustBeNonzeroLengthText }
                label string{ mustBeTextScalar, mustBeNonzeroLengthText }
                details.priority string{ mustBeTextScalar, mustBeMember( details.priority, [ "", "priority.none", "priority.high", "priority.low", "None", "Low", "High" ] ) } = "";
            end

            if details.priority == "" || details.priority.contains( "None" )
                priority = "";
            elseif details.priority.contains( "priority." )
                priority = lower( details.priority );
            else
                priority = "priority." + lower( details.priority );
            end


            if priority ~= ""
                definition = "{value={" + value + ",'" + unit + "'},priority=" + priority + "}";
            else
                definition = "{" + value + ",'" + unit + "'}";
            end

            obj.SectionContent( end  + 1 ) = simscape.battery.internal.sscinterface.EqualityStatement( name, definition, "Comment", label );
        end
    end
end

