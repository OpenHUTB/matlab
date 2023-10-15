classdef ComponentPort < systemcomposer.arch.BasePort




    properties ( SetAccess = private )
        Parent
        ArchitecturePort
    end

    methods ( Hidden )
        function this = ComponentPort( archElemImpl )

            narginchk( 1, 1 );
            if ~isa( archElemImpl, 'systemcomposer.architecture.model.design.ComponentPort' )
                error( 'systemcomposer:API:ComponentPortInvalidInput',  ...
                    message( 'SystemArchitecture:API:ComponentPortInvalidInput' ).getString );
            end
            this@systemcomposer.arch.BasePort( archElemImpl );
        end
        function destroy( ~ )

            error( 'Method should not be called' );
        end

        function tf = isPropertyValueDefault( this, qualifiedPropName )
            tf = isPropertyValueDefault@systemcomposer.arch.Element( this.ArchitecturePort, qualifiedPropName );
        end

        function interface = createAnonymousInterface( this )

            interface = this.ArchitecturePort.createAnonymousInterface(  );
        end

        function interface = createOwnedInterface( this, kind )
            arguments
                this
                kind = ""
            end
            interface = this.ArchitecturePort.createOwnedInterface( kind );
        end
    end

    methods
        function parent = get.Parent( this )
            parent = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getComponent, '' );
        end

        function owningPort = get.ArchitecturePort( this )
            this.Parent.Architecture;
            owningPort = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getArchitecturePort,  ...
                'systemcomposer.arch.ArchitecturePort' );
        end


        function setName( this, newName )
            if this.Parent.isReference
                error( 'systemcomposer:API:ComponentPortNameError',  ...
                    message( 'SystemArchitecture:API:ComponentPortNameError' ).getString );
            end
            this.ArchitecturePort.setName( newName );
        end

        function setInterface( this, interface )

            this.ArchitecturePort.setInterface( interface );
        end

        function interface = createInterface( this, kind )


            arguments
                this
                kind = ""
            end
            interface = this.ArchitecturePort.createInterface( kind );
        end

        function names = getStereotypes( this )


            names = getStereotypes@systemcomposer.arch.Element( this.ArchitecturePort );
        end

        function [ propExpr, propUnits ] = getProperty( this, qualifiedPropName )







            [ propExpr, propUnits ] = getProperty@systemcomposer.arch.Element( this.ArchitecturePort, qualifiedPropName );
        end

        function value = getEvaluatedPropertyValue( this, qualifiedPropName )






            value = getEvaluatedPropertyValue( this.ArchitecturePort, qualifiedPropName );
        end

        function setProperty( this, qualifiedPropName, propExpr, propUnit )






            if nargin < 4
                propUnit = '';
            end
            setProperty@systemcomposer.arch.Element( this.ArchitecturePort, qualifiedPropName, propExpr, propUnit );
        end

        function val = getPropertyValue( this, qualifiedPropName )





            val = getPropertyValue( this.ArchitecturePort, qualifiedPropName );
        end

        function removeStereotype( ~, ~ )
            error( 'SystemArchitecture:Property:NotPrototypable',  ...
                message( 'SystemArchitecture:Property:NotPrototypable',  ...
                'systemcomposer.arch.ComponentPort' ).getString );
        end

        cn = connect( this, otherPort, stereotype, varargin );
        applyStereotype( this, stereotypeName );
    end

    methods ( Access = protected )
        function archObj = getArchitectureScopeForConnectors( this )
            archObj = this.Parent.Parent;
        end
    end

end

