





classdef CodeAnalyzer < sldv.code.CodeAnalyzer

    properties ( SetAccess = protected, GetAccess = public )
        IsCodeConfigExtracted logical = false
        CodeGenFolder = [  ]
        CodeGenFolderInfo = [  ]
        InTheLoopType = [  ]
        CoderConfig = [  ]
    end

    properties ( Hidden )
        AtsHarnessInfo = [  ]
    end

    properties ( SetAccess = protected, GetAccess = public, Transient = true )
        XilWrapperUtils = [  ]
    end

    methods



        function this = CodeAnalyzer( varargin )
            this@sldv.code.CodeAnalyzer( varargin{ : } );
            this.IsCodeConfigExtracted = false;
        end




        function that = shallowCopy( this )
            that = shallowCopy@sldv.code.CodeAnalyzer( this );
            copyCodeGenInfo( this, that );
        end




        function copyCodeGenInfo( this, that )
            that.IsCodeConfigExtracted = this.IsCodeConfigExtracted;
            that.CodeGenFolder = this.CodeGenFolder;
            that.CodeGenFolderInfo = this.CodeGenFolderInfo;
            that.InTheLoopType = this.InTheLoopType;
            that.CoderConfig = this.CoderConfig;
            that.AtsHarnessInfo = this.AtsHarnessInfo;
            that.XilWrapperUtils = this.XilWrapperUtils;
        end






        function removed = removeUnsupported( ~ )
            removed = {  };
        end




        function containerName = getInstanceContainerName( ~, instancePath )
            containerName = instancePath;
        end




        fullOk = runSldvAnalysis( this, options, varargin )





        function extractCodeConfig( this )
            if this.IsCodeConfigExtracted || isempty( this.ModelName )
                return
            end

            try
                cgDirInfo = RTW.getBuildDir( this.ModelName );
                switch lower( char( this.SimulationMode ) )
                    case { 'sil', 'modelreftopsil' }
                        cgDir = cgDirInfo.BuildDirectory;
                        inTheLoopType = rtw.pil.InTheLoopType.ModelBlockStandalone;
                        tgtType = 'NONE';
                    case 'modelrefsil'
                        cgDir = fullfile( cgDirInfo.CodeGenFolder, cgDirInfo.ModelRefRelativeBuildDir );
                        inTheLoopType = rtw.pil.InTheLoopType.ModelBlock;
                        tgtType = 'RTW';
                    otherwise
                        return
                end

                binfoMATFile = coderprivate.getBinfoMATFileAndCodeName( cgDir );
                infoStruct = coder.internal.infoMATFileMgr( 'loadPostBuild',  ...
                    'binfo', this.ModelName, tgtType, binfoMATFile, true );
                cgConfig = coder.connectivity.SimulinkCoderConfig( infoStruct, this.ModelName );
                this.IsCodeConfigExtracted = true;

            catch ME
                if sldv.code.internal.feature( 'disableErrorRecovery' )
                    rethrow( ME );
                end
                cgDir = [  ];
                cgDirInfo = [  ];
                inTheLoopType = [  ];
                cgConfig = [  ];
            end

            this.CodeGenFolder = cgDir;
            this.CodeGenFolderInfo = cgDirInfo;
            this.InTheLoopType = inTheLoopType;
            this.CoderConfig = cgConfig;
        end




        function [ cgDir, cgDirInfo, inTheLoopType ] = getCodeFolder( this )
            this.extractCodeConfig(  );
            cgDir = this.CodeGenFolder;
            cgDirInfo = this.CodeGenFolderInfo;
            inTheLoopType = this.InTheLoopType;
        end




        function codeDesc = getCodeDescriptor( this )

            codeDesc = [  ];

            try
                this.extractCodeConfig(  );
                if isempty( this.CodeGenFolder )
                    return
                end

                codeDescriptor = coder.internal.getCodeDescriptorInternal( this.CodeGenFolder, this.ModelName, 247362 );
                codeDesc.codeInfo = codeDescriptor.getComponentInterface(  );
                codeDesc.expInports = codeDescriptor.getExpInports(  );
                codeDesc.checksum = '';


                codeDescDmrFile = fullfile( this.CodeGenFolder, 'codedescriptor.dmr' );
                chk = coder.internal.utils.Checksum.calculate( { codeDescDmrFile } );
                codeDesc.checksum = chk{ 1 };

            catch ME
                if sldv.code.internal.feature( 'disableErrorRecovery' )
                    rethrow( ME );
                end
            end
        end




        function xilWrapperUtils = getXilInfo( this )

            this.extractCodeConfig(  );

            if ~isempty( this.XilWrapperUtils ) && isa( this.XilWrapperUtils, 'rtw.pil.SILPILWrapperUtils' )
                xilWrapperUtils = this.XilWrapperUtils;
                return
            end

            isSIL = true;
            options = coder.connectivity.VerificationOptions( isSIL );
            targetServices = coder.connectivity.createTargetServices( this.CoderConfig, options );

            isSilAndPws = strcmp( get_param( this.ModelName, 'PortableWordSizes' ), 'on' );


            lDefaultCompInfo = coder.internal.DefaultCompInfo.createDefaultCompInfo;


            lXilCompInfo =  ...
                coder.internal.utils.XilCompInfo.slCreateXilCompInfo ...
                ( this.ModelName, lDefaultCompInfo, isSilAndPws );

            if ~isempty( this.AtsHarnessInfo )

                [ restoreMgr, restorePrms ] = sldv.code.xil.CodeAnalyzer.setupXILAtomicSubsystem( this.AtsHarnessInfo.name );%#ok<ASGLU>

                atsEntryPointFunSigs = [  ];
                moduleName = SlCov.coder.EmbeddedCoder.buildModuleName( this.ModelName, char( this.SimulationMode ) );
                trDataFile = SlCov.coder.EmbeddedCoder.getCodeCovDataFiles( moduleName, this.CodeGenFolderInfo );
                if isfile( trDataFile )
                    try
                        traceabilityData = codeinstrum.internal.TraceabilityData( trDataFile );
                        buildInfoFile = fullfile( this.CodeGenFolder, 'buildInfo.mat' );
                        if isfile( buildInfoFile )
                            bInfo = load( buildInfoFile );
                            [ ~, entryPointsInfo ] =  ...
                                coder.connectivity.XILSubsystemUtils.getEntryPointsForAtomicSusbystemCoverage(  ...
                                this.AtsHarnessInfo.name, this.AtsHarnessInfo.model, bInfo.buildInfo );
                            if ~isempty( entryPointsInfo )
                                atsEntryPointFunSigs = traceabilityData.extractReachableFunSignatures( entryPointsInfo );
                            end
                        end
                    catch Mex %#ok<NASGU>

                    end
                end
                this.AtsHarnessInfo.atsEntryPointFunSigs = atsEntryPointFunSigs;

                extraArgs = {  ...
                    'TopModel', this.AtsHarnessInfo.name,  ...
                    'SubsystemName', this.AtsHarnessInfo.ownerFullPath ...
                    };
            else
                extraArgs = {  ...
                    'TopModel', this.ModelName,  ...
                    };
            end
            xilInterface = rtw.pil.SILPILInterface(  ...
                this.CodeGenFolderInfo.CodeGenFolder,  ...
                this.CodeGenFolder,  ...
                this.InTheLoopType,  ...
                coder.connectivity.SimulinkInterface(  ),  ...
                targetServices, lXilCompInfo, isSIL,  ...
                'ForSldv', true, extraArgs{ : } );

            xilWrapperUtils = xilInterface.getSILPILWrapperUtils(  );
            if ~isempty( this.AtsHarnessInfo )


                this.XilWrapperUtils = xilWrapperUtils;
            end
        end
    end

    methods ( Static = true )




        function buildDirInfo = getModuleBuilDirInfo( moduleName )




            codeAnalyzer = [  ];
            [ modelName, covMode, isSharedUtils ] = SlCov.coder.EmbeddedCoder.parseModuleName( moduleName );
            if ~isSharedUtils && char( covMode ) == "SIL"
                codeAnalyzer = sldv.code.xil.internal.getCurrentCodeAnalyzer(  );
            end
            if isempty( codeAnalyzer )
                codeAnalyzer = sldv.code.xil.CodeAnalyzer(  );
                codeAnalyzer.ModelName = modelName;
                codeAnalyzer.SimulationMode = covMode;
            end
            try
                [ ~, buildDirInfo ] = codeAnalyzer.getCodeFolder(  );
            catch ME
                if sldv.code.internal.feature( 'disableErrorRecovery' )
                    rethrow( ME );
                end
                buildDirInfo = [  ];
            end
        end




        function [ isATS, harnessInfo ] = isATSHarnessModel( modelName )
            arguments
                modelName( 1, 1 )string
            end
            modelName = char( modelName );
            harnessInfo = [  ];
            isATS = false;
            if ~sldv.code.internal.isAtsEnabled(  )
                return
            end
            if strcmp( get_param( modelName, 'IsHarness' ), 'on' )
                harnessInfo = Simulink.harness.internal.getHarnessInfoForHarnessBD( modelName );
                if ~isempty( harnessInfo )
                    if harnessInfo.ownerType == "Simulink.SubSystem" && harnessInfo.origSrc == "Inport"
                        isATS = ~isempty( harnessInfo.model ) && ~isempty( harnessInfo.ownerFullPath );
                    end
                end
            end
        end




        function [ restoreMgr, restorePrms, activationPvps ] = setupXILAtomicSubsystem( harnessName )


            if SlCov.CodeCovUtils.isAtomicSubsystem( harnessName )
                restoreMgr = [  ];
                restorePrms = [  ];
                activationPvps = [  ];
                return
            end
            manager = rtw.pil.AtomicSubsystemManager( harnessName );
            manager.workflowSLTSetup(  );
            restoreMgr = onCleanup( @(  )manager.workflowTeardown(  ) );
            restorePrms = onCleanup( @(  ) ...
                rtw.pil.SubsystemManager.cleanupWorkflowParameters( harnessName ) );
            activationPvps = manager.getActivationParamValuePairs(  );

            set_param( harnessName, activationPvps{ : } );
        end


        function xilCleanupObjs = registerXILSimulationPlugins( modelName, isATS )
            if nargin < 2
                isATS = sldv.code.xil.CodeAnalyzer.isATSHarnessModel( modelName );
            end
            xilCleanupObjs = onCleanup.empty(  );
            if isATS
                [ restoreMgr, restorePrms ] = sldv.code.xil.CodeAnalyzer.setupXILAtomicSubsystem( modelName );
                if ~isempty( restoreMgr )
                    xilCleanupObjs = onCleanup( @(  )delete( restoreMgr ) );
                end
                if ~isempty( restorePrms )
                    xilCleanupObjs = [ xilCleanupObjs, onCleanup( @(  )delete( restorePrms ) ) ];
                end
            end
        end

        [ analysis, warningMessages ] = createFromModel( modelName, varargin )

        [ status, msg, codeAnalyzer ] = checkCompatibility( modelName, varargin )

        [ status, msg ] = checkCompatibilityForTopOffCoverage( modelName, covData, varargin )
    end
end



