classdef PhysicalInterface < systemcomposer.base.StereotypableElement & systemcomposer.base.BaseElement






















































    properties ( Dependent )

        Name{ mustBeValidVariableName }

        Description{ mustBeValidVariableName }
    end

    properties ( SetAccess = private, Dependent )

        Owner systemcomposer.interface.Dictionary

        Elements( 1, : )systemcomposer.interface.PhysicalElement

        Model
    end

    methods ( Hidden )
        function this = PhysicalInterface( impl )
            narginchk( 1, 1 );
            if ~isa( impl, 'systemcomposer.architecture.model.interface.PhysicalInterface' )
                error( message( 'SystemArchitecture:API:PhysicalInterfaceCtorInvalidInput' ) );
            end
            this@systemcomposer.base.BaseElement( impl );
            impl.cachedWrapper = this;
        end
    end

    methods
        function m = get.Model( this )



            m = systemcomposer.arch.Model.empty;
            catalog = this.getImpl(  ).getCatalog(  );
            catalogOwnerName = catalog.getStorageSource;
            if ( catalog.getStorageContext == systemcomposer.architecture.model.interface.Context.MODEL ) ...
                    && bdIsLoaded( catalogOwnerName )
                m = systemcomposer.loadModel( catalogOwnerName );
            end
        end

        function dictionary = get.Owner( this )
            dictionary = systemcomposer.internal.getWrapperForImpl(  ...
                this.getImpl(  ).getCatalog(  ), 'systemcomposer.interface.Dictionary' );
        end

        function name = get.Name( this )
            name = this.getImpl(  ).getName;
        end

        function set.Name( this, name )
            this.setName( name );
        end

        function setName( this, name )
            arguments
                this
                name{ mustBeValidVariableName }
            end

            isModelContext = isempty( this.Owner.ddConn );
            sourceName = this.Owner.getSourceName;
            systemcomposer.BusObjectManager.RenameInterface( sourceName, isModelContext, this.Name, name );
        end

        function desc = get.Description( this )
            desc = this.getImpl(  ).getDescription;
        end

        function set.Description( this, desc )
            this.setDescription( desc );
        end

        function setDescription( this, desc )
            arguments
                this
                desc{ mustBeText }
            end

            isModelContext = isempty( this.Owner.ddConn );
            sourceName = this.Owner.getSourceName;
            systemcomposer.BusObjectManager.SetInterfaceDescription( sourceName, isModelContext, this.Name, desc );
        end

        function elements = get.Elements( this )
            interfaceImpl = this.getImpl(  );
            interfaceImplElements = interfaceImpl.getElementsInIndexOrder(  );
            elements = systemcomposer.interface.PhysicalElement.empty( numel( interfaceImplElements ), 0 );
            for i = 1:numel( interfaceImplElements )
                elements( i ) = systemcomposer.internal.getWrapperForImpl(  ...
                    interfaceImplElements( i ), 'systemcomposer.interface.PhysicalElement' );
            end
        end

        function element = addElement( this, elementName, nameValArgs )


            arguments
                this
                elementName{ mustBeTextScalar }
                nameValArgs.Type{ mustBeTextScalar } = ""
            end

            resolvedName = this.resolvePhysicalDomainOrInterfaceName( nameValArgs.Type );

            isModelContext = isempty( this.Owner.ddConn );
            sourceName = this.Owner.getSourceName;
            elemPrms.Type = resolvedName;

            systemcomposer.BusObjectManager.AddInterfaceElement(  ...
                sourceName, isModelContext, this.Name, elementName, elemPrms );

            elementImpl = this.getImpl.getElement( elementName );

            element = systemcomposer.internal.getWrapperForImpl(  ...
                elementImpl, 'systemcomposer.interface.PhysicalElement' );
        end

        function removeElement( this, elementName )





            isModelContext = isempty( this.Owner.ddConn );
            sourceName = this.Owner.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterfaceElement( sourceName, isModelContext, this.Name, elementName );
        end

        function element = getElement( this, elementName )





            elementImpl = this.getImpl(  ).getElement( elementName );
            if ( isempty( elementImpl ) )
                element = systemcomposer.interface.PhysicalElement.empty(  );
            else
                element = systemcomposer.internal.getWrapperForImpl( elementImpl, 'systemcomposer.interface.PhysicalElement' );
            end
        end

        function destroy( this )
            isModelContext = isempty( this.Owner.ddConn );
            sourceName = this.Owner.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterface( sourceName,  ...
                isModelContext, this.Name );
        end

    end

    methods ( Hidden )
        function intrf = resolveInterface( this, name )



            intrf = systemcomposer.interface.PhysicalInterface.empty;
            typeObj = this.Owner.getInterface( name );
            if isa( typeObj, 'systemcomposer.interface.PhysicalInterface' )
                intrf = typeObj;
            end
        end

        function resolvedName = resolvePhysicalDomainOrInterfaceName( this, name )






            name = strrep( name, 'Connection: ', '' );
            name = strrep( name, 'Bus: ', '' );

            try
                resolvedName = systemcomposer.interface.PhysicalDomain.resolveDomain( name );

            catch me
                if strcmp( me.identifier, 'SystemArchitecture:API:InvalidPhysicalDomainName' )

                    obj = this.resolveInterface( name );
                    if ~isempty( obj )
                        resolvedName = obj.Name;
                    else
                        error( message( 'SystemArchitecture:API:InvalidPhysicalDomainOrInterfaceName', name ) );
                    end
                else
                    throw( me );
                end

            end
        end
    end

end

