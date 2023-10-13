classdef ( Hidden, Abstract )PortBase < autosar.arch.ArchElement & matlab.mixin.CustomDisplay




    properties ( Dependent = true, SetAccess = protected )
        Kind
        Connected
    end

    properties ( Dependent = true, SetAccess = private )
        Interface Simulink.interface.dictionary.PortInterface
    end

    methods ( Abstract, Access = protected )
        getPortName( this );
        setPortName( this, newName );
        getPortKind( this );
        getIsConnected( this );
    end

    properties ( GetAccess = protected, SetAccess = private )
        SLPortBlock;
    end

    methods ( Access = protected )
        function propgrp = getPropertyGroups( ~ )

            proplist = { 'Name', 'Interface', 'SimulinkHandle', 'Parent',  ...
                'Kind', 'Connected' };
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end

    methods
        function this = PortBase( portBlkOrH )



            assert( autosar.arch.Utils.isPort( portBlkOrH ) ||  ...
                autosar.arch.Utils.isBusPortBlock( portBlkOrH ),  ...
                'portBlockOrH should either be port handle or port block handle' );


            portBlkOrH = get_param( portBlkOrH, 'Handle' );
            this@autosar.arch.ArchElement( portBlkOrH );


            this.SLPortBlock = this.getSLPortBlock(  );
        end

        function interface = get.Interface( this )
            interface = Simulink.interface.dictionary.PortInterface.empty(  );

            if ~autosar.arch.Utils.isBusPortBlock( this.SLPortBlock )

                return ;
            end

            dt = autosar.simulink.bep.Utils.getParam(  ...
                this.SLPortBlock, true, 'OutDataTypeStr' );

            if ~strcmp( dt, 'Inherit: auto' )
                interfaceName = strrep( dt, 'Bus: ', '' );
                interfaces = this.getRootArchModelObj(  ).Interfaces;
                interface = interfaces( strcmp( interfaceName, { interfaces.Name } ) );
            end
        end

        function portKind = get.Kind( this )
            portKind = this.getPortKind(  );
        end

        function tf = get.Connected( this )

            tf = this.getIsConnected(  );
        end
    end

    methods ( Hidden )
        function setInterface( this, interface )



            arguments
                this
                interface{ mustBeValidPortInterface }
            end

            if isempty( interface )

                busName = 'Inherit: auto';
            else
                busName = [ 'Bus: ', interface.Name ];
            end



            autosar.simulink.bep.Utils.setParam(  ...
                this.SLPortBlock,  ...
                true, 'OutDataTypeStr', busName );

            systemcomposer.internal.arch.internal.processBatchedPluginEvents(  ...
                bdroot( this.SimulinkHandle ) );
        end
    end

    methods ( Access = protected )
        function portName = getName( this )

            portName = this.getPortName(  );
        end

        function setName( this, newName )

            this.setPortName( newName );
        end
    end

    methods ( Access = private )
        function slPortBlk = getSLPortBlock( this )
            if autosar.arch.Utils.isBusPortBlock( this.SimulinkHandle )
                slPortBlk = getfullname( this.SimulinkHandle );
            else
                slPortBlk = autosar.arch.Utils.findSLPortBlock( this.SimulinkHandle );
                slPortBlk = slPortBlk{ 1 };
            end
        end
    end

    methods ( Hidden, Static )
        function port = createPort( portOrPortBlkH )


            isPort = autosar.arch.Utils.isPort( portOrPortBlkH );
            if isPort
                portOwner = get_param( portOrPortBlkH, 'Parent' );
                if autosar.arch.Utils.isBusPortBlock( portOwner )
                    port = autosar.arch.ArchPort.create( portOwner );
                else
                    assert( autosar.arch.Utils.isSubSystem( portOwner ) ||  ...
                        autosar.arch.Utils.isModelBlock( portOwner ),  ...
                        'unexpected block type for port owner' );
                    port = autosar.arch.CompPort.create( portOrPortBlkH );
                end
            else
                assert( autosar.arch.Utils.isBusPortBlock( portOrPortBlkH ),  ...
                    'unexpected block type for port block' );
                port = autosar.arch.ArchPort.create( portOrPortBlkH );
            end
        end
    end
end

function mustBeValidPortInterface( x )
isValid = isa( x, 'Simulink.interface.dictionary.PortInterface' ) ||  ...
    isempty( x );
if ~isValid
    error( message( 'autosarstandard:api:ArchModelInvalidPortInterface' ) );
end
end

