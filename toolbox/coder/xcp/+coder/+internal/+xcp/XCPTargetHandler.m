classdef XCPTargetHandler < handle
    properties ( SetAccess = private, GetAccess = private )
        XCPTargetConnection;
        XCPParameterTuning;
        XCPConnected = false;
        XCPSyncDataTransferEnabled = false;
        XCPProfilingDataTransferEnabled = false;
        XCPConnectionTimer;
        XCPError = false;
        XCPException = '';
        XCPModelStartRequest = struct(  );
        XCPModelStopRequest = struct(  );
        XCPModelStatus = struct(  );
        XCPModelChecksum0 = struct(  );
        XCPModelChecksum1 = struct(  );
        XCPModelChecksum2 = struct(  );
        XCPModelChecksum3 = struct(  );
        XCPModelIntegerCode = struct(  );
        XCPCurrentSimulationTimeInMs = struct(  );
        XCPCurrentSimulationTimeInTicks = struct(  );
        XCPClassicTriggerEventId = struct(  );
        XCPClassicTriggerSignalAddress = struct(  );
        XCPClassicTriggerSignalAddressExtension = struct(  );
        XCPClassicTriggerLevel = struct(  );
        XCPClassicTriggerDuration = struct(  );
        XCPClassicTriggerHoldOff = struct(  );
        XCPClassicTriggerDelay = struct(  );
        XCPClassicTriggerDirection = struct(  );
        XCPClassicTriggerArmRequest = struct(  );
        XCPClassicTriggerCancelRequest = struct(  );
        XCPClassicTriggerSource = struct(  );
        XCPClassicTriggerMode = struct(  );
        XCPClassicTriggerStatus = struct(  );
        XCPExtmodeFinalSimulationTime = struct(  );
        XCPModelStarted = false;
        ModelName = '';
        BuildDir = '';
        SymbolsFileName = '';
        SymbolsParser;
        LoadedBds;
        ModelLoaded;
        StopTime = Inf;
        PurelyIntegerCode = false;
        BaseRatePeriod = 0;
        ExtOpenUtils = [  ];
        MF0Model = [  ];
        ClassicTriggerConfig = [  ];
        TaskConfig = [  ];
        TargetConfig = [  ];
        XCPSimulationTimeInTicksEnabled = false;
        XCPTimeouts;

        XCPSlaveInfo = struct(  );

        MemUnitTransformer = [  ];
        BytesPerMultiWordChunk = 8;
    end

    properties ( Constant )
        XCP_TIMEOUTS_NUMBER = 7;


    end

    methods ( Abstract, Access = protected )
        connection = startTargetConnection( src, timeouts );
        stopTargetConnection( src, connection );
    end

    methods ( Access = private )
        function updateSDIRunMetadata( src )

            verInfo = ver( 'simulink' );
            slVersionString = sprintf( '%s %s %s',  ...
                verInfo.Name,  ...
                verInfo.Version,  ...
                verInfo.Release );

            r = Simulink.sdi.getCurrentSimulationRun( src.ModelName, '', false );
            if ~isempty( r )
                Simulink.HMI.updateRunMetaData( r.id,  ...
                    src.ModelName,  ...
                    get_param( src.ModelName, 'SimulationMode' ),  ...
                    0,  ...
                    src.StopTime,  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    get_param( src.ModelName, 'SolverType' ),  ...
                    get_param( src.ModelName, 'Solver' ),  ...
                    slVersionString,  ...
                    0,  ...
                    0,  ...
                    0,  ...
                    0,  ...
                    0,  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ),  ...
                    DAStudio.message( 'coder_xcp:host:NotAvailableForSDIRun' ) );
            end
        end

        function name = getXcpCommandName( ~, code )


            try
                command = coder.internal.xcp.XCPCommand( code );
                name = command.string;
            catch

                name = dec2hex( code );
            end
        end

        function name = getXcpErrorCodeName( ~, code )


            try
                errorCode = coder.internal.xcp.XCPErrorCode( code );
                name = errorCode.string;
            catch

                name = dec2hex( code );
            end
        end

        function rethrowException( src, ME )





            xcpErrPacketMessage = 'Error (?<error>\d+) for command (?<command>\d+)';

            errInfo = regexp( ME.message, xcpErrPacketMessage, 'names' );

            if isempty( errInfo )


                rethrow( ME );
            else
                command = src.getXcpCommandName( str2double( errInfo.command ) );
                errorCode = src.getXcpErrorCodeName( str2double( errInfo.error ) );

                if strcmp( errorCode, coder.internal.xcp.XCPErrorCode.ERR_MEMORY_OVERFLOW.string )
                    if strcmp( command, coder.internal.xcp.XCPCommand.START_STOP_DAQ_LIST.string ) ||  ...
                            strcmp( command, coder.internal.xcp.XCPCommand.START_STOP_SYNCH.string )


                        DAStudio.error( 'coder_xcp:host:XcpERRInsufficientMemForSignals',  ...
                            command, errorCode );
                    else
                        DAStudio.error( 'coder_xcp:host:XcpERRInsufficientMemForInternalDataStructures',  ...
                            command, errorCode );
                    end
                else
                    DAStudio.error( 'coder_xcp:host:XcpERRPacketReceived',  ...
                        command, errorCode );
                end
            end
        end

        function bytes = numericToRawData( src, val )


            bytes = coder.internal.xcp.numericToRawData( val, src.MemUnitTransformer );
        end

        function val = rawDataToInt( src, bytes, needsMemUnitTransform )



            if needsMemUnitTransform
                val = coder.internal.xcp.rawDataToInt( bytes, src.MemUnitTransformer );
            else
                val = coder.internal.xcp.rawDataToInt( bytes, [  ] );
            end
        end

        function downloadUnsignedInteger( src, symbol, val )




            assert( isscalar( val ), 'val must be scalar' );
            assert( ismember( class( val ), { 'uint8', 'uint16', 'uint32', 'uint64' } ),  ...
                'downloadUnsignedInteger applies only to unsigned integer types' );


            sizeInBytes = symbol.size * src.XCPSlaveInfo.addressGranularity;
            switch sizeInBytes
                case 1
                    intVal = uint8( val );
                case 2
                    intVal = uint16( val );
                case 4
                    intVal = uint32( val );
                case 8
                    intVal = uint64( val );
                otherwise
                    assert( false, 'Unsupported variable size for symbol' );
            end
            src.XCPTargetConnection.writeData(  ...
                symbol.address,  ...
                symbol.addressExtension,  ...
                src.numericToRawData( intVal ) );
        end

        function downloadSignedInteger( src, symbol, val )




            assert( isscalar( val ), 'val must be scalar' );
            assert( ismember( class( val ), { 'int8', 'int16', 'int32', 'int64' } ),  ...
                'downloadSignedInteger applies only to signed integer types' );


            sizeInBytes = symbol.size * src.XCPSlaveInfo.addressGranularity;
            switch sizeInBytes
                case 1
                    intVal = int8( val );
                case 2
                    intVal = int16( val );
                case 4
                    intVal = int32( val );
                case 8
                    intVal = int64( val );
                otherwise
                    assert( false, 'Unsupported variable size for symbol' );
            end
            src.XCPTargetConnection.writeData(  ...
                symbol.address,  ...
                symbol.addressExtension,  ...
                src.numericToRawData( intVal ) );
        end

        function downloadFloatingPointScalar( src, symbol, val )



            assert( isscalar( val ), 'val must be scalar' );


            sizeInBytes = symbol.size * src.XCPSlaveInfo.addressGranularity;
            switch sizeInBytes
                case 4
                    floatVal = single( val );
                case 8
                    floatVal = double( val );
                otherwise
                    assert( false, 'Unsupported variable size for symbol' );
            end
            src.XCPTargetConnection.writeData(  ...
                symbol.address,  ...
                symbol.addressExtension,  ...
                src.numericToRawData( floatVal ) );
        end

        function val = uploadUnsignedInteger( src, symbol, options )
            arguments
                src
                symbol
                options.NeedsMemUnitTransform = true;
            end





            sizeInBytes = symbol.size * src.XCPSlaveInfo.addressGranularity;
            bytes = src.XCPTargetConnection.readData(  ...
                symbol.address,  ...
                symbol.addressExtension,  ...
                sizeInBytes );
            val = src.rawDataToInt( bytes, options.NeedsMemUnitTransform );
        end

        function val = uploadDouble( src, symbol, options )

            arguments
                src
                symbol
                options.NeedsMemUnitTransform = true;
            end
            sizeInBytes = symbol.size * src.XCPSlaveInfo.addressGranularity;
            bytes = src.XCPTargetConnection.readData(  ...
                symbol.address,  ...
                symbol.addressExtension,  ...
                sizeInBytes );
            if options.NeedsMemUnitTransform
                if src.XCPSlaveInfo.numBitsPerDouble == 32
                    bytes = src.MemUnitTransformer.transform(  ...
                        'single',  ...
                        coder.internal.connectivity.MemUnitTransformDirection.INBOUND,  ...
                        bytes );
                    val = typecast( bytes, 'single' );
                    val = double( val );
                else
                    assert( src.XCPSlaveInfo.numBitsPerDouble == 64,  ...
                        'Number of bits for double is not 32 or 64' );
                    bytes = src.MemUnitTransformer.transform(  ...
                        'double',  ...
                        coder.internal.connectivity.MemUnitTransformDirection.INBOUND,  ...
                        bytes );
                    val = typecast( bytes, 'double' );
                end
            else
                val = typecast( bytes, 'double' );
            end
        end

        function xcpVariable = getXcpVariable( src, symbolName )




            symbol = src.SymbolsParser.describeSymbol( symbolName );
            [ xcpVariable.address, xcpVariable.addressExtension ] = src.getXcpAddress( symbol.address, symbolName );
            xcpVariable.size = symbol.size;
        end

        function readAddressTable( src, mf0Model )


            if slfeature( 'ExtModeXCPImageType' )

                table = coder.xcp.addresstable.AddressTable.getTable( mf0Model );
                if ~isempty( table )
                    table.destroy(  );
                end

                parser = mf.zero.io.JSONParser;
                parser.Model = mf0Model;
                addressTableFile = fullfile( src.BuildDir, 'xcp', 'addr_table.json' );
                parser.parseFile( addressTableFile );
            end
        end
    end

    methods ( Access = public )

        function this = XCPTargetHandler( BuildDir, SymbolsFileName )


            ?coder.internal.connectivity.XcpTargetConnection;
            this.BuildDir = BuildDir;
            this.SymbolsFileName = SymbolsFileName;
            this.ExtOpenUtils = ext_open_utils(  );
        end


        function delete( src )
            try
                if src.XCPSyncDataTransferEnabled
                    src.disableSyncDataTransfer(  );
                end

                if src.XCPConnected
                    src.resetConnection(  );
                end
            catch

                if isvalid( src.XCPConnectionTimer )
                    stop( src.XCPConnectionTimer );
                    delete( src.XCPConnectionTimer );
                end

                if isvalid( src.XCPTargetConnection )
                    delete( src.XCPTargetConnection );
                end
            end
        end


        function initConnection( src, timeouts )



            arguments
                src
                timeouts = repelem( 2, src.XCP_TIMEOUTS_NUMBER )
            end

            src.XCPTimeouts = timeouts;

            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );

            if ( src.XCPConnected )
                return ;
            end





            codeDescriptor = coder.internal.getCodeDescriptorInternal( src.BuildDir, 247362 );
            src.ModelName = codeDescriptor.ModelName;

            if slfeature( 'ExtModeXCPMemoryConfiguration' ) &&  ...
                    slprivate( 'onoff', get_param( src.ModelName, 'ExtModeAutomaticAllocSize' ) ) &&  ...
                    slprivate( 'onoff', get_param( src.ModelName, 'ExtModeSendContiguousSamples' ) ) &&  ...
                    ( get_param( src.ModelName, 'ExtModeTrigDuration' ) >  ...
                    get_param( src.ModelName, 'ExtModeMaxTrigDuration' ) )




                MSLDiagnostic( 'coder_xcp:host:DurationBufferingMismatch' ).reportAsWarning;
            end



            buildInfo = coder.make.internal.loadBuildInfo( src.BuildDir );

            defineMap = coder.internal.xcp.a2l.DefineMapFactory.fromBuildInfo( buildInfo );
            src.XCPSimulationTimeInTicksEnabled = defineMap.isKey( 'XCP_EXTMODE_SIMULATION_TIME_IN_TICKS' );


            src.BaseRatePeriod = codeDescriptor.getSampleTimeInfo.ModelFixedStepSize;
            src.PurelyIntegerCode = strcmp( get_param( src.ModelName, 'PurelyIntegerCode' ), 'on' );

            src.BytesPerMultiWordChunk = coder.internal.xcp.getBytesPerMultiWordChunk( src.ModelName );

            if coder.internal.connectivity.featureOn( 'XcpBigEndian' )

                isHostBased = coder.internal.isHostBasedTarget( src.ModelName );
                src.MemUnitTransformer = coder.internal.xcp.getMemUnitTransformer( src.ModelName, isHostBased );
            end



            byteAddressableEmulationEnabled = false;

            [ ~, ~, fileFormat ] = fileparts( src.SymbolsFileName );

            if ( strcmp( fileFormat, '.pdb' ) )
                src.SymbolsParser = coder.internal.ProgramDatabase( src.SymbolsFileName );
            else
                src.SymbolsParser = coder.internal.ExtendedDwarfParser( src.SymbolsFileName );
                byteAddressableEmulationEnabled = src.SymbolsParser.isByteAddressableEmulationEnabled(  );
            end


            numBitsPerChar = get_param( src.ModelName, 'TargetBitPerChar' );
            src.XCPSlaveInfo.addressGranularity = numBitsPerChar / 8;



            if byteAddressableEmulationEnabled
                src.XCPSlaveInfo.addressGranularity = 1;
                numBitsPerChar = 8;
            end




            if ( src.PurelyIntegerCode )
                numWordsPerDouble = 0;
            else
                numWordsPerDouble = src.getXcpVariable( 'xcpDummyDoubleVariable' ).size;
            end


            src.XCPSlaveInfo.numBitsPerDouble = numWordsPerDouble * numBitsPerChar;


            XCPCacheIssuedWarningEvent( 'clear' );

            eventTag = 'matlab::lang::diagnostic::IssuedEnabledWarningEvent';
            callback = @XCPCacheIssuedWarningEvent;

            issuedWarningEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe( eventTag, callback );
            deleteListener = onCleanup( @(  )delete( issuedWarningEventListener ) );

            clear codeDescriptor;

            coder.internal.xcp.updateCodeDescriptor(  ...
                src.BuildDir,  ...
                src.SymbolsParser,  ...
                'extmode_task_info',  ...
                TargetAddressGranularity = src.XCPSlaveInfo.addressGranularity );


            drawnow;

            try


                src.XCPModelStartRequest = src.getXcpVariable( 'xcpModelStartRequest' );
                src.XCPModelStopRequest = src.getXcpVariable( 'xcpModelStopRequest' );
                src.XCPModelStatus = src.getXcpVariable( 'xcpModelStatus' );
                src.XCPModelChecksum0 = src.getXcpVariable( 'xcpModelChecksum0' );
                src.XCPModelChecksum1 = src.getXcpVariable( 'xcpModelChecksum1' );
                src.XCPModelChecksum2 = src.getXcpVariable( 'xcpModelChecksum2' );
                src.XCPModelChecksum3 = src.getXcpVariable( 'xcpModelChecksum3' );
                src.XCPModelIntegerCode = src.getXcpVariable( 'xcpModelIntegerCode' );

                if src.PurelyIntegerCode || src.XCPSimulationTimeInTicksEnabled
                    src.XCPCurrentSimulationTimeInTicks = src.getXcpVariable( 'xcpCurrentSimulationTimeInTicks' );
                else
                    src.XCPCurrentSimulationTimeInMs = src.getXcpVariable( 'xcpCurrentSimulationTimeInMs' );
                end



                src.XCPClassicTriggerEventId = src.getXcpVariable( 'xcpClassicTriggerEventId' );
                src.XCPClassicTriggerSignalAddress = src.getXcpVariable( 'xcpClassicTriggerSignalAddress' );
                src.XCPClassicTriggerSignalAddressExtension = src.getXcpVariable( 'xcpClassicTriggerSignalAddressExtension' );

                src.XCPClassicTriggerLevel = src.getXcpVariable( 'xcpClassicTriggerLevel' );
                src.XCPClassicTriggerDuration = src.getXcpVariable( 'xcpClassicTriggerDuration' );
                src.XCPClassicTriggerHoldOff = src.getXcpVariable( 'xcpClassicTriggerHoldOff' );
                src.XCPClassicTriggerDelay = src.getXcpVariable( 'xcpClassicTriggerDelay' );
                src.XCPClassicTriggerDirection = src.getXcpVariable( 'xcpClassicTriggerDirection' );

                src.XCPClassicTriggerArmRequest = src.getXcpVariable( 'xcpClassicTriggerArmRequest' );
                src.XCPClassicTriggerCancelRequest = src.getXcpVariable( 'xcpClassicTriggerCancelRequest' );

                src.XCPClassicTriggerSource = src.getXcpVariable( 'xcpClassicTriggerSource' );
                src.XCPClassicTriggerMode = src.getXcpVariable( 'xcpClassicTriggerMode' );

                src.XCPClassicTriggerStatus = src.getXcpVariable( 'xcpClassicTriggerStatus' );


                src.XCPExtmodeFinalSimulationTime = src.getXcpVariable( 'xcpExtmodeFinalSimulationTime' );


                handle = get_param( src.ModelName, 'Handle' );
                mf0Model = coder.xcp.trig.classic.getModel( handle );
                src.populateTrigConfig( mf0Model );



                src.XCPTargetConnection = src.startTargetConnection( src.XCPTimeouts );



                if ~isempty( src.MemUnitTransformer )
                    src.XCPTargetConnection.MemUnitTransformer = src.MemUnitTransformer;
                end


                slaveResponse = src.XCPTargetConnection.getSlaveInfo(  );
                if ( slaveResponse.addressGranularity ~= src.XCPSlaveInfo.addressGranularity )
                    DAStudio.error( 'coder_xcp:host:IncorrectSlaveAddressGranularity',  ...
                        src.XCPSlaveInfo.addressGranularity,  ...
                        slaveResponse.addressGranularity );
                end

                src.XCPTargetConnection.setSlaveInfo( 'numBitsPerDouble', double( src.XCPSlaveInfo.numBitsPerDouble ) );
                src.XCPTargetConnection.setSlaveInfo( 'numBytesPerMultiWordChunk', src.BytesPerMultiWordChunk );

                src.XCPParameterTuning = coder.internal.xcp.ParameterTuning( src.XCPTargetConnection, src.BytesPerMultiWordChunk, src.BuildDir );
                src.XCPParameterTuning.setNumBitsPerDouble( src.XCPSlaveInfo.numBitsPerDouble );
                src.XCPParameterTuning.setPurelyIntegerCode( src.PurelyIntegerCode );
                src.XCPConnected = true;

            catch ME
                src.ModelName = '';
                src.SymbolsParser = '';
                src.XCPModelStartRequest = struct(  );
                src.XCPModelStopRequest = struct(  );
                src.XCPModelStatus = struct(  );
                src.XCPModelChecksum0 = struct(  );
                src.XCPModelChecksum1 = struct(  );
                src.XCPModelChecksum2 = struct(  );
                src.XCPModelChecksum3 = struct(  );
                src.XCPModelIntegerCode = struct(  );
                src.XCPCurrentSimulationTimeInMs = struct(  );
                src.XCPClassicTriggerEventId = struct(  );
                src.XCPClassicTriggerSignalAddress = struct(  );
                src.XCPClassicTriggerSignalAddressExtension = struct(  );
                src.XCPClassicTriggerLevel = struct(  );
                src.XCPClassicTriggerDuration = struct(  );
                src.XCPClassicTriggerHoldOff = struct(  );
                src.XCPClassicTriggerDelay = struct(  );
                src.XCPClassicTriggerDirection = struct(  );
                src.XCPClassicTriggerArmRequest = struct(  );
                src.XCPClassicTriggerCancelRequest = struct(  );
                src.XCPClassicTriggerSource = struct(  );
                src.XCPClassicTriggerMode = struct(  );
                src.XCPClassicTriggerStatus = struct(  );

                src.rethrowException( ME );
            end
        end

        function populateTrigConfig( src, mf0Model )





            src.ClassicTriggerConfig = coder.xcp.trig.classic.TriggerConfig.findConfig( mf0Model );
            assert( ~isempty( src.ClassicTriggerConfig ), 'no classic trigger configuration found' );

            triggerSignalBlockPath = get_param( src.ModelName, 'ExtModeTrigSignalBlockPath' );
            triggerSignalOutputPortIndex = get_param( src.ModelName, 'ExtModeTrigSignalOutputPortIndex' );
            triggerDuration = uint64( get_param( src.ModelName, 'ExtModeTrigDuration' ) );

            if coder.internal.connectivity.featureOn( 'XcpPackedMode' ) &&  ...
                    slprivate( 'onoff', get_param( src.ModelName, 'ExtModeSendContiguousSamples' ) ) &&  ...
                    triggerDuration >= 2 ^ 16

                DAStudio.error( 'coder_xcp:host:InvalidDurationForPackedMode' );
            end



            src.ClassicTriggerConfig.Trigger.BlockPath = triggerSignalBlockPath;
            src.ClassicTriggerConfig.Trigger.OutputPortIndex = triggerSignalOutputPortIndex;
            src.ClassicTriggerConfig.Trigger.Address = 0;
            src.ClassicTriggerConfig.Trigger.EventId = 0;

            src.ClassicTriggerConfig.Duration = triggerDuration;



            modelLoggingInfo = coder.internal.xcp.getModelLoggingInfo( src.ModelName );



            src.ClassicTriggerConfig.SignalLoggingOverride =  ...
                strcmp( modelLoggingInfo.LoggingMode, 'OverrideSignals' );


            src.ClassicTriggerConfig.OverriddenSignals.destroyAllContents(  );

            for i = 1:numel( modelLoggingInfo.Signals )
                sig = modelLoggingInfo.Signals( i );

                blockPath = sig.BlockPath.toPipePath;
                outputPortIndex = int32( sig.OutputPortIndex );
                sourcePort = sprintf( '%s:%d', blockPath, outputPortIndex );
                dataLogging = sig.LoggingInfo.DataLogging;
                decimateData = sig.LoggingInfo.DecimateData;
                decimation = int32( sig.LoggingInfo.Decimation );
                limitDataPoints = sig.LoggingInfo.LimitDataPoints;
                maxPoints = int32( sig.LoggingInfo.MaxPoints );
                src.ClassicTriggerConfig.createIntoOverriddenSignals(  ...
                    struct( 'SourcePort', sourcePort,  ...
                    'BlockPath', blockPath,  ...
                    'OutputPortIndex', outputPortIndex,  ...
                    'DataLogging', dataLogging,  ...
                    'DecimateData', decimateData,  ...
                    'Decimation', decimation,  ...
                    'LimitDataPoints', limitDataPoints,  ...
                    'MaxPoints', maxPoints ) );
            end
        end

        function populateTaskAndTargetConfig( src, mf0Model )



            src.TaskConfig = coder.xcp.trig.classic.TaskConfig.findConfig( mf0Model );
            assert( ~isempty( src.TaskConfig ), 'cannot find TaskConfig object' );
            src.TargetConfig = coder.xcp.trig.classic.TargetConfig.findConfig( mf0Model );
            assert( ~isempty( src.TargetConfig ), 'cannot find TargetConfig object' );

            usePackedMode = coder.internal.connectivity.featureOn( 'XcpPackedMode' ) &&  ...
                slprivate( 'onoff', get_param( src.ModelName, 'ExtModeSendContiguousSamples' ) );
            src.TargetConfig.UsePackedMode = usePackedMode;

            if src.TargetConfig.UsePackedMode
                err = coder.internal.xcp.populateTaskConfig( src.TaskConfig, src.BuildDir );
                if ~isempty( err )
                    DAStudio.error( err );
                end

                if src.PurelyIntegerCode || src.XCPSimulationTimeInTicksEnabled
                    stopTimeInTicks = src.uploadUnsignedInteger(  ...
                        src.XCPExtmodeFinalSimulationTime );
                    if stopTimeInTicks == intmax( 'uint32' )
                        stopTime = inf;
                    else
                        stopTime = stopTimeInTicks * src.BaseRatePeriod;
                    end
                else
                    stopTime = src.uploadDouble(  ...
                        src.XCPExtmodeFinalSimulationTime );
                    if stopTime ==  - 2

                        stopTime = str2double(  ...
                            get_param( src.ModelName, 'StopTime' ) );
                    elseif stopTime ==  - 1

                        stopTime = inf;
                    end
                end

                src.TargetConfig.StopTime = stopTime;
            else

                src.TargetConfig.StopTime = inf;


                currentDir = pwd;
                restoreDir = onCleanup( @(  )cd( currentDir ) );
                cd( src.BuildDir );
                assert( isfile( 'extmode_task_info.m' ),  ...
                    'cannot find extmode_task_info.m to populate TaskConfig' );
                [ ~, numTasks, ~ ] = extmode_task_info;
                clear restoreDir

                if numTasks >= 2 ^ 16
                    DAStudio.error( 'coder_xcp:host:TooManyTasksForXCP' );
                end
            end
        end


        function params = getParams( src, params )









            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );

            for p = 1:numel( params )
                blockPath = params( p ).BlockName;
                paramName = params( p ).ParameterName;
                params( p ).Values = src.XCPParameterTuning.getParam( blockPath, paramName );
            end
        end


        function setParams( src, params )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );


            isTuningNeeded = false;
            for i = 1:length( params )
                p = params( i );
                if isempty( p.BlockName )
                    p.BlockName = '';
                    fullParameterName = p.ParameterName;
                else
                    fullParameterName = [ p.BlockName, '/', p.ParameterName ];
                end


                fullParameterName = regexprep( fullParameterName, '[\n]+', ' ' );


                isParamTuningSupported = src.XCPParameterTuning.checkParamTuningSupported( p.Values, fullParameterName, p.DataTypeName );

                if isParamTuningSupported
                    try
                        src.XCPParameterTuning.setParam( p.BlockName, p.ParameterName, p.Values );

                        isTuningNeeded = true;

                    catch ME
                        if ( strcmp( ME.identifier, 'coder_xcp:host:XcpError' ) )
                            MSLDiagnostic( ME.identifier, ME.message ).reportAsWarning;
                        else
                            src.rethrowException( ME );
                        end
                    end
                end
            end

            if isTuningNeeded
                try
                    src.XCPParameterTuning.tuneParams(  );
                catch ME
                    src.rethrowException( ME );
                end
            end
        end

        function prepareForSyncDataTransfer( src )




            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );

            if ( src.XCPSyncDataTransferEnabled )
                return ;
            end




            src.LoadedBds = find_system( 'type', 'block_diagram' );
            src.ModelLoaded = any( strcmp( src.LoadedBds, src.ModelName ) );

            try
                if strcmp( get_param( src.ModelName, 'CodeExecutionProfiling' ), 'on' )

                    lTargetInfo = coder.profile.CoderInstrumentationInfo.getTargetInfo( src.BuildDir, true );

                    if isfield( lTargetInfo, 'isXCPTarget' ) && lTargetInfo.isXCPTarget

                        coder.profile.xcp.profilingInitCallback( src.ModelName );

                        lGlobalRegistry =  ...
                            coder.profile.CoderInstrumentationInfo.getGlobalRegistry(  ...
                            fullfile( src.BuildDir, 'instrumented' ), true );
                        instrInfoData.lGlobalRegistry = lGlobalRegistry;
                        instrInfoData.profChecksum = lGlobalRegistry.getModelInstrumentationChecksum;
                        instrInfoData.targetInfo = lTargetInfo;
                        coder.profile.CoderInstrumentationInfo.writeInfo( src.BuildDir, instrInfoData );

                        mem = src.getXcpVariable( lTargetInfo.bufferName );

                        lOnTargetMetrics = strcmpi( get_param( src.ModelName, 'CodeProfilingSaveOptions' ), 'MetricsOnly' );
                        if lOnTargetMetrics || ~lGlobalRegistry.XCPCustomMemoryModel
                            memSize = mem.size;
                        else
                            memSize = lGlobalRegistry.XCPBufferConfig.BufferSizeInBytes;
                        end
                        profilingStream = src.XCPTargetConnection.configureProfiling( src.ModelName, src.BuildDir,  ...
                            lTargetInfo.eventID, mem.address, mem.addressExtension, memSize,  ...
                            lTargetInfo.timerInBytes, lTargetInfo.wordSizeInBytes,  ...
                            lTargetInfo.hasNodeField, lTargetInfo.hasThreadField,  ...
                            lTargetInfo.numSamples, lOnTargetMetrics );
                        if ~lOnTargetMetrics && codertarget.utils.isESBEnabled( src.ModelName )
                            coder.internal.connectivity.StreamingProfilerXCPBridge.connect( profilingStream, src.ModelName );
                        end
                        src.XCPProfilingDataTransferEnabled = true;
                    end
                end

                handle = get_param( src.ModelName, 'Handle' );
                src.MF0Model = coder.xcp.trig.classic.getModel( handle );
                src.populateTaskAndTargetConfig( src.MF0Model );
                src.readAddressTable( src.MF0Model );



                xcpEnableFrameSupportOrig = slfeature( 'XCPEnableFrameSupport', 0 );
                reenableFrameSupport = onCleanup( @(  )slfeature( 'XCPEnableFrameSupport', xcpEnableFrameSupportOrig ) );

                src.XCPTargetConnection.prepareForLogging( src.BuildDir, src.MF0Model );
            catch ME
                src.LoadedBds = '';
                src.ModelLoaded = '';

                src.rethrowException( ME );
            end
        end

        function startSyncDataTransfer( src )



            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );

            if ( src.XCPSyncDataTransferEnabled )
                return ;
            end

            try






                src.XCPTargetConnection.startLogging( src.ModelName, src.MF0Model );
                src.XCPSyncDataTransferEnabled = true;
            catch ME
                src.LoadedBds = '';
                src.ModelLoaded = '';

                src.rethrowException( ME );
            end





            if src.ModelLoaded
                hmiOpts.RecordOn = slprivate( 'onoff', get_param( src.ModelName, 'InspectSignalLogs' ) );
                hmiOpts.VisualizeOn = slprivate( 'onoff', get_param( src.ModelName, 'VisualizeSimOutput' ) );
                hmiOpts.CommandLine = false;
                hmiOpts.StartTime = get_param( src.ModelName, 'SimulationTime' );
                hmiOpts.StopTime = src.StopTime;
                hmiOpts.EnableRollback = slprivate( 'onoff', get_param( src.ModelName, 'EnableRollback' ) );
                hmiOpts.SnapshotInterval = get_param( src.ModelName, 'SnapshotInterval' );
                hmiOpts.NumberOfSteps = get_param( src.ModelName, 'NumberOfSteps' );
            else
                hmiOpts.RecordOn = false;
                hmiOpts.VisualizeOn = true;
                hmiOpts.CommandLine = false;
                hmiOpts.StartTime = 0;
                hmiOpts.StopTime = inf;
                hmiOpts.EnableRollback = false;
                hmiOpts.SnapshotInterval = 10;
                hmiOpts.NumberOfSteps = 1;
            end
            Simulink.HMI.slhmi( 'sim_start', src.ModelName, hmiOpts );

            src.updateSDIRunMetadata(  );


            src.XCPConnectionTimer = timer( 'Period', 0.1, 'ExecutionMode', 'fixedRate',  ...
                'TimerFcn', { @XCPTgtConnTimerCallback, src } );

            start( src.XCPConnectionTimer );
        end


        function disableSyncDataTransfer( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );

            if ( ~src.XCPSyncDataTransferEnabled ||  ...
                    ~src.XCPConnected )
                return ;
            end


            if isvalid( src.XCPConnectionTimer )
                stop( src.XCPConnectionTimer );
                delete( src.XCPConnectionTimer );
            end


            src.updateSDIRunMetadata(  );





            try
                src.XCPTargetConnection.stopLogging(  );
                src.XCPSyncDataTransferEnabled = false;
                if codertarget.utils.isESBEnabled( src.ModelName )
                    coder.internal.connectivity.StreamingProfilerXCPBridge.stop( src.ModelName );
                end
                src.XCPProfilingDataTransferEnabled = false;
            catch ME
                src.rethrowException( ME );
            end
        end


        function resetConnection( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( ~src.XCPSyncDataTransferEnabled, 'XCP connection needs to be stopped first' );

            if ( ~src.XCPConnected )
                return ;
            end



            delete( src.XCPParameterTuning );



            try
                src.stopTargetConnection( src.XCPTargetConnection );
            catch ME
                src.rethrowException( ME );
            end

            delete( src.XCPTargetConnection );


            delete( src.SymbolsParser );

            src.XCPConnected = false;
        end


        function ret = isXCPConnected( src )
            ret = src.XCPConnected;
        end


        function ret = isXCPSyncDataTransferEnabled( src )
            ret = src.XCPSyncDataTransferEnabled;
        end


        function ret = isXCPProfilingDataTransferEnabled( src )
            ret = src.XCPProfilingDataTransferEnabled;
        end


        function modelStart( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try
                src.downloadUnsignedInteger(  ...
                    src.XCPModelStartRequest,  ...
                    uint8( 1 ) );
            catch ME
                src.rethrowException( ME );
            end

            src.XCPModelStarted = true;
        end


        function modelStop( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try
                src.downloadUnsignedInteger(  ...
                    src.XCPModelStopRequest,  ...
                    uint8( 1 ) );
            catch ME
                src.rethrowException( ME );
            end

            src.XCPModelStarted = false;
        end


        function status = getModelStatus( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try








                value = double( src.uploadUnsignedInteger( src.XCPModelStatus ) );
            catch ME
                src.rethrowException( ME );
            end

            assert( ismember( value, enumeration( 'coder.internal.xcp.TargetStatus' ) ),  ...
                'XCPTargetHandler: invalid target status received from the target' );

            status = coder.internal.xcp.TargetStatus( value );

            src.XCPModelStarted = ( status == coder.internal.xcp.TargetStatus.RUNNING );
        end


        function [ checksum0, checksum1, checksum2, checksum3, integerCode ] = getModelInfo( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );
            try

                checksum0 = double( src.uploadUnsignedInteger( src.XCPModelChecksum0 ) );
                checksum1 = double( src.uploadUnsignedInteger( src.XCPModelChecksum1 ) );
                checksum2 = double( src.uploadUnsignedInteger( src.XCPModelChecksum2 ) );
                checksum3 = double( src.uploadUnsignedInteger( src.XCPModelChecksum3 ) );
                integerCode = double( src.uploadUnsignedInteger( src.XCPModelIntegerCode ) );
            catch ME
                src.rethrowException( ME );
            end
        end




        function time = getModelTime( src, readFromRemoteTarget )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );

            if readFromRemoteTarget
                try


                    if src.PurelyIntegerCode || src.XCPSimulationTimeInTicksEnabled
                        value = src.uploadUnsignedInteger( src.XCPCurrentSimulationTimeInTicks,  ...
                            'NeedsMemUnitTransform', false );
                        time = double( value ) * src.BaseRatePeriod;
                    else
                        value = src.uploadUnsignedInteger( src.XCPCurrentSimulationTimeInMs,  ...
                            'NeedsMemUnitTransform', false );
                        time = double( value ) / 1000;
                    end
                catch ME
                    src.rethrowException( ME );
                end

            else
                time = src.XCPTargetConnection.getTime(  );
            end
        end



        function setModelStartTime( src, time )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );

            src.XCPTargetConnection.setStartTime( time );
        end


        function setModelStopTime( src, time )
            src.StopTime = time;
        end


        function time = getModelStopTime( src )
            time = src.StopTime;
        end



        function checkError( src )
            if src.XCPError
                src.XCPError = false;
                throw( src.XCPException );
            end
        end


        function setError( src, ME )
            if ~src.XCPError
                src.XCPException = ME;
                src.XCPError = true;

                if ~src.XCPModelStarted



                    set_param( src.ModelName, 'SimulationCommand', 'disconnect' );
                end
            end
        end


        function hasSignals = hasInstrumentedSignals( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );

            hasSignals = src.XCPTargetConnection.hasInstrumentedSignals( src.BuildDir );
        end



        function classicTriggerConfiguration( src, triggerParams )
            assert( src.XCPConnected, 'XCP connection not initialized' );



            try
                if isempty( triggerParams.Signal )

                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerSource,  ...
                        uint8( 0 ) );
                else
                    if isempty( src.ClassicTriggerConfig.Trigger.BlockPath )
                        MSLDiagnostic( 'coder_xcp:host:ClassicTrigNoTriggerSignalSpecified' ).reportAsWarning;
                    elseif src.ClassicTriggerConfig.Trigger.Address == 0
                        MSLDiagnostic( 'coder_xcp:host:ClassicTrigNoAddressForTriggerSignal',  ...
                            src.ClassicTriggerConfig.Trigger.BlockPath,  ...
                            src.ClassicTriggerConfig.Trigger.OutputPortIndex ).reportAsWarning;
                    end


                    trigName = sprintf( '%s:%d', src.ClassicTriggerConfig.Trigger.BlockPath,  ...
                        src.ClassicTriggerConfig.Trigger.OutputPortIndex );
                    [ trigAddress, trigAddressExtension ] =  ...
                        src.getXcpAddress( src.ClassicTriggerConfig.Trigger.Address, trigName, false );


                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerSource,  ...
                        uint8( 1 ) );


                    eventId = src.ClassicTriggerConfig.Trigger.EventId;
                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerEventId,  ...
                        eventId );


                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerSignalAddress,  ...
                        trigAddress );


                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerSignalAddressExtension,  ...
                        trigAddressExtension );


                    switch triggerParams.Signal.Direction
                        case 'rising'
                            triggerDirection = uint32( 0 );
                        case 'falling'
                            triggerDirection = uint32( 1 );
                        case 'either'
                            triggerDirection = uint32( 2 );
                        otherwise
                            assert( false, 'invalid signal direction' );
                    end
                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerDirection,  ...
                        triggerDirection );


                    if ( src.PurelyIntegerCode )
                        signalLevel = int32( triggerParams.Signal.Level );
                        src.downloadSignedInteger( src.XCPClassicTriggerLevel, signalLevel );
                    else


                        signalLevel = src.XCPParameterTuning.convertToTargetDouble(  ...
                            triggerParams.Signal.Level, 'ExtModeTrigLevel' );
                        src.downloadFloatingPointScalar( src.XCPClassicTriggerLevel,  ...
                            signalLevel );
                    end


                    holdOff = uint32( triggerParams.Signal.HoldOff );
                    src.downloadUnsignedInteger(  ...
                        src.XCPClassicTriggerHoldOff,  ...
                        holdOff );


                    if triggerParams.Signal.Delay >= 0
                        delay = int32( triggerParams.Signal.Delay );
                    else
                        MSLDiagnostic( 'coder_xcp:host:ClassicTrigNegativeDelayNotSupported' ).reportAsWarning;
                        delay = int32( 0 );
                    end
                    src.downloadSignedInteger( src.XCPClassicTriggerDelay, delay );
                end


                if ( triggerParams.OneShot )
                    triggerMode = uint32( 1 );
                else
                    triggerMode = uint32( 0 );
                end
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerMode,  ...
                    triggerMode );


                duration = uint32( get_param( src.ModelName, 'ExtModeTrigDuration' ) );
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerDuration,  ...
                    duration );
            catch ME


                src.setError( ME );
            end
        end



        function classicTriggerArm( src )
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerArmRequest,  ...
                    uint8( 1 ) );
            catch ME


                src.setError( ME );
            end
        end



        function classicTriggerCancel( src )
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerCancelRequest,  ...
                    uint8( 1 ) );
            catch ME


                src.setError( ME );
            end
        end



        function classicTriggerAbortPendingRequests( src )
            assert( src.XCPConnected, 'XCP connection not initialized' );



            try
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerArmRequest,  ...
                    uint8( 0 ) );
                src.downloadUnsignedInteger(  ...
                    src.XCPClassicTriggerCancelRequest,  ...
                    uint8( 0 ) );
            catch ME


                src.setError( ME );
            end
        end



        function status = getClassicTriggerStatus( src )
            assert( coder.internal.xcp.isXCPTargetEnabled(  ), 'XCP feature is off' );
            assert( src.XCPConnected, 'XCP connection not initialized' );


            try
                value = double( src.uploadUnsignedInteger( src.XCPClassicTriggerStatus ) );
            catch ME
                src.rethrowException( ME );
            end

            assert( ismember( value, enumeration( 'coder.internal.xcp.ClassicTriggerStatus' ) ),  ...
                'XCPTargetHandler: invalid target status received from the target' );

            status = coder.internal.xcp.ClassicTriggerStatus( value );
        end
    end

    methods ( Static, Access = public )
        function [ xcpAddress, xcpAddressExtension ] = getXcpAddress( address, name, checkNotInTable )






            arguments
                address( 1, 1 )uint64
                name( 1, : )char
                checkNotInTable( 1, 1 )logical = true
            end

            if any( bitget( address, 41:64 ) )

                DAStudio.error( 'coder_xcp_mc_system:mc:SymbolAddressExceedsLimit', name );
            end
            if slfeature( 'ExtModeXCPImageType' ) && checkNotInTable && bitget( address, 40 )

                DAStudio.error( 'coder_xcp:host:AddressClashWithTable', name );
            end
            xcpAddress = uint32( bitand( uint64( address ), uint64( 0xFFFFFFFF ) ) );
            xcpAddressExtension = uint8( bitshift( bitand( uint64( address ), uint64( 0xFF00000000 ) ),  - 32 ) );
        end
    end
end

function XCPTgtConnTimerCallback( ~, ~, src )
try
    src.XCPTargetConnection.runOnce(  );
catch ME
    src.setError( ME );
end
end

function cachedWarnings = XCPCacheIssuedWarningEvent( aEvent )
persistent IssuedWarningsCache;
if isempty( IssuedWarningsCache )
    IssuedWarningsCache = {  };
end
if nargin < 1

elseif strcmpi( aEvent, 'clear' )
    IssuedWarningsCache = {  };
else
    IssuedWarningsCache = [ IssuedWarningsCache;{ aEvent } ];
end
cachedWarnings = IssuedWarningsCache;
end

