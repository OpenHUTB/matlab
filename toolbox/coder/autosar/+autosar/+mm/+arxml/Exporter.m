classdef Exporter < handle

    properties ( Hidden, Constant )
        StubFolderName = 'stub';
    end

    properties ( GetAccess = private, SetAccess = private )
        model;
        exporter;
        mainFileName;
        xsdMajor;
        xsdMinor;
        xsdRev;
        xsdUrl;
        xsdVer;
        info;
        debug;
        IsModelTesterCaller;
    end

    properties ( GetAccess = public, SetAccess = private )
        useUUID;
        xmlValidate;
    end

    methods ( Access = public )



        function self = Exporter( model, varargin )

            self.model = model;
            self.mainFileName = '';
            self.xsdMajor = [  ];
            self.xsdMinor = [  ];
            self.xsdRev = [  ];
            self.xsdUrl = [  ];
            self.xsdVer = [  ];
            self.info = [  ];
            self.debug = false;
            self.useUUID = true;
            self.xmlValidate = false;
            self.exporter = [  ];
            s = dbstack;
            self.IsModelTesterCaller = any( strcmp( { s.file }, 'ModelTester.m' ) );
            self.setup( varargin{ : } );
        end



        function setup( self, varargin )

            self.info.xmlOpts = [  ];
            self.info.biObj = [  ];
            self.info.Name = '';
            self.info.ExportedArxmlFolder = '';
            self.mainFileName = 'out.arxml';

            if nargin > 1
                if isstruct( varargin{ 1 } )
                    self.info = varargin{ 1 };
                    xmlOpts = self.info.xmlOpts;
                    self.setSchema( xmlOpts.SchemaVersion );

                    if ~self.info.WritingSharedDictionary
                        self.defaultCompPackages(  );
                    end



                    self.mainFileName = self.getMainArxmlFileName(  );


                    self.splitPackagedElements(  );
                else

                    self.setSchema( varargin{ : } );
                end
            else
                self.setSchema(  );
            end

            if ~isempty( self.info.Name )
                self.setModelName( self.info.Name );
            end

            if ~isempty( self.info.biObj ) && ~self.info.WritingSharedDictionary
                buildInfo = self.info.biObj;
                hasAUTOSAR4p0CRL = strcmp( self.info.CodeReplacementLibrary, 'AUTOSAR 4.0' );
                files = arxml.exporter.pGetSourceFiles( buildInfo, hasAUTOSAR4p0CRL );
                self.setCodeDescriptorFiles( files{ : } );
            end
        end

        function defaultCompPackages( self )
            xmlOpts = self.info.xmlOpts;
            bhvName = xmlOpts.BehaviorName;
            implName = xmlOpts.ImplementationName;
            implPkg = self.getPackageName( implName );
            compName = xmlOpts.ComponentName;

            compObj = autosar.mm.Model.findChildByName( self.model, compName );
            if isa( compObj, 'Simulink.metamodel.arplatform.composition.CompositionComponent' )

                return ;
            end






            bhvs = autosar.mm.Model.findChildByTypeName( self.model, 'Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior' );
            if self.xsdMajor < 4 && length( bhvs ) == 1
                self.mapObjToAutosarPath( bhvs{ 1 }, bhvName );
            end



            self.setImplementationPkgName( implPkg );
            if compObj.isvalid(  ) && isa( compObj, 'Simulink.metamodel.arplatform.component.Component' )
                self.mapObjToAutosarPath( compObj, implName, 'IMPL' );
            end
        end

        function splitPackagedElements( self )
            name = self.info.Name;
            xmlOpts = self.info.xmlOpts;
            arRoot = self.model.RootPackage.front(  );

            if strcmp( self.info.ArxmlFilePackaging, 'Modular' ) && ( self.xsdMajor < 4 ) &&  ...
                    ~isempty( xmlOpts.BehaviorName )
                self.split( xmlOpts.BehaviorName, [ name, '_behavior.arxml' ] );
            end

            if isempty( self.info.M3ISeqOfPackagedElmsToWrite )

                self.doSplitAllPackagedElements( arRoot );
            else

                self.doSplitPackagedElements(  ...
                    arRoot,  ...
                    self.info.M3ISeqOfPackagedElmsToWrite,  ...
                    self.info.ElmQNameToFileMap );
            end
        end

        function pkgName = getPackageName( ~, qname )
            s = find( qname == '/' );
            pkgName = qname( 1:s( end  ) - 1 );
        end



        function setOptions( self, varargin )
            argParser = inputParser(  );
            argParser.addParameter( 'debug', false, @( x )( islogical( x ) || ( x == 1 ) || ( x == 0 ) ) );
            argParser.addParameter( 'UseUUID', true, @( x )( islogical( x ) || ( x == 1 ) || ( x == 0 ) ) );
            argParser.addParameter( 'XmlValidate', false, @( x )( islogical( x ) || ( x == 1 ) || ( x == 0 ) ) );
            argParser.parse( varargin{ : } )

            self.debug = argParser.Results.debug;
            self.useUUID = argParser.Results.UseUUID;
            self.xmlValidate = argParser.Results.XmlValidate;
        end



        function setModelName( self, modelName )
            self.exporter.setModelName( modelName );
        end

        function setBehaviorPkgName( self, behaviorPkgName )
            self.exporter.setBehaviorPkgName( behaviorPkgName );
        end

        function setInterfacePkgName( self, interfacePkgName )
            self.exporter.setInterfacePkgName( interfacePkgName );
        end

        function setDataTypesPkgName( self, dataTypesPkgName )
            self.exporter.setDataTypesPkgName( dataTypesPkgName );
        end

        function setSemanticsPkgName( self, semanticsPkgName )
            self.exporter.setSemanticsPkgName( semanticsPkgName );
        end

        function setConstantSpecPkgName( self, constantSpecPkgName )
            self.exporter.setConstantSpecPkgName( constantSpecPkgName );
        end

        function setImplementationPkgName( self, implementationPkgName )
            self.exporter.setImplementationPkgName( implementationPkgName );
        end

        function setCodeDescriptorFiles( self, varargin )
            m = self.model.modelM3I;
            ss = M3I.SequenceOfString.make( m );
            for i = 1:length( varargin )
                ss.append( varargin{ i } );
            end
            self.exporter.setCodeDescriptorFiles( ss );
        end

        function setMaxShortNameLength( self, maxShortNameLength )
            self.exporter.setMaxShortNameLength( maxShortNameLength );
        end

        function setIsAdaptiveExport( self, isAdaptiveExport )
            self.exporter.setIsAdaptiveExport( isAdaptiveExport );
        end

        function setIsRowMajorArrayLayout( self, isRowMajorArrayLayout )
            self.exporter.setIsRowMajorArrayLayout( isRowMajorArrayLayout );
        end


        function mapQnameToAutosarPath( self, qname, autosarPath, context )
            if nargin < 4
                context = '';
            end
            self.exporter.mapQnameToAutosarPath( qname, autosarPath, context );
        end

        function mapObjToAutosarPath( self, obj, autosarPath, context )
            if nargin < 4
                context = '';
            end
            self.exporter.mapNamedElementToAutosarPath( obj, autosarPath, context );
        end



        function split( self, elem, fileName, context )
            if nargin < 4
                context = '';
            end





            if strcmpi( fileName, self.mainFileName )
                return ;
            end

            m = self.model.modelM3I;
            if ischar( elem ) || isStringScalar( elem )
                ss = M3I.SequenceOfString.make( m );
            else
                ss = M3I.SequenceOfClassObject.make( m );
            end
            ss.append( elem );
            fullFilePath = fullfile( self.info.ExportedArxmlFolder, fileName );
            self.exporter.split( ss, fullFilePath, context );
        end



        function checkSchemaVersion( self )






            major = sprintf( '%d', self.xsdMajor );
            minor = sprintf( '%d', self.xsdMinor );
            revision = sprintf( '%d', self.xsdRev );
            schemaFileLocation = autosar.mm.arxml.SchemaUtil.getSchemaFile( major, minor, revision );
            if isempty( schemaFileLocation )
                autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage( 'error', self.xsdVer );
            end
        end



        function ret = write( self, fileName )
            if nargin < 2
                fileName = self.mainFileName;
            end
            t1Impl = [  ];
            t2Impl = [  ];
            t3Impl = [  ];
            tDbgImpl = [  ];

            self.checkSchemaVersion(  );




            factory = M3I.XmiWriterFactory(  );

            if self.xsdMajor == 49
                t1 = M3I.Transformer(  );
                t1Impl = autosar.mm.arxml.XformVer49To49( self.xsdVer, t1 );
                factory.appendTransformer( t1 );
            elseif self.xsdMajor == 48
                t1 = M3I.Transformer(  );
                t1Impl = autosar.mm.arxml.XformVer49To48( self.xsdVer, t1 );
                factory.appendTransformer( t1 );
            elseif self.xsdMajor == 47
                t1 = M3I.Transformer(  );
                t1Impl = autosar.mm.arxml.XformVer48To47( self.xsdVer, self.model, t1 );
                factory.appendTransformer( t1 );
            elseif self.xsdMajor == 46
                t1 = M3I.Transformer(  );
                t1Impl = autosar.mm.arxml.XformVer47To46( self.xsdVer, self.model, t1 );
                factory.appendTransformer( t1 );

            elseif self.xsdMajor >= 40
                t1 = M3I.Transformer(  );
                t1Impl = autosar.mm.arxml.XformVer43To43( self.xsdVer, t1 );
                factory.appendTransformer( t1 );
            elseif self.xsdMajor >= 4


                major = 4;
                minor = 3;
                if self.xsdMajor == major && self.xsdMinor == minor


                    t1 = M3I.Transformer(  );
                    t1Impl = autosar.mm.arxml.XformVer43To43( self.xsdVer, t1 );
                    factory.appendTransformer( t1 );

                else
                    if self.xsdMinor < minor


                        t3 = M3I.Transformer(  );
                        t3Impl = autosar.mm.arxml.XformVer43To42( self.xsdVer, t3 );
                        factory.appendTransformer( t3 );
                        minor = 2;
                    end

                    if self.xsdMinor < minor


                        t2 = M3I.Transformer(  );
                        t2Impl = autosar.mm.arxml.XformVer42To41( self.xsdVer, t2 );
                        factory.appendTransformer( t2 );
                        minor = 1;
                    end

                    if self.xsdMinor < minor


                        t1 = M3I.Transformer(  );
                        t2Impl = autosar.mm.arxml.XformVer41To40( self.xsdVer, t1 );
                        factory.appendTransformer( t1 );

                    end

                end
            else
                assert( false, '2.1/3.x Export no longer supported' );
            end

            if self.debug
                tDbg = M3I.Transformer(  );
                tDbgImpl = autosar.mm.arxml.XformEcho( self.xsdVer, tDbg );
                factory.appendTransformer( tDbg );
            end

            try
                autosarcore.unregisterListenerCB( self.model );
                fullFilePath = fullfile( self.info.ExportedArxmlFolder, fileName );
                ret = self.exporter.write( self.model, fullFilePath, factory );
                autosar.ui.utils.registerListenerCB( self.model );
                delete( t1Impl );
                delete( t2Impl );
                delete( t3Impl );
                delete( tDbgImpl );
                delete( factory );
            catch me
                delete( t1Impl );
                delete( t2Impl );
                delete( t3Impl );
                delete( tDbgImpl );
                delete( factory );
                rethrow( me );
            end
        end
    end

    methods ( Hidden = true )

        function [ major, minor, rev ] = getMajorMinorRev( this )
            major = this.xsdMajor;
            minor = this.xsdMinor;
            rev = this.xsdRev;
        end
    end

    methods ( Access = private )



        function setSchema( self, varargin )
            major = [  ];
            minor = [  ];
            rev = [  ];
            if nargin ~= 1
                if ( ischar( varargin{ 1 } ) || isStringScalar( varargin{ 1 } ) ) &&  ...
                        ~contains( varargin{ 1 }, '-' )

                    verStr = varargin{ 1 };
                    output = regexp( verStr, '(?<major>\d*)\.*(?<minor>\d*)\.*(?<rev>\d*)', 'names' );

                    assert( ~isempty( output.major ), 'Could not find major version in string %s', verStr );
                    major = str2num( output.major );%#ok<ST2NM>
                    minor = str2num( output.minor );%#ok<ST2NM>
                    rev = str2num( output.rev );%#ok<ST2NM>
                else

                    major = varargin{ 1 };
                    if nargin > 2
                        minor = varargin{ 2 };
                        if nargin > 3
                            rev = varargin{ 3 };
                        end
                    end
                end
            end
            [ major, minor, rev ] = autosar.mm.arxml.Exporter.getMajorMinorRevDefaults( major, minor, rev );

            self.xsdMajor = major;
            self.xsdMinor = minor;
            self.xsdRev = rev;

            if isempty( rev ) || strcmp( rev, 'undefined' )
                self.xsdVer = sprintf( '%d.%d', major, minor );
            elseif major < 40
                self.xsdVer = sprintf( '%d.%d.%d', major, minor, rev );
            else
                self.xsdVer = sprintf( '%05d', major );
            end
            if major == 2 && minor == 0
                self.xsdUrl = 'http://autosar.org';
            elseif major < 4
                self.xsdUrl = sprintf( 'http://autosar.org/%d.%d.%d', major, minor, rev );
            else
                self.xsdUrl = sprintf( 'http://autosar.org/schema/r%d.%d', major, minor );
            end

            assert( isempty( self.exporter ), 'ArxmlExporter should not have been instantiated' );
            assert( self.xsdMajor >= 4, 'ArxmlExporter only supports AUTOSAR 4.x export' );

            self.exporter = Simulink.metamodel.arplatform.ArxmlExporter(  );
            self.exporter.setSchemaVersion( self.xsdMajor, self.xsdMinor, self.xsdRev );

        end

        function doSplitAllPackagedElements( self, m3iPkg )
            for ii = 1:m3iPkg.packagedElement.size(  )
                m3iPkgElm = m3iPkg.packagedElement.at( ii );

                if isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.Package' )

                    self.doSplitAllPackagedElements( m3iPkgElm );
                else
                    arxmlFileName = autosar.mm.arxml.Exporter.getArxmlFileForPackagedElement(  ...
                        m3iPkgElm, self.getArxmlFilePrefix(  ), self.info.ElmQNameToFileMap );


                    if self.IsModelTesterCaller && autosar.mm.arxml.Exporter.isExternalReference( m3iPkgElm )


                        arxmlFileName = autosar.mm.arxml.Exporter.getArxmlFileForPackagedElementBasedOnType(  ...
                            m3iPkgElm, self.getArxmlFilePrefix(  ) );
                    end

                    self.split( m3iPkgElm, arxmlFileName );
                end
            end
        end


        function doSplitPackagedElements( self, m3iPkg, m3iSeqOfPackagedElmsToWrite, elmQNameToFileMap )
            for ii = 1:m3iPkg.packagedElement.size(  )
                m3iPkgElm = m3iPkg.packagedElement.at( ii );

                if isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.Package' )

                    self.doSplitPackagedElements( m3iPkgElm, m3iSeqOfPackagedElmsToWrite, elmQNameToFileMap );
                else
                    if autosar.mm.Model.findObjectIndexInSequence( m3iSeqOfPackagedElmsToWrite, m3iPkgElm ) ~=  - 1
                        pkgElmQName = autosar.api.Utils.getQualifiedName( m3iPkgElm );



                        assert( elmQNameToFileMap.isKey( pkgElmQName ),  ...
                            'could not find ARXML file for %s', pkgElmQName );
                        arxmlFileName = elmQNameToFileMap( pkgElmQName );
                    else
                        arxmlFileName = autosar.mm.arxml.Exporter.getFileNameForDiscardedArxmlContent( self.info.Name );
                    end

                    self.split( m3iPkgElm, arxmlFileName );
                end
            end
        end


        function fileName = getMainArxmlFileName( self )
            isModularPackaging = strcmp( self.info.ArxmlFilePackaging, 'Modular' );
            fileNamePrefix = self.getArxmlFilePrefix(  );

            if self.info.WritingSharedDictionary
                fileName = autosar.mm.arxml.Exporter.getSharedDictMainArxmlFileName(  ...
                    fileNamePrefix, true );
            else
                m3iMappedComponent = autosar.mm.Model.findChildByName( self.model, self.info.xmlOpts.ComponentName );
                if isa( m3iMappedComponent, 'Simulink.metamodel.arplatform.composition.CompositionComponent' )
                    fileName = autosar.mm.arxml.Exporter.getFileNameForDiscardedArxmlContent( fileNamePrefix );
                elseif ~isempty( self.info.M3ISeqOfPackagedElmsToWrite )
                    fileName = autosar.mm.arxml.Exporter.getImplementationArxmlFileName( fileNamePrefix, true );
                elseif isa( m3iMappedComponent, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )

                    fileName = autosar.mm.arxml.Exporter.getComponentArxmlFileName( fileNamePrefix, isModularPackaging );
                else
                    if isModularPackaging
                        fileName = autosar.mm.arxml.Exporter.getImplementationArxmlFileName(  ...
                            fileNamePrefix, isModularPackaging );
                    else
                        fileName = [ fileNamePrefix, '.arxml' ];
                    end
                end
            end
        end

        function arxmlFilePrefix = getArxmlFilePrefix( self )
            arxmlFilePrefix = self.info.ArxmlFilePrefix;
        end
    end

    methods ( Static, Access = private )

        function isPlatformTypesPackage = isPlatformTypesPackage( m3iPkgElm )
            import autosar.mm.util.XmlOptionsAdapter;

            isPlatformTypesPackage = false;


            if slfeature( 'AUTOSARPlatformTypesRefAndNativeDecl' )


                if ~isempty( m3iPkgElm.getExternalToolInfo( 'ARXML_ArxmlFileInfo' ).externalId )
                    return ;
                end

                arRoot = m3iPkgElm.rootModel.RootPackage.front(  );
                platformTypesPackageName = XmlOptionsAdapter.get( arRoot, 'PlatformDataTypePackage' );
                isPlatformTypesPackage = ~isempty( platformTypesPackageName ) && startsWith( autosar.api.Utils.getQualifiedName( m3iPkgElm ), platformTypesPackageName );
            end
        end

        function arxmlFileName = getArxmlFileForPackagedElementBasedOnType(  ...
                m3iPkgElm, fileNamePrefix )

            import autosar.mm.arxml.Exporter;



            arxmlFileName = '';
            pkgElementClass = m3iPkgElm.MetaClass.qualifiedName;

            isPlatformTypesPackage = Exporter.isPlatformTypesPackage( m3iPkgElm );


            isModularPackaging = Exporter.isModularPackaging( m3iPkgElm );

            if autosar.mm.arxml.Exporter.isExternalReference( m3iPkgElm )

                arxmlFileName = Exporter.getExternalReferenceArxmlFileName( fileNamePrefix );

            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.interface.PortInterface' )

                isService = isprop( m3iPkgElm, 'IsService' ) && m3iPkgElm.IsService;
                arxmlFileName = Exporter.getInterfaceArxmlFileName( fileNamePrefix, isModularPackaging, isService );

            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.Machine' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.DltLogChannelToProcessMapping' )
                arxmlFileName = Exporter.getMachineManifestArxmlFileName(  );

            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.Process' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.ProcessDesign' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.Executable' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.StartupConfig' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.StartupConfigSet' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.ProcessToMachineMappingSet' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.PersistencyPortToKeyValueDatabaseMapping' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.PersistencyKeyValueDatabase' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.manifest.FunctionGroupSet' )
                arxmlFileName = Exporter.getExecutionManifestArxmlFileName( fileNamePrefix );

            elseif startsWith( pkgElementClass, 'Simulink.metamodel.arplatform.manifest' )
                arxmlFileName = Exporter.getServiceInstanceManifestArxmlFileName( fileNamePrefix );
            elseif startsWith( pkgElementClass, 'Simulink.metamodel.types' ) ||  ...
                    startsWith( pkgElementClass, 'Simulink.metamodel.arplatform.variant' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.DataTypeMappingSet' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.ModeDeclarationGroup' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.ModeRequestTypeMap' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.common.SwAddrMethod' )

                arxmlFileName = Exporter.getDataTypeArxmlFileName( fileNamePrefix, isModularPackaging, isPlatformTypesPackage );

            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.component.Component' )
                arxmlFileName = Exporter.getComponentArxmlFileName( fileNamePrefix, isModularPackaging );
            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.timingExtension.SwcTiming' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.timingExtension.VfbTiming' )
                arxmlFileName = Exporter.getTimingExtensionArxmlFileName( fileNamePrefix, isModularPackaging );
            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.ecuc.EcucModuleConfigurationValues' )
                arxmlFileName = Exporter.getEcucArxmlFileName(  );
            elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.system.System' ) ||  ...
                    isa( m3iPkgElm, 'Simulink.metamodel.arplatform.system.EcuInstance' )
                arxmlFileName = Exporter.getSystemArxmlFileName( fileNamePrefix, isModularPackaging );
            else
                assert( false, 'Unexpected element "%s" of type "%s".',  ...
                    autosar.api.Utils.getQualifiedName( m3iPkgElm ),  ...
                    pkgElementClass );
            end

        end

        function [ arxmlFileName, preserveFolder ] = getArxmlFileForPackagedElementBasedOnImport( m3iPkgElm )


            arxmlFileName = '';
            preserveFolder = false;
            tok = regexp( m3iPkgElm.getExternalToolInfo( 'ARXML_ArxmlFileInfo' ).externalId, '#', 'split' );
            if iscell( tok ) && ( length( tok ) == 3 )
                preserveFolder = ( tok{ 1 } == '2' );
                arxmlFileName = tok{ 3 };
            end

            if ( contains( arxmlFileName, '+autosar' ) && contains( arxmlFileName, '+bsw' ) )



                arxmlFileName = '';
            end
        end



        function fileName = getFileNameForDiscardedArxmlContent( fileNamePrefix )
            fileName = [ fileNamePrefix, '_arxml_to_delete' ];
        end

        function fileName = getSharedDictMainArxmlFileName( fileNamePrefix, isModularPackaging )
            fileName = autosar.mm.arxml.Exporter.getDataTypeArxmlFileName( fileNamePrefix, isModularPackaging, false );
        end

        function fileName = getImplementationArxmlFileName( fileNamePrefix, isModularPackaging )
            if isModularPackaging
                fileName = [ fileNamePrefix, '_implementation.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getDataTypeArxmlFileName( fileNamePrefix, isModularPackaging, isPlatformTypesPackage )
            if isPlatformTypesPackage && isModularPackaging
                fileName = [ autosar.mm.arxml.Exporter.StubFolderName, '/', fileNamePrefix, '_platformtypes.arxml' ];
            elseif isModularPackaging
                fileName = [ fileNamePrefix, '_datatype.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getExecutionManifestArxmlFileName( fileNamePrefix )

            fileName = [ fileNamePrefix, '_ExecutionManifest.arxml' ];

        end

        function fileName = getEcucArxmlFileName(  )
            fileName = 'ECUC.arxml';
        end

        function fileName = getServiceInstanceManifestArxmlFileName( fileNamePrefix )

            fileName = [ fileNamePrefix, '_ServiceInstanceManifest.arxml' ];

        end

        function fileName = getInterfaceArxmlFileName( fileNamePrefix, isModularPackaging, isService )
            if isService
                fileName = [ autosar.mm.arxml.Exporter.StubFolderName, '/', fileNamePrefix, '_external_interface.arxml' ];
            elseif isModularPackaging
                fileName = [ fileNamePrefix, '_interface.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getExternalReferenceArxmlFileName( fileNamePrefix )
            fileName = [ autosar.mm.arxml.Exporter.StubFolderName, '/', fileNamePrefix, '_referenced_elements.arxml' ];
        end

        function autosarInfo = createAutosarInfo( modelName, varargin )


            p = inputParser;
            p.addRequired( 'ModelName', @( x )ischar( x ) );
            p.addParameter( 'ArxmlFilePrefix', modelName, @( x )ischar( x ) );
            p.addParameter( 'BuildInfo', RTW.BuildInfo.empty, @( x )( isa( x, 'RTW.BuildInfo' ) ) );
            p.addParameter( 'ExportedArxmlFolder', autosar.mm.arxml.Exporter.getModelArxmlFolder( modelName ),  ...
                @( x )ischar( x ) );
            p.addParameter( 'M3ISeqOfPackagedElmsToWrite', M3I.SequenceOfClassObject.empty(  ),  ...
                @( x )( isa( x, 'M3I.SequenceOfClassObject' ) ) );


            p.addParameter( 'ElmQNameToFileMap', containers.Map.empty,  ...
                @( x )( isa( x, 'containers.Map' ) ) );
            p.addParameter( 'WritingSharedDictionary', false, @( x )islogical( x ) );
            p.parse( modelName, varargin{ : } );


            autosarInfo.xmlOpts = arxml.arxml_private( 'p_config_xml_adapter', 'get_options', get_param( modelName, 'handle' ) );
            autosarInfo.Name = modelName;
            autosarInfo.ArxmlFilePrefix = p.Results.ArxmlFilePrefix;
            autosarInfo.biObj = p.Results.BuildInfo;
            autosarInfo.ExportedArxmlFolder = p.Results.ExportedArxmlFolder;
            autosarInfo.CodeReplacementLibrary = get_param( modelName, 'CodeReplacementLibrary' );
            autosarInfo.ElmQNameToFileMap = p.Results.ElmQNameToFileMap;
            autosarInfo.M3ISeqOfPackagedElmsToWrite = p.Results.M3ISeqOfPackagedElmsToWrite;
            autosarInfo.WritingSharedDictionary = p.Results.WritingSharedDictionary;
            dataobj = autosar.api.getAUTOSARProperties( modelName, true );
            autosarInfo.ArxmlFilePackaging = dataobj.get( 'XmlOptions', 'ArxmlFilePackaging' );
        end

        function isModular = isModularPackaging( m3iPkgElm )



            if autosar.dictionary.Utils.isSharedM3IModel( m3iPkgElm.rootModel )

                isModular = true;
            else


                m3iRoot = m3iPkgElm.rootModel.RootPackage.front(  );
                if autosar.dictionary.Utils.hasReferencedModels( m3iPkgElm.rootModel )
                    if ~autosar.composition.Utils.isAUTOSARArchModel( m3iPkgElm.rootModel )
                        sharedM3IModel = autosar.dictionary.Utils.getUniqueReferencedModel( m3iPkgElm.rootModel );
                        m3iRoot = sharedM3IModel.RootPackage.front(  );
                    end
                end
                isModular = m3iRoot.ArxmlFilePackaging == Simulink.metamodel.arplatform.common.ArxmlFilePackagingKind.Modular;
            end
        end
    end

    methods ( Static )
        function [ major, minor, rev ] = getMajorMinorRevDefaults( major, minor, rev )


            if isempty( major )
                schemaVer = arxml.getDefaultSchemaVersion(  );
            elseif isempty( minor )
                if ischar( major ) && contains( major, '-' )
                    schemaVer = major;
                else
                    schemaVer = sprintf( '%d', major );
                end
            elseif isempty( rev )
                schemaVer = sprintf( '%d.%d', major, minor );
            else

                return ;
            end

            switch schemaVer
                case { '4.0' }
                    major = 4;
                    minor = 0;
                    rev = 3;
                case { '4.1' }
                    major = 4;
                    minor = 1;
                    rev = 3;
                case { '4.2' }
                    major = 4;
                    minor = 2;
                    rev = 2;
                case { '4', '4.3' }
                    major = 4;
                    minor = 3;
                    rev = 1;
                case { 'R18-10' }
                    major = 46;
                    minor = 0;
                    rev = 0;
                case { 'R19-03', '4.4' }
                    major = 47;
                    minor = 0;
                    rev = 0;
                case { 'R19-11' }
                    major = 48;
                    minor = 0;
                    rev = 0;
                case { 'R20-11' }
                    major = 49;
                    minor = 0;
                    rev = 0;
                otherwise
                    assert( false, 'Unknown schema version %s in autosar.mm.arxml.Exporter', schemaVer );
            end
        end

    end

    methods ( Static, Access = public )
        function setDefaultArxmlFileForM3iElem( m3iElem, arxmlFileName )

            tok = regexp( m3iElem.getExternalToolInfo( 'ARXML_ArxmlFileInfo' ).externalId, '#', 'split' );
            if ~iscell( tok ) || length( tok ) ~= 3
                m3iElem.setExternalToolInfo( M3I.ExternalToolInfo( 'ARXML_ArxmlFileInfo', sprintf( '2#FileName#%s', arxmlFileName ) ) );
            end
        end
        function fileName = getMachineManifestArxmlFileName(  )

            fileName = [ autosar.mm.arxml.Exporter.StubFolderName, '/', 'MachineManifest.arxml'; ];
        end
        function fileName = getComponentArxmlFileName( fileNamePrefix, isModularPackaging )
            if isModularPackaging
                fileName = [ fileNamePrefix, '_component.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getCompositionArxmlFileName( fileNamePrefix, isModularPackaging )
            if isModularPackaging
                fileName = [ fileNamePrefix, '_composition.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getTimingExtensionArxmlFileName( fileNamePrefix, isModularPackaging )
            if isModularPackaging
                fileName = [ fileNamePrefix, '_timing.arxml' ];
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end

        function fileName = getSystemArxmlFileName( fileNamePrefix, isModularPackaging )
            if isModularPackaging
                fileName = 'System.arxml';
            else
                fileName = [ fileNamePrefix, '.arxml' ];
            end
        end



        function fileName = getArxmlFileForPackagedElement( m3iPkgElm,  ...
                fileNamePrefix, elmQNameToFileMap )

            if nargin < 3
                elmQNameToFileMap = containers.Map.empty(  );
            end



            [ isPkgElmImported, fileName, preserveFolder ] = autosar.mm.arxml.Exporter.isPackagedElementImported( m3iPkgElm );
            if isPkgElmImported

                if ~preserveFolder
                    [ ~, n, e ] = fileparts( fileName );
                    fileName = [ n, e ];
                end

                return ;
            else







                if isa( m3iPkgElm, 'Simulink.metamodel.arplatform.component.Component' ) &&  ...
                        ~elmQNameToFileMap.isempty(  )
                    if elmQNameToFileMap.isKey( autosar.api.Utils.getQualifiedName( m3iPkgElm ) )


                        fileName = elmQNameToFileMap( autosar.api.Utils.getQualifiedName( m3iPkgElm ) );
                    else
                        fileName = autosar.mm.arxml.Exporter.getFileNameForDiscardedArxmlContent(  ...
                            fileNamePrefix );
                    end
                else

                    fileName = autosar.mm.arxml.Exporter.getArxmlFileForPackagedElementBasedOnType(  ...
                        m3iPkgElm, fileNamePrefix );
                end
            end
        end


        function [ isPkgElmImported, fileName, preserveFolder ] = isPackagedElementImported( m3iPkgElm )
            [ fileName, preserveFolder ] = autosar.mm.arxml.Exporter.getArxmlFileForPackagedElementBasedOnImport( m3iPkgElm );
            isPkgElmImported = ~isempty( fileName );
        end

        function seq = findByBaseType( seq, parent, type )
            try

                metaClass = feval( sprintf( '%s.MetaClass', type ) );

                m3iSeq = autosar.mm.Model.findObjectByMetaClass( parent, metaClass, true, true );
                for ii = 1:m3iSeq.size(  )
                    seq.append( m3iSeq.at( ii ) );
                end
            catch
            end
        end
        function ret = isAncestorOf( pkg, qname )

            if strcmp( pkg, qname )
                ret = true;
            else
                ancestor = [ pkg, '/' ];
                idx = strfind( qname, ancestor );
                ret = ~isempty( idx ) && idx( 1 ) == 1;
            end
        end
        function [ ret, val ] = isExternalReference( pkg )
            ret = false;
            val = 0;
            extraInfo = autosar.mm.Model.getExtraExternalToolInfo(  ...
                pkg, 'ARXML_IsReference', { 'IsReference' }, { '%s' } );
            if ~isempty( extraInfo.IsReference ) && ~strcmp( extraInfo.IsReference, '0' )
                val = str2double( extraInfo.IsReference );
                ret = true;
            end
        end
        function ret = hasExternalReference( arRoot )
            ret = false;
            extraInfo = autosar.mm.Model.getExtraExternalToolInfo(  ...
                arRoot, 'ARXML_HasExternalReference', { 'HasExternalReference' }, { '%s' } );
            if ~isempty( extraInfo.HasExternalReference ) && strcmp( extraInfo.HasExternalReference, '1' )
                ret = true;
            end
        end

        function arxmlDir = getModelArxmlFolder( modelName )
            bDir = RTW.getBuildDir( modelName );
            arxmlDir = bDir.BuildDirectory;
        end

        function arxmlDir = getModelArxmlStubFolder( modelName )
            arxmlDir = fullfile( autosar.mm.arxml.Exporter.getModelArxmlFolder( modelName ),  ...
                autosar.mm.arxml.Exporter.StubFolderName );
        end

        function exporter = createExporter( modelName, m3iModelToExport, autosarInfo )

            maxShortNameLength = get_param( modelName, 'AutosarMaxShortNameLength' );
            arrayLayout = get_param( modelName, 'ArrayLayout' );
            isRowMajorArrayLayout = strcmpi( arrayLayout, 'Row-major' );


            exporter = autosar.mm.arxml.Exporter( m3iModelToExport, autosarInfo );
            exporter.setMaxShortNameLength( maxShortNameLength );
            exporter.setIsAdaptiveExport( autosar.api.Utils.isMappedToAdaptiveApplication( modelName ) );
            exporter.setIsRowMajorArrayLayout( isRowMajorArrayLayout );
        end

        function exportModel( modelName, varargin )
            import autosar.mm.arxml.Exporter


            m3iModelToExport = autosar.api.Utils.m3iModel( modelName );
            autosarInfo = Exporter.createAutosarInfo( modelName, varargin{ : } );
            exporter = Exporter.createExporter( modelName, m3iModelToExport, autosarInfo );


            if ~autosar.composition.Utils.isModelInCompositionDomain( modelName )
                filesToDelete = autosar.api.internal.getExportedArxmlFileNames(  ...
                    modelName, 'IncludeStubFiles', true );

                for fileIdx = 1:length( filesToDelete )
                    fileToDelete = filesToDelete{ fileIdx };
                    if ( exist( fileToDelete, 'file' ) == 2 )
                        rtw_delete_file( fileToDelete );
                    end
                end
            end


            exporter.write(  );


            fileNamePrefix = modelName;
            fileToDelete = fullfile( autosarInfo.ExportedArxmlFolder,  ...
                Exporter.getFileNameForDiscardedArxmlContent( fileNamePrefix ) );
            if ( exist( fileToDelete, 'file' ) == 2 )
                rtw_delete_file( fileToDelete );
            end


            if ~Simulink.internal.isArchitectureModel( modelName, 'AUTOSARArchitecture' )
                if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels( m3iModelToExport )
                    sharedM3IModel = autosar.dictionary.Utils.getUniqueReferencedModel( m3iModelToExport );
                    dictFilePath = Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel( sharedM3IModel );
                    Exporter.exportSharedAUTOSARDictionary( modelName, dictFilePath );
                end
            end
        end

        function exportSharedAUTOSARDictionary( modelName, dictFilePath, namedargs )
            arguments
                modelName
                dictFilePath





                namedargs.IsStandaloneDictExport = false
            end

            import autosar.mm.arxml.Exporter

            [ ~, dictionaryName ] = fileparts( dictFilePath );
            dictionaryFolder = fullfile( RTW.getBuildDir( modelName ).CodeGenFolder, dictionaryName );

            if ~exist( dictionaryFolder, 'dir' )
                mkdir( dictionaryFolder );
            end

            dictionaryStubFolder = fullfile( dictionaryFolder, autosar.mm.arxml.Exporter.StubFolderName );
            if ~exist( dictionaryStubFolder, 'dir' )
                mkdir( dictionaryStubFolder );
            end



            origDir = cd( dictionaryFolder );
            restoreDir = onCleanup( @(  )cd( origDir ) );
            origPath = path;
            restorePath = onCleanup( @(  )path( origPath ) );
            addpath( origDir );


            m3iModelToExport = autosarcore.ModelUtils.getSharedElementsM3IModel( modelName );
            autosarInfo = Exporter.createAutosarInfo( modelName,  ...
                'ArxmlFilePrefix', dictionaryName,  ...
                'ExportedArxmlFolder', dictionaryFolder,  ...
                'WritingSharedDictionary', true );
            if namedargs.IsStandaloneDictExport

                autosarInfo.Name = '';
            end
            exporter = Exporter.createExporter( modelName, m3iModelToExport, autosarInfo );


            exporter.write(  );
        end




        function exportPackagedElements( modelName, m3iSeqOfPackagedElmsToWrite,  ...
                elmQNameToFileMap, arxmlFolder, buildInfo )
            import autosar.mm.arxml.Exporter;


            args = { 'M3ISeqOfPackagedElmsToWrite', m3iSeqOfPackagedElmsToWrite,  ...
                'ElmQNameToFileMap', elmQNameToFileMap,  ...
                'ExportedArxmlFolder', arxmlFolder,  ...
                'BuildInfo', buildInfo };


            m3iModelToExport = autosar.api.Utils.m3iModel( modelName );
            autosarInfo = Exporter.createAutosarInfo( modelName, args{ : } );
            exporter = Exporter.createExporter( modelName, m3iModelToExport, autosarInfo );


            exporter.write(  );


            fileNamePrefix = modelName;
            fileToDelete = fullfile( autosarInfo.ExportedArxmlFolder,  ...
                Exporter.getFileNameForDiscardedArxmlContent( fileNamePrefix ) );
            if ( exist( fileToDelete, 'file' ) == 2 )
                rtw_delete_file( fileToDelete );
            end
        end
    end
end



