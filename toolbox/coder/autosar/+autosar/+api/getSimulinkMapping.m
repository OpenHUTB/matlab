classdef getSimulinkMapping < handle

    properties ( Access = private, Transient = true )
        ModelName;
        ChangeLogger;
    end

    properties ( Constant, Access = private )
        ValidReceiverDAMs = { 'ImplicitReceive'
            'ExplicitReceive'
            'ExplicitReceiveByVal'
            'QueuedExplicitReceive'
            'ErrorStatus'
            'IsUpdated'
            'EndToEndRead'
            'EndToEndQueuedReceive' };
        ValidBepReceiverDAMs = { 'ExplicitReceive'
            'ImplicitReceive'
            'ExplicitReceiveByVal'
            'ModeReceive'
            'EndToEndRead'
            'QueuedExplicitReceive'
            'EndToEndQueuedReceive' };
        ValidSenderDAMs = { 'ImplicitSend'
            'ImplicitSendByRef'
            'ExplicitSend'
            'EndToEndWrite'
            'QueuedExplicitSend'
            'EndToEndQueuedSend' };
        ValidBepSenderDAMs = { 'ExplicitSend'
            'ImplicitSend'
            'ImplicitSendByRef'
            'ModeSend'
            'EndToEndWrite'
            'QueuedExplicitSend'
            'EndToEndQueuedSend' };
        ValidNvReceiverDAMs = { 'ImplicitReceive'
            'ExplicitReceive'
            'ExplicitReceiveByVal' };
        ValidNvSenderDAMs = { 'ImplicitSend'
            'ImplicitSendByRef'
            'ExplicitSend' };
        ValidParameterAccessModes = { 'PortParameter'
            'PerInstance'
            'Shared'
            'ConstantMemory'
            'Auto' };
        DummyServiceRequiredPortDAM = 'ImplicitReceive';
        ValidServiceProvidedAllocateMemory = { 'true'
            'false' };
    end

    properties ( Access = private, Transient = true, Hidden = true )
        InternalMappingType;
    end

    methods ( Access = public )
        function this = getSimulinkMapping( modelName, changeLogger )








            this.ModelName = get_param( modelName, 'Name' );

            this.InternalMappingType = coder.mapping.internal.Utils.getCurrentMappingType( this.ModelName );


            if autosar.composition.Utils.isModelInCompositionDomain( this.ModelName )
                DAStudio.error( 'autosarstandard:api:CapabilityNotSupportForAUTOSARArchitectureModel',  ...
                    'autosar.api.getSimulinkMapping' );
            end

            if nargin > 1
                this.ChangeLogger = changeLogger;
            else
                this.ChangeLogger = [  ];
            end
        end

        function [ ARIRVName, ARDataAccessMode ] = getDataTransfer( this, SLDataTransferName )







            if ~( ischar( SLDataTransferName ) || isStringScalar( SLDataTransferName ) )
                DAStudio.error( 'autosarstandard:validation:invalidDataTransferName' );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            findDataTransfer = false;


            SLDataTransfer = modelMapping.DataTransfers.findobj( 'SignalName', SLDataTransferName );
            if length( SLDataTransfer ) == 1
                findDataTransfer = true;
            else
                if ~autosar.api.getSimulinkMapping.isValidRateTransitionBlock( SLDataTransferName )
                    DAStudio.error( 'RTW:autosar:invalidMappingDataTransfer', SLDataTransferName );
                end
                SLDataTransfer = modelMapping.RateTransition.findobj( 'Block', SLDataTransferName );

                if length( SLDataTransfer ) == 1
                    findDataTransfer = true;
                end
            end


            if ~findDataTransfer
                DAStudio.error( 'RTW:autosar:invalidMappingDataTransfer', SLDataTransferName );
            end

            ARIRVName = SLDataTransfer.MappedTo.IrvName;
            ARDataAccessMode = SLDataTransfer.MappedTo.IrvAccessMode;
        end

        function [ arRunnableOrPortName, arRunnableSwAddrMethodOrMethodName, arInternalDataSwAddrMethod ] =  ...
                getFunction( this, slEntryPointFunction )









































            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                slEntryPointFunction = autosar.api.getSimulinkMapping.escapeSimulinkName( slEntryPointFunction );

                if autosar.api.Utils.isMappedToAdaptiveApplication( this.ModelName )

                    arInternalDataSwAddrMethod = '';
                    [ arRunnableOrPortName, arRunnableSwAddrMethodOrMethodName ] =  ...
                        this.getAdaptiveFunction( slEntryPointFunction );
                else
                    [ arRunnableOrPortName, arRunnableSwAddrMethodOrMethodName, arInternalDataSwAddrMethod ] =  ...
                        this.getClassicFunction( slEntryPointFunction );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

        end

        function [ ARPortName, ARElementName, ARDataAccessMode ] = getInport( this, SLPortName )









            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );

            SLPort = modelMapping.Inports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );


            blockH = get_param( [ this.ModelName, '/', SLPortName ], 'Handle' );
            if strcmp( get_param( blockH, 'IsBusElementPort' ), 'on' )
                if ~( codermapping.internal.bep.isMappableBEP( blockH ) )
                    DAStudio.error( 'RTW:autosar:invalidBlockForBEMapping',  ...
                        getfullname( blockH ) );
                end
            end

            if length( SLPort ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'Simulink Port', SLPortName );
            end

            if isa( SLPort.MappedTo, 'Simulink.AutosarTarget.PortEvent' )
                ARPortName = SLPort.MappedTo.Port;
                ARElementName = SLPort.MappedTo.Event;
                ARDataAccessMode = [  ];
            else
                ARPortName = SLPort.MappedTo.Port;
                ARElementName = SLPort.MappedTo.Element;
                ARDataAccessMode = SLPort.MappedTo.DataAccessMode;
            end

        end

        function [ ARPortName, ARElementName, ARDataAccessMode ] = getOutport( this, SLPortName )









            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLPort = modelMapping.Outports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );


            blockH = get_param( [ this.ModelName, '/', SLPortName ], 'Handle' );
            if strcmp( get_param( blockH, 'IsBusElementPort' ), 'on' )
                if ~( codermapping.internal.bep.isMappableBEP( blockH ) )
                    DAStudio.error( 'RTW:autosar:invalidBlockForBEMapping',  ...
                        getfullname( blockH ) );
                end
            end

            if length( SLPort ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'Simulink Port', SLPortName );
            end

            if isa( SLPort.MappedTo, 'Simulink.AutosarTarget.PortProvidedEvent' )
                ARPortName = SLPort.MappedTo.Port;
                ARElementName = SLPort.MappedTo.Event;
                ARDataAccessMode = SLPort.MappedTo.AllocateMemory;
            else
                ARPortName = SLPort.MappedTo.Port;
                ARElementName = SLPort.MappedTo.Element;
                ARDataAccessMode = SLPort.MappedTo.DataAccessMode;
            end

        end

        function [ ARPortName, AROperationName ] = getFunctionCaller( this, SLFcnName )







            if autosar.api.getSimulinkMapping.usesFunctionPortMapping( this.ModelName )
                isClient = true;
                blockMappings = autosar.simulink.functionPorts.Mapping.getPortMapping( this.ModelName, SLFcnName, isClient );
            else
                blockMappings = autosar.api.internal.MappingFinder.getFunctionCallerBlockMappings( this.ModelName, SLFcnName );
            end
            if isempty( blockMappings )
                DAStudio.error( 'RTW:autosar:invalidFunctionCallerBlock', SLFcnName );
            end

            if isa( blockMappings( 1 ).MappedTo, 'Simulink.AutosarTarget.PortMethod' )
                ARPortName = blockMappings( 1 ).MappedTo.Port;
                AROperationName = blockMappings( 1 ).MappedTo.Method;
            else
                ARPortName = blockMappings( 1 ).MappedTo.ClientPort;
                AROperationName = blockMappings( 1 ).MappedTo.Operation;
            end

        end


        function mapDataTransfer( this, SLDataTransferName, ARIRVName, ARDataAccessMode )








            autosar.api.Utils.autosarlicensed( true );

            if ~( ischar( SLDataTransferName ) || isStringScalar( SLDataTransferName ) )
                DAStudio.error( 'autosarstandard:validation:invalidDataTransferName' );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            findSignal = false;
            findRTB = false;



            SLDataTransfer = modelMapping.DataTransfers.findobj( 'SignalName', SLDataTransferName );
            if length( SLDataTransfer ) == 1
                findSignal = true;


                componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                ARIRVPaths = dataObj.find( componentQualifiedName, 'IrvData',  ...
                    'Name', ARIRVName, 'PathType', 'FullyQualified' );
                if length( ARIRVPaths ) ~= 1
                    DAStudio.error( 'RTW:autosar:invalidMappingDataTransferIrv',  ...
                        SLDataTransferName, ARIRVName );
                end
            else
                if ~autosar.api.getSimulinkMapping.isValidRateTransitionBlock( SLDataTransferName )
                    DAStudio.error( 'RTW:autosar:invalidMappingDataTransfer', SLDataTransferName );
                end

                if ~( strcmp( get_param( SLDataTransferName, 'Integrity' ), 'on' ) &&  ...
                        strcmp( get_param( SLDataTransferName, 'Deterministic' ), 'off' ) )
                    DAStudio.error(  ...
                        'autosarstandard:validation:RateTranBlkForIRV',  ...
                        SLDataTransferName );
                end

                SLDataTransfer = modelMapping.RateTransition.findobj( 'Block', SLDataTransferName );

                if length( SLDataTransfer ) == 1
                    findRTB = true;


                    componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                    ARIRVPaths = dataObj.find( componentQualifiedName, 'IrvData',  ...
                        'Name', ARIRVName, 'PathType', 'FullyQualified' );
                    if length( ARIRVPaths ) ~= 1
                        DAStudio.error( 'autosarstandard:validation:IRVNotExistForDataTransfer',  ...
                            SLDataTransferName, ARIRVName );
                    end
                end
            end

            if ~findSignal && ~findRTB
                DAStudio.error( 'RTW:autosar:invalidMappingDataTransfer', SLDataTransferName );
            end


            isIRVChanged = ~strcmp( SLDataTransfer.MappedTo.IrvName, ARIRVName );
            isAccessModeChanged = ~strcmp( SLDataTransfer.MappedTo.IrvAccessMode, ARDataAccessMode );
            if ~isIRVChanged && ~isAccessModeChanged


                return ;
            end

            if ~isempty( this.ChangeLogger )
                if isIRVChanged
                    this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR IRV mapping',  ...
                        'Simulink data transfer',  ...
                        SLDataTransferName,  ...
                        SLDataTransfer.MappedTo.IrvName,  ...
                        ARIRVName );
                end

                if isAccessModeChanged
                    this.ChangeLogger.logModification( 'Automatic', 'DataAccessMode',  ...
                        'Simulink data transfer',  ...
                        SLDataTransferName,  ...
                        SLDataTransfer.MappedTo.IrvAccessMode,  ...
                        ARDataAccessMode );
                end
            end

            if findSignal
                SLDataTransfer.mapInterRunnableVariable( SLDataTransferName, ARIRVName, ARDataAccessMode, '' );
            else
                SLDataTransfer.mapInterRunnableVariable( ARIRVName, ARDataAccessMode, '' );
            end

        end

        function mapInport( this, SLPortName, ARPortName, ARDataName, ARDataAccessModeStr )













            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLPort = modelMapping.Inports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );


            blockH = get_param( [ this.ModelName, '/', SLPortName ], 'Handle' );
            if strcmp( get_param( blockH, 'IsBusElementPort' ), 'on' )
                if ~( codermapping.internal.bep.isMappableBEP( blockH ) )
                    DAStudio.error( 'RTW:autosar:invalidBlockForBEMapping',  ...
                        getfullname( blockH ) );
                end
            end


            if length( SLPort ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'Simulink Port', SLPortName );
            end

            isEventPort = isa( SLPort.MappedTo, 'Simulink.AutosarTarget.PortEvent' );
            if isEventPort
                dataElementPropertyName = 'Event';
            else
                dataElementPropertyName = 'Element';
            end


            isPortChanged = ~strcmp( SLPort.MappedTo.Port, ARPortName );
            isElementChanged = ~strcmp( SLPort.MappedTo.( dataElementPropertyName ), ARDataName );
            isDAMChanged = ~isEventPort && ~strcmp( SLPort.MappedTo.DataAccessMode, ARDataAccessModeStr );

            if ~isPortChanged && ~isElementChanged && ~isDAMChanged


                return ;
            end

            if strcmp( get_param( SLPort.Block, 'IsBusElementPort' ), 'on' ) && ~isEventPort

                if ~any( strcmp( ARDataAccessModeStr, this.getValidDataReceiverDAMs( true ) ) )
                    DAStudio.error( 'RTW:autosar:invalidMappingDAM', ARDataAccessModeStr, SLPortName, autosar.api.Utils.cell2str( this.ValidBepReceiverDAMs ) );
                else
                    if ~strcmp( strtrim( get_param( SLPort.Block, 'PortName' ) ), ARPortName ) ...
                            || ~strcmp( get_param( SLPort.Block, 'Element' ), ARDataName )

                        DAStudio.error( 'autosarstandard:api:busElementPortMappingChanged', getfullname( SLPort.Block ) );
                    end
                    SLPort.mapPortElement( ARPortName, ARDataName, ARDataAccessModeStr );
                    return ;
                end
            end

            componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );


            if isEventPort
                portType = 'ServiceRequiredPort';
            elseif strcmp( ARDataAccessModeStr, 'ModeReceive' )
                portType = 'ModeReceiverPort';
            else
                portType = 'DataReceiverPort';
            end
            ARPortPaths = dataObj.find( componentQualifiedName, portType,  ...
                'Name', ARPortName, 'PathType', 'FullyQualified' );


            if isempty( ARPortPaths ) && strcmp( portType, 'DataReceiverPort' )
                ARPortPaths = dataObj.find( componentQualifiedName, 'DataSenderReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
                if ~isempty( ARPortPaths )

                    portType = 'DataSenderReceiverPort';
                end
            end


            if isempty( ARPortPaths ) && strcmp( portType, 'DataReceiverPort' )
                ARPortPaths = dataObj.find( componentQualifiedName, 'NvDataReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
                if ~isempty( ARPortPaths )

                    portType = 'NvDataReceiverPort';
                end
            end


            if isempty( ARPortPaths ) && strcmp( portType, 'DataReceiverPort' )
                ARPortPaths = dataObj.find( componentQualifiedName, 'NvDataSenderReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
                if ~isempty( ARPortPaths )

                    portType = 'NvDataSenderReceiverPort';
                end
            end

            if isempty( ARPortPaths ) && strcmp( portType, 'ModeReceiverPort' )

                ARPortPaths = dataObj.find( componentQualifiedName, 'DataReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
            end

            if length( ARPortPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, portType, ARPortName );
            end

            if strcmp( portType, 'ServiceRequiredPort' )
                ARDataAccessModeStr = autosar.api.getSimulinkMapping.DummyServiceRequiredPortDAM;
            end


            ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
            if strcmp( ARDataAccessModeStr, 'ModeReceive' )
                metaModelClassName = 'ModeDeclarationGroupElement';
            else
                metaModelClassName = 'FlowData';
            end
            ARDataElementPaths = dataObj.find( ifPath, metaModelClassName,  ...
                'Name', ARDataName, 'PathType', 'FullyQualified' );
            if isempty( ifPath ) || length( ARDataElementPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'DataElement', ARDataName );
            end

            switch portType
                case 'DataReceiverPort'
                    validDataAccessModes = this.ValidReceiverDAMs;
                case 'DataSenderReceiverPort'
                    validDataAccessModes = this.getValidDataSenderReceiverDAMsForInports(  );
                case { 'NvDataReceiverPort', 'NvDataSenderReceiverPort' }
                    validDataAccessModes = this.ValidNvReceiverDAMs;
                case 'ModeReceiverPort'
                    validDataAccessModes = { 'ModeReceive' };
                case 'ServiceRequiredPort'
                    validDataAccessModes = { autosar.api.getSimulinkMapping.DummyServiceRequiredPortDAM };
                otherwise
                    assert( false, 'Did not recognize portType %s', portType );
            end


            if ~any( strcmp( ARDataAccessModeStr, validDataAccessModes ) )
                validDataAccessModesStr = autosar.api.Utils.cell2str( validDataAccessModes );
                DAStudio.error( 'RTW:autosar:invalidMappingDAM', ARDataAccessModeStr, SLPortName, validDataAccessModesStr );
            end
            if ~isempty( this.ChangeLogger )
                if isPortChanged
                    this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Port mapping',  ...
                        'Simulink inport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.Port,  ...
                        ARPortName );
                end

                if isElementChanged
                    this.ChangeLogger.logModification( 'Automatic',  ...
                        [ 'AUTOSAR ', dataElementPropertyName, ' mapping' ],  ...
                        'Simulink inport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.( dataElementPropertyName ),  ...
                        ARDataName );
                end

                if isDAMChanged
                    this.ChangeLogger.logModification( 'Automatic', 'DataAccessMode',  ...
                        'Simulink inport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.DataAccessMode,  ...
                        ARDataAccessModeStr );
                end
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                if isEventPort
                    SLPort.mapPortEvent( ARPortName, ARDataName, '' );
                else

                    autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec( ARPortName,  ...
                        ARDataName, ARDataAccessModeStr, this.ModelName );
                    SLPort.mapPortElement( ARPortName, ARDataName, ARDataAccessModeStr );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function mapOutport( this, SLPortName, ARPortName, ARDataName, ARDataAccessModeStr )












            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLPort = modelMapping.Outports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );


            blockH = get_param( [ this.ModelName, '/', SLPortName ], 'Handle' );
            if strcmp( get_param( blockH, 'IsBusElementPort' ), 'on' )
                if ~( codermapping.internal.bep.isMappableBEP( blockH ) )
                    DAStudio.error( 'RTW:autosar:invalidBlockForBEMapping',  ...
                        getfullname( blockH ) );
                end
            end

            if length( SLPort ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'Simulink Port', SLPortName );
            end

            isEventPort = isa( SLPort.MappedTo, 'Simulink.AutosarTarget.PortProvidedEvent' );
            if isEventPort
                dataElementPropertyName = 'Event';
                dataAccessModePropertyName = 'AllocateMemory';
            else
                dataElementPropertyName = 'Element';
                dataAccessModePropertyName = 'DataAccessMode';
            end


            isPortChanged = ~strcmp( SLPort.MappedTo.Port, ARPortName );
            isElementChanged = ~strcmp( SLPort.MappedTo.( dataElementPropertyName ), ARDataName );
            isDAMChanged = ~strcmp( SLPort.MappedTo.( dataAccessModePropertyName ), ARDataAccessModeStr );

            if ~isPortChanged && ~isElementChanged && ~isDAMChanged


                return ;
            end

            if strcmp( get_param( SLPort.Block, 'IsBusElementPort' ), 'on' ) && ~isEventPort

                if ~any( strcmp( ARDataAccessModeStr, this.getValidDataSenderDAMs( true ) ) )
                    DAStudio.error( 'RTW:autosar:invalidMappingDAM', ARDataAccessModeStr, SLPortName, autosar.api.Utils.cell2str( this.ValidBepSenderDAMs ) );
                else
                    if ~strcmp( strtrim( get_param( SLPort.Block, 'PortName' ) ), ARPortName ) ...
                            || ~strcmp( get_param( SLPort.Block, 'Element' ), ARDataName )

                        DAStudio.error( 'autosarstandard:api:busElementPortMappingChanged', getfullname( SLPort.Block ) );
                    end
                    SLPort.mapPortElement( ARPortName, ARDataName, ARDataAccessModeStr );
                    return ;
                end
            end

            if isEventPort
                portType = 'ServiceProvidedPort';
            elseif strcmp( ARDataAccessModeStr, 'ModeSend' )
                portType = 'ModeSenderPort';
            else
                portType = 'DataSenderPort';
            end


            componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
            ARPortPaths = dataObj.find( componentQualifiedName, portType,  ...
                'Name', ARPortName, 'PathType', 'FullyQualified' );


            if isempty( ARPortPaths )
                ARPortPaths = dataObj.find( componentQualifiedName, 'DataSenderReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
            end


            if isempty( ARPortPaths )
                ARPortPaths = dataObj.find( componentQualifiedName, 'NvDataSenderPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
                if ~isempty( ARPortPaths )

                    portType = 'NvDataSenderPort';
                end
            end


            if isempty( ARPortPaths )
                ARPortPaths = dataObj.find( componentQualifiedName, 'NvDataSenderReceiverPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
                if ~isempty( ARPortPaths )

                    portType = 'NvDataSenderPort';
                end
            end

            if isempty( ARPortPaths ) && strcmp( portType, 'ModeSenderPort' )



                ARPortPaths = dataObj.find( componentQualifiedName, 'DataSenderPort',  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );
            end

            if length( ARPortPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, portType, ARPortName );
            end


            ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
            if strcmp( ARDataAccessModeStr, 'ModeSend' )
                metaModelClassName = 'ModeDeclarationGroupElement';
            else
                metaModelClassName = 'FlowData';
            end
            ARDataElementPaths = dataObj.find( ifPath, metaModelClassName,  ...
                'Name', ARDataName, 'PathType', 'FullyQualified' );
            if isempty( ifPath ) || length( ARDataElementPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidMappingPort', SLPortName, 'DataElement', ARDataName );
            end


            switch portType
                case { 'DataSenderPort', 'DataSenderReceiverPort' }
                    validDataAccessModes = [ this.ValidSenderDAMs;'ModeSend' ];
                case { 'NvDataSenderPort', 'NvDataSenderReceiverPort' }
                    validDataAccessModes = this.ValidNvSenderDAMs;
                case 'ModeSenderPort'
                    validDataAccessModes = { 'ModeSend' };
                case 'ServiceProvidedPort'
                    validDataAccessModes = this.ValidServiceProvidedAllocateMemory;
                otherwise
                    assert( false, 'Did not recognize portType %s', portType );
            end



            if ~any( strcmp( ARDataAccessModeStr, validDataAccessModes ) )
                validDataAccessModesStr = autosar.api.Utils.cell2str( validDataAccessModes );
                DAStudio.error( 'RTW:autosar:invalidMappingDAM', ARDataAccessModeStr, SLPortName, validDataAccessModesStr );
            end

            if ~isempty( this.ChangeLogger )
                if isPortChanged
                    this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Port mapping',  ...
                        'Simulink outport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.Port,  ...
                        ARPortName );
                end
                if isElementChanged
                    this.ChangeLogger.logModification( 'Automatic',  ...
                        [ 'AUTOSAR ', dataElementPropertyName, ' mapping' ],  ...
                        'Simulink outport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.( dataElementPropertyName ),  ...
                        ARDataName );
                end

                if ~isEventPort





                    implicitSendAccessModes = { 'ImplicitSend', 'ImplicitSendByRef' };
                    currIsImplicitSendAm = ismember( SLPort.MappedTo.( dataAccessModePropertyName ),  ...
                        implicitSendAccessModes );
                    newIsImplicitSendAm = ismember( ARDataAccessModeStr,  ...
                        implicitSendAccessModes );
                    if ( currIsImplicitSendAm && newIsImplicitSendAm )
                        ARDataAccessModeStr = SLPort.MappedTo.( dataAccessModePropertyName );
                        isDAMChanged = false;
                    end

                end
                if isDAMChanged
                    this.ChangeLogger.logModification( 'Automatic', 'DataAccessMode',  ...
                        'Simulink outport',  ...
                        SLPort.Block,  ...
                        SLPort.MappedTo.( dataAccessModePropertyName ),  ...
                        ARDataAccessModeStr );
                end
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                if isEventPort
                    SLPort.mapPortProvidedEvent( ARPortName, ARDataName, ARDataAccessModeStr, '' );
                else

                    autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec( ARPortName,  ...
                        ARDataName, ARDataAccessModeStr, this.ModelName );
                    SLPort.mapPortElement( ARPortName, ARDataName, ARDataAccessModeStr );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function mapFunction( this, slEntryPointFunction, arRunnableName, varargin )
















































            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                slEntryPointFunction = autosar.api.getSimulinkMapping.escapeSimulinkName( slEntryPointFunction );

                if autosar.api.Utils.isMappedToAdaptiveApplication( this.ModelName )

                    DAStudio.error( 'autosarstandard:api:mappingAPINotSupportedAdaptive', 'mapFunction' )
                else


                    this.mapClassicFunction( slEntryPointFunction, arRunnableName, varargin{ : } );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function mapFunctionCaller( this, SLFcnName, ARPortName, AROperationName )







            autosar.api.Utils.autosarlicensed( true );

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping( this.ModelName )
                DAStudio.error( 'autosarstandard:api:mappingAPINotSupportedAdaptive', 'mapFunctionCaller' );
            end


            if isstring( ARPortName )
                ARPortName = convertStringsToChars( ARPortName );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end


            blockMappings = autosar.api.internal.MappingFinder.getFunctionCallerBlockMappings( this.ModelName, SLFcnName );
            if isempty( blockMappings )
                DAStudio.error( 'RTW:autosar:invalidCallerMapping', SLFcnName, 'function caller', SLFcnName );
            end

            componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );


            portType = 'ClientPort';
            portPropName = 'ClientPort';
            operationPropName = 'Operation';
            ARPortPaths = dataObj.find( componentQualifiedName, portType,  ...
                'Name', ARPortName, 'PathType', 'FullyQualified' );

            if length( ARPortPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidCallerMapping', SLFcnName, portType, ARPortName );
            end


            ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
            metaModelClassName = 'Operation';
            AROperationPaths = dataObj.find( ifPath, metaModelClassName,  ...
                'Name', AROperationName, 'PathType', 'FullyQualified' );
            if isempty( ifPath ) || length( AROperationPaths ) ~= 1
                DAStudio.error( 'RTW:autosar:invalidCallerMapping', SLFcnName, 'Operation', AROperationName );
            end

            componentCategory = dataObj.get( componentQualifiedName, 'Category' );
            if ~any( strcmp( componentCategory, { 'AtomicComponent', 'AdaptiveApplication' } ) )
                assert( false, 'Did not recognize componentCategory %s', componentCategory );
            end

            for index = 1:length( blockMappings )
                SLBlockMap = blockMappings( index );
                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                    isPortChanged = ~strcmp( SLBlockMap.MappedTo.( portPropName ), ARPortName );
                    isOperationChanged = ~strcmp( SLBlockMap.MappedTo.( operationPropName ), AROperationName );
                    if ~isPortChanged && ~isOperationChanged


                        continue ;
                    end

                    if ~isempty( this.ChangeLogger )
                        if isPortChanged
                            this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Port mapping',  ...
                                'Simulink Function Caller block',  ...
                                SLBlockMap.Block,  ...
                                SLBlockMap.MappedTo.( portPropName ),  ...
                                ARPortName );
                        end

                        if isOperationChanged
                            this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Operation mapping',  ...
                                'Simulink Function Caller block',  ...
                                SLBlockMap.Block,  ...
                                SLBlockMap.MappedTo.( operationPropName ),  ...
                                AROperationName )
                        end
                    end

                    autosar.api.Utils.mapCaller( this.ModelName, SLBlockMap,  ...
                        ARPortName, AROperationName );
                catch Me
                    autosar.mm.util.MessageReporter.throwException( Me );
                end
            end
        end

        function Value = getSignal( this, PortHandle, Property )

































            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            PortHandleStr = '';
            if ~ischar( PortHandle ) && ~isstring( PortHandle )
                PortHandleStr = num2str( PortHandle );
            end

            try
                objectType = get_param( PortHandle, 'Type' );
            catch ME
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end
            if ~strcmp( objectType, 'port' )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end

            if nargin == 3
                validateattributes( Property, { 'string', 'char' }, { 'nonempty' },  ...
                    'autosar.api.getSimulinkMapping.getSignal', 'PROPERTY', 3 );
            end
            Value = '';

            SLSignals = modelMapping.Signals.findobj( 'PortHandle', PortHandle );
            if length( SLSignals ) < 1
                DAStudio.error( 'coderdictionary:api:invalidMappingAutosarSignalPort',  ...
                    PortHandleStr );
            end
            SLSignal = SLSignals;

            mappedTo = SLSignal.MappedTo;
            if nargin > 2
                if ~strcmp( mappedTo.ArDataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                    Property = validatestring( Property,  ...
                        mappedTo.getPerInstancePropertyNames( true ),  ...
                        'autosar.api.getSimulinkMapping.getSignal', 'PROPERTY', 3 );
                    Value = mappedTo.getPerInstancePropertyValue( Property );
                end
            else
                Value = mappedTo.ArDataRole;
            end
        end

        function mapSignal( this, PortHandle, VariableRole, varargin )
































            autosar.api.Utils.autosarlicensed( true );

            argParser = inputParser;
            argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapSignal';
            argParser.KeepUnmatched = true;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.addRequired( 'VariableRole', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );

            validateattributes( VariableRole, { 'string', 'char' }, { 'nonempty' },  ...
                'autosar.api.getSimulinkMapping.mapSignal', 'PROPERTY', 3 );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            allowedRoles = autosar.api.getSimulinkMapping.getValidVariableRoles( modelMapping.IsSubComponent );
            VariableRole = validatestring( VariableRole, allowedRoles );
            argParser.parse( this, VariableRole, varargin{ : } );

            PortHandleStr = '';
            if ~ischar( PortHandle ) && ~isstring( PortHandle )
                PortHandleStr = num2str( PortHandle );
            end
            try
                objectType = get_param( PortHandle, 'Type' );
            catch ME
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end
            if ~strcmp( objectType, 'port' )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end

            SLSignals = modelMapping.Signals.findobj( 'PortHandle', PortHandle );
            if length( SLSignals ) < 1
                DAStudio.error( 'coderdictionary:api:invalidMappingAutosarSignalPort',  ...
                    PortHandleStr );
            end
            SLSignal = SLSignals;
            this.setInternalDataProperties( this.ModelName,  ...
                SLSignal, VariableRole, true, argParser );
        end

        function addSignal( this, PortHandle )



















            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            PortHandleStr = '';
            if ~ischar( PortHandle ) && ~isstring( PortHandle )
                PortHandleStr = num2str( PortHandle );
            end
            try
                objectType = get_param( PortHandle, 'Type' );
            catch ME
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end
            if ~strcmp( objectType, 'port' )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end

            SLSignals = modelMapping.Signals.findobj( 'PortHandle', PortHandle );
            if length( SLSignals ) == 1
                return ;
            end

            try
                modelMapping.addSignal( PortHandle )
            catch ME
                throwAsCaller( ME );
            end
        end

        function removeSignal( this, PortHandle )


















            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            PortHandleStr = '';
            if ~ischar( PortHandle ) && ~isstring( PortHandle )
                PortHandleStr = num2str( PortHandle );
            end
            try
                objectType = get_param( PortHandle, 'Type' );
            catch ME
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end
            if ~strcmp( objectType, 'port' )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'signal mapping', 'port handle', PortHandleStr );
            end

            modelMapping.removeSignal( PortHandle )
        end

        function Value = getState( this, Object, StateName, Property )







































            slRoot = slroot;
            if slRoot.isValidSlObject( Object ) && strcmp( get_param( Object, 'Type' ), 'block' )
                blockH = get_param( Object, 'Handle' );
                SLBlockPath = getfullname( Object );
                if nargin >= 3
                    validateattributes( StateName, { 'string', 'char' }, {  },  ...
                        'autosar.api.getSimulinkMapping.getState', 'STATENAME', 3 );
                else
                    StateName = '';
                end
                if nargin == 4
                    validateattributes( Property, { 'string', 'char' }, { 'nonempty' },  ...
                        'autosar.api.getSimulinkMapping.getState', 'PROPERTY', 4 );
                end
                Value = '';
                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                    modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                catch Me

                    autosar.mm.util.MessageReporter.throwException( Me );
                end
                SLStates = modelMapping.States.findobj( 'OwnerBlockHandle', blockH );
                if length( SLStates ) < 1
                    DAStudio.error( 'coderdictionary:api:invalidMappingStateBlock',  ...
                        StateName, SLBlockPath );
                end
                if numel( SLStates ) == 1
                    SLState = SLStates;
                    if ~isempty( StateName ) && ~strcmp( SLState.Name, StateName )
                        DAStudio.error( 'coderdictionary:api:invalidMappingStateName',  ...
                            StateName, SLBlockPath, StateName );
                    end
                elseif isempty( StateName )


                    SLState = SLStates( 1 );
                else
                    stateFound = false;
                    for ii = 1:numel( SLStates )
                        SLState = SLStates( ii );
                        if strcmp( SLState.Name, StateName )
                            stateFound = true;
                            break ;
                        end
                    end
                    if ~stateFound
                        DAStudio.error( 'coderdictionary:api:invalidMappingStateName',  ...
                            StateName, SLBlockPath, StateName );
                    end
                end
                mappedTo = SLState.MappedTo;
                if nargin > 3
                    if ~strcmp( mappedTo.ArDataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                        Property = validatestring( Property,  ...
                            mappedTo.getPerInstancePropertyNames( true ),  ...
                            'autosar.api.getSimulinkMapping.getState', 'PROPERTY', 4 );
                        Value = mappedTo.getPerInstancePropertyValue( Property );
                    end
                else
                    Value = mappedTo.ArDataRole;
                end
            else

                if ~ischar( Object ) && ~isstring( Object )
                    Object = num2str( Object );
                end
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'state mapping', 'Simulink block', Object );
            end
        end

        function mapState( this, Object, StateName, VariableRole, varargin )
































            autosar.api.Utils.autosarlicensed( true );

            slRoot = slroot;
            if slRoot.isValidSlObject( Object ) && strcmp( get_param( Object, 'Type' ), 'block' )
                blockH = get_param( Object, 'Handle' );
                SLBlockPath = getfullname( Object );
                argParser = inputParser;
                argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapState';
                argParser.KeepUnmatched = true;
                argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
                argParser.addRequired( 'StateName', @( x )( ( ischar( x ) || isStringScalar( x ) ) ) );
                argParser.addRequired( 'VariableRole', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );

                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                    modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                catch Me

                    autosar.mm.util.MessageReporter.throwException( Me );
                end

                allowedRoles = autosar.api.getSimulinkMapping.getValidVariableRoles( modelMapping.IsSubComponent );
                VariableRole = validatestring( VariableRole, allowedRoles );
                argParser.parse( this, StateName, VariableRole, varargin{ : } );

                SLStates = modelMapping.States.findobj( 'OwnerBlockHandle', blockH );
                if length( SLStates ) < 1
                    DAStudio.error( 'coderdictionary:api:invalidMappingStateBlock',  ...
                        StateName, SLBlockPath );
                end
                if numel( SLStates ) == 1
                    SLState = SLStates;
                    if ~isempty( StateName ) && ~strcmp( SLState.Name, StateName )
                        DAStudio.error( 'coderdictionary:api:invalidMappingStateName',  ...
                            StateName, SLBlockPath, StateName );
                    end
                elseif isempty( StateName )


                    SLState = SLStates( 1 );
                else

                    stateFound = false;
                    for ii = 1:numel( SLStates )
                        SLState = SLStates( ii );
                        if strcmp( SLState.Name, StateName )
                            stateFound = true;
                            break ;
                        end
                    end
                    if ~stateFound
                        DAStudio.error( 'coderdictionary:api:invalidMappingStateName',  ...
                            StateName, SLBlockPath, StateName );
                    end
                end
                this.setInternalDataProperties( this.ModelName,  ...
                    SLState, VariableRole, true, argParser );
            else

                if ~ischar( Object ) && ~isstring( Object )
                    Object = num2str( Object );
                end
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'state mapping', 'Simulink block', Object );
            end
        end

        function Value = getDataStore( this, Object, Property )

































            slRoot = slroot;
            if slRoot.isValidSlObject( Object ) && strcmp( get_param( Object, 'Type' ), 'block' )
                blockH = get_param( Object, 'Handle' );
                SLBlockPath = getfullname( Object );
                if nargin == 3
                    validateattributes( Property, { 'string', 'char' }, { 'nonempty' },  ...
                        'autosar.api.getSimulinkMapping.getDataStore', 'PROPERTY', 3 );
                end
                Value = '';
                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                    modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                catch Me

                    autosar.mm.util.MessageReporter.throwException( Me );
                end

                SLDataStores = modelMapping.DataStores.findobj( 'OwnerBlockHandle', blockH );
                if length( SLDataStores ) ~= 1
                    DAStudio.error( 'coderdictionary:api:invalidMappingDataStoreMemBlock',  ...
                        SLBlockPath );
                end

                mappedTo = SLDataStores.MappedTo;
                if nargin == 3
                    if ~strcmp( mappedTo.ArDataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                        Property = validatestring( Property,  ...
                            mappedTo.getPerInstancePropertyNames( true ),  ...
                            'autosar.api.getSimulinkMapping.getDataStore', 'PROPERTY', 3 );
                        Value = mappedTo.getPerInstancePropertyValue( Property );
                    end
                else
                    Value = mappedTo.ArDataRole;
                end
            else

                if ~ischar( Object ) && ~isstring( Object )
                    Object = num2str( Object );
                end
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'data store mapping', 'Simulink block', Object );
            end
        end

        function mapDataStore( this, Object, VariableRole, varargin )





































            autosar.api.Utils.autosarlicensed( true );

            slRoot = slroot;
            if slRoot.isValidSlObject( Object ) && strcmp( get_param( Object, 'Type' ), 'block' )
                blockH = get_param( Object, 'Handle' );
                SLBlockPath = getfullname( Object );

                argParser = inputParser;
                argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapDataStore';
                argParser.KeepUnmatched = true;
                argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
                argParser.addRequired( 'VariableRole', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );

                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                    modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                catch Me

                    autosar.mm.util.MessageReporter.throwException( Me );
                end

                if Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName )
                    if strcmp( VariableRole, 'Auto' )


                        if numel( varargin ) > 0
                            DAStudio.error( 'autosarstandard:validation:PerInstPropsForAutoRole', SLBlockPath );
                        end
                    end
                    allowedRoles = autosar.api.getSimulinkMapping.getAdaptiveValidVariableRoles(  );
                else
                    allowedRoles = autosar.api.getSimulinkMapping.getValidVariableRoles( modelMapping.IsSubComponent );
                end
                VariableRole = validatestring( VariableRole, allowedRoles );
                argParser.parse( this, VariableRole, varargin{ : } );

                SLDataStores = modelMapping.DataStores.findobj( 'OwnerBlockHandle', blockH );
                if length( SLDataStores ) ~= 1
                    DAStudio.error( 'coderdictionary:api:invalidMappingDataStoreMemBlock',  ...
                        SLBlockPath );
                end

                if ( isfield( argParser.Unmatched, 'NeedsNVRAMAccess' ) )

                    NeedsNVRAMAccess = argParser.Unmatched.NeedsNVRAMAccess;
                    if ~islogical( NeedsNVRAMAccess )
                        validatestring( NeedsNVRAMAccess, { 'true', 'false' } );
                        NeedsNVRAMAccess = autosar.mm.util.NvBlockNeedsCodePropsHelper.convertNvBlockNeedFromStringToLogical( NeedsNVRAMAccess );
                    end
                else
                    NeedsNVRAMAccess = false;
                end


                nvBlockNeedsArgumentsExist = false;
                nvBlockNeedAttributes = autosar.mm.util.NvBlockNeedsCodePropsHelper.getSupportedNvBlockNeedsAttributes;
                for i = 1:length( nvBlockNeedAttributes )
                    if isfield( argParser.Unmatched, nvBlockNeedAttributes{ i } )
                        nvBlockNeedsArgumentsExist = true;
                        nvBlockNeedsAttribute = argParser.Unmatched.( nvBlockNeedAttributes{ i } );
                        if ~islogical( nvBlockNeedsAttribute )
                            validatestring( nvBlockNeedsAttribute, { 'true', 'false' } );
                        end
                    end
                end


                if nvBlockNeedsArgumentsExist && ~NeedsNVRAMAccess
                    DAStudio.error( 'autosarstandard:api:invalidNVRAMAccessArgument', SLBlockPath );
                end

                if Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName ) && ( isfield( argParser.Unmatched, 'Port' ) || isfield( argParser.Unmatched, 'DataElement' ) )
                    dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
                    modelMapping = Simulink.CodeMapping.get( this.ModelName );
                    dataStoreName = get_param( modelMapping.DataStores( 1 ).OwnerBlockPath, 'DataStoreName' );
                    componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                    portType = 'PersistencyProvidedRequiredPort';
                    elementType = 'PersistencyDataElement';
                    ARPortName = argParser.Unmatched.Port;
                    ARElementName = argParser.Unmatched.DataElement;
                    if ~isempty( ARPortName )
                        ARPortPaths = dataObj.find( componentQualifiedName, portType,  ...
                            'Name', ARPortName, 'PathType', 'FullyQualified' );
                        if length( ARPortPaths ) ~= 1
                            DAStudio.error( 'autosarstandard:api:invalidDataStoreMemoryBlockMapping', dataStoreName, portType, ARPortName );
                        end

                        if ~isempty( ARElementName )

                            ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
                            metaModelClassName = 'PersistencyData';
                            ARElementPaths = dataObj.find( ifPath, metaModelClassName,  ...
                                'Name', ARElementName, 'PathType', 'FullyQualified' );
                            if isempty( ifPath ) || length( ARElementPaths ) ~= 1
                                DAStudio.error( 'autosarstandard:api:invalidDataStoreMemoryBlockMapping', dataStoreName, elementType, ARElementName );
                            end
                        end
                    elseif ~isempty( ARElementName )
                        DAStudio.error( 'autosarstandard:api:invalidDataStoreMemoryBlockMapping', dataStoreName, elementType, ARElementName );
                    end
                end

                this.setInternalDataProperties( this.ModelName,  ...
                    SLDataStores, VariableRole, true, argParser );
            else

                if ~ischar( Object ) && ~isstring( Object )
                    Object = num2str( Object );
                end
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    'data store mapping', 'Simulink block', Object );
            end
        end

        function Value = getParameter( this, SLParam, Property )





























            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            validateattributes( SLParam, { 'string', 'char' }, { 'nonempty' },  ...
                'autosar.api.getSimulinkMapping.getParameter', 'SLPARAM', 2 );
            if nargin == 3
                validateattributes( Property, { 'string', 'char' }, { 'nonempty' },  ...
                    'autosar.api.getSimulinkMapping.getParameter', 'PROPERTY', 3 );
            end

            Value = '';
            mappedParam = modelMapping.ModelScopedParameters.findobj( 'Parameter', SLParam );
            if length( mappedParam ) < 1
                DAStudio.error( 'coderdictionary:api:invalidMappingParameterName',  ...
                    SLParam );
            elseif modelMapping.IsSubComponent && ~mappedParam.InstanceSpecific
                DAStudio.error( 'autosarstandard:api:invalidMappingParameterNameSubComponent',  ...
                    SLParam );
            end
            mappedTo = mappedParam.MappedTo;
            if nargin > 2
                if ~strcmp( mappedTo.ArDataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                    Property = validatestring( Property,  ...
                        mappedTo.getPerInstancePropertyNames( false ),  ...
                        'autosar.api.getSimulinkMapping.getParameter', 'PROPERTY', 3 );
                    Value = mappedTo.getPerInstancePropertyValue( Property );
                end
            else
                Value = mappedTo.ArDataRole;
            end
        end

        function mapParameter( this, SLParam, ParameterRole, varargin )


























            autosar.api.Utils.autosarlicensed( true );
            argParser = inputParser;
            argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapParameter';
            argParser.KeepUnmatched = true;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.addRequired( 'ParameterRole', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );

            validateattributes( SLParam, { 'string', 'char' }, { 'nonempty' },  ...
                'autosar.api.getSimulinkMapping.mapParameter', 'SLPARAM', 2 );
            validateattributes( ParameterRole, { 'string', 'char' }, { 'nonempty' },  ...
                'autosar.api.getSimulinkMapping.mapParameter', 'PROPERTY', 3 );
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            mappedParam = modelMapping.ModelScopedParameters.findobj( 'Parameter', SLParam );
            if length( mappedParam ) < 1
                DAStudio.error( 'coderdictionary:api:invalidMappingParameterName',  ...
                    SLParam );
            elseif modelMapping.IsSubComponent && ~mappedParam.InstanceSpecific
                DAStudio.error( 'autosarstandard:api:invalidMappingParameterNameSubComponent',  ...
                    SLParam );
            end

            if modelMapping.IsSubComponent
                allowedRoles = autosar.api.getSimulinkMapping.getValidParameterRoles( true );

                allowedRoles = setdiff( allowedRoles, 'PortParameter', 'stable' );
            else
                allowedRoles = autosar.api.getSimulinkMapping.getValidParameterRoles( mappedParam.InstanceSpecific );
            end
            ParameterRole = validatestring( ParameterRole, allowedRoles );
            argParser.parse( this, ParameterRole, varargin{ : } );

            if strcmp( ParameterRole, 'PortParameter' )




                argumentNames = fieldnames( argParser.Unmatched );
                if ~all( ismember( { 'Port', 'DataElement' }, argumentNames ) )
                    DAStudio.error( 'autosarstandard:api:portParamMappingRequiredArgs', SLParam );
                end


                argParser.addParameter( 'Port', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );
                argParser.addParameter( 'DataElement', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );
                argParser.parse( this, ParameterRole, varargin{ : } );


                dataObj = autosar.api.getAUTOSARProperties( this.ModelName );
                componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                ARPortPaths = dataObj.find( componentQualifiedName, 'ParameterReceiverPort',  ...
                    'Name', argParser.Results.Port, 'PathType', 'FullyQualified' );

                if ~isempty( argParser.Results.Port )
                    if length( ARPortPaths ) ~= 1
                        DAStudio.error( 'RTW:autosar:invalidMappingPortParameter',  ...
                            SLParam, 'ParameterReceiverPort', argParser.Results.Port );
                    end

                    ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
                    ARDataElementPaths = dataObj.find( ifPath, 'ParameterData',  ...
                        'Name', argParser.Results.DataElement, 'PathType', 'FullyQualified' );
                    if ~isempty( argParser.Results.DataElement )
                        if isempty( ifPath ) || length( ARDataElementPaths ) ~= 1
                            DAStudio.error( 'RTW:autosar:invalidMappingPortParameter', SLParam, 'DataElement', argParser.Results.DataElement );
                        end



                        if ~strcmp( ParameterRole, mappedParam.MappedTo.ArDataRole )
                            mappedParam.map( ParameterRole );
                        end
                    end
                elseif ~isempty( argParser.Results.DataElement )

                    DAStudio.error( 'RTW:autosar:invalidMappingPortParameter', SLParam, 'DataElement', argParser.Results.DataElement );
                end
                Simulink.CodeMapping.setPerInstancePropertyValue( this.ModelName,  ...
                    mappedParam, 'MappedTo', 'Port', argParser.Results.Port );
                Simulink.CodeMapping.setPerInstancePropertyValue( this.ModelName,  ...
                    mappedParam, 'MappedTo', 'DataElement', argParser.Results.DataElement );
            end

            this.setInternalDataProperties( this.ModelName,  ...
                mappedParam, ParameterRole, false, argParser );
        end

        function MemoryType = getInternalDataPackaging( this )








            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            MemoryType = modelMapping.DataDefaultsMapping.InternalData.Memory;
        end

        function setInternalDataPackaging( this, value )












            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            allowedRoles = autosar.api.getSimulinkMapping.getValidInternalDataPackagingOptions( this.ModelName );

            argParser = inputParser;
            argParser.addRequired( 'InternalDataPackaging', @( x )any( validatestring( x,  ...
                allowedRoles ) ) );
            argParser.parse( value );

            if modelMapping.IsSubComponent
                if ~strcmp( value, 'Default' )
                    DAStudio.error( 'autosarstandard:validation:invalidInternalDataDefaultForMultiInstOrSubComp',  ...
                        value );
                end
            end

            if ~strcmp( modelMapping.DataDefaultsMapping.InternalData.Memory, value )
                modelMapping.DataDefaultsMapping.InternalData.Memory = value;
                set_param( this.ModelName, 'Dirty', 'on' );
            end
        end

        function [ AdaptiveClassName ] = getClassName( this )











            if ( ~Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName ) )
                DAStudio.error( 'autosarstandard:api:getSimulinkMappingAPIOnlySupportedForAdaptive' );
            end

            modelMapping = this.getAutosarModelMapping(  );
            AdaptiveClassName = modelMapping.CppClassReference.ClassName;
        end

        function setClassName( this, value )
















            if ( ~Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName ) )
                DAStudio.error( 'autosarstandard:api:getSimulinkMappingAPIOnlySupportedForAdaptive' );
            end


            autosar.api.getSimulinkMapping.checkCppIdentifier( value,  ...
                'C++ Class name' );

            modelMapping = this.getAutosarModelMapping(  );
            modelMapping.CppClassReference.ClassName = value;
        end

        function [ AdaptiveClassNamespace ] = getClassNamespace( this )








            if ( ~Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName ) )
                DAStudio.error( 'autosarstandard:api:getSimulinkMappingAPIOnlySupportedForAdaptive' );
            end
            modelMapping = this.getAutosarModelMapping(  );
            AdaptiveClassNamespace = modelMapping.CppClassReference.ClassNamespace;
        end

        function setClassNamespace( this, value )








            if ( ~Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName ) )
                DAStudio.error( 'autosarstandard:api:getSimulinkMappingAPIOnlySupportedForAdaptive' );
            end


            if ( slfeature( 'CppNestedNamespaces' ) > 0 )
                namespaces = split( string( value ), '::' );
                if strcmp( namespaces( 1 ), 'std' )
                    DAStudio.error( 'coderdictionary:api:InvalidCPPIdentifier',  ...
                        'Class Namespace', value );
                end
                arrayfun( @( argValue )autosar.api.getSimulinkMapping.checkCppIdentifier( argValue,  ...
                    'C++ namespace' ), namespaces );
            else
                autosar.api.getSimulinkMapping.checkCppIdentifier( value,  ...
                    'C++ namespace' );
            end

            modelMapping = this.getAutosarModelMapping(  );
            modelMapping.CppClassReference.ClassNamespace = value;
        end

        function Value = getSynthesizedDataStore( this, signalName, Property )




























            if ~strcmp( this.InternalMappingType, 'AutosarTarget' )


                DAStudio.error( 'autosarstandard:api:onlySupportedForClassicAUTOSAR', 'Synthesized data store' );
            end

            validateattributes( signalName, { 'string', 'char' }, { 'nonempty' },  ...
                'autosar.api.getSimulinkMapping.getSynthesizedDataStore', 'signalName', 2 );


            modelMapping = Simulink.CodeMapping.get( this.ModelName, this.InternalMappingType );

            Value = '';
            SLDataStore = modelMapping.SynthesizedDataStores.findobj( 'Name', signalName );
            if length( SLDataStore ) < 1
                DAStudio.error( 'coderdictionary:api:invalidMappingSynthesizedDataStoreName',  ...
                    signalName );
            end
            mappedTo = SLDataStore.MappedTo;

            if nargin == 3
                if ~strcmp( mappedTo.ArDataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                    Property = validatestring( Property,  ...
                        mappedTo.getPerInstancePropertyNames( true ),  ...
                        'autosar.api.getSimulinkMapping.getSynthesizedDataStore', 'PROPERTY', 3 );
                    Value = mappedTo.getPerInstancePropertyValue( Property );
                end
            else
                Value = mappedTo.ArDataRole;
            end

        end

        function mapSynthesizedDataStore( this, signalName, VariableRole, varargin )





















            autosar.api.Utils.autosarlicensed( true );

            argParser = inputParser;
            argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapSynthesizedDataStore';
            argParser.KeepUnmatched = true;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.addRequired( 'VariableRole', @( x )( ( ischar( x ) || isStringScalar( x ) ) && strlength( x ) > 0 ) );

            if ~strcmp( this.InternalMappingType, 'AutosarTarget' )


                DAStudio.error( 'autosarstandard:api:onlySupportedForClassicAUTOSAR', 'Synthesized data store' );
            end


            modelMapping = Simulink.CodeMapping.get( this.ModelName, this.InternalMappingType );



            allowedRoles = autosar.api.getSimulinkMapping.getValidVariableRoles( modelMapping.IsSubComponent );

            VariableRole = validatestring( VariableRole, allowedRoles );
            argParser.parse( this, VariableRole, varargin{ : } );

            SLDataStore = modelMapping.SynthesizedDataStores.findobj( 'Name', signalName );
            if length( SLDataStore ) ~= 1
                DAStudio.error( 'coderdictionary:api:invalidMappingSynthesizedDataStoreName',  ...
                    signalName );
            end

            originalMappedTo = SLDataStore.MappedTo;

            this.setInternalDataProperties( this.ModelName,  ...
                SLDataStore, VariableRole, true, argParser );

            if originalMappedTo ~= SLDataStore.MappedTo
                set_param( this.ModelName, 'Dirty', 'on' );
            end
        end

        function addSynthesizedDataStore( this, signalName )



















            mappingType = 'synthesized data store mapping';
            slRoot = slroot;
            if ~slRoot.isValidSlObject( this.ModelName )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    mappingType, 'model', this.ModelName );
            end

            if ~strcmp( this.InternalMappingType, 'AutosarTarget' )


                DAStudio.error( 'autosarstandard:api:onlySupportedForClassicAUTOSAR', 'Synthesized data store' );
            end


            modelMapping = Simulink.CodeMapping.get( this.ModelName, this.InternalMappingType );


            validateattributes( signalName, { 'string', 'char' }, { 'nonempty' },  ...
                'addSynthesizedDataStore', 'signalName', 2 );


            SLDataStore = string( signalName );

            for ds = SLDataStore

                modelMapping.addSynthesizedDataStore( ds );
            end

            set_param( this.ModelName, 'Dirty', 'on' );
        end

        function removeSynthesizedDataStore( this, signalName )



















            mappingType = 'synthesized data store mapping';

            slRoot = slroot;
            if ~slRoot.isValidSlObject( this.ModelName )
                DAStudio.error( 'coderdictionary:api:invalidMappingSimulinkObject',  ...
                    mappingType, 'model', this.ModelName );
            end

            if ~strcmp( this.InternalMappingType, 'AutosarTarget' )

                DAStudio.error( 'autosarstandard:api:onlySupportedForClassicAUTOSAR', 'Synthesized data store' );
            end


            modelMapping = Simulink.CodeMapping.get( this.ModelName, this.InternalMappingType );

            validateattributes( signalName, { 'string', 'char' }, { 'nonempty' },  ...
                'removeSynthesizedDataStore', 'SIGNALNAME', 2 );


            SLDataStore = string( signalName );

            for ds = SLDataStore

                mappedDSM = modelMapping.SynthesizedDataStores.findobj( 'Name', ds );
                if isempty( mappedDSM )
                    DAStudio.error( 'coderdictionary:api:invalidMappingSynthesizedDataStoreName',  ...
                        ds );
                end

                modelMapping.removeSynthesizedDataStore( ds );
            end

            set_param( this.ModelName, 'Dirty', 'on' );
        end


        function dataDefaultValue = getDataDefaults( this, modelingElementType, mappedTo )



















            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            switch modelingElementType
                case 'InportsOutports'
                    argParser = inputParser;
                    argParser.KeepUnmatched = true;
                    argParser.addRequired( 'modelingElementType', @( x )strcmp( 'InportsOutports', x ) );
                    argParser.addRequired( 'mappedTo', @( x )strcmp( 'EndToEndProtectionMethod', x ) );

                    argParser.parse( modelingElementType, mappedTo );
                    autosar.api.getSimulinkMapping.errorIfSettingE2EForSubComp( modelMapping );
                    dataDefaultValue = modelMapping.DataDefaultsMapping.EndToEndProtectionMethod.MethodName;

                otherwise
                    DAStudio.error( 'autosarstandard:api:invalidDataDefaultsData', modelingElementType );
            end

        end

        function setDataDefaults( this, modelingElementType, mappedTo, varargin )






















            argParser = inputParser;
            argParser.KeepUnmatched = true;
            argParser.addRequired( 'ModelingElementType', @( x )any( validatestring( x,  ...
                autosar.utils.mappingCategories.getDataCategoriesForDataDefaults(  ) ) ) );

            if strcmp( modelingElementType, 'InternalData' )
                argParser.addRequired( 'MappedTo', @( x )any( validatestring( x,  ...
                    autosar.utils.mappingCategories.getMappedToCategoriesForInternalData(  ) ) ) );
            elseif strcmp( modelingElementType, 'LocalParameters' )
                argParser.addRequired( 'MappedTo', @( x )any( validatestring( x,  ...
                    autosar.utils.mappingCategories.getMappedToCategoriesForParameters(  ) ) ) );
            elseif strcmp( modelingElementType, 'InportsOutports' )
                argParser.addRequired( 'mappedTo', @( x )strcmp( 'EndToEndProtectionMethod', x ) );
                argParser.addRequired( 'methodName', @( x )ischar( x ) || isStringScalar( x ) );
            else
                DAStudio.error( 'autosarstandard:api:invalidDataDefaultsData', modelingElementType );
            end

            if strcmp( modelingElementType, 'InportsOutports' )
                argParser.parse( modelingElementType, mappedTo, varargin{ 1 } );
                allowedValues = autosar.utils.mappingCategories.getMappedToCategoriesForEndToEndProtectionMethods(  );
                newMethodName = argParser.Results.methodName;


                if ~any( strcmp( allowedValues, newMethodName ) )
                    DAStudio.error( 'autosarstandard:api:invalidEndToEndProtectionMethod', newMethodName );
                end
            else
                argParser.parse( modelingElementType, mappedTo );
            end

            try
                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                Me.throwAsCaller(  );
            end

            if strcmp( modelingElementType, 'InportsOutports' )
                if strcmp( newMethodName, 'TransformerError' ) && ~( slfeature( 'AutosarTransformer' ) > 0 )
                    DAStudio.error( 'autosarstandard:api:transformerErrorFeatureOff' );
                end

                autosar.api.getSimulinkMapping.errorIfSettingE2EForSubComp( modelMapping );
                if ~isempty( this.ChangeLogger ) &&  ...
                        ~strcmp( newMethodName, modelMapping.DataDefaultsMapping.EndToEndProtectionMethod.MethodName )
                    this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Mapping',  ...
                        'Data Default',  ...
                        mappedTo,  ...
                        modelMapping.DataDefaultsMapping.EndToEndProtectionMethod.MethodName,  ...
                        newMethodName );
                end
                modelMapping.DataDefaultsMapping.EndToEndProtectionMethod.MethodName = newMethodName;
            else
                modelMapping.DefaultsMapping.setMappedTo( modelingElementType, mappedTo );
            end
        end
    end

    methods ( Hidden )
        function mapComponent( this, componentQualifiedName )


            m3iModel = autosar.api.Utils.m3iModel( this.ModelName );
            modelMapping = autosar.api.Utils.modelMapping( this.ModelName );


            m3iComp = autosar.mm.Model.findChildByName( m3iModel, componentQualifiedName );
            if isa( m3iComp, 'Simulink.metamodel.arplatform.composition.CompositionComponent' )
                compObj = Simulink.AutosarTarget.Composition( m3iComp.qualifiedName, m3iComp.Name );
                modelMapping.mapComposition( compObj );
            elseif isa( m3iComp, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )
                compObj = Simulink.AutosarTarget.Application( m3iComp.qualifiedName, m3iComp.Name );
                modelMapping.mapApplication( compObj );
            else
                componentId = m3iComp.qualifiedName;
                compObj = Simulink.AutosarTarget.Component( componentId, m3iComp.Name );
                modelMapping.mapComponent( compObj );
            end
        end

        function [ ARParameterAccessMode, ARPortName, ARParameterData ] = getLookupTable( this, SLParam )







            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            SLLut = modelMapping.LookupTables.findobj( 'LookupTableName', SLParam );

            if length( SLLut ) ~= 1
                DAStudio.error( 'autosarstandard:api:invalidMapping', 'Lookup Table',  ...
                    SLParam, 'Simulink Lookup Table', SLParam );
            end

            ARParameterAccessMode = SLLut.MappedTo.ParameterAccessMode;
            ARPortName = SLLut.MappedTo.Port;
            ARParameterData = SLLut.MappedTo.Parameter;
        end

        function mapLookupTable( this, SLParam, ARParameterAccessMode, ARPortName, ARParameterData )


























            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
                dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            SLLUTMap = modelMapping.LookupTables.findobj( 'LookupTableName', SLParam );


            if length( SLLUTMap ) ~= 1
                DAStudio.error( 'autosarstandard:api:invalidMapping', 'Lookup Table',  ...
                    SLParam, 'Simulink Lookup Table', SLParam );
            end

            if strcmp( ARParameterAccessMode, 'PortParameter' )

                portType = 'ParameterReceiverPort';
                componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                ARPortPaths = dataObj.find( componentQualifiedName, portType,  ...
                    'Name', ARPortName, 'PathType', 'FullyQualified' );

                if length( ARPortPaths ) ~= 1
                    DAStudio.error( 'autosarstandard:api:invalidMapping', 'Lookup Table',  ...
                        SLParam, portType, ARPortName );
                end


                ifPath = dataObj.get( ARPortPaths{ 1 }, 'Interface', 'PathType', 'FullyQualified' );
                metaModelClassName = 'ParameterData';
                ARParameterDataPaths = dataObj.find( ifPath, metaModelClassName,  ...
                    'Name', ARParameterData, 'PathType', 'FullyQualified' );
                if isempty( ifPath ) || length( ARParameterDataPaths ) ~= 1
                    DAStudio.error( 'autosarstandard:api:invalidMapping', 'Lookup Table',  ...
                        SLParam, 'Parameter Data', ARParameterData );

                end
            end

            if ~any( strcmp( ARParameterAccessMode, this.ValidParameterAccessModes ) )
                validParameterDataRolesStr = autosar.api.Utils.cell2str( this.ValidParameterAccessModes );
                DAStudio.error( 'autosarstandard:api:invalidParameterMappingRole',  ...
                    ARParameterAccessMode, 'Simulink Lookup Table', SLLUTMap.LookupTableName,  ...
                    validParameterDataRolesStr );
            end
            SLLUTMap.mapLookupTable( SLLUTMap.LookupTableName, ARParameterAccessMode,  ...
                ARPortName, ARParameterData, '' );
        end

        function mapFunctionElementCall( this, fcnElementCall, timeout )





            arguments
                this( 1, 1 )autosar.api.getSimulinkMapping;
                fcnElementCall( 1, : )char;
                timeout( 1, : )char;
            end


            autosar.api.Utils.autosarlicensed( true );

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping( this.ModelName )
                isClient = true;
                portMapping = autosar.simulink.functionPorts.Mapping.getPortMapping(  ...
                    this.ModelName, fcnElementCall, isClient );
            else
                DAStudio.error( 'autosarstandard:api:mappingAPINotSupportedClassic', 'mapFunctionElementCall' );
            end

            if isstring( timeout )
                timeout = convertStringsToChars( timeout );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                autosar.validation.AutosarUtils.verifyNonNegativeNumber( timeout, 'Timeout' );
                portMapping.mapPortMethod( portMapping.MappedTo.Port,  ...
                    portMapping.MappedTo.Method, timeout, 'false', '' );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function [ arPortName, arMethodName, timeout ] = getFunctionElementCall( this, fcnElementCall )





            arguments
                this( 1, 1 )autosar.api.getSimulinkMapping;
                fcnElementCall( 1, : )char;
            end


            autosar.api.Utils.autosarlicensed( true );

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping( this.ModelName )
                isClient = true;
                portMapping = autosar.simulink.functionPorts.Mapping.getPortMapping(  ...
                    this.ModelName, fcnElementCall, isClient );
            else
                DAStudio.error( 'autosarstandard:api:mappingAPINotSupportedClassic', 'mapFunctionElementCall' );
            end

            arPortName = portMapping.MappedTo.Port;
            arMethodName = portMapping.MappedTo.Method;
            timeout = portMapping.MappedTo.Timeout;
        end
    end

    methods ( Hidden )

        function modelName = getModelName( this )


            modelName = this.ModelName;
        end

        function mapPort( this, SLPortName, ARPortName, ARDataName, ARDataAccessModeStr )









            autosar.api.Utils.autosarlicensed( true );

            modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            SLPortName2 = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLInport = modelMapping.Inports.findobj( 'Block', [ this.ModelName, '/', SLPortName2 ] );

            if length( SLInport ) == 1
                this.mapInport( SLPortName, ARPortName,  ...
                    ARDataName, ARDataAccessModeStr );
            else
                this.mapOutport( SLPortName, ARPortName,  ...
                    ARDataName, ARDataAccessModeStr );
            end
        end

        function mapModelBlock( this, SLModelBlockName, ARPrototypeName, uuid )





            autosar.api.Utils.autosarlicensed( true );

            modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            SLModelBlockName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLModelBlockName );
            SLModelBlock = modelMapping.ModelBlocks.findobj( 'Block', [ this.ModelName, '/', SLModelBlockName ] );

            if ~isempty( this.ChangeLogger )
                if ~isempty( SLModelBlock.MappedTo ) &&  ...
                        ~strcmp( SLModelBlock.MappedTo.PrototypeName, ARPrototypeName )
                    this.ChangeLogger.logModification(  ...
                        'Automatic', 'ARPrototypeName',  ...
                        'Simulink model block',  ...
                        SLModelBlock.Block,  ...
                        SLModelBlock.MappedTo.PrototypeName,  ...
                        ARPrototypeName );
                end
            end

            SLModelBlock.mapComponentPrototype( ARPrototypeName, uuid );
        end


        function isMapped = isInportMapped( this, SLPortName )
            [ ARPortName, ARElementName, ARDataAccessMode ] = this.getInport( SLPortName );
            if Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName )
                isMapped = ~isempty( ARPortName ) && ~isempty( ARElementName );
            else
                isMapped = ~isempty( ARPortName ) && ~isempty( ARElementName ) && ~isempty( ARDataAccessMode );
            end
        end


        function isMapped = isOutportMapped( this, SLPortName )
            [ ARPortName, ARElementName, ARDataAccessMode ] = this.getOutport( SLPortName );
            if Simulink.CodeMapping.isAutosarAdaptiveSTF( this.ModelName )
                isMapped = ~isempty( ARPortName ) && ~isempty( ARElementName );
            else
                isMapped = ~isempty( ARPortName ) && ~isempty( ARElementName ) && ~isempty( ARDataAccessMode );
            end
        end


        function isMapped = isFunctionMapped( this, SLFcnName )
            ARRunnableName = this.getFunction( SLFcnName );
            isMapped = ~isempty( ARRunnableName );
        end



        function isMapped = isServerFunctionMapped( this, SLFcnName )
            [ ARPortName, ARMethodName ] = this.getFunction( SLFcnName );
            isMapped = ~isempty( ARPortName ) && ~isempty( ARMethodName );
        end


        function isMapped = isFunctionCallerMapped( this, SLFcnName )
            [ ARPortName, AROperationName ] = this.getFunctionCaller( SLFcnName );
            isMapped = ~isempty( ARPortName ) && ~isempty( AROperationName );
        end


        function isMapped = isAdaptiveDataStoreMapped( this, dataStoreBlockPath )
            ARPortName = this.getDataStore( dataStoreBlockPath, 'Port' );
            ARElementName = this.getDataStore( dataStoreBlockPath, 'DataElement' );
            isMapped = ~isempty( ARPortName ) && ~isempty( ARElementName );
        end



        function isMapped = isDataTransferMapped( this, SLDataTransferName )
            isMapped = false;
            try
                ARIRVName = this.getDataTransfer( SLDataTransferName );
                isMapped = ~isempty( ARIRVName );
            catch ME
                if strcmp( ME.identifier, 'RTW:autosar:invalidMappingDataTransfer' )


                else
                    rethrow( ME )
                end
            end
        end


        function mapSSToExclusiveArea( this, BlockH, ARShortName )





            autosar.api.Utils.autosarlicensed( true );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end


            if ~isempty( ARShortName )
                maxShortNameLength = get_param( this.ModelName, 'AutosarMaxShortNameLength' );
                idcheckmessage = autosar.ui.utils.isValidARIdentifier( ARShortName, 'shortName',  ...
                    maxShortNameLength );
                if ~isempty( idcheckmessage )
                    error( idcheckmessage );
                end
            end

            modelMapping.mapSubSystem( BlockH, ARShortName, false );
        end

        function mapping = getExclusiveArea( this, BlockH )




            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            sid = get_param( BlockH, 'SID' );
            SLExclusiveArea = modelMapping.SubSystemMappings.findobj( 'SID', sid );
            if ~isempty( SLExclusiveArea )
                mapping = SLExclusiveArea.MappedTo;
            else
                DAStudio.error( 'autosarstandard:api:noExclusiveAreaMapping', getfullname( BlockH ) );
            end

        end


        function mappings = getExclusiveAreas( this )



            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            Subsystems = [  ];
            ExclusiveAreas = [  ];
            for i = 1:length( modelMapping.SubSystemMappings )


                block = find_system( this.ModelName,  ...
                    'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                    'SID', modelMapping.SubSystemMappings( i ).SID );
                Subsystems = [ Subsystems;block ];%#ok<AGROW>
                ExclusiveAreas = [ ExclusiveAreas;modelMapping.SubSystemMappings( i ).MappedTo ];%#ok<AGROW>
            end
            mappings = table( Subsystems, ExclusiveAreas );
        end


        function Value = isPartialOrConditionalWrite( this, SLPortName )

            autosar.api.Utils.autosarlicensed( true );
            assert( slfeature( 'ArPartialWriteForRTE' ) > 0,  ...
                'ArPartialWriteForRTE feature is not enabled' );
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLPort = modelMapping.Outports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );

            Value = SLPort.MappedTo.PartialOrConditionalWrite;
        end

        function setPartialOrConditionalWrite( this, SLPortName, Value )

            autosar.api.Utils.autosarlicensed( true );
            assert( slfeature( 'ArPartialWriteForRTE' ) > 0,  ...
                'ArPartialWriteForRTE feature is not enabled' );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            SLPortName = autosar.api.getSimulinkMapping.escapeSimulinkName( SLPortName );
            SLPort = modelMapping.Outports.findobj( 'Block', [ this.ModelName, '/', SLPortName ] );

            argParser = inputParser;
            argParser.addRequired( 'PartialOrConditionalWrite', @( x )islogical( x ) );
            argParser.parse( Value );

            if ~strcmp( SLPort.MappedTo.PartialOrConditionalWrite, Value )
                SLPort.MappedTo.PartialOrConditionalWrite = Value;
                set_param( this.ModelName, 'Dirty', 'on' );
            end
        end
    end

    methods ( Access = private )

        function [ ARPortName, ARMethodName ] = getAdaptiveFunction( this, slEntryPointFunction )




            if ~autosar.api.Utils.isMappedToAdaptiveApplication( this.ModelName )
                DAStudio.error( 'autosarstandard:api:getSimulinkMappingAPIOnlySupportedForAdaptive' );
            end

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping( this.ModelName )
                isClient = false;
                blockMapping = autosar.simulink.functionPorts.Mapping.getPortMapping( this.ModelName, slEntryPointFunction, isClient );
            else
                blockMapping = autosar.api.internal.MappingFinder.getServerFunctionBlockMappings( this.ModelName, slEntryPointFunction );
            end

            if isempty( blockMapping )
                DAStudio.error( 'autosarstandard:api:invalidMappingServerFunction', slEntryPointFunction, 'Simulink function', slEntryPointFunction );
            end

            ARPortName = blockMapping.MappedTo.Port;
            ARMethodName = blockMapping.MappedTo.Method;
        end

        function [ ARRunnableName, ARRunnableSwAddrMethod, ARInternalDataSwAddrMethod ] = getClassicFunction( this, slEntryPointFunction )
            entryPointMapping = this.getEntryPointMappingForSlEntryPointFunction( this.ModelName, slEntryPointFunction );

            ARRunnableName = entryPointMapping.MappedTo.Runnable;
            ARRunnableSwAddrMethod = entryPointMapping.MappedTo.SwAddrMethod;
            if isempty( ARRunnableSwAddrMethod )
                ARRunnableSwAddrMethod = DAStudio.message( 'RTW:autosar:uiUnselectOptions' );
            end
            ARInternalDataSwAddrMethod = entryPointMapping.MappedTo.InternalDataSwAddrMethod;
            if isempty( ARInternalDataSwAddrMethod )
                ARInternalDataSwAddrMethod = DAStudio.message( 'RTW:autosar:uiUnselectOptions' );
            end
        end

        function mapClassicFunction( this, slEntryPointFunction, arRunnableName, varargin )
            argParser = inputParser;
            argParser.FunctionName = 'autosar.api.getSimulinkMapping.mapFunction';
            argParser.KeepUnmatched = true;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.parse( this, varargin{ : } );


            if isempty( arRunnableName )
                DAStudio.error( 'RTW:autosar:invalidRunnableName',  ...
                    arRunnableName );
            end



            functionType = autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunction( this.ModelName, slEntryPointFunction );
            if strcmp( functionType, 'Step' ) ||  ...
                    strcmp( functionType, 'Periodic' ) ||  ...
                    strcmp( functionType, 'Partition' ) ||  ...
                    strcmp( functionType, 'SimulinkFunction' ) ||  ...
                    strcmp( functionType, 'ExportedFunction' )
                isSwAddrMethodConfigurableForInternalData = true;
            else
                isSwAddrMethodConfigurableForInternalData = false;
            end


            mappingObj = this.getEntryPointMappingForSlEntryPointFunction( this.ModelName, slEntryPointFunction );


            isRunnableChanged = ~strcmp( mappingObj.MappedTo.Runnable, arRunnableName );
            if ~isRunnableChanged && isempty( varargin )


                return ;
            end

            dataObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
            componentQualifiedName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
            componentCategory = dataObj.get( componentQualifiedName, 'Category' );

            switch componentCategory
                case 'AtomicComponent'
                    if ~isempty( this.ChangeLogger )
                        if isRunnableChanged
                            if isa( mappingObj, 'Simulink.AutosarTarget.BlockMapping' )
                                fcnPath = mappingObj.Block;
                            else
                                fcnPath = slEntryPointFunction;
                            end
                            this.ChangeLogger.logModification( 'Automatic', 'AUTOSAR Runnable mapping',  ...
                                'Function',  ...
                                fcnPath,  ...
                                mappingObj.MappedTo.Runnable,  ...
                                arRunnableName );
                        end
                    end
                    autosar.api.Utils.mapFunction( this.ModelName,  ...
                        mappingObj, arRunnableName );
                    params = argParser.Unmatched;
                    if ~isempty( fields( params ) )
                        instSpecificPropertyNames = fieldnames( params );
                        instSpecificPropertyValues = struct2cell( params );
                        for ii = 1:numel( instSpecificPropertyNames )
                            propertyName = instSpecificPropertyNames{ ii };
                            propertyName = validatestring( propertyName,  ...
                                { 'SwAddrMethod', 'SwAddrMethodForInternalData' } );

                            propertyValue = instSpecificPropertyValues{ ii };


                            validateattributes( propertyValue,  ...
                                { 'char', 'string' }, {  },  ...
                                'autosar.api.getSimulinkMapping.mapFunction',  ...
                                propertyName )

                            if strcmpi( propertyValue, DAStudio.message( 'RTW:autosar:uiUnselectOptions' ) )
                                propertyValue = '';
                            end
                            m3iModel = autosar.api.Utils.m3iModel( this.ModelName );
                            if strcmpi( propertyName, 'SwAddrMethod' )
                                propNameForM3I = 'Runnable';
                                mapFcn = 'mapSwAddrMethod';
                            elseif strcmpi( propertyName, 'SwAddrMethodForInternalData' )


                                if ~isSwAddrMethodConfigurableForInternalData
                                    DAStudio.error( 'autosarstandard:validation:invalidRunnableForInternalDataSwAddrMethod', slEntryPointFunction );
                                end
                                propNameForM3I = 'RunnableInternalData';
                                mapFcn = 'mapInternalDataSwAddrMethod';
                            end


                            [ allowedSwAddrMethods, validSectionTypes ] =  ...
                                autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(  ...
                                m3iModel, propNameForM3I );

                            if ~isempty( propertyValue ) &&  ...
                                    ~any( strcmp( propertyValue, allowedSwAddrMethods ) )
                                DAStudio.error( 'autosarstandard:validation:invalidSwAddrMethodForMapping',  ...
                                    slEntryPointFunction, propertyValue, propertyName, autosar.api.Utils.cell2str( validSectionTypes ) );
                            end
                            mappingObj.( mapFcn )( propertyValue );
                        end
                    end
                otherwise
                    assert( false, 'Did not recognize componentCategory %s', componentCategory );
            end
        end

        function modelMapping = getAutosarModelMapping( this )
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                modelMapping = autosar.api.Utils.modelMapping( this.ModelName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end
    end

    methods ( Static, Hidden )
        function res = escapeSimulinkName( pathStr )





            if isstring( pathStr )
                pathStr = convertStringsToChars( pathStr );
            end
            pathStr = strrep( pathStr, newline, ' ' );
            res = strrep( pathStr, '/', '//' );
        end

        function functionType = findFunctionTypeForSlEntryPointFunctionWithoutPrefix( modelName, slEntryPointFunction )



            functionType = '';
            resetFunction = autosar.api.internal.MappingFinder.getResetFunctionEntryPointMapping( modelName, slEntryPointFunction );
            if ~isempty( resetFunction )
                functionType = 'Reset';
                return
            end

            modelMapping = autosar.api.Utils.modelMapping( modelName );
            inputPort = modelMapping.FcnCallInports.findobj(  ...
                'Block', [ modelName, '/', slEntryPointFunction ] );
            if ~isempty( inputPort )
                functionType = 'ExportedFunction';
                return
            end

            SLFunction = autosar.api.internal.MappingFinder.getServerFunctionBlockMappings( modelName, slEntryPointFunction );
            if ~isempty( SLFunction )
                functionType = 'SimulinkFunction';
                return
            end
        end

        function functionType = helperFindFunctionTypeForSlEntryPointFunction( slEntryPointFunction )

            if strcmp( slEntryPointFunction, 'Initialize' ) ||  ...
                    strcmp( slEntryPointFunction, 'Terminate' ) ||  ...
                    strcmp( slEntryPointFunction, 'Periodic' )
                functionType = slEntryPointFunction;
                return
            end

            functionTypes = { 'Periodic',  ...
                'Partition',  ...
                'Reset',  ...
                'ExportedFunction',  ...
                'SimulinkFunction' };
            fcnType = strtrim( extractBefore( slEntryPointFunction, ':' ) );
            if any( ismember( functionTypes, fcnType ) )
                functionType = fcnType;
                return
            end


            functionType = '';
        end

        function functionType = helperFindFunctionTypeForSlEntryPointFunctionDeprecated( modelName, slEntryPointFunction )

            switch slEntryPointFunction
                case 'InitializeFunction'
                    functionType = 'Initialize';
                case 'TerminateFunction'
                    functionType = 'Terminate';
                case 'StepFunction'
                    functionType = 'Step';
                otherwise
                    tid = regexp( slEntryPointFunction, '^StepFunction(\d+)', 'tokens' );
                    if ~isempty( tid )
                        functionType = 'Step';
                    else
                        functionType =  ...
                            autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunctionWithoutPrefix( modelName, slEntryPointFunction );
                    end
            end



            autosar.mm.util.MessageReporter.print(  ...
                message( 'autosarstandard:validation:ObsoleteFunctionValues',  ...
                slEntryPointFunction ).getString(  ) );
        end

        function functionType = findFunctionTypeForSlEntryPointFunction( modelName, slEntryPointFunction )

            functionType = autosar.api.getSimulinkMapping.helperFindFunctionTypeForSlEntryPointFunction( slEntryPointFunction );
            if ~isempty( functionType )
                return
            end


            functionType = autosar.api.getSimulinkMapping.helperFindFunctionTypeForSlEntryPointFunctionDeprecated( modelName, slEntryPointFunction );
            if ~isempty( functionType )
                return
            end


            isExportStyle = autosar.validation.ExportFcnValidator.isTopModelExportFcn( modelName );
            if isExportStyle
                DAStudio.error( 'autosarstandard:validation:invalidMappingFcnForExportFcnModel', slEntryPointFunction );
            else
                DAStudio.error( 'autosarstandard:validation:invalidMappingFcnForRateBasedModel', slEntryPointFunction );
            end
        end

        function validNvReceiverDAMs = getValidNvReceiverDAMs(  )


            validNvReceiverDAMs = autosar.api.getSimulinkMapping.ValidNvReceiverDAMs;
        end

        function validNvSenderDAMs = getValidNvSenderDAMs(  )


            validNvSenderDAMs = autosar.api.getSimulinkMapping.ValidNvSenderDAMs;
        end

        function validParameterAMs = getValidParameterAMs(  )


            validParameterAMs = autosar.api.getSimulinkMapping.ValidParameterAccessModes;
        end

        function validDataDefaultsData = getValidDataDefaultsData(  )


            validDataDefaultsData = autosar.api.getSimulinkMapping.ValidDataDefValidReceiverDAMsaultsData;
        end

        function validDataDefaultsMemory = getValidDataDefaultsMemory(  )


            validDataDefaultsMemory = autosar.api.getSimulinkMapping.ValidDataDefaultsMemory;
        end

        function validDataReceiverDAMs = getValidDataReceiverDAMs( isBusElementPort )


            if isBusElementPort
                validDataReceiverDAMs = autosar.api.getSimulinkMapping.ValidBepReceiverDAMs;
            else
                validDataReceiverDAMs = autosar.api.getSimulinkMapping.ValidReceiverDAMs;
            end
        end

        function validDataSenderDAMs = getValidDataSenderDAMs( isBusElementPort )


            if isBusElementPort
                validDataSenderDAMs = [ autosar.api.getSimulinkMapping.ValidBepSenderDAMs; ...
                    'ModeSend' ];
            else
                validDataSenderDAMs = [ autosar.api.getSimulinkMapping.ValidSenderDAMs; ...
                    'ModeSend' ];
            end
        end

        function validDataSenderReceiverDAMs = getValidDataSenderReceiverDAMsForInports(  )





            validDataSenderReceiverDAMs = { 'ImplicitReceive',  ...
                'ExplicitReceive',  ...
                'ExplicitReceiveByVal',  ...
                'ErrorStatus',  ...
                'IsUpdated',  ...
                'EndToEndRead' };
        end

        function ValidServiceProvidedAllocateMemory = getValidServiceProvidedAllocateMemory(  )



            ValidServiceProvidedAllocateMemory = autosar.api.getSimulinkMapping.ValidServiceProvidedAllocateMemory;
        end

        function validVariableRoles = getValidVariableRoles( isInstanceSpecific )


            if isInstanceSpecific
                validVariableRoles = { DAStudio.message( 'coderdictionary:mapping:NoMapping' ),  ...
                    'ArTypedPerInstanceMemory' };
            else
                validVariableRoles = { DAStudio.message( 'coderdictionary:mapping:NoMapping' ),  ...
                    'ArTypedPerInstanceMemory', 'StaticMemory' };
            end
        end

        function validVariableRoles = getAdaptiveValidVariableRoles(  )


            validVariableRoles = { DAStudio.message( 'coderdictionary:mapping:NoMapping' ),  ...
                DAStudio.message( 'autosarstandard:ui:uiPersistencyArDataRole' ) };
        end

        function validInternalDataPackagingOptions = getValidInternalDataPackagingOptions( modelName )



            modelMapping = autosar.api.Utils.modelMapping( modelName );
            validInternalDataPackagingOptions = { 'Default' };

            if modelMapping.IsSubComponent
                return ;
            end


            if autosar.validation.CommonConfigSetValidator.isCodeInterfacePackagingReusable( modelName ) &&  ...
                    ( matlab.internal.feature( "ArMultiInstInternalDataPackaging" ) > 0 )
                validInternalDataPackagingOptions{ end  + 1 } = 'CTypedPerInstanceMemory';
            else
                validInternalDataPackagingOptions = cat( 2, validInternalDataPackagingOptions,  ...
                    { 'PrivateGlobal', 'PrivateStructure', 'PublicGlobal', 'PublicStructure' } );
            end
        end

        function validParameterRoles = getValidParameterRoles( isInstanceSpecific )


            if isInstanceSpecific
                validParameterRoles = { DAStudio.message( 'coderdictionary:mapping:NoMapping' ),  ...
                    'PerInstanceParameter' };
                validParameterRoles{ end  + 1 } = 'PortParameter';
            else
                validParameterRoles = { DAStudio.message( 'coderdictionary:mapping:NoMapping' ),  ...
                    'SharedParameter', 'ConstantMemory' };
            end
        end

        function properties = getValidCodePerInstanceProperties( mapObj, useLocalizedNames )


            properties = {  };
            dictRef = mapObj.MappedTo;
            if nargin < 2
                useLocalizedNames = false;
            end
            allProps =  ...
                autosar.api.getSimulinkMapping.getAllPerInstanceProperties(  ...
                mapObj, useLocalizedNames );
            for name = allProps

                if ~dictRef.isPerInstancePropertyCalibrationParameter( name{ 1 } ) ...
                        && ~dictRef.isPerInstancePropertyNvBlockNeeds( name{ 1 } )
                    if ~slfeature( 'AUTOSARLongNameAuthoring' ) && strcmp( name{ 1 }, 'LongName' )

                        continue
                    end
                    properties{ end  + 1 } = name{ 1 };%#ok<AGROW>
                end
            end
            arDataRole = dictRef.ArDataRole;

            if isa( mapObj, 'Simulink.AutosarTarget.DataStoreMapping' ) ||  ...
                    isa( mapObj, 'Simulink.AutosarTarget.SynthesizedDataStoreMapping' )
                properties =  ...
                    autosar.api.getSimulinkMapping.getValidCodePerInstancePropertiesForDataStores(  ...
                    properties, arDataRole );
            elseif isa( mapObj, 'Simulink.AutosarTarget.SignalMapping' ) ||  ...
                    isa( mapObj, 'Simulink.AutosarTarget.StateMapping' )
                properties =  ...
                    autosar.api.getSimulinkMapping.getValidCodePerInstancePropertiesForSignalsAndStates(  ...
                    properties, arDataRole );
            elseif isa( mapObj, 'Simulink.AutosarTarget.ModelScopedParameterMapping' )
                properties =  ...
                    autosar.api.getSimulinkMapping.getValidCodePerInstancePropertiesForParameters(  ...
                    properties, arDataRole );
            else
                assert( false, 'Unexpected mapping object' )
            end
        end

        function properties = getValidCalibrationPerInstanceProperties( mapObj, useLocalizedNames )


            properties = {  };
            dictRef = mapObj.MappedTo;
            if nargin < 2
                useLocalizedNames = false;
            end
            allProps =  ...
                autosar.api.getSimulinkMapping.getAllPerInstanceProperties(  ...
                mapObj, useLocalizedNames );
            for name = allProps
                if ~slfeature( 'AUTOSARLongNameAuthoring' ) && strcmp( name{ 1 }, 'LongName' )

                    continue
                end
                if dictRef.isPerInstancePropertyCalibrationParameter( name{ 1 } )
                    properties{ end  + 1 } = name{ 1 };%#ok<AGROW>
                end
            end
        end

        function properties = getValidNvBlockNeedsPerInstanceProperties( mapObj, useLocalizedNames )


            properties = {  };
            dictRef = mapObj.MappedTo;
            if nargin < 2
                useLocalizedNames = false;
            end
            allProps =  ...
                autosar.api.getSimulinkMapping.getAllPerInstanceProperties(  ...
                mapObj, useLocalizedNames );
            for name = allProps
                if dictRef.isPerInstancePropertyNvBlockNeeds( name{ 1 } )
                    properties{ end  + 1 } = name{ 1 };%#ok<AGROW>
                end
            end
        end

        function usesFcnPortMapping = usesFunctionPortMapping( modelName )
            usesFcnPortMapping =  ...
                autosar.api.Utils.isMappedToAdaptiveApplication( modelName );
        end

    end

    methods ( Static, Access = private )
        function mapping = getEntryPointMappingForSlEntryPointFunction( modelName, slEntryPointFunction )
            mapping = '';
            modelMapping = autosar.api.Utils.modelMapping( modelName );


            functionType = autosar.api.getSimulinkMapping.findFunctionTypeForSlEntryPointFunction( modelName, slEntryPointFunction );

            switch functionType
                case 'Initialize'

                    mapping = modelMapping.InitializeFunctions( 1 );
                case 'Terminate'
                    if length( modelMapping.TerminateFunctions ) == 1
                        mapping = modelMapping.TerminateFunctions( 1 );
                    end
                case 'Reset'
                    mapping = autosar.api.internal.MappingFinder.getResetFunctionEntryPointMapping( modelName, slEntryPointFunction );
                case 'Step'
                    mapping = autosar.api.internal.MappingFinder.getStepFunctionEntryPointMapping( modelName, slEntryPointFunction );
                case 'Periodic'
                    mapping = autosar.api.internal.MappingFinder.getPeriodicEntryPointMapping( modelName, slEntryPointFunction, 'Periodic' );
                case 'Partition'
                    mapping = autosar.api.internal.MappingFinder.getPeriodicEntryPointMapping( modelName, slEntryPointFunction, 'Partition' );
                case 'ExportedFunction'
                    mapping = autosar.api.internal.MappingFinder.getExportedFunctionEntryPointMapping( modelName, slEntryPointFunction );
                case 'SimulinkFunction'
                    mapping = autosar.api.internal.MappingFinder.getServerFunctionBlockMappings( modelName, slEntryPointFunction );
            end

            if isempty( mapping )

                DAStudio.error( 'autosarstandard:validation:EntryPointDoesNotExist', slEntryPointFunction );
            end
        end

        function isValid = isValidRateTransitionBlock( blkPath )

            isValid = false;
            try
                if Simulink.ID.isValid( Simulink.ID.getSID( blkPath ) )
                    if strcmp( get_param( blkPath, 'BlockType' ), 'RateTransition' )
                        isValid = true;
                    end
                end
            catch ex %#ok<NASGU>
            end
        end

        function setInternalDataProperties( modelName, mappingObj, DataRole, isVariable, argParser )



            if ~strcmp( DataRole, mappingObj.MappedTo.ArDataRole )
                mappingObj.map( DataRole );
            end
            mappedTo = mappingObj.MappedTo;
            if ~strcmp( DataRole, DAStudio.message( 'coderdictionary:mapping:NoMapping' ) )
                params = argParser.Unmatched;
                if ~isempty( fields( params ) )
                    instSpecificPropertyNames = fieldnames( params );
                    instSpecificPropertyValues = struct2cell( params );
                    modelH = get_param( modelName, 'Handle' );
                    allowedPerInstanceProperties = mappedTo.getPerInstancePropertyNames( isVariable );
                    errorMessages = cell( size( instSpecificPropertyNames ) );
                    for ii = 1:numel( instSpecificPropertyNames )
                        propertyName = instSpecificPropertyNames{ ii };
                        propertyName = validatestring( propertyName, allowedPerInstanceProperties );
                        propertyValue = instSpecificPropertyValues{ ii };

                        if isa( mappingObj, 'Simulink.AutosarTarget.ModelScopedParameterMapping' )
                            source = mappingObj.Parameter;
                        elseif isa( mappingObj, 'Simulink.AutosarTarget.SignalMapping' )
                            portHandles = get_param( mappingObj.OwnerBlockPath, 'PortHandles' );

                            if numel( portHandles.Outport ) > 1
                                source = [ mappingObj.OwnerBlockPath, ':', num2str( get_param( mappingObj.PortHandle, 'PortNumber' ) ) ];
                            else
                                source = mappingObj.OwnerBlockPath;
                            end
                        elseif isa( mappingObj, 'Simulink.AutosarTarget.SynthesizedDataStoreMapping' )

                            source = mappingObj.Name;
                        else
                            source = mappingObj.OwnerBlockPath;
                        end
                        [ result, errorMessage, propertyValue ] = autosar.validation.AutosarUtils.isValidPerInstanceProperty(  ...
                            modelName, mappingObj, source, propertyName, propertyValue );
                        if ~result
                            errorMessages{ ii } = errorMessage;
                        else
                            Simulink.CodeMapping.setPerInstancePropertyValue( modelH, mappingObj, 'MappedTo', propertyName, propertyValue );
                        end
                    end
                    errorMessages = errorMessages( ~cellfun( 'isempty', errorMessages ) );
                    if numel( errorMessages ) > 0
                        error( errorMessages{ 1 } );
                    end
                end
            end
        end

        function properties = getValidCodePerInstancePropertiesForDataStores( properties, arDataRole )
            if strcmp( arDataRole, 'Persistency' )
                properties = setdiff( properties,  ...
                    { DAStudio.message( 'RTW:autosar:ArShortNameProperty' ),  ...
                    'ShortName',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierAdditionalQualifier' ),  ...
                    'Qualifier',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierIsVolatile' ),  ...
                    'IsVolatile',  ...
                    DAStudio.message( 'RTW:autosar:SwAddrMethodProperty' ),  ...
                    'SwAddrMethod',  ...
                    DAStudio.message( 'RTW:autosar:uiNeedsNVRAMAccess' ),  ...
                    'NeedsNVRAMAccess' },  ...
                    'stable' );
            elseif strcmp( arDataRole, 'ArTypedPerInstanceMemory' )
                properties = setdiff( properties,  ...
                    { DAStudio.message( 'RTW:autosar:uiTypeQualifierIsVolatile' ),  ...
                    'IsVolatile',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierAdditionalQualifier' ),  ...
                    'Qualifier',  ...
                    DAStudio.message( 'RTW:autosar:PortNameProperty' ),  ...
                    'Port',  ...
                    DAStudio.message( 'RTW:autosar:PortElementNameProperty' ),  ...
                    'DataElement' },  ...
                    'stable' );
            elseif strcmp( arDataRole, 'StaticMemory' )
                properties = setdiff( properties,  ...
                    { DAStudio.message( 'RTW:autosar:uiNeedsNVRAMAccess' ),  ...
                    'NeedsNVRAMAccess',  ...
                    DAStudio.message( 'RTW:autosar:PortNameProperty' ),  ...
                    'Port',  ...
                    DAStudio.message( 'RTW:autosar:PortElementNameProperty' ),  ...
                    'DataElement' },  ...
                    'stable' );
            end
        end

        function properties = getValidCodePerInstancePropertiesForSignalsAndStates( properties, arDataRole )
            if ~strcmp( arDataRole, 'StaticMemory' )
                properties = setdiff( properties,  ...
                    { DAStudio.message( 'RTW:autosar:uiTypeQualifierIsVolatile' ),  ...
                    'IsVolatile',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierAdditionalQualifier' ),  ...
                    'Qualifier' },  ...
                    'stable' );
            end
            properties = setdiff( properties,  ...
                { DAStudio.message( 'RTW:autosar:uiNeedsNVRAMAccess' ),  ...
                'NeedsNVRAMAccess',  ...
                DAStudio.message( 'RTW:autosar:PortNameProperty' ),  ...
                'Port',  ...
                DAStudio.message( 'RTW:autosar:PortElementNameProperty' ),  ...
                'DataElement' },  ...
                'stable' );
        end

        function properties = getValidCodePerInstancePropertiesForParameters( properties, arDataRole )
            if ~strcmp( arDataRole, 'ConstantMemory' )
                properties = setdiff( properties, { DAStudio.message( 'RTW:autosar:uiTypeQualifierIsConst' ),  ...
                    'IsConst',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierIsVolatile' ),  ...
                    'IsVolatile',  ...
                    DAStudio.message( 'RTW:autosar:uiTypeQualifierAdditionalQualifier' ),  ...
                    'Qualifier' },  ...
                    'stable' );
            end
            if ~strcmp( arDataRole, 'PortParameter' )
                properties = setdiff( properties, { DAStudio.message( 'RTW:autosar:PortNameProperty' ),  ...
                    DAStudio.message( 'RTW:autosar:PortElementNameProperty' ) }, 'stable' );
            end
            properties = setdiff( properties, { DAStudio.message( 'RTW:autosar:uiNeedsNVRAMAccess' ) },  ...
                'stable' );
        end

        function allProps = getAllPerInstanceProperties( mapObj, useLocalizedNames )
            if isa( mapObj, 'Simulink.AutosarTarget.ModelScopedParameterMapping' )
                isVariableData = false;
            else
                isVariableData = true;
            end
            dictRef = mapObj.MappedTo;
            if useLocalizedNames
                allProps = dictRef.getPerInstancePropertyLocalizedNames( isVariableData )';
            else
                allProps = dictRef.getPerInstancePropertyNames( isVariableData )';
            end
        end

        function checkCppIdentifier( value, property )

            isValid = isempty( value ) ||  ...
                RTW.CPPFcnArgSpec( '', 'Inport', 'Pointer', value, 0, 'None', 0, 0 ).isValidCPPIdentifier;
            if ~isValid
                DAStudio.error( 'coderdictionary:api:InvalidCPPIdentifier',  ...
                    property, value );
            end
        end

        function errorIfSettingE2EForSubComp( modelMapping )


            if ~isa( modelMapping, 'Simulink.AutosarTarget.ModelMapping' )
                DAStudio.error( 'autosarstandard:api:onlySupportedForClassicAUTOSAR', 'EndToEnd Protection method' );
            end

            if modelMapping.IsSubComponent
                DAStudio.error( 'autosarstandard:api:invalidEndToEndProtectionMethodForSubComp' );
            end
        end

    end

end


