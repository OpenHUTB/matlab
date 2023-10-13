classdef FaultInjector < handle

    properties
        slFunction char
    end

    methods
        function this = FaultInjector( bswConnectorPath )
            assert( slfeature( 'FaultAnalyzerBsw' ), 'Fault Analyzer support fro BSW should be enabled' );
            this.getOrCreateUpdateCaller( bswConnectorPath );
        end

        function eventFaultBlock = getOrCreateFaultedEvent( this, eventId )
            assert( ~isempty( this.slFunction ), 'Expected updateFaults function to exist' );

            eventFaultBlock = find_system(  ...
                this.slFunction,  ...
                'MaskType', 'FaultableEvent',  ...
                'EventId', eventId );
            if isempty( eventFaultBlock )
                position = this.getIdealPosition( eventId );
                eventFaultBlock = add_block(  ...
                    'autosarspkglib_internal_utils/Faultable Event',  ...
                    [ this.slFunction, '/Faultable Event' ],  ...
                    'MakeNameUnique', 'on',  ...
                    'CopyOption', 'nolink',  ...
                    'Position', position );
                set_param( eventFaultBlock, 'EventId', eventId );
                eventFaultBlock = { getfullname( eventFaultBlock ) };
            end
        end

        function eventFaults = getEventFaults( this )


            eventFaults = containers.Map;
            eventFaultBlocks = this.findFaultedEvents(  );
            for ii = 1:numel( eventFaultBlocks )
                faultedEventBlk = eventFaultBlocks{ ii };
                eventId = get_param( faultedEventBlk, 'EventId' );
                faultedLine = find_system( faultedEventBlk,  ...
                    'FindAll', 'on',  ...
                    'FollowLinks', 'on',  ...
                    'LookUnderMasks', 'all',  ...
                    'type', 'line',  ...
                    'Name', 'fault' );
                srcPortH = get( faultedLine, 'SrcPortHandle' );
                faults = Simulink.fault.findFaults( bdroot( srcPortH ), 'ModelElement', srcPortH );
                eventFaults( eventId ) = faults;
            end
        end

        function fault = addFault( this, eventId, faultName, faultType )
            arguments
                this
                eventId
                faultName
                faultType
            end
            fault = [  ];
            eventFaultBlock = this.getOrCreateFaultedEvent( eventId );
            faultedLine = find_system( eventFaultBlock{ 1 },  ...
                'FindAll', 'on',  ...
                'LookUnderMasks', 'all',  ...
                'type', 'line',  ...
                'Name', 'fault' );
            srcPortH = get( faultedLine, 'SrcPortHandle' );
            modelName = bdroot( eventFaultBlock{ 1 } );
            faultModelName = [ modelName, '_Faults' ];
            try
                fault = Simulink.fault.addFault( srcPortH,  ...
                    'Name', faultName );
                fault.addBehavior( faultModelName );
                slFault = this.findFaultBlkInFaultMdl( fault );
                this.populateFault( slFault, faultType );
            catch E

                E.rethrow(  );
            end
        end

        function removeFault( this, fault )
            arguments
                this autosar.bsw.rte.FaultInjector
                fault Simulink.fault.Fault
            end
            slFault = this.findFaultBlkInFaultMdl( fault );
            delete_block( slFault );
            Simulink.fault.deleteFault( fault.ModelElement, fault.Name );
        end

        function clearEventFaults( this, eventId )
            eventFaultBlock = this.getOrCreateFaultedEvent( eventId );
            delete_block( this.getOrCreateFaultedEvent( eventFaultBlock ) );
        end

        function clearUnfaultedEvents( this )
            eventFaults = this.getEventFaults(  );
            emptyValues = cellfun( @( x )isempty( x ), eventFaults.values );
            eventIds = eventFaults.keys;
            unfaultedEventIds = eventIds( emptyValues );
            for ii = 1:numel( unfaultedEventIds )
                delete_block( this.getOrCreateFaultedEvent( unfaultedEventIds{ ii } ) );
            end
        end
    end

    methods ( Access = private )
        function getOrCreateUpdateCaller( this, bswConnectorPath )
            bswConnectorPath = getfullname( bswConnectorPath );
            triggerBlk = find_system(  ...
                bswConnectorPath,  ...
                'LookUnderMasks', 'all',  ...
                'FollowLinks', 'on',  ...
                'BlockType', 'TriggerPort',  ...
                'FunctionPrototype', 'updateFaults()' );
            if ~isempty( triggerBlk )
                this.slFunction = get_param( triggerBlk( 1 ), 'Parent' );
            else
                faultUpdateFcnPath = [ bswConnectorPath, '/Update Faults' ];
                add_block( 'simulink/User-Defined Functions/Simulink Function',  ...
                    faultUpdateFcnPath,  ...
                    'CopyOption', 'nolink' );
                set_param( [ faultUpdateFcnPath, '/f' ],  ...
                    'FunctionPrototype', 'updateFaults()' );



                line = find_system( faultUpdateFcnPath,  ...
                    'LookUnderMasks', 'all',  ...
                    'FindAll', 'on',  ...
                    'type', 'line' );
                delete_line( line );
                this.slFunction = faultUpdateFcnPath;
            end
        end

        function eventFaultBlocks = findFaultedEvents( this )
            eventFaultBlocks = find_system(  ...
                this.slFunction,  ...
                'LookUnderMasks', 'all',  ...
                'MaskType', 'FaultableEvent' );
        end

        function position = getIdealPosition( ~, eventIdStr )
            eventId = str2double( eventIdStr );
            yBaseOffset = 50;
            ySpacing = 30;
            blkHeight = 28;
            y = yBaseOffset + ( ( ySpacing + blkHeight ) * eventId );
            position = [ 210, y, 270, y + blkHeight ];
        end
    end

    methods ( Static )
        function faultInjector = getFaultInjector( dscBlk )
            dsc = getfullname( dscBlk );
            rteConnector = [ dsc, '/RTE Service Connector' ];
            faultInjector = autosar.bsw.rte.FaultInjector( rteConnector );
        end

        function blkPath = findFaultBlkInFaultMdl( fault )
            arguments
                fault Simulink.fault.Fault
            end
            blkPath = '';
            if ~exist( fault.getBehaviorModel, 'file' )
                return ;
            else
                blkPath = find_system( fault.getBehaviorModel, 'SearchDepth', 1, 'Name', fault.Name );
                blkPath = blkPath{ 1 };
            end
        end

        function populateFault( blkPath, faultType )
            switch faultType
                case 'Override'
                    faultBlkPath = [ blkPath, '/Dem Status Source' ];
                    add_block( 'autosarlibfault/Dem Status Source', faultBlkPath );
                    termPath = [ blkPath, '/Terminator' ];
                    add_block( 'simulink/Sinks/Terminator', termPath );
                    add_line( blkPath, 'InjectorInport/1', 'Terminator/1' );
                    add_line( blkPath, 'Dem Status Source/1', 'InjectorOutport/1' );
                case 'Inject'
                    faultBlkPath = [ blkPath, '/Dem Status Modify' ];
                    add_block( 'autosarlibfault/Dem Status Modify', faultBlkPath );
                    add_line( blkPath, 'InjectorInport/1', 'Dem Status Modify/1' );
                    add_line( blkPath, 'Dem Status Modify/1', 'InjectorOutport/1' );
                otherwise
                    assert( false, 'Unable to construct fault type %s', faultType );
            end

            Simulink.BlockDiagram.arrangeSystem( blkPath, 'Animation', 'false' );
        end
    end
end



