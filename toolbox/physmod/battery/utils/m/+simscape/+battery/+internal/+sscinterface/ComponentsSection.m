classdef ( Sealed, Hidden )ComponentsSection < simscape.battery.internal.sscinterface.Section

    properties ( Constant )
        Type = "ComponentsSection";
    end

    properties ( Constant, Access = protected )
        SectionIdentifier = "components"
    end

    methods
        function obj = ComponentsSection( attributeArguments )

            arguments
                attributeArguments.CompileReuse string{ mustBeTextScalar, mustBeMember( attributeArguments.CompileReuse, [ "true", "false", "" ] ) } = ""
            end


            obj = obj.setAttribute( "ExternalAccess", "observe" );
            obj = obj.setAttribute( "CompileReuse", attributeArguments.CompileReuse );
        end

        function obj = addComponent( obj, compositeComponent )

            arguments
                obj( 1, 1 ){ mustBeA( obj, "simscape.battery.internal.sscinterface.ComponentsSection" ) }
                compositeComponent( 1, 1 ){ mustBeA( compositeComponent, "simscape.battery.internal.sscinterface.CompositeComponent" ) }
            end
            obj.SectionContent( end  + 1 ) = compositeComponent;
        end
    end
end

