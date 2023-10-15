classdef PhysicalElement < systemcomposer.interface.Element




































    properties ( Dependent )

        Name


        Type
    end

    properties ( Dependent, SetAccess = private )

        Interface
    end

    methods ( Hidden )
        function this = PhysicalElement( impl )
            narginchk( 1, 1 );
            if ~isa( impl, 'systemcomposer.architecture.model.interface.PhysicalElement' )
                error( message( 'SystemArchitecture:API:PhysicalElementCtorInvalidInput' ) );
            end
            this@systemcomposer.interface.Element( impl );
            impl.cachedWrapper = this;
        end
    end

    methods
        function interface = get.Interface( this )
            interface = this.getWrapperForImpl(  ...
                this.getImpl(  ).getInterface(  ), 'systemcomposer.interface.PhysicalInterface' );
        end

        function name = get.Name( this )
            name = this.getImpl(  ).getName(  );
        end

        function set.Name( this, name )
            this.setName( name );
        end

        function setName( this, name )
            arguments
                this
                name{ mustBeValidVariableName }
            end

            isModelContext = isempty( this.Interface.Owner.ddConn );
            sourceName = this.Interface.Owner.getSourceName;
            systemcomposer.BusObjectManager.RenameInterfaceElement(  ...
                sourceName, isModelContext, this.Interface.Name, this.Name, name );
        end

        function type = get.Type( this )
            typeImpl = this.getImpl(  ).getTypeAsInterface(  );
            if this.isImplUntyped( typeImpl )
                type = systemcomposer.interface.PhysicalDomain.empty(  );
            else
                type = systemcomposer.internal.getWrapperForImpl( typeImpl );
            end
        end

        function set.Type( this, type )
            this.setType( type );
        end

        function destroy( this )
            isModelContext = isempty( this.Interface.Owner.ddConn );
            sourceName = this.Interface.Owner.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterfaceElement( sourceName,  ...
                isModelContext, this.Interface.Name, this.Name );
        end
    end

    methods ( Hidden )
        function setType( this, type )
            if isa( type, 'systemcomposer.interface.PhysicalInterface' )

                this.setTypeFromString( type.Name );
            elseif isa( type, 'char' ) || isStringScalar( type )
                this.setTypeFromString( type );
            else
                error( "Put in catalog" );
            end
        end

        function setTypeFromString( this, typeStr )
            arguments
                this
                typeStr{ mustBeTextScalar }
            end



            typeStr = strrep( typeStr, 'Connection: ', '' );
            typeStr = strrep( typeStr, 'Bus: ', '' );

            if strcmp( typeStr, '' ) || strcmp( typeStr, '<domain name>' )
                this.setTypeInSimulink( '<domain name>' );
            else
                resolvedName = this.Interface.resolvePhysicalDomainOrInterfaceName( typeStr );
                this.setTypeInSimulink( resolvedName );
            end
        end
    end

    methods ( Access = private )
        function setTypeInSimulink( this, propVal )
            isModelContext = isempty( this.Interface.Owner.ddConn );
            sourceName = this.Interface.Owner.getSourceName;
            systemcomposer.BusObjectManager.SetInterfaceElementProperty(  ...
                sourceName, isModelContext, this.Interface.Name, this.Name,  ...
                'Type', propVal );
        end

        function is = isImplUntyped( ~, impl )
            is = isa( impl, 'systemcomposer.architecture.model.interface.AtomicPhysicalInterface' ) &&  ...
                ~isempty( strfind( impl.p_Type, '<domain name>' ) );
        end
    end
end

