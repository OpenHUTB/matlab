classdef DictionaryExporter < handle




    properties ( Constant, Access = private )
        TempPortName = 'TEMPORARY_AUTO_GENERATED';
        TempHiddenModelTag = 'Temp_Model_For_Exporting_Dictionary';
    end

    properties ( SetAccess = immutable, GetAccess = private )
        InterfaceDictAPI Simulink.interface.Dictionary
        IsArchModelUIContext
        IsInterfaceDictUIContext
        ConfigSetOfBuildContext
    end

    methods
        function this = DictionaryExporter( dictionaryFilePath, namedargs )
            arguments
                dictionaryFilePath
                namedargs.IsArchModelUIContext = false;
                namedargs.IsInterfaceDictUIContext = false;
                namedargs.ConfigSetOfBuildContext = [  ];
            end
            this.InterfaceDictAPI = Simulink.interface.dictionary.open( dictionaryFilePath );
            this.IsArchModelUIContext = namedargs.IsArchModelUIContext;
            this.IsInterfaceDictUIContext = namedargs.IsInterfaceDictUIContext;
            this.ConfigSetOfBuildContext = namedargs.ConfigSetOfBuildContext;
        end

        function exportedARXMLFolder = exportToARXML( this )





            if this.IsInterfaceDictUIContext
                msg = DAStudio.message( 'autosarstandard:exporter:InterfaceDictExportInProgressUI' );
                progressBarDialog = Simulink.internal.ScopedProgressBar( msg );
            elseif this.IsArchModelUIContext
                msg = DAStudio.message( 'autosarstandard:exporter:InterfaceDictExportPleaseWait' );
                disp( msg );
            else

                msg = DAStudio.message( 'autosarstandard:exporter:InterfaceDictExportInProgress' );
                disp( msg );
            end


            if isempty( which( this.InterfaceDictAPI.DictionaryFileName ) )
                DAStudio.error( 'SLDD:sldd:DictionaryNotFound',  ...
                    this.InterfaceDictAPI.DictionaryFileName );
            end


            [ modelName, destroyTempModel ] = this.createTemporaryModelMappedToClassicAUTOSAR(  );%#ok<ASGLU>


            this.addPortsUsingInterfaces( modelName );


            this.addPortsUsingDataTypes( modelName );


            exportedARXMLFolder = this.buildModelAndCopyArtifacts( modelName );
            exportMsg = DAStudio.message( 'autosarstandard:exporter:DictExportArxmlFiles', exportedARXMLFolder );

            if this.IsInterfaceDictUIContext
                progressBarDialog.delete(  );
                dialogProvider = DAStudio.DialogProvider;
                exportTitle = DAStudio.message( 'autosarstandard:exporter:DictExportComplete' );
                dialogProvider.msgbox( exportMsg, exportTitle, false );
            elseif this.IsArchModelUIContext
                disp( DAStudio.message( 'autosarstandard:exporter:DictExportComplete' ) );
            else

                disp( exportMsg );
            end
        end
    end

    methods ( Access = private )

        function addPortsUsingInterfaces( this, modelName )



            import autosar.dictionary.internal.DictionaryExporter

            interfaces = this.InterfaceDictAPI.Interfaces;
            portIdx = 0;
            for intfIdx = 1:length( interfaces )
                interface = interfaces( intfIdx );
                elements = interface.Elements;
                if isempty( elements )


                    continue
                end
                portIdx = portIdx + 1;
                portName = [ DictionaryExporter.TempPortName, num2str( portIdx ) ];
                isInport = false;
                for elemIdx = 1:length( elements )
                    element = elements( elemIdx );
                    portH = autosar.simulink.bep.Utils.addBusElement( modelName, portName, element.Name, isInport, num2str( portIdx ) );
                    if elemIdx == 1

                        autosar.simulink.bep.Utils.setParam( portH, true, 'OutDataTypeStr', [ 'Bus:', interface.Name ] );
                    end




                    if startsWith( autosar.simulink.bep.Utils.getParam( portH, false, 'OutDataTypeStr' ), 'Bus:' )
                        autosar.simulink.bep.Utils.setParam( portH, false, 'Virtuality', 'nonvirtual' );
                    end
                end
            end
        end

        function addPortsUsingDataTypes( this, modelName )



            import autosar.dictionary.internal.DictionaryExporter


            existingPorts = find_system( modelName,  ...
                'SearchDepth', 1, 'BlockType', 'Outport' );
            if ~isempty( existingPorts )
                nextPortIdx = max( str2double( get_param( existingPorts, 'Port' ) ) ) + 1;
            else
                nextPortIdx = 1;
            end

            dataTypes = this.InterfaceDictAPI.DataTypes;
            for idx = 1:length( dataTypes )
                dataType = dataTypes( idx );
                if DictionaryExporter.isBSWEnumType( dataType.Name )







                    continue
                end
                portName = [ DictionaryExporter.TempPortName, num2str( nextPortIdx ) ];
                isInport = false;
                portH = autosar.simulink.bep.Utils.addBusElement( modelName, portName, 'DE1', isInport, num2str( nextPortIdx ) );
                if isa( dataType, 'Simulink.interface.dictionary.StructType' )
                    autosar.simulink.bep.Utils.setParam( portH, false, 'OutDataTypeStr', [ 'Bus:', dataType.Name ] );
                    if isempty( dataType.Elements )
                        DAStudio.error( 'Simulink:DataType:InvalidDataTypeNumElements',  ...
                            dataType.Name, getfullname( portH ) );
                    end
                    autosar.simulink.bep.Utils.setParam( portH, false, 'Virtuality', 'nonvirtual' );
                elseif isa( dataType, 'Simulink.interface.dictionary.ValueType' )
                    autosar.simulink.bep.Utils.setParam( portH, false, 'OutDataTypeStr', [ 'ValueType:', dataType.Name ] );
                elseif isa( dataType, 'Simulink.interface.dictionary.EnumType' )
                    autosar.simulink.bep.Utils.setParam( portH, false, 'OutDataTypeStr', [ 'Enum:', dataType.Name ] );
                else
                    autosar.simulink.bep.Utils.setParam( portH, false, 'OutDataTypeStr', dataType.Name );
                end
                nextPortIdx = nextPortIdx + 1;
            end
        end

        function configureCodeGenSettings( this, modelName )

            addterms( modelName );
            autosar.api.create( modelName, 'incremental', DisableM3IListeners = true );


            set_param( modelName, 'ArrayLayout', 'row-major' );



            if ~isempty( this.ConfigSetOfBuildContext )
                set_param( modelName, 'ProdHWDeviceType',  ...
                    this.ConfigSetOfBuildContext.get_param( 'ProdHWDeviceType' ) );
                params = { 'ProdBitPerChar',  ...
                    'ProdBitPerShort',  ...
                    'ProdBitPerInt',  ...
                    'ProdBitPerLong',  ...
                    'ProdBitPerFloat',  ...
                    'ProdBitPerDouble',  ...
                    'ProdBitPerLongLong',  ...
                    'ProdWordSize',  ...
                    'ProdBitPerPointer',  ...
                    'ProdBitPerSizeT',  ...
                    'ProdBitPerPtrDiffT',  ...
                    'ProdLargestAtomicInteger',  ...
                    'ProdLargestAtomicFloat',  ...
                    'ProdEndianess',  ...
                    'ProdIntDivRoundTo',  ...
                    'ProdShiftRightIntArith',  ...
                    'ProdLongLongMode' };
                for i = 1:length( params )
                    paramName = params{ i };
                    csParamValue = this.ConfigSetOfBuildContext.get_param( paramName );
                    if ~strcmp( get_param( modelName, paramName ), csParamValue )



                        try %#ok<TRYNC>
                            set_param( modelName, paramName, csParamValue );
                        end
                    end
                end
            end
        end

        function dstFolder = buildModelAndCopyArtifacts( this, modelName )



            import autosar.dictionary.internal.DictionaryExporter



            dictFilePath = this.InterfaceDictAPI.filepath;
            restoreDictionaryM3IModel = onCleanup( @(  ) ...
                DictionaryExporter.restoreDictionaryM3IModelState( dictFilePath ) );


            this.configureCodeGenSettings( modelName );



            codeGenFolder = Simulink.fileGenControl( 'getConfig' ).CodeGenFolder;
            [ ~, dictionaryFolderName ] = fileparts( this.InterfaceDictAPI.DictionaryFileName );
            dstFolder = fullfile( codeGenFolder, dictionaryFolderName );
            if ~( exist( dstFolder, 'dir' ) == 7 )
                mkdir( dstFolder );
            end

            restoreFolderState = DictionaryExporter.cdIntoTempFolder(  );%#ok<NASGU>



            logsInterceptor = Simulink.output.registerProcessor(  ...
                Simulink.output.VoidInterceptorCb(  ) );%#ok<NASGU>
            try
                evalc( [ 'rtwbuild(''', modelName, ''')' ] );
            catch causeExp
                if this.IsInterfaceDictUIContext
                    commandlineMsg = DAStudio.message( 'autosarstandard:exporter:InterfaceDictFailedToExportAppend1' );
                else
                    commandlineMsg = DAStudio.message( 'autosarstandard:exporter:InterfaceDictFailedToExportAppend2' );
                end
                id = 'autosarstandard:exporter:InterfaceDictFailedToExport';
                newME = MException( id, DAStudio.message( id, this.InterfaceDictAPI.DictionaryFileName, commandlineMsg ) );
                newME = newME.addCause( causeExp );
                throw( newME );
            end



            restoreDictionaryM3IModel.delete(  );



            srcFolder = fullfile( pwd, dictionaryFolderName );
            if exist( srcFolder, 'dir' )
                existingArxmlFiles = DictionaryExporter.collectFilesInFolder( srcFolder, '.arxml' );
                cellfun( @( x )delete( x ), existingArxmlFiles );
            end


            autosar.mm.arxml.Exporter.exportSharedAUTOSARDictionary( modelName,  ...
                dictFilePath, IsStandaloneDictExport = true );


            existingArxmlFiles = DictionaryExporter.collectFilesInFolder( dstFolder, '.arxml' );
            cellfun( @( x )delete( x ), existingArxmlFiles );


            copyfile( srcFolder, dstFolder, 'f' );


            buildDir = RTW.getBuildDir( modelName );
            stubSrcFolder = fullfile( buildDir.BuildDirectory, 'stub' );
            stubDstFolder = fullfile( dstFolder, 'stub' );
            copyfile( fullfile( stubSrcFolder, 'Rte_Type.h' ), stubDstFolder, 'f' );


            staticRTEHeaderPath = autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderPath;
            staticRTEHeaderFiles = autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderFiles;
            for fIdx = 1:length( staticRTEHeaderFiles )
                copyfile( fullfile( staticRTEHeaderPath, staticRTEHeaderFiles{ fIdx } ), stubDstFolder, 'f' );
            end
        end

        function [ modelName, destroyTempModel ] = createTemporaryModelMappedToClassicAUTOSAR( this )


            mdlH = load_system( Simulink.createFromTemplate( 'autosar_classic_model.sltx' ) );
            modelName = get_param( mdlH, 'Name' );
            Simulink.BlockDiagram.deleteContents( modelName );
            set_param( modelName, 'DataDictionary', this.InterfaceDictAPI.DictionaryFileName );
            autosar.api.create( modelName, 'init', DisableM3IListeners = true );
            set_param( modelName, 'Tag', autosar.dictionary.internal.DictionaryExporter.TempHiddenModelTag );



            sharedM3IModel = autosar.dictionary.Utils.getM3IModelForDictionaryFile( this.InterfaceDictAPI.filepath );
            dictSchemaVer = autosar.ui.utils.getAutosarSchemaVersion( sharedM3IModel );
            set_param( modelName, 'AutosarSchemaVersion', dictSchemaVer );

            destroyTempModel = onCleanup( @(  )close_system( modelName, 0 ) );
        end
    end

    methods ( Static )
        function tf = isTempHiddenModelForDictExport( modelName )
            tf = strcmp( get_param( modelName, 'Tag' ),  ...
                autosar.dictionary.internal.DictionaryExporter.TempHiddenModelTag );
        end
    end

    methods ( Access = private, Static )
        function restoreFolderState = cdIntoTempFolder(  )


            origDir = pwd;
            restoreFolderState.restoreLocation = onCleanup( @(  )cd( origDir ) );
            tempDir = tempname;
            mkdir( tempDir );
            origPath = addpath( origDir );
            restoreFolderState.restorePath = onCleanup( @(  )path( origPath ) );
            cd( tempDir );



            origCfg = Simulink.fileGenControl( 'getInternalConfig' );
            if ~strcmp( origCfg.CodeGenFolder, pwd )
                restoreFolderState.restoreFileGenControl = onCleanup( @(  ) ...
                    Simulink.fileGenControl( 'setConfig', 'config', origCfg ) );
                Simulink.fileGenControl( 'set', 'CodeGenFolder', tempDir );
                Simulink.fileGenControl( 'set', 'CacheFolder', tempDir );
            end

            restoreFolderState.cleanupTempFolder = onCleanup( @(  )rmdir( tempDir, 's' ) );
        end


        function restoreDictionaryM3IModelState( dictFilePath )



            import autosar.dictionary.internal.DictionaryExporter

            m3iModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictFilePath );
            m3iInterfaces = autosar.mm.Model.findObjectByMetaClass( m3iModel,  ...
                Simulink.metamodel.arplatform.interface.SenderReceiverInterface.MetaClass );
            if ~m3iInterfaces.isEmpty(  )

                reRegisterListener = autosarcore.unregisterListenerCBTemporarily( m3iModel );%#ok<NASGU>
                tran = M3I.Transaction( m3iModel );
                for idx = 1:m3iInterfaces.size
                    m3iInterface = m3iInterfaces.at( idx );
                    if startsWith( m3iInterface.Name, DictionaryExporter.TempPortName )
                        m3iInterface.destroy(  );
                    end
                end
                tran.commit(  );
            end
        end

        function arxmlFiles = collectFilesInFolder( folder, extension )
            arxmlFiles = {  };
            files = dir( fullfile( folder, [ '*', extension ] ) );
            for fileIdx = 1:length( files )
                file = fullfile( files( fileIdx ).folder, files( fileIdx ).name );
                arxmlFiles{ end  + 1 } = file;%#ok<AGROW>
            end
        end

        function isBSWType = isBSWEnumType( datatypeName )

            isBSWType = any( strcmp( datatypeName, { 'Std_ReturnType',  ...
                'NvM_RamBlockStatusType', 'NvM_RequestResultType',  ...
                'Dem_EventStatusType', 'Dem_DTCFormatType',  ...
                'Dem_OperationCycleStateType', 'Dem_DebouncingStateType',  ...
                'Dem_IumprDenomCondStatusType', 'Dem_DTRControlType',  ...
                'Dem_IndicatorStatusType' } ) );
        end
    end
end




% Decoded using De-pcode utility v1.2 from file /tmp/tmpipWlKf.p.
% Please follow local copyright laws when handling this file.

