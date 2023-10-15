classdef ArchitecturePort < systemcomposer.arch.BasePort





    properties ( SetAccess = private )
        Parent
    end

    methods ( Hidden )
        function this = ArchitecturePort( archElemImpl )
            narginchk( 1, 1 );
            if ~isa( archElemImpl, 'systemcomposer.architecture.model.design.ArchitecturePort' )
                error( 'systemcomposer:API:ArchitecturePortInvalidInput', message( 'SystemArchitecture:API:ArchitecturePortInvalidInput' ).getString );
            end
            this@systemcomposer.arch.BasePort( archElemImpl );
        end

        function tf = hasAnonymousCompositeInterface( this )
            tf = false;
            if this.hasAnonymousInterface(  )
                if isa( this.getImpl.p_InterfaceUsage.p_AnonymousInterface, 'systemcomposer.architecture.model.interface.CompositeDataInterface' )
                    tf = true;
                    return ;
                end
            end
        end

        function tf = hasAnonymousInterface( this )
            tf = false;
            if ~isempty( this.getImpl.p_InterfaceUsage ) && ~isempty( this.getImpl.p_InterfaceUsage.p_AnonymousInterface )
                tf = true;
                return ;
            end
        end

        function interface = createAnonymousInterface( this, isComposite )


            arguments
                this
                isComposite = false
            end
            warning( message( 'SystemArchitecture:API:DeprecatedMethod', 'createAnonymousInterface', 'createInterface' ) );
            if this.Direction == systemcomposer.arch.PortDirection.Physical
                interface = this.createInterface( 'PhysicalDomain' );
            else
                if nargin > 1 && isComposite
                    interface = this.createInterface( "DataInterface" );
                else
                    interface = this.createInterface( "ValueType" );
                end
            end
        end

        function interface = createOwnedInterface( this, kind )

            arguments
                this( 1, 1 )systemcomposer.arch.ArchitecturePort
                kind{ mustBeMember( kind, [ "ValueType", "DataInterface", "PhysicalDomain", "" ] ) } = ""
            end


            if strlength( kind ) == 0
                if this.Direction == systemcomposer.arch.PortDirection.Physical
                    kind = "PhysicalDomain";
                else
                    kind = "ValueType";
                end
            end

            if strcmp( kind, "DataInterface" )
                if this.Direction == systemcomposer.arch.PortDirection.Physical ||  ...
                        strcmpi( get_param( this.SimulinkHandle, 'isComposite' ), 'off' )


                    error( message( 'SystemArchitecture:API:NonBEPForCompositeAnonymous' ) )
                end


                systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties( this.getImpl );
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );


                systemcomposer.AnonymousInterfaceManager.AddInlinedInterfaceElement( this.getImpl, 'elem0' );
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );

                interfaceImpl = this.getImpl(  ).getPortInterface(  );
                if this.getImpl.getPortAction == systemcomposer.architecture.model.core.PortAction.PHYSICAL
                    interface = systemcomposer.internal.getWrapperForImpl( interfaceImpl, 'systemcomposer.interface.PhysicalInterface' );
                else
                    interface = systemcomposer.internal.getWrapperForImpl( interfaceImpl, 'systemcomposer.interface.DataInterface' );
                end
            elseif strcmp( kind, "ValueType" )
                if this.Direction == systemcomposer.arch.PortDirection.Physical
                    error( message( 'SystemArchitecture:API:ValueTypeNotForPhysicalPort' ) );
                end
                systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties( this.getImpl, true );
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );

                interfaceImpl = this.getImpl(  ).getPortInterface(  );
                interface = systemcomposer.internal.getWrapperForImpl( interfaceImpl, 'systemcomposer.ValueType' );
            else
                assert( strcmp( kind, "PhysicalDomain" ) );
                if this.Direction ~= systemcomposer.arch.PortDirection.Physical
                    error( message( 'SystemArchitecture:API:PhysicalDomainOnlyForPhysicalPort' ) );
                end

                systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties( this.getImpl, true );
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );

                interfaceImpl = this.getImpl(  ).getPortInterface(  );
                interface = systemcomposer.internal.getWrapperForImpl( interfaceImpl, 'systemcomposer.interface.PhysicalDomain' );
            end
        end
    end

    methods
        function setName( this, newName )
            portBlocks = systemcomposer.utils.getSimulinkPeer( this.getImpl );
            for i = 1:numel( portBlocks )
                if this.Direction == systemcomposer.arch.PortDirection.Physical
                    set_param( portBlocks( i ), 'Name', newName );
                else
                    if ( strcmpi( get_param( portBlocks( i ), 'isBusElementPort' ), 'on' ) )
                        set_param( portBlocks( i ), 'PortName', newName );
                    else


                        set_param( portBlocks( i ), 'Name', newName );
                    end
                end
            end
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
        end

        function parent = get.Parent( this )
            parent = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getArchitecture, 'systemcomposer.arch.Architecture' );
        end

        function setInterface( this, interface )


            arguments
                this
                interface{ mustBeValidInterfaceArg }
            end

            if isempty( interface ) || isstring( interface ) && matches( interface, "" )

                if this.hasAnonymousCompositeInterface


                    slPortBlocks = systemcomposer.utils.getSimulinkPeer( this.getImpl );
                    assert( numel( slPortBlocks ) > 0 );
                    rootBd = bdroot( slPortBlocks( 1 ) );
                    for i = 2:numel( slPortBlocks )
                        delete_block( slPortBlocks( i ) );
                    end
                    set_param( slPortBlocks( 1 ), 'Element', '' );
                    systemcomposer.internal.arch.internal.processBatchedPluginEvents( rootBd );
                end
                systemcomposer.BusObjectManager.SetPortInterface( this.getImpl, '' );
            else
                systemcomposer.architecture.model.design.ArchitecturePort.validateInterfaceCompatibility( this.getImpl, interface.getImpl );
                systemcomposer.BusObjectManager.SetPortInterface( this.getImpl, interface.Name, class( interface ) );
            end
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( this.SimulinkHandle( 1 ) ) );
        end

        function interface = createInterface( this, kind )


            arguments
                this( 1, 1 )systemcomposer.arch.ArchitecturePort
                kind{ mustBeMember( kind, [ "ValueType", "DataInterface", "PhysicalDomain", "" ] ) } = ""
            end





            parentArch = this.Parent;
            parentComp = parentArch.Parent;
            if ~isempty( parentComp ) && ~systemcomposer.internal.isVariantComponent( parentComp.SimulinkHandle ) && parentComp.IsAdapterComponent
                error( message( 'SystemArchitecture:API:NoAnonymousInterfaceForAdapterPorts' ) )
            end


            if this.Direction == systemcomposer.arch.PortDirection.Server ||  ...
                    this.Direction == systemcomposer.arch.PortDirection.Client
                error( message( 'SystemArchitecture:API:NoAnonymousInterfaceForClientOrServerPort' ) )
            end

            interface = this.createOwnedInterface( kind );
        end

        function sharedInterface = makeOwnedInterfaceShared( this, newInterfaceName )





            arguments
                this( 1, 1 )systemcomposer.arch.ArchitecturePort
                newInterfaceName( 1, : )char;
            end


            if this.Direction == systemcomposer.arch.PortDirection.Physical ||  ...
                    this.Direction == systemcomposer.arch.PortDirection.Client ||  ...
                    this.Direction == systemcomposer.arch.PortDirection.Server
                error( message( 'SystemArchitecture:API:NotASupportedPortType' ) );
            end




            if ~this.hasAnonymousInterface
                error( message( 'SystemArchitecture:API:NoOwnedInterfaceFound', this.Name ) );
            end
            ownedInterface = this.Interface;

            zcModel = this.Model;
            interfDictionary = zcModel.InterfaceDictionary;
            if this.hasAnonymousCompositeInterface

                sharedInterface = interfDictionary.addInterface( newInterfaceName );
                for element = ownedInterface.Elements
                    systemcomposer.internal.adapter.createElementFromSource( sharedInterface, element, element.Name );
                end
            else

                sharedInterface = interfDictionary.addValueType( newInterfaceName,  ...
                    'DataType', ownedInterface.DataType,  ...
                    'Dimensions', ownedInterface.Dimensions,  ...
                    'Units', ownedInterface.Units,  ...
                    'Complexity', ownedInterface.Complexity,  ...
                    'Minimum', ownedInterface.Minimum,  ...
                    'Maximum', ownedInterface.Maximum,  ...
                    'Description', ownedInterface.Description );
            end


            this.setInterface( sharedInterface );


            if ~isempty( this.Parent ) &&  ...
                    ~isempty( this.Parent.Parent ) &&  ...
                    this.Parent.Parent.IsAdapterComponent
                adapterDialog = systemcomposer.internal.adapter.Dialog.dialogFor( this.Parent.Parent.SimulinkHandle );
                if ~isempty( adapterDialog ) && isa( adapterDialog, 'DAStudio.Dialog' )
                    adapterDialog.refresh(  );
                end
            end
        end

        cn = connect( this, otherPort, stereotype, varargin );
        applyStereotype( this, stereotype );
    end

    methods
        function destroy( this )
            if strcmp( this.Parent.Definition, 'StateflowBehavior' )
                stateflowRoot = sfroot;
                chartId = sfprivate( 'block2chart', this.Parent.Parent.SimulinkHandle );
                chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
                sfData = chartObj.find( '-isa', 'Stateflow.Data', '-depth', 1, 'Name', this.Name );
                sfData.delete;
            else
                delete_block( systemcomposer.utils.getSimulinkPeer( this.getImpl ) );
            end
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
        end
    end

    methods ( Access = protected )
        function archObj = getArchitectureScopeForConnectors( this )
            archObj = this.Parent;
        end
    end

end

function mustBeValidInterfaceArg( x )
isValid = isa( x, 'systemcomposer.interface.DataInterface' ) ||  ...
    isa( x, 'systemcomposer.ValueType' ) ||  ...
    isa( x, 'systemcomposer.interface.PhysicalInterface' ) ||  ...
    isa( x, 'systemcomposer.interface.ServiceInterface' ) ||  ...
    ( ( isstring( x ) || ischar( x ) ) && matches( x, "" ) );
if ~isValid
    error( message( 'SystemArchitecture:API:InvalidInterfaceForPort' ) );
end
end
