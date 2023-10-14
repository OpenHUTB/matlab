function [ infoStruct, varargout ] = infoMATFileMgr( action, minfo_or_binfo,  ...
    modelName, mdlRefTgtType, varargin )

if nargin < 5
    if nargin <= 3
        switch ( action )
            case { 'ResetRtwMatInfoFileStructs', 'ClearRtwMatInfoFileStructs' }
                infoStruct = [  ];
                locAccessGlbMatInfoStruct( 'set', [  ] );
                coder.internal.ParallelAnchorDirManager( 'set', '', '' );
                return ;
            case 'getParallelAnchorDir'

                mdlRefTgtType = minfo_or_binfo;
                infoStruct = coder.internal.ParallelAnchorDirManager( 'get', mdlRefTgtType );
                return ;
            case 'getVersionForSlprj'

                infoStruct = '_091';
                return ;
        end
    end
    varargin = {  };
end

if ~strcmp( action, 'loadPostBuild' )

    if ~isempty( varargin ) && ischar( varargin{ 1 } ) && strcmp( varargin{ 1 }, 'InitializeGenSettings' )
        if ~isempty( varargin{ 2 } )


            lGenSettings = coder.internal.infoMATGenSettings;


            infoStruct =  ...
                onCleanup( @(  )coder.internal.infoMATFileMgr( [  ], [  ], [  ], [  ],  ...
                'RestoreGenSettings', lGenSettings ) );
        end

        lGenSettingsFull = varargin{ 2 };

        lGenSettings = [  ];
        if ~isempty( lGenSettingsFull )
            lGenSettings.SystemTargetFile = lGenSettingsFull.SystemTargetFile;
        end


        coder.internal.infoMATGenSettings( lGenSettings );

        return ;
    elseif ~isempty( varargin ) && ischar( varargin{ 1 } ) && strcmp( varargin{ 1 }, 'RestoreGenSettings' )
        lGenSettings = varargin{ 2 };


        coder.internal.infoMATGenSettings( lGenSettings );
        return
    else


        lGenSettings = coder.internal.infoMATGenSettings;
    end
    h = locCreateHobj( modelName,  ...
        lGenSettings,  ...
        minfo_or_binfo,  ...
        mdlRefTgtType );
end

switch ( action )
    case 'getDefaultInfoStruct'
        infoStruct = get_default_info_struct;

    case 'getSTF'
        infoStruct = lGenSettings.SystemTargetFile;

    case 'load'
        loadConfigSet = 1;
        infoStruct = load_create_method( h, modelName, lGenSettings, loadConfigSet );

    case 'loadNoConfigSet'
        loadConfigSet = 0;
        infoStruct = load_create_method( h, modelName, lGenSettings, loadConfigSet );

    case 'loadPostBuild'













        fullMatFileName = varargin{ 1 };
        loadConfigSet = varargin{ 2 };

        infoStruct = locLoadMethodPostBuild( modelName,  ...
            minfo_or_binfo,  ...
            mdlRefTgtType,  ...
            fullMatFileName,  ...
            loadConfigSet );

    case 'save'

        if ~isempty( varargin )
            infoStruct = varargin{ 1 };
            loc_set_matfile_info( h, infoStruct );
        else
            infoStruct = updateBinfoCache( h, modelName, lGenSettings );
        end

    case 'deleteInfoFile'
        infoFile = h.fullMatFileName;


        if ( exist( infoFile, 'file' ) ~= 0 )
            delete( infoFile );
        end

        loc_invalidate_infofile_cache( h );

    case 'saveAndcheckSharedUtils'
        checkSharedUtils = 1;
        firstModel = varargin{ 1 };
        buildHooks = varargin{ 2 };
        fTopModelStandalone = varargin{ 3 };
        fCodeExecutionProfilingTop = varargin{ 4 };
        fCodeStackProfilingTop = varargin{ 5 };
        fCodeProfilingWCETAnalysis = varargin{ 6 };
        fXILChildModelsWithProfilingForAccelTop = varargin{ 7 };
        mdsSkipRTWBuild = false;
        [ infoStruct, protectedMdlRefsDirect ] =  ...
            updateBinfoCache( h, modelName, lGenSettings,  ...
            mdsSkipRTWBuild, firstModel, buildHooks, fTopModelStandalone,  ...
            fCodeExecutionProfilingTop, fCodeStackProfilingTop,  ...
            fCodeProfilingWCETAnalysis, fXILChildModelsWithProfilingForAccelTop,  ...
            checkSharedUtils );
        varargout{ 1 } = protectedMdlRefsDirect;

    case 'saveAndcheckSharedUtilsDuringCompile'
        checkSharedUtils = 2;
        infoStruct = load_method( h );
        if ~isempty( infoStruct )
            utilsDir = get_utils_dir_name( h, infoStruct, infoStruct.firstModel,  ...
                infoStruct.buildHooks, infoStruct.fTopModelStandalone,  ...
                checkSharedUtils );
            infoStruct.sharedSourcesDir = rtwprivate( 'rtw_relativize', utilsDir, h.anchorDir );
            infoStruct.sharedBinaryDir = infoStruct.sharedSourcesDir;
            loc_set_matfile_info( h, infoStruct );
        end

    case 'updateMinfoWithSave'
        if ~isempty( varargin )
            optArgs = varargin{ 1 };
        else
            optArgs = [  ];
        end
        infoStruct = updateMinfoWithSave( h, mdlRefTgtType, modelName, lGenSettings, optArgs );

    case 'updateModelLibName'
        infoStruct = load_method( h );
        infoStruct.modelLibName = varargin{ 1 };
        infoStruct.modelLibFullName =  ...
            fullfile( infoStruct.srcCoreDir, infoStruct.modelLibName );
        loc_set_matfile_info( h, infoStruct );

    case 'updateIncludeDirs'
        infoStruct = load_method( h );
        infoStruct.IncludeDirs = varargin{ 1 };
        infoStruct.SourceDirs = varargin{ 2 };
        loc_set_matfile_info( h, infoStruct );

    case 'getUserDataSize'
        infoStruct = load_method( h );
        if isfield( infoStruct, 'mdlrefuserdata' )
            infoStruct = size( infoStruct.mdlrefuserdata, 2 );
        else
            infoStruct = 0;
        end

    case 'getUserData'
        infoStruct = load_method( h );
        idx = varargin{ 1 };
        if isfield( infoStruct, 'mdlrefuserdata' )
            infoStruct = infoStruct.mdlrefuserdata;
            infoStruct = infoStruct{ idx };
        else
            infoStruct = [  ];
        end

    case 'appendToUserData'
        infoStruct = load_method( h );
        mdlrefuserdata = varargin{ 1 };
        if isfield( infoStruct, 'mdlrefuserdata' )
            infoStruct.mdlrefuserdata = [ infoStruct.mdlrefuserdata, mdlrefuserdata ];
        else
            infoStruct.mdlrefuserdata = { mdlrefuserdata };
        end
        loc_set_matfile_info( h, infoStruct );
        infoStruct = [  ];

    case 'updatehtmlrptLinks'
        infoStruct = load_method( h );
        rptFileName = varargin{ 1 };
        rptFileName = rtwprivate( 'rtw_relativize', rptFileName, h.anchorDir );
        if isfield( infoStruct, 'htmlrptLinks' )
            infoStruct.htmlrptLinks = [ { rptFileName }, infoStruct.htmlrptLinks ];
        else
            infoStruct.htmlrptLinks = ( { rptFileName } );
        end
        loc_set_matfile_info( h, infoStruct );

    case 'updateField'
        infoStruct = load_method( h );
        nVarargins = length( varargin );
        for iVarargins = 1:2:nVarargins
            fieldName = varargin{ iVarargins };
            fieldValue = varargin{ iVarargins + 1 };
            if ~isfield( infoStruct, fieldName )



                defaultInfoStruct = get_default_info_struct(  );
                if ~isfield( defaultInfoStruct, fieldName )
                    DAStudio.error( 'RTW:buildProcess:infoMATFileMgrFieldNotFound',  ...
                        fieldName, h.fullMatFileName );
                end
            end
            infoStruct.( fieldName ) = fieldValue;
        end
        loc_set_matfile_info( h, infoStruct );

    case 'addMdlInfos'
        isOk = isstruct( varargin{ 1 } ) && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.mdlInfos = varargin{ 1 };
            loc_set_matfile_info( h, infoStruct );
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end




        infoStruct = [  ];

    case 'addGlobalsInfo'
        isOk = isstruct( varargin{ 1 } ) && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.globalsInfo = varargin{ 1 };


            collapsedTunVars = infoStruct.globalsInfo.GlobalParamInfo.CollapsedTunableList;
            if ~isempty( collapsedTunVars )
                collapsedTunVars = textscan( collapsedTunVars, '%s', 'delimiter', ',' );
                infoStruct.globalsInfo.GlobalParamInfo.CollapsedTunableList =  ...
                    collapsedTunVars{ 1 };
            end


            globalParamInfo = infoStruct.globalsInfo.GlobalParamInfo;
            errorMsg = [  ];
            try
                cscChecksums = processcsc( 'GetCSCChecksums', globalParamInfo.CSCPackageList );
                cscChecksums = cscChecksums.Checksum;
            catch ME
                errorMsg = ME.message;
                cscChecksums = [  ];
            end



            infoStruct.cscChecksums = cscChecksums;
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end
        loc_set_matfile_info( h, infoStruct );

        infoStruct = constructErrorMessageForTLC( errorMsg );

    case 'computeGlobalsChecksum'
        isOk = strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if ( isOk )
            infoStruct = load_method( h );

            if ( isfield( infoStruct, 'globalsInfo' ) &&  ...
                    isfield( infoStruct.globalsInfo, 'GlobalParamInfo' ) )
                varList = infoStruct.globalsInfo.GlobalParamInfo;
                ignoreCSCs = infoStruct.globalsInfo.IgnoreCustomStorageClasses;
                inlineParameters = infoStruct.globalsInfo.InlineParameters;


                toPerformCleanup = false;
                [ checksum, varChecksums ] = slprivate( 'getGlobalParamChecksum',  ...
                    modelName,  ...
                    h.mdlRefTgtType,  ...
                    varList,  ...
                    inlineParameters,  ...
                    ignoreCSCs,  ...
                    infoStruct.designDataLocation,  ...
                    toPerformCleanup,  ...
                    true,  ...
                    infoStruct.enableAccessToBaseWorkspace );
                infoStruct.globalsInfo.GlobalParamInfo.Checksum = checksum;
                infoStruct.globalsInfo.GlobalParamInfo.VarChecksums = varChecksums;
            end
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end
        loc_set_matfile_info( h, infoStruct );

    case 'addInterface'
        isOk = isstruct( varargin{ 1 } ) && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.modelInterface = varargin{ 1 };





            infoStruct.CCDepInfoStructs =  ...
                slccprivate( 'getAllCCDependencyInfoFromModel', h.modelName );


            infoStruct.stateflowRebuildInfoForMATLABFiles =  ...
                sfprivate( 'getRebuildInfoForMFiles', h.modelName );


            infoStruct.mlsysblockRebuildInfoForMATLABSystemDeps =  ...
                cgxeprivate( 'getRebuildInfoForMATLABSystemDeps', h.modelName );


            infoStruct.dataflowRebuildInfo =  ...
                Simulink.ModelReference.internal.getDataflowRebuildInfo(  ...
                h.modelName, mdlRefTgtType );


            infoStruct.simHardwareAccelerationInfo =  ...
                Simulink.ModelReference.internal.getSimHardwareAccelerationInfo(  ...
                h.modelName, mdlRefTgtType );


            if isfield( infoStruct.globalsInfo, 'GlobalParamInfo' )
                globalParamInfo = infoStruct.globalsInfo.GlobalParamInfo;
                cscChecksums = processcsc( 'GetCSCChecksums', globalParamInfo.CSCPackageList );
                cscChecksums = cscChecksums.Checksum;




                infoStruct.cscChecksums = cscChecksums;
            end
            if ~strcmpi( get_param( h.modelName, 'IsCPPClassGenMode' ), 'on' )
                fpc = get_param( h.modelName, 'RTWFcnClass' );
                if ~isempty( fpc ) &&  ...
                        isa( fpc, 'RTW.ModelSpecificCPrototype' ) &&  ...
                        strcmp( get_param( h.modelName, 'ModelStepFunctionPrototypeControlCompliant' ), 'on' )
                    if isempty( fpc.ArgSpecData )
                        infoStruct.modelInterface.FPC.ArgSpecData = [  ];
                    else
                        infoStruct.modelInterface.FPC.ArgSpecData = fpc.ArgSpecData.get;
                    end
                    infoStruct.modelInterface.FPC.FunctionName = fpc.FunctionName;
                else
                    infoStruct.modelInterface.FPC = [  ];
                end
            else

                fpc = get_param( h.modelName, 'RTWCPPFcnClass' );
                if ~isempty( fpc ) && isa( fpc, 'RTW.ModelCPPClass' ) &&  ...
                        strcmp( h.mdlRefTgtType, 'RTW' )
                    if isempty( fpc.ArgSpecData )
                        infoStruct.modelInterface.FPC.ArgSpecData = [  ];
                    else
                        infoStruct.modelInterface.FPC.ArgSpecData = fpc.ArgSpecData.get;
                    end
                    infoStruct.modelInterface.FPC.FunctionName = fpc.FunctionName;
                    infoStruct.modelInterface.FPC.ModelClassName = fpc.ModelClassName;
                    infoStruct.modelInterface.FPC.ClassNamespace = fpc.ClassNamespace;




                    if isa( fpc, 'RTW.ModelCPPDefaultClass' ) ||  ...
                            isa( fpc, 'RTW.ModelCPPVoidClass' )
                        infoStruct.modelInterface.FPC.IsAuto = 1;
                    end
                else
                    infoStruct.modelInterface.FPC = [  ];
                end
            end
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end
        loc_set_matfile_info( h, infoStruct );





        infoStruct = [  ];

    case 'addInternalDependencyChecksums'
        isOk = strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            [ infoStruct.internalMdlDeps, infoStruct.rebuildChecksums.internalMdlDepChecksums,  ...
                infoStruct.modelWorkspaceDeps, infoStruct.rebuildChecksums.modelWorkspaceDepChecksums ] =  ...
                locGetModelDependenciesChecksum( h.modelName );
            loc_set_matfile_info( h, infoStruct );
        end


    case 'addChecksum'
        isOk = ( ( length( varargin{ 1 } ) == 4 ) || isempty( varargin{ 1 } ) ) ...
            && ( ( length( varargin{ 2 } ) == 4 ) || isempty( varargin{ 2 } ) ) ...
            && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.checkSum = varargin{ 1 };
            infoStruct.parameterCheckSum = varargin{ 2 };
            loc_set_matfile_info( h, infoStruct );
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end




    case 'addTunableStructParamInfo'
        isOk = ( length( varargin ) == 1 ) && islogical( varargin{ 1 } );
        if isOk
            infoStruct = load_method( h );
            infoStruct.modelHasTunableStructParams = varargin{ 1 };
            loc_set_matfile_info( h, infoStruct );
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end


    case 'addTflChecksum'
        isOk = ( ( length( varargin{ 1 } ) == 4 ) || isempty( varargin{ 1 } ) ) ...
            && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.tflCheckSum = varargin{ 1 };
            loc_set_matfile_info( h, infoStruct );
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end

    case 'addGeneralDataFromTLC'
        isOk = isstruct( varargin{ 1 } ) && strcmp( h.minfo_or_binfo, 'binfo' ) == 1;
        if isOk
            infoStruct = load_method( h );
            infoStruct.GeneralDataFromTLC = varargin{ 1 };
            loc_set_matfile_info( h, infoStruct );
        else
            DAStudio.error( 'RTW:utility:invalidInputArgs', 'infoMATFileMgr' );
        end





        infoStruct = [  ];

    case 'loadInterface'


        completeInfoStruct = load_method( h );
        infoStruct = completeInfoStruct.modelInterface;

    case 'loadforTLC'

        infoStruct = load_method( h, 0 );
        infoStruct.configSet = [  ];

    case 'getAnchorDir'

        infoStruct = locGetAnchorDir( modelName, mdlRefTgtType );

    case 'getMatFileName'
        infoStruct = h.fullMatFileName;

    case 'saveSfcnInfo'
        infoStruct = load_method( h );
        infoStruct.sfcnInfo = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

    case 'computeAndSaveSfcnChecksums'
        infoStruct = load_method( h );
        sfcnSourceFileMap = varargin{ 1 };
        startDir = varargin{ 2 };
        currDir = pwd;

        rapidAcceleratorIsActive = false;

        if length( varargin ) == 3
            rapidAcceleratorIsActive = varargin{ 3 };
        end

        c1 = onCleanup( @(  )cd( currDir ) );
        cd( startDir );

        infoStruct.rebuildChecksums.sfcnDepChecksums =  ...
            slprivate( 'mdlRefComputeSFcnChecksums',  ...
            infoStruct.sfcnInfo,  ...
            sfcnSourceFileMap,  ...
            true,  ...
            mdlRefTgtType,  ...
            rapidAcceleratorIsActive ...
            );
        infoStruct.rebuildChecksums.sfcnSourceFileMap = sfcnSourceFileMap;
        loc_set_matfile_info( h, infoStruct );

    case 'setBuildStats'
        infoStruct = load_method( h );
        infoStruct.buildStats = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

    case 'getBuildStats'
        infoStruct = load_method( h );
        infoStruct = infoStruct.buildStats;

    case 'setrtwSfcnStr'
        infoStruct = load_method( h );
        infoStruct.rtwSfcnStr = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

        infoStruct = [  ];

    case 'getrtwSfcnStr'
        tmp = load_method( h );
        if isempty( tmp )
            infoStruct = [  ];
        else
            infoStruct = tmp.rtwSfcnStr;
        end

    case 'getCodeGenerationId'
        tmp = load_method( h );
        if isempty( tmp ) || isempty( tmp.codeGenerationIdentifier )






            codeGenerationIdInitVal = typecast( now, 'uint64' );
            infoStruct = codeGenerationIdInitVal;
        else
            infoStruct = tmp.codeGenerationIdentifier;
        end

    case 'setCodeGenerationId'
        infoStruct = load_method( h );
        infoStruct.codeGenerationIdentifier = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

        infoStruct = [  ];

    case 'setTopModelIncChecksum'
        infoStruct = load_method( h );
        infoStruct.topModelIncChecksum = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

        infoStruct = [  ];

    case 'setTargetCompiler'
        infoStruct = load_method( h );
        infoStruct.targetCompiler = varargin{ 1 };
        loc_set_matfile_info( h, infoStruct );

        infoStruct = [  ];

    case 'getTargetCompiler'
        tmp = load_method( h );
        if isempty( tmp )
            infoStruct = locGetDefaultTargetCompiler(  );
        else
            infoStruct = tmp.targetCompiler;
            infoStruct.GenerateMakefile =  ...
                get_param( tmp.configSet, 'GenerateMakefile' );
        end
    case 'getTargetExecutableFullName'
        tmp = load_method( h, 0 );
        if isempty( tmp )

            infoStruct = '';
        else
            infoStruct = tmp.TargetExecutableFullName;
        end

    case 'createEmptyBinfo'
        mdsSkipRTWBuild = true;

        mdlsToClose = slprivate( 'load_model', h.modelName );
        infoStruct = updateBinfoCache( h, modelName, lGenSettings, mdsSkipRTWBuild );
        slprivate( 'close_models', mdlsToClose );

    case 'getTMWInternalDirectory'
        isSILOrPILProtected = varargin{ 1 };
        if length( varargin ) > 1

            lAnchorDir = varargin{ 2 };
        else
            lAnchorDir = h.anchorDir;
        end
        if isSILOrPILProtected



            Simulink.filegen.internal.FolderConfiguration.updateCache( h.modelName );
            lTargetDirName = Simulink.filegen.internal.FolderConfiguration( h.modelName ).CodeGeneration.ModelReferenceCode;
        else
            lTargetDirName = h.targetDirName;
        end
        h = locCreateHobj( modelName, lGenSettings, h.minfo_or_binfo, mdlRefTgtType,  ...
            'markerFile', h.markerFile,  ...
            'targetDirName', lTargetDirName,  ...
            'anchorDir', lAnchorDir );
        infoStruct = h.matFileDir;

    otherwise
        DAStudio.error( 'RTW:buildProcess:infoMATFileMgrInvalidAction', action );
end
end











function [ resaveInfoFile, resaveReason, resaveShortReason ] =  ...
    loc_check_for_outofdate_minfo_file( h, infoStruct )
resaveInfoFile = false;
resaveReason = '';
resaveShortReason = '';



if ( ~isfield( infoStruct, 'computer' ) ||  ...
        ~isequal( infoStruct.computer, computer ) )
    resaveInfoFile = true;
    resaveReason = DAStudio.message(  ...
        'Simulink:slbuild:minfoResaveDifferentPlatform',  ...
        infoStruct.computer, computer );
    resaveShortReason = DAStudio.message( 'Simulink:slbuild:bs2PlatformChange',  ...
        infoStruct.computer, computer );
    return ;
end







mdls = [ { h.modelName };infoStruct.libDeps;infoStruct.ssrefDeps ];
nMdls = length( mdls );
[ anyModelDirty, dirtyModelName ] = loc_any_mdl_dirty( mdls );
if anyModelDirty
    resaveInfoFile = true;
    resaveReason = DAStudio.message(  ...
        'Simulink:slbuild:minfoResaveModelDirty', dirtyModelName );
    resaveShortReason = DAStudio.message( 'Simulink:slbuild:bs2LibraryDirty',  ...
        dirtyModelName );
    return ;
end





if ( infoStruct.matFileSavedWhenMdlWasDirty )
    resaveInfoFile = true;
    resaveReason = DAStudio.message(  ...
        'Simulink:slbuild:minfoResaveLastSaveWhenDirtyModel' );
    resaveShortReason = DAStudio.message( 'Simulink:slbuild:bs2ModelDirty' );
    return ;
end




for i = 1:length( infoStruct.unresolvedMdlRefs )
    name = infoStruct.unresolvedMdlRefs( i ).name;
    block = infoStruct.unresolvedMdlRefs( i ).block;
    expProtected = infoStruct.unresolvedMdlRefs( i ).protected;
    actProtected = slInternal( 'getReferencedModelFileInformation', name );

    if ( ~isequal( expProtected, actProtected ) )
        resaveInfoFile = true;
        protectedName = Simulink.ModelReference.ProtectedModel.getProtectedModelFileName( name );
        msgID = 'Simulink:slbuild:minfoResaveProtectionChange';
        shortID = 'Simulink:slbuild:bs2ProtectionChange';
        if expProtected
            resaveReason = DAStudio.message( msgID, block, protectedName, name );
            resaveShortReason = DAStudio.message( shortID, block, protectedName, name );
        else
            resaveReason = DAStudio.message( msgID, block, name, protectedName );
            resaveShortReason = DAStudio.message( shortID, block, name, protectedName );
        end
        return ;
    end
end



for i = 1:nMdls
    mdl = mdls{ i };
    if ( ~isfield( infoStruct.rebuildChecksums.mdlFileAndLibraryChecksums, mdl ) )
        resaveInfoFile = true;
        resaveReason = DAStudio.message(  ...
            'Simulink:slbuild:minfoResaveModelAdded', mdl );
        resaveShortReason = DAStudio.message( 'Simulink:slbuild:bs2MissingModel', mdl );
        return ;
    end

    oldChecksum = infoStruct.rebuildChecksums.mdlFileAndLibraryChecksums.( mdl );

    extensionsToCheck = { '.mdl', '.slx' };
    [ mdlExists, sameChecksum ] = slprivate( 'sl_compare_file_checksum', mdl, oldChecksum, extensionsToCheck );
    if ~mdlExists
        if strcmp( mdl, h.modelName )
            DAStudio.error( 'RTW:buildProcess:infoMATFileMgrMdlOrLibNotFound', mdl );
        else


            resaveInfoFile = true;
            resaveReason = DAStudio.message(  ...
                'Simulink:slbuild:minfoResaveMissingLibrary', mdl );
            resaveShortReason = DAStudio.message(  ...
                'Simulink:slbuild:bs2MissingLibrary', mdl );
            return ;
        end
    end

    if ( ~sameChecksum )
        resaveInfoFile = true;
        resaveReason = DAStudio.message(  ...
            'Simulink:slbuild:minfoResaveModelChanged', mdl );
        resaveShortReason = DAStudio.message(  ...
            'Simulink:slbuild:bs2ModelChange', mdl );
        return ;
    end
end



newOverrideVal =  ...
    Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.isOverride(  );
if infoStruct.hasProtectedModelsInXIL &&  ...
        newOverrideVal ~= infoStruct.IsProtectedModelRefSILPILOverride
    resaveInfoFile = true;
    reasonID = { 'Simulink:slbuild:minfoResaveSILVerificationChange1',  ...
        'Simulink:slbuild:minfoResaveSILVerificationChange2' };
    shortReasonID = { 'Simulink:slbuild:bs2SILVerificationChange1',  ...
        'Simulink:slbuild:bs2SILVerificationChange2' };
    resaveReason = DAStudio.message( reasonID{ newOverrideVal + 1 } );
    resaveShortReason = DAStudio.message( shortReasonID{ newOverrideVal + 1 } );
end

for i = 1:length( infoStruct.variantObjects )
    info = infoStruct.variantObjects( i );

    name = info.name;
    oldValue = info.active;

    if ( slfeature( 'VariantControlFromMask' ) )
        [ newValue, error, ~, ~ ] = loc_evaluateVariantObject( h.modelName, name.blk, name.var );
        varControl = name.var;
    else
        [ newValue, error, ~, ~ ] = loc_evaluateVariantObject( h.modelName, 0, name );
        varControl = name;
    end

    if ( error || ~isequal( oldValue, newValue ) )
        resaveInfoFile = true;
        if error
            resaveReason = DAStudio.message(  ...
                'Simulink:slbuild:minfoResaveVariantEvaluateError',  ...
                varControl );
        else
            logicalStr = { 'false', 'true' };
            resaveReason = DAStudio.message(  ...
                'Simulink:slbuild:minfoResaveVariantValueChange',  ...
                varControl, logicalStr{ oldValue + 1 }, logicalStr{ newValue + 1 } );
            resaveShortReason = DAStudio.message(  ...
                'Simulink:slbuild:bs2VariantChange', varControl,  ...
                logicalStr{ oldValue + 1 }, logicalStr{ newValue + 1 } );
        end
        return ;
    end
end




if ~isempty( infoStruct.configSetChecksum )
    assert( ~isempty( infoStruct.configSetWSVarName ) );





    try
        if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0
            configSet = getConfigurationsItem(  ...
                infoStruct.configSetWSVarName, infoStruct.designDataLocation,  ...
                infoStruct.enableAccessToBaseWorkspace );
        else
            configSet = getConfigurationsItem(  ...
                infoStruct.configSetWSVarName, infoStruct.designDataLocation );
        end
        newCheckSum = configSet.computeChecksum( 'MdlRef' );
        if ( strcmp( newCheckSum, infoStruct.configSetChecksum ) == 0 )
            resaveInfoFile = true;
            resaveReason = DAStudio.message(  ...
                'Simulink:slbuild:minfoResaveConfigSetChanged',  ...
                infoStruct.configSetWSVarName );
            resaveShortReason = DAStudio.message(  ...
                'Simulink:slbuild:bs2ConfigSetRefChange',  ...
                infoStruct.configSetWSVarName );
            return ;
        end
    catch
        resaveInfoFile = true;
        resaveReason = DAStudio.message(  ...
            'Simulink:slbuild:minfoResaveConfigSetChanged',  ...
            infoStruct.configSetWSVarName );
        resaveShortReason = DAStudio.message(  ...
            'Simulink:slbuild:bs2ConfigSetRefChange',  ...
            infoStruct.configSetWSVarName );
        return ;
    end
end







if ~isequal( infoStruct.sharedCoderDictionaryCheckSum,  ...
        coder.internal.CoderDataStaticAPI.getCoderDataChecksum( infoStruct.sharedCoderDictionaryLocation, h.mdlRefTgtType ) )
    resaveInfoFile = true;
    resaveReason = DAStudio.message(  ...
        'Simulink:slbuild:minfoResaveSharedCoderDictChanged',  ...
        infoStruct.sharedCoderDictionaryLocation );
    resaveShortReason = DAStudio.message(  ...
        'Simulink:slbuild:bs2SharedCoderDictChange',  ...
        infoStruct.sharedCoderDictionaryLocation );
    return ;
end
end













function infoStruct = updateMinfoWithSave( h, originalMdlRefTargetType, modelName, lGenSettings, optArgs )

assert( strcmp( h.minfo_or_binfo, 'minfo' ), 'function is only applicable to minfo' )


if ~isfile( h.fullMatFileName )




    mdlsToClose = slprivate( 'load_model', h.modelName );
    cleanupObj = onCleanup( @(  )slprivate( 'close_models', mdlsToClose ) );

    Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.attachOverride( h.modelName );



    Simulink.filegen.internal.FolderConfiguration( h.modelName );


    h = locCreateHobj( modelName,  ...
        lGenSettings,  ...
        h.minfo_or_binfo,  ...
        originalMdlRefTargetType );

    minfoFileRevision = uint32( 0 );
    resaveInfoFileShortReason = '';
    resaveInfoFileReason = '';
    resaveInfoFile = true;
else



    infoStruct = load_method( h );






    if ( slfeature( 'VariantControlFromMask' ) )
        if ( infoStruct.variantsFromMask )
            mdlsToClose = slprivate( 'load_model', h.modelName );
            cleanupObj = onCleanup( @(  )slprivate( 'close_models', mdlsToClose ) );
            slInternal( 'evalModelInitFcn', get_param( h.modelName, 'Handle' ) );
            slInternal( 'evalMask', get_param( h.modelName, 'Handle' ) );
        end
    end


    [ resaveInfoFile, resaveInfoFileReason, resaveInfoFileShortReason ] =  ...
        loc_check_for_outofdate_minfo_file( h, infoStruct );

    if resaveInfoFile
        minfoFileRevision = infoStruct.minfoFileRevision + 1;
    end
end

if resaveInfoFile
    infoStruct = loc_create_minfo( h, modelName, optArgs );
    infoStruct.minfoFileRevision = minfoFileRevision;
    infoStruct.minfoResaveReason = resaveInfoFileReason;
    infoStruct.minfoResaveShortReason = resaveInfoFileShortReason;
    loc_set_matfile_info( h, infoStruct );

    if bdIsLoaded( h.modelName ) &&  ...
            ( bdIsLibrary( h.modelName ) || bdIsSubsystem( h.modelName ) )


        return
    end

    rtwprivate( 'rtw_create_directory_path', h.matFileDir );
    markerFile = fullfile( h.anchorDir, h.markerFile );
    coder.internal.folders.MarkerFile.create( markerFile );
    coder.internal.saveMinfoOrBinfo( infoStruct, h.fullMatFileName );
end
end




function infoStruct = addToInfoStruct( infoStruct, codeVarStruct, activeVarStruct )

infoStruct.modelRefsCodeVar = codeVarStruct.modelRefs;
infoStruct.accelMdlRefsCodeVar = codeVarStruct.accelMdlRefs;
infoStruct.normalMdlRefsCodeVar = codeVarStruct.normalMdlRefs;
infoStruct.silMdlRefsCodeVar = codeVarStruct.silMdlRefs;
infoStruct.pilMdlRefsCodeVar = codeVarStruct.pilMdlRefs;
infoStruct.protectedModelRefsCodeVar = codeVarStruct.protectedModelRefs;
infoStruct.protectedModelRefsWithTopModelXILCodeVar = codeVarStruct.protectedModelRefsWithTopModelXIL;
infoStruct.protectedModelRefsBuildDirsAllCodeVar = codeVarStruct.protectedModelRefsBuildDirsAll;
infoStruct.unresolvedMdlRefsCodeVar = codeVarStruct.unresolvedMdlRefs;
infoStruct.variantObjectsCodeVar = codeVarStruct.variantObjects;
infoStruct.variantsFromMask = codeVarStruct.variantsFromMask;


infoStruct.modelRefsActiveVar = activeVarStruct.modelRefs;
infoStruct.accelMdlRefsActiveVar = activeVarStruct.accelMdlRefs;
infoStruct.normalMdlRefsActiveVar = activeVarStruct.normalMdlRefs;
infoStruct.silMdlRefsActiveVar = activeVarStruct.silMdlRefs;
infoStruct.pilMdlRefsActiveVar = activeVarStruct.pilMdlRefs;
infoStruct.protectedModelRefsActiveVar = activeVarStruct.protectedModelRefs;
infoStruct.protectedModelRefsWithTopModelXILActiveVar = codeVarStruct.protectedModelRefsWithTopModelXIL;
infoStruct.protectedModelRefsBuildDirsAllActiveVar = activeVarStruct.protectedModelRefsBuildDirsAll;
infoStruct.unresolvedMdlRefsActiveVar = activeVarStruct.unresolvedMdlRefs;
infoStruct.variantObjectsActiveVar = activeVarStruct.variantObjects;
end








function infoStruct = loc_compute_target_independent_minfo_data( infoStruct, modelName, matfilename, optArgs )%#ok<INUSL>



if ( strcmp( get_param( modelName, 'SimulationStatus' ), 'stopped' ) )

    modelObj = get_param( modelName, 'Object' );
    modelObj.refreshModelBlocks;
end

if ~isempty( optArgs ) && isstruct( optArgs ) && isfield( optArgs, 'TopModel' )
    topModelHandle = optArgs.TopModel;


    slInternal( 'trackModelRefsForVariantSimCodegenContext', topModelHandle, modelName );
end




infoStruct.libDeps = slprivate( 'mdlRefGetLinkedLibraryModels', modelName );


infoStruct.ssrefDeps = slprivate( 'mdlRefGetSubsystemReferenceModels', modelName );



currConfigSet = getActiveConfigSet( modelName );
if isa( currConfigSet, 'Simulink.ConfigSetRef' )
    currConfigSet.refresh;
end

infoStruct.genCodeOnly = strcmpi( currConfigSet.getProp( 'GenCodeOnly' ), 'on' );
infoStruct.isERTTarget = strcmpi( currConfigSet.getProp( 'IsERTTarget' ), 'on' );
infoStruct.IsPortableWordSizesEnabled = strcmpi( currConfigSet.getProp( 'PortableWordSizes' ), 'on' );

infoStruct.targetLanguage = get_param( modelName, 'TargetLang' );
infoStruct.IsGPUCodegen = strcmpi( currConfigSet.getProp( 'GenerateGPUCode' ), 'cuda' );

infoStruct.usingVarStepSolver =  ...
    isequal( currConfigSet.getProp( 'SolverType' ), 'Variable-step' );
infoStruct.rtwSystemTargetFile =  ...
    strtok( get_param( modelName, 'SystemTargetFile' ), '.' );
infoStruct.signalResolutionControl =  ...
    get_param( modelName, 'SignalResolutionControl' );











runMaskEval = ~infoStruct.variantsFromMask;
if ( ~slfeature( 'VariantControlFromMask' ) || runMaskEval )
    slInternal( 'evalModelInitFcn', get_param( modelName, 'Handle' ) );
    slInternal( 'evalMask', get_param( modelName, 'Handle' ) );
end



codeVarStruct = get_mdlref_info_for_minfo( modelName, true );
activeVarStruct = get_mdlref_info_for_minfo( modelName, false );
infoStruct = addToInfoStruct( infoStruct, codeVarStruct, activeVarStruct );
infoStruct = use_modelref_active_variants_fields( infoStruct );


infoStruct = get_to_from_file_blocks( modelName, infoStruct );

infoStruct = get_server_info_for_minfo( modelName, infoStruct );

infoStruct.mVersion = version;
infoStruct.computer = computer;
infoStruct.modelName = modelName;



mdls = [ { modelName };infoStruct.libDeps;infoStruct.ssrefDeps ];
infoStruct.matFileSavedWhenMdlWasDirty = loc_any_mdl_dirty( mdls );
infoStruct.minfoFileRevision = uint32( 0 );





if ~isempty( get_param( modelName, 'OriginalConfigSetRefVarName' ) )
    infoStruct.configSetWSVarName =  ...
        get_param( modelName, 'OriginalConfigSetRefVarName' );
elseif isa( currConfigSet, 'Simulink.ConfigSetRef' )
    infoStruct.configSetWSVarName = currConfigSet.SourceName;
end


modelDataDictionary = get_param( modelName, 'DataDictionary' );
if ~isempty( modelDataDictionary )
    infoStruct.designDataLocation = modelDataDictionary;
else
    infoStruct.designDataLocation = 'base';
end
if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0
    infoStruct.enableAccessToBaseWorkspace = get_param( modelName,  ...
        'EnableAccessToBaseWorkspace' );
end
if ~isempty( infoStruct.configSetWSVarName )
    if isa( currConfigSet, 'Simulink.ConfigSetRef' )











        if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0
            origConfigSet = getConfigurationsItem(  ...
                infoStruct.configSetWSVarName, infoStruct.designDataLocation,  ...
                infoStruct.enableAccessToBaseWorkspace );
        else
            origConfigSet = getConfigurationsItem(  ...
                infoStruct.configSetWSVarName, infoStruct.designDataLocation );
        end
        infoStruct.configSetChecksum = origConfigSet.computeChecksum( 'MdlRef' );
    else
        infoStruct.configSetChecksum = currConfigSet.computeChecksum( 'MdlRef' );
    end
end



infoStruct.rebuildChecksums.mdlFileAndLibraryChecksums = [  ];
for i = 1:length( mdls )
    modelOrLib = mdls{ i };


    extensionsToCheck = { '.mdl', '.slx' };
    [ file, foundFile ] = slprivate( 'sl_get_file_ignoring_builtins', modelOrLib, extensionsToCheck );



    if ( foundFile )
        checksum = slprivate( 'file2hash', file );
        infoStruct.rebuildChecksums.mdlFileAndLibraryChecksums.( modelOrLib ) = checksum;
    end
end



infoStruct.hasProtectedModelsInXIL =  ...
    strcmp( get_param( modelName, 'ModelRefSimModeOverrideXILProtectedModels' ), 'on' ) ||  ...
    ( ~isempty( infoStruct.protectedModelRefs ) &&  ...
    ~isempty( intersect( infoStruct.protectedModelRefs,  ...
    union( infoStruct.silMdlRefs, infoStruct.pilMdlRefs ) ) ) );
infoStruct.IsProtectedModelRefSILPILOverride =  ...
    Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.isOverride(  );
end









function infoStruct = loc_compute_target_dependent_minfo_data( infoStruct, h )

infoStruct.matFileName = rtwprivate( 'rtw_relativize', h.fullMatFileName, h.anchorDir );

folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( h.modelName );

if ~isempty( folders.CodeGeneration )
    infoStruct.mdlRefTgtDir = folders.CodeGeneration.TargetRoot;
end

infoStruct.mdlRefSimDir = folders.Simulation.TargetRoot;


if ~strcmpi( h.mdlRefTgtType, 'NONE' )
    evalStr = strtrim( get_param( h.modelName, 'ModelDependencies' ) );

    if ~isempty( evalStr )
        try
            stripStr = loc_strip_comments( evalStr );
            if ( ~isempty( stripStr ) )
                infoStruct.mdlDeps = eval( stripStr );
            end
        catch exc
            errID = 'RTW:buildProcess:infoMATFileMgrMdlDependencyError';
            msg = DAStudio.message( errID, h.modelName, evalStr, exc.message );
            newExc = MException( errID, '%s', msg );
            newExc = newExc.addCause( exc );
            throw( newExc );
        end
    end
else
    infoStruct.mdlDeps = {  };
end




if infoStruct.isERTTarget
    infoStruct.sharedCoderDictionaryLocation = get_param( h.modelName, 'DataDictionary' );
    infoStruct.sharedCoderDictionaryCheckSum = coder.internal.CoderDataStaticAPI.getCoderDataChecksum( infoStruct.sharedCoderDictionaryLocation,  ...
        h.mdlRefTgtType );
end

if ~strcmpi( h.mdlRefTgtType, 'NONE' )
    matFileDirParent = fileparts( h.matFileDir );
    infoStruct.srcDir = rtwprivate( 'rtw_relativize', matFileDirParent, h.anchorDir );
    infoStruct.srcCoreDir = rtwprivate( 'rtw_relativize', matFileDirParent, h.anchorDir );
end
end



function infoStruct = use_modelref_code_variants_fields( infoStruct )
infoStruct.modelRefs = infoStruct.modelRefsCodeVar;
infoStruct.accelMdlRefs = infoStruct.accelMdlRefsCodeVar;
infoStruct.normalMdlRefs = infoStruct.normalMdlRefsCodeVar;
infoStruct.silMdlRefs = infoStruct.silMdlRefsCodeVar;
infoStruct.pilMdlRefs = infoStruct.pilMdlRefsCodeVar;
infoStruct.protectedModelRefs = infoStruct.protectedModelRefsCodeVar;
infoStruct.protectedModelRefsBuildDirsAll = infoStruct.protectedModelRefsBuildDirsAllCodeVar;
infoStruct.unresolvedMdlRefs = infoStruct.unresolvedMdlRefsCodeVar;
infoStruct.variantObjects = infoStruct.variantObjectsCodeVar;
infoStruct.variantsFromMask = infoStruct.variantsFromMask;
end



function infoStruct = use_modelref_active_variants_fields( infoStruct )
infoStruct.modelRefs = infoStruct.modelRefsActiveVar;
infoStruct.accelMdlRefs = infoStruct.accelMdlRefsActiveVar;
infoStruct.normalMdlRefs = infoStruct.normalMdlRefsActiveVar;
infoStruct.silMdlRefs = infoStruct.silMdlRefsActiveVar;
infoStruct.pilMdlRefs = infoStruct.pilMdlRefsActiveVar;
infoStruct.protectedModelRefs = infoStruct.protectedModelRefsActiveVar;
infoStruct.protectedModelRefsWithTopModelXIL = infoStruct.protectedModelRefsWithTopModelXILActiveVar;
infoStruct.protectedModelRefsBuildDirsAll = infoStruct.protectedModelRefsBuildDirsAllActiveVar;
infoStruct.unresolvedMdlRefs = infoStruct.unresolvedMdlRefsActiveVar;
infoStruct.variantObjects = infoStruct.variantObjectsActiveVar;
end




function infoStruct = loc_create_minfo( h, modelName, optArgs )



mdlsToClose = slprivate( 'load_model', modelName );
cleanupObj = onCleanup( @(  )slprivate( 'close_models', mdlsToClose ) );

Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.attachOverride( h.modelName );

if ( isequal( h.mdlRefTgtType, 'RTW' ) )

    folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( h.modelName );
    [ ~, minfoFileName ] =  ...
        loc_getMatFileNames( 'SIM', h.anchorDir,  ...
        folders.CodeGeneration.TargetRoot, h.minfo_or_binfo );

    assert( ~isfile( minfoFileName ), 'If minfo file exists, we would have loaded it' )

    infoStruct = get_default_info_struct;
    infoStruct = loc_compute_target_independent_minfo_data( infoStruct, h.modelName, h.fullMatFileName, optArgs );

    if ~Simulink.ModelReference.ProtectedModel.protectingModel( h.modelName )

        infoStruct = use_modelref_code_variants_fields( infoStruct );
    end
else
    infoStruct = get_default_info_struct;
    infoStruct = loc_compute_target_independent_minfo_data( infoStruct, h.modelName, h.fullMatFileName, optArgs );



    if isequal( h.mdlRefTgtType, 'NONE' )
        if ~Simulink.ModelReference.ProtectedModel.protectingModel( h.modelName )
            infoStruct = use_modelref_code_variants_fields( infoStruct );
        end
    end
end

infoStruct = loc_compute_target_dependent_minfo_data( infoStruct, h );
end






function [ infoStruct, protectedMdlRefsDirect ] = updateBinfoCache( h, modelName, lGenSettings,  ...
    mdsSkipRTWBuild, firstModel, buildHooks, fTopModelStandalone,  ...
    fCodeExecutionProfilingTop, fCodeStackProfilingTop, fCodeProfilingWCETAnalysis,  ...
    fXILChildModelsWithProfilingForAccelTop,  ...
    checkSharedUtils )

arguments
    h
    modelName
    lGenSettings
    mdsSkipRTWBuild = false;
    firstModel = ''
    buildHooks = [  ]
    fTopModelStandalone = ''
    fCodeExecutionProfilingTop = false
    fCodeStackProfilingTop = false
    fCodeProfilingWCETAnalysis = false
    fXILChildModelsWithProfilingForAccelTop = {  }
    checkSharedUtils = 0
end

assert( strcmp( h.minfo_or_binfo, 'binfo' ), 'This method is for use with binfo' );


newH = locCreateHobj( modelName, lGenSettings, 'minfo', h.mdlRefTgtType,  ...
    'anchorDir', h.anchorDir,  ...
    'markerFile', h.markerFile,  ...
    'matFileDir', h.matFileDir,  ...
    'targetDirName', h.targetDirName );

loadConfigSet = 1;
infoStruct = load_create_method( newH, modelName, lGenSettings, loadConfigSet );



protectedMdlRefsDirect = infoStruct.protectedModelRefs;


infoStruct.relativePathToAnchor = loc_get_relative_path_to_anchor( h.modelName, h.mdlRefTgtType );

infoStruct.mVersion = version;
infoStruct.computer = computer;
infoStruct.modelName = modelName;
infoStruct.rebuildChecksums.minfoChecksum = slprivate( 'file2hash',  ...
    fullfile( h.anchorDir, infoStruct.matFileName ) );
infoStruct.matFileName = rtwprivate( 'rtw_relativize', h.fullMatFileName, h.anchorDir );


depTypes = repmat( Simulink.ModelReference.internal.ModelDependencyType( 'MODELDEP_USER' ),  ...
    length( infoStruct.mdlDeps ), 1 );
userDeps = slprivate( 'mdlRefParseUserDeps', h.modelName, infoStruct.mdlDeps, true, depTypes );
numUserDeps = length( userDeps );
checksums = struct( 'Key', cell( 1, numUserDeps ), 'Checksum', cell( 1, numUserDeps ),  ...
    'Type', cell( 1, numUserDeps ) );
for i = 1:numUserDeps
    depBase = userDeps( i ).Base;
    depActual = userDeps( i ).Actual;
    depType = userDeps( i ).Type;

    checksumval = slprivate( 'file2hash', depActual );
    checksums( i ).Key = depBase;
    checksums( i ).Checksum = checksumval;
    checksums( i ).Type = depType.char;
end
infoStruct.rebuildChecksums.userDepChecksums = checksums;


infoStruct.BuildDir = get_target_dir( h.modelName, h.mdlRefTgtType );

if checkSharedUtils == 1
    infoStruct.firstModel = firstModel;
    infoStruct.buildHooks = buildHooks;
    infoStruct.fTopModelStandalone = fTopModelStandalone;
    utilsDir = get_utils_dir_name( h, infoStruct, firstModel, buildHooks,  ...
        fTopModelStandalone, checkSharedUtils );
    infoStruct.sharedSourcesDir = rtwprivate( 'rtw_relativize', utilsDir, h.anchorDir );
    infoStruct.sharedBinaryDir = infoStruct.sharedSourcesDir;
end

if sl( 'isSimulationBuild', h.modelName, h.mdlRefTgtType )
    childTargetType = 'SIM';
else
    childTargetType = 'RTW';
end

currConfigSet = getActiveConfigSet( h.modelName );

currConfigSet.evalParams(  );
infoStruct.configSet = currConfigSet;


areStatesLogged = ( strcmp( get_param( h.modelName, 'SaveState' ), 'on' ) ||  ...
    strcmp( get_param( h.modelName, 'SaveFinalState' ), 'on' ) ) &&  ...
    strcmp( get_param( h.modelName, 'ModelReferenceMatFileLogging' ), 'on' );
infoStruct.areStatesLogged = areStatesLogged;


infoStruct.modelRefsAll = infoStruct.modelRefs';
infoStruct.directMdlRefs = infoStruct.modelRefs';

for i = 1:length( infoStruct.modelRefsAll )
    modelRef = infoStruct.modelRefsAll{ i };
    coder.internal.modelRefUtil( modelRef, 'setupFolderCacheForReferencedModel', h.modelName );
    folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( modelRef );
    infoStruct.modelRefsBuildDirsAll{ i } = folders.getFolderSetFor( childTargetType ).ModelReferenceCode;
end


if mdsSkipRTWBuild
    infoStruct.modelLibName = '';
    infoStruct.modelLibFullName = '';

    infoStruct.modelInterface.InputPortGlobal = {  };
    infoStruct.modelInterface.InputPortNotReusable = {  };
    infoStruct.modelInterface.InputPortOverWritable = {  };
    infoStruct.modelInterface.InputPortAlignment = {  };
    infoStruct.modelInterface.OutputPortGlobal = {  };
    infoStruct.modelInterface.OutputPortNotReusable = {  };
    infoStruct.modelInterface.OutputPortAlignment = {  };
    infoStruct.mdlInfos.mdlInfo = {  };
    infoStruct.modelInterface.NumBlockFcns = 0;
    infoStruct.modelInterface.NeedAbsoluteTime = false;
    infoStruct.modelInterface.ModelRefTsInheritanceAllowed = false;
    infoStruct.modelInterface.PortRTWStorageInfo.RTWIdentifier = '';
    infoStruct.modelInterface.PortRTWStorageInfo.StorageTypeQualifier = '';
    infoStruct.modelInterface.PortRTWStorageInfo.StorageClassStr = '';
end

isAccel = is_accel( h.mdlRefTgtType, lGenSettings );

infoStruct.rebuildChecksums.childModelTargetChecksums = [  ];
mdlRefCount = 1;
lAccelAndNormalMdlRefs = [ infoStruct.accelMdlRefs, infoStruct.normalMdlRefs ];
while mdlRefCount <= length( infoStruct.modelRefs )
    lCurrModelRef = infoStruct.modelRefs{ mdlRefCount };





    if ~isAccel || ismember( lCurrModelRef, lAccelAndNormalMdlRefs )
        infoStruct = locPopulateInfoStructForMdlRefs( h,  ...
            infoStruct,  ...
            lCurrModelRef,  ...
            childTargetType,  ...
            lGenSettings );
    end
    mdlRefCount = mdlRefCount + 1;
end

mdlRefCount = 1;
while mdlRefCount <= length( infoStruct.protectedModelRefs )
    lCurrModelRef = infoStruct.protectedModelRefs{ mdlRefCount };


    if ~isAccel || ismember( lCurrModelRef, lAccelAndNormalMdlRefs )
        infoStruct = locPopulateInfoStructForMdlRefs( h,  ...
            infoStruct,  ...
            lCurrModelRef,  ...
            childTargetType,  ...
            lGenSettings );
    end
    mdlRefCount = mdlRefCount + 1;
end



infoStruct.linkLibrariesFullPaths = RTW.uniquePath( infoStruct.linkLibrariesFullPaths, 'keeplast' );
infoStruct.linkLibraries = RTW.unique( infoStruct.linkLibraries, 'keeplast' );



mdls = [ { h.modelName };infoStruct.libDeps;infoStruct.ssrefDeps ];
infoStruct.matFileSavedWhenMdlWasDirty = loc_any_mdl_dirty( mdls );

if ~mdsSkipRTWBuild
    if fCodeExecutionProfilingTop


        isAccel = is_accel( h.mdlRefTgtType, lGenSettings );
        if isAccel
            lModelsOnlyInXILMode =  ...
                setdiff( [ infoStruct.silMdlRefs, infoStruct.pilMdlRefs ],  ...
                lAccelAndNormalMdlRefs );
            lModelsWithProfilingSameSTF = setdiff( infoStruct.directMdlRefs, lModelsOnlyInXILMode );
        else
            lModelsWithProfilingSameSTF = infoStruct.directMdlRefs;
        end
        infoStruct.allModelsWithCodeProfiling =  ...
            locIdentifyChildModelsWithProfiling ...
            ( h, lModelsWithProfilingSameSTF, childTargetType, lGenSettings,  ...
            fXILChildModelsWithProfilingForAccelTop );
    elseif fCodeStackProfilingTop || fCodeProfilingWCETAnalysis
        infoStruct.allModelsWithCodeProfiling = infoStruct.modelRefsAll;
    end


    if fCodeStackProfilingTop || fCodeProfilingWCETAnalysis ||  ...
            ~strcmp( get_param( infoStruct.configSet, 'CodeProfilingInstrumentation' ), 'off' )
        infoStruct.allModelsWithCodeProfiling{ end  + 1 } = infoStruct.modelName;
    end
end


loc_set_matfile_info( h, infoStruct );

end


function oChecksum = loc_compute_interface_checksum( iInfostruct, mdlRefTgtType )
oChecksum = CGXE.Utils.md5(  );


optOut = { 'checkSum',  ...
    'configSet',  ...
    'interfaceChecksum',  ...
    'parameterCheckSum',  ...
    'codeGenerationIdentifier',  ...
    'tflCheckSum',  ...
    'IncludeDirs',  ...
    'minfoFileRevision',  ...
    'buildStats',  ...
    ...
    ...
    ...
    'topModelIncChecksum',  ...
    'allModelsWithCodeProfiling',  ...
    'rebuildChecksums' ...
    ...
    , 'genCodeOnly' ...
    , 'modelRefInfo' ...
    ...
    , 'rebuildReason' ...
    , 'minfoResaveReason' ...
    , 'minfoResaveShortReason' ...
    , 'htmlrptLinks' ...
    };

for i = 1:length( optOut )
    iInfostruct.( optOut{ i } ) = [  ];
end



iInfostruct.modelInterface.ModelMultipleExecInstancesNoSupportMsg = [  ];



if ~isempty( iInfostruct.modelInterface ) && isfield( iInfostruct.modelInterface, 'BlockFcns' )
    numFcns = length( iInfostruct.modelInterface.BlockFcns );

    if numFcns == 1
        iInfostruct.modelInterface.BlockFcns.StackSize = 0;
    else
        for i = 1:numFcns
            iInfostruct.modelInterface.BlockFcns{ i }.StackSize = 0;
        end
    end
end







if strcmp( mdlRefTgtType, 'RTW' ) &&  ...
        ~isempty( iInfostruct.modelInterface ) &&  ...
        isfield( iInfostruct.modelInterface, 'Outports' )
    numOutports = numel( iInfostruct.modelInterface.Outports );
    if numOutports == 1
        iInfostruct.modelInterface.Outports.OkToMerge = [  ];
    else
        for i = 1:numOutports
            iInfostruct.modelInterface.Outports{ i }.OkToMerge = [  ];
        end
    end
end

oChecksum = CGXE.Utils.md5( oChecksum, 'infoStruct', iInfostruct );



desc = 'ModelReferenceCompileInformation';
value = iInfostruct.modelReferenceCompileInformationChecksum;
oChecksum = CGXE.Utils.md5( oChecksum, desc, value );
end


function [ oAns, mdl ] = loc_any_mdl_dirty( iMdls )

oAns = false;
mdl = '';

nMdls = length( iMdls );
for i = 1:nMdls
    mdl = iMdls{ i };
    mdlIsDirty = ( bdIsLoaded( mdl ) &&  ...
        isequal( get_param( mdl, 'Dirty' ), 'on' ) );
    if mdlIsDirty, oAns = true;return ;end
end
end


function infoStruct = locLoadMethodPostBuild( modelName,  ...
    minfo_or_binfo,  ...
    mdlRefTgtType,  ...
    fullMatFileName,  ...
    loadConfigSet )
if isfile( fullMatFileName )
    infoStruct = loc_get_matfile_info( modelName,  ...
        minfo_or_binfo,  ...
        mdlRefTgtType,  ...
        fullMatFileName,  ...
        loadConfigSet );
else
    msgID = 'RTW:buildProcess:infoMATFileMgrMatFileNotFound';
    msg = DAStudio.message( msgID, fullMatFileName );
    newExc = MException( msgID, '%s', msg );
    throw( newExc );

end
end

function infoStruct = load_create_method( h, modelName, lGenSettings, loadConfigSet )


[ ~, ~, ~, infoStruct ] = loc_find_mdl_entry( modelName,  ...
    h.minfo_or_binfo,  ...
    h.mdlRefTgtType, loadConfigSet );
if ~isempty( infoStruct )
    return
end



fileNotExists = isempty( h.fullMatFileName ) || ~isfile( h.fullMatFileName );
if fileNotExists


    paDir = coder.internal.ParallelAnchorDirManager( 'get', h.mdlRefTgtType );
    if ( ~isempty( paDir ) && ~strcmp( paDir, h.anchorDir ) )




        newH = locCreateHobj( modelName, lGenSettings, h.minfo_or_binfo,  ...
            h.mdlRefTgtType,  ...
            'anchorDir', paDir,  ...
            'markerFile', h.markerFile,  ...
            'targetDirName', h.targetDirName );






        if ~isfolder( h.matFileDir )
            mkdir( h.matFileDir );
        end

        if isfile( newH.fullMatFileName )

            copyfile( newH.fullMatFileName, h.fullMatFileName );

            fileNotExists = 0;
        end
    end

    if ( fileNotExists )
        if ( strcmp( h.minfo_or_binfo, 'minfo' ) )

            newH = locCreateHobj( modelName, lGenSettings, 'minfo',  ...
                h.mdlRefTgtType,  ...
                'anchorDir', h.anchorDir,  ...
                'markerFile', h.markerFile,  ...
                'fullMatFileName', h.fullMatFileName,  ...
                'matFileDir', h.matFileDir,  ...
                'targetDirName', h.targetDirName );
            infoStruct = loc_create_minfo( newH, modelName, [  ] );
        else
            infoStruct = [  ];
            return
        end
    else
        infoStruct = load_method( h, loadConfigSet );
    end
else
    infoStruct = load_method( h, loadConfigSet );
end
end






function infoStruct = load_method( h, loadConfigSet )
arguments
    h
    loadConfigSet = 1
end
infoStruct = loc_get_matfile_info ...
    ( h.modelName, h.minfo_or_binfo, h.mdlRefTgtType, h.fullMatFileName,  ...
    loadConfigSet );
end


function varargout = locAccessGlbMatInfoStruct( action, varargin )
persistent glb_matInfoStruct
switch action
    case 'get'
        varargout{ 1 } = glb_matInfoStruct;
    case 'set'
        glb_matInfoStruct = varargin{ 1 };
    otherwise
        assert( false, 'Invalid action' );
end
end





function [ rowIdx, j, foundField, infoStruct ] = loc_find_mdl_entry( modelName,  ...
    minfo_or_binfo,  ...
    mdlRefTgtType, loadConfigSet )
glb_matInfoStruct = locAccessGlbMatInfoStruct( 'get' );

if ( strcmpi( mdlRefTgtType, 'SIM' ) )
    j = 1;
elseif ( strcmpi( mdlRefTgtType, 'RTW' ) )
    j = 2;
else
    j = 3;
end
if strcmp( minfo_or_binfo, 'binfo' )
    j = j + 3;
end

rowIdx = [  ];
if ~isempty( glb_matInfoStruct )
    mdls = { glb_matInfoStruct.modelName };
    rowIdx = find( strcmp( modelName, mdls ) == true );
end

if nargout > 2
    infoStruct = [  ];
    foundField = false;
    foundMdl = ~isempty( rowIdx );
    if foundMdl
        if ( length( rowIdx ) > 1 )
            DAStudio.error( 'RTW:buildProcess:infoMATFileMgrDuplicateMdlName' );
        else

            foundField = ( ( loadConfigSet &&  ...
                glb_matInfoStruct( rowIdx ).targets( j ).cfgIsValid ) ||  ...
                ( ~loadConfigSet &&  ...
                glb_matInfoStruct( rowIdx ).targets( j ).structIsValid ) );

            if foundField

                infoStruct = glb_matInfoStruct( rowIdx ).targets( j ).infoStruct;
            end
        end
    end
end
end




function rowIdx = loc_init_mdl_entry( modelName )
glb_matInfoStruct = locAccessGlbMatInfoStruct( 'get' );
glb_matInfoStruct( end  + 1 ).modelName = modelName;
rowIdx = length( glb_matInfoStruct );


s = get_default_info_struct;
s.structIsValid = false;
s.cfgIsValid = false;

glb_matInfoStruct( rowIdx ).targets = repmat( s, 6, 1 );

locAccessGlbMatInfoStruct( 'set', glb_matInfoStruct );
end




function loc_invalidate_infofile_cache( h )
glb_matInfoStruct = locAccessGlbMatInfoStruct( 'get' );
[ rowIdx, j ] = loc_find_mdl_entry( h.modelName, h.minfo_or_binfo, h.mdlRefTgtType );
if ( ~isempty( rowIdx ) )
    glb_matInfoStruct( rowIdx ).targets( j ).structIsValid = false;
    glb_matInfoStruct( rowIdx ).targets( j ).cfgIsValid = false;
    locAccessGlbMatInfoStruct( 'set', glb_matInfoStruct );
end
end



function loc_set_matfile_info( h, infoStructAndCfg )



infoStruct = infoStructAndCfg;
infoStruct.configSet = [  ];
infoStructConfigSet = infoStructAndCfg.configSet;




if ( strcmp( h.minfo_or_binfo, 'binfo' ) )
    infoStruct.interfaceChecksum = loc_compute_interface_checksum( infoStruct, h.mdlRefTgtType );
end


[ rowIdx, j ] = loc_find_mdl_entry( h.modelName,  ...
    h.minfo_or_binfo,  ...
    h.mdlRefTgtType );
if isempty( rowIdx )
    rowIdx = loc_init_mdl_entry( h.modelName );
end

glb_matInfoStruct = locAccessGlbMatInfoStruct( 'get' );

glb_matInfoStruct( rowIdx ).targets( j ).infoStruct = infoStructAndCfg;
glb_matInfoStruct( rowIdx ).targets( j ).structIsValid = true;
glb_matInfoStruct( rowIdx ).targets( j ).cfgIsValid = true && ~isempty( infoStructConfigSet );


if ( strcmp( h.minfo_or_binfo, 'binfo' ) )
    glb_matInfoStruct( rowIdx ).targets( j ).infoStruct.interfaceChecksum =  ...
        infoStruct.interfaceChecksum;
end

locAccessGlbMatInfoStruct( 'set', glb_matInfoStruct );
end





function infoStruct = loc_get_matfile_info( modelName,  ...
    minfo_or_binfo,  ...
    mdlRefTgtType,  ...
    fullMatFileName,  ...
    loadConfigSet )

[ rowIdx, j, foundField, infoStruct ] = loc_find_mdl_entry( modelName,  ...
    minfo_or_binfo,  ...
    mdlRefTgtType, loadConfigSet );

if ~isempty( infoStruct )
    return ;
end

foundMdl = ~isempty( rowIdx );
if ~foundMdl
    rowIdx = loc_init_mdl_entry( modelName );
end
glb_matInfoStruct = locAccessGlbMatInfoStruct( 'get' );

if ~foundField && isfile( fullMatFileName )
    if loadConfigSet

        info = load( fullMatFileName );
        infoStruct = info.infoStruct;
        infoStruct.configSet = info.infoStructConfigSet;
    else
        info = load( fullMatFileName, 'infoStruct' );
        infoStruct = info.infoStruct;
        infoStruct.configSet = [  ];
    end


    glb_matInfoStruct( rowIdx ).targets( j ).infoStruct = infoStruct;
    glb_matInfoStruct( rowIdx ).targets( j ).structIsValid = true;
    glb_matInfoStruct( rowIdx ).targets( j ).cfgIsValid = loadConfigSet ...
        && ~isempty( info.infoStructConfigSet );
else
    infoStruct = [  ];
end

locAccessGlbMatInfoStruct( 'set', glb_matInfoStruct );
end

function isAccel = is_accel( mdlRefTgtType, genSet )
[ ~, stfName ] = fileparts( genSet.SystemTargetFile );
isAccel = strcmp( stfName, 'accel' ) && strcmp( mdlRefTgtType, 'NONE' );
end


function targetDir = get_target_dir( modelName, mdlRefTgtType )

folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( modelName );

switch mdlRefTgtType
    case 'SIM'
        targetDir = folders.Simulation.ModelReferenceCode;
    case 'RTW'
        targetDir = folders.CodeGeneration.ModelReferenceCode;
    otherwise
        assert( strcmp( mdlRefTgtType, 'NONE' ), 'Unexpected target type, %s', mdlRefTgtType );

        targetDir = folders.CodeGeneration.ModelCode;

end
end







function errorToEval = checkForValidVariantObjectNameOrCondition( variant )

errorToEval = false;

if ( isvarname( strtrim( variant ) ) )
    return ;
end


if isempty( variant )
    errorToEval = true;
    return ;
end


if strfind( strtrim( variant ), '%' ) == 1
    errorToEval = true;
    return ;
end
errorToEval = Simulink.variant.keywords.isValidVariantKeyword( variant );

end


function [ value, error, newExc, isVarFromMask ] = loc_evaluateVariantObject( iMdl, blk, variant )
value = [  ];
newExc = '';
isVarFromMask = false;


load_system( iMdl );

isVarObj = existsInGlobalScope( iMdl, variant );
if isVarObj
    isVarObj = evalinGlobalScope( iMdl, [ 'isa(', variant, ', ''Simulink.Variant'')||isa(', variant, ', ''Simulink.slobject.Variant'');' ] );
end

if isVarObj
    try
        condition = evalinGlobalScope( iMdl, [ variant, '.Condition' ] );
        value = slInternal( 'evalSimulinkBooleanExprInGlobalScopeWS', get_param( iMdl, 'Handle' ), condition );
        error = ~islogical( value );
    catch ME
        error = true;
        errID = 'RTW:buildProcess:infoMATFileMgrConditionExprEvalError';
        errmsg = DAStudio.message( errID, condition );
        newExc = MException( errID, '%s', errmsg );
        newExc = newExc.addCause( ME );
        return ;
    end
else
    try
        if ( slfeature( 'VariantControlFromMask' ) )
            [ value, isVarFromMask ] = slInternal( 'evalSimulinkBooleanExprInAnyWks', get_param( blk, 'Handle' ), variant );
        else
            value = slInternal( 'evalSimulinkBooleanExprInGlobalScopeWS', get_param( iMdl, 'Handle' ), variant );
        end
        error = ~islogical( value );
    catch ME
        error = true;
        errID = 'RTW:buildProcess:infoMATFileMgrConditionExprEvalError';
        errmsg = DAStudio.message( errID, variant );
        newExc = MException( errID, '%s', errmsg );
        newExc = newExc.addCause( ME );
        return ;
    end
end
end




function findSysOpts = loc_getFindSystemOpts( variantControl )




findSysOpts = { 'FollowLinks', 'on', 'LookUnderMasks', 'all',  ...
    'LookUnderReadProtectedSubsystems', 'on' };
if strcmpi( variantControl, 'ActiveVariants' ) || isempty( variantControl )
    findSysOpts = [ findSysOpts, 'MatchFilter', { @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices } ];
elseif strcmpi( variantControl, 'ActivePlusCodeVariants' )
    findSysOpts = [ findSysOpts, 'MatchFilter', { @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices } ];
end
end

function ret = loc_variantBlockForMinfoUpdate( blk )
bType = get_param( blk, 'BlockType' );
ret = 0;
if ( strcmp( bType, 'SubSystem' ) && strcmp( get_param( blk, 'Variant' ), 'on' ) ) ||  ...
        strcmp( bType, 'VariantSource' ) ||  ...
        strcmp( bType, 'VariantSink' )
    ret = 1;
end
end


function [ info, isVarFromMask ] = loc_getVariantObjects( iMdl, iFindSysOpts )
info = struct( 'name', {  }, 'active', {  } );%#ok<NASGU>
isvfm = 0;
variantBlks = find_system( iMdl, iFindSysOpts{ : }, 'type', 'block' );

filterVarNonSTBlocks = arrayfun( @( x )loc_variantBlockForMinfoUpdate( x ), variantBlks );
cellArrayOfBlocks = [ variantBlks( filterVarNonSTBlocks == 1 ) ];

try
    slInternal( 'determineActiveVariant', cellArrayOfBlocks );
catch me
    throw( me )
end

objects = loc_getVariantObjectsFromCellArrayOfBlocks( cellArrayOfBlocks );

values = cell( size( objects ) );

for i = 1:length( objects )
    object = objects{ i };
    if ( slfeature( 'VariantControlFromMask' ) )
        [ val, err, newExc, isvfm ] = loc_evaluateVariantObject( iMdl, object.blk, object.var );
    else
        [ val, err, newExc, ~ ] = loc_evaluateVariantObject( iMdl, 0, object );
    end


    if err
        throw( newExc );
    end

    values{ i } = val;
end
isVarFromMask = isvfm;
info = struct( 'name', objects, 'active', values );
end






function [ objects ] = loc_addVariantControlsToMInfo( blk, objects )
object.blk = blk;
if strcmp( get_param( blk, 'BlockType' ), 'SubSystem' )
    variants = get_param( blk, 'Variants' );

    for idx = 1:length( variants )

        if Simulink.variant.keywords.isValidVariantKeyword( variants( idx ).Name )
            continue ;
        end
        object.var = variants( idx ).Name;
        err = checkForValidVariantObjectNameOrCondition( object.var );
        if ~err
            objects{ end  + 1 } = object;%#ok<AGROW>
        end
    end
else
    variants = get_param( blk, 'VariantControls' );
    for idx = 1:length( variants )
        if Simulink.variant.keywords.isValidVariantKeyword( variants{ idx } )
            continue ;
        end
        object.var = variants{ idx };
        err = checkForValidVariantObjectNameOrCondition( object.var );
        if ~err
            objects{ end  + 1 } = object;%#ok<AGROW>
        end
    end
end
end

function [ objects ] = loc_getVariantObjectsFromCellArrayOfBlocks( cellArrayOfBlocks )
objects = {  };

for i = 1:length( cellArrayOfBlocks )
    blk = cellArrayOfBlocks{ i };




    if ( ~isempty( get_param( blk, 'LabelModeActiveChoice' ) ) )
        continue ;
    end






    if isequal( get_param( blk, 'VariantActivationTime' ), 'startup' )
        continue ;
    end

    if ( slfeature( 'VariantControlFromMask' ) )
        objects = loc_addVariantControlsToMInfo( blk, objects );
    else
        variants = get_param( blk, 'Variants' );

        for j = 1:length( variants )
            object = variants( j ).Name;



            err = checkForValidVariantObjectNameOrCondition( object );
            if ~err
                objects{ end  + 1 } = object;%#ok<AGROW>
            end
        end
    end
end
if ( ~slfeature( 'VariantControlFromMask' ) )
    objects = unique( objects );
end
end


function hasCS = loc_getClientsOrServers( iMdl )

findSysOpts = loc_getFindSystemOpts( 'ActivePlusCodeVariants' );

hasCS = false;
subsysBlks = find_system( iMdl, findSysOpts{ : }, 'BlockType', 'SubSystem' );
for i = 1:length( subsysBlks )
    subsysBlk = subsysBlks{ i };
    if strcmpi( get_param( subsysBlk, 'IsSimulinkFunction' ), 'on' )
        hasCS = true;
        break ;
    end
end
if ~hasCS
    clientBlks = find_system( iMdl, findSysOpts{ : }, 'BlockType', 'FunctionCaller' );
    hasCS = ~isempty( clientBlks );
end
end


function infoStruct = get_to_from_file_blocks( iMdl, infoStruct )


    function fileIOArray = populate_fileio_info( blocks )
        fileIOArray = cell( 0 );
        for blk = 1:length( blocks )
            fileIO.blockPath = blocks{ blk };
            fileIO.originalFileName = get_param( blocks{ blk }, 'Filename' );
            fileIO.model = iMdl;
            fileIOArray = [ fileIOArray;fileIO ];%#ok
        end
    end

findSysOpts = loc_getFindSystemOpts( '' );

mdlToFileBlocks = find_system( iMdl, findSysOpts{ : }, 'BlockType', 'ToFile' );
infoStruct.toFileBlocks = populate_fileio_info( mdlToFileBlocks );

mdlFromFileBlocks = find_system( iMdl, findSysOpts{ : }, 'BlockType', 'FromFile' );
infoStruct.fromFileBlocks = populate_fileio_info( mdlFromFileBlocks );

instSigs = get_param( iMdl, 'InstrumentedSignals' );
infoStruct.hasInstrumentedSignals = ~isempty( instSigs ) && instSigs.Count > 0;
end




function oStruct = get_mdlref_info_for_minfo( iMdl, isCodeVariants )










oStruct.modelRefs = {  };
oStruct.accelMdlRefs = {  };
oStruct.normalMdlRefs = {  };
oStruct.silMdlRefs = {  };
oStruct.pilMdlRefs = {  };
oStruct.protectedModelRefs = {  };
oStruct.protectedModelRefsWithTopModelXIL = {  };
oStruct.protectedModelRefsBuildDirsAll = {  };
oStruct.unresolvedMdlRefs = struct( 'name', {  }, 'protected', {  }, 'block', {  } );
oStruct.variantObjects = struct( 'name', {  }, 'active', {  } );
oStruct.variantsFromMask = false;





findSysOpts = loc_getFindSystemOpts( 'ActivePlusCodeVariants' );

aBlks = find_system( iMdl, findSysOpts{ : }, 'BlockType', 'ModelReference' );

[ objects, isVarFromMask ] = loc_getVariantObjects( iMdl, findSysOpts );
oStruct.variantObjects = objects;
oStruct.variantsFromMask = isVarFromMask;


[ names, modes, codeInterface, nameDialogs, blocks ] = coder.internal.getNonUniqueModelRefsByBlock( aBlks, isCodeVariants );


resolvedMap = containers.Map(  );

unresolvedNames = {  };
unresolvedProtected = {  };
unresolvedBlks = {  };


for i = 1:length( nameDialogs )
    nameDialog = nameDialogs{ i };
    name = names{ i };


    if ( resolvedMap.isKey( nameDialog ) )
        protected = resolvedMap( nameDialog );
    else
        protected = slInternal( 'getReferencedModelFileInformation', nameDialog );
        resolvedMap( nameDialog ) = protected;
    end



    if ( isequal( nameDialog, name ) )
        unresolvedNames{ end  + 1 } = name;%#ok<AGROW>
        unresolvedProtected{ end  + 1 } = protected;%#ok<AGROW>
        unresolvedBlks{ end  + 1 } = blocks{ i };%#ok<AGROW>
    end



    if ( protected )
        oStruct.protectedModelRefs{ end  + 1 } = name;
        oStruct.protectedModelRefsBuildDirsAll{ end  + 1 } = RTW.getBuildDir( name, 'ModelRefRelativeBuildDir' );
    else
        oStruct.modelRefs{ end  + 1 } = name;
    end

    mode = modes{ i };
    isTopModelXIL = strcmp( codeInterface{ i }, 'Top model' );
    switch ( mode )
        case 'Normal'
            oStruct.normalMdlRefs{ end  + 1 } = name;
        case 'Software-in-the-loop (SIL)'
            oStruct.silMdlRefs{ end  + 1 } = name;
            if isTopModelXIL && protected
                oStruct.protectedModelRefsWithTopModelXIL{ end  + 1 } = name;
            end
        case 'Processor-in-the-loop (PIL)'
            oStruct.pilMdlRefs{ end  + 1 } = name;
            if isTopModelXIL && protected
                oStruct.protectedModelRefsWithTopModelXIL{ end  + 1 } = name;
            end
        case 'Accelerator'



            oStruct.accelMdlRefs{ end  + 1 } = name;
        otherwise
            assert( false, 'Unexpected simulation mode "%s".', mode );
    end

end


fieldsToUnique = { 'modelRefs', 'normalMdlRefs', 'silMdlRefs',  ...
    'pilMdlRefs', 'accelMdlRefs', 'protectedModelRefs' };
for i = 1:length( fieldsToUnique )
    field = fieldsToUnique{ i };

    if ( ~isempty( oStruct.( field ) ) )
        oStruct.( field ) = unique( oStruct.( field ) );
    end
end


oStruct.protectedModelRefsBuildDirsAll = repmat( { '' }, 1, length( oStruct.protectedModelRefs ) );


if ( ~isempty( unresolvedNames ) )
    [ unresolvedNames, indexes ] = unique( unresolvedNames );
    unresolvedProtected = unresolvedProtected( indexes );
    unresolvedBlks = unresolvedBlks( indexes );

    oStruct.unresolvedMdlRefs = struct( 'name', unresolvedNames,  ...
        'protected', unresolvedProtected,  ...
        'block', unresolvedBlks );
end



oStruct.modelRefs = oStruct.modelRefs';
end


function oStruct = get_server_info_for_minfo( iMdl, oStruct )


oStruct.clientsOrServers = loc_getClientsOrServers( iMdl );
end


function [ matFileDir, matFileName ] =  ...
    loc_getMatFileNames( mdlRefTgtType, anchorDir, targetDirName, minfo_or_binfo )

matFileDir = fullfile( anchorDir, targetDirName, 'tmwinternal' );

mdlRefStr = '';
if ~strcmpi( mdlRefTgtType, 'NONE' )
    mdlRefStr = '_mdlref';
end

matFileName = fullfile( matFileDir, [ minfo_or_binfo, mdlRefStr, '.mat' ] );
end









function oStr = loc_strip_comments( iStr )


newLIdx = regexp( iStr, '\n' );
strlen = length( iStr );
newLineLength = length( newline );
str = [  ];
startIdx = 1;
numRows = length( newLIdx );
for i = 1:length( newLIdx )
    str{ i } = iStr( startIdx:newLIdx( i ) );%#ok<AGROW>
    startIdx = newLIdx( i ) + newLineLength;
end



if ( startIdx < strlen )
    str{ length( newLIdx ) + 1 } = iStr( startIdx:end  );
    numRows = numRows + 1;
end


oStr = '';
for i = 1:numRows
    s = regexp( str{ i }, '^\s*%', 'once' );
    if isempty( s )
        oStr = [ oStr, str{ i } ];%#ok<AGROW>
    end
end


oStr = strtrim( oStr );
end



function relativePathToAnchor = loc_get_relative_path_to_anchor( modelName, mdlRefTgtType )





folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( modelName );

if ( strcmpi( get_param( modelName, 'SystemTargetFile' ), 'accel.tlc' ) )
    relativePathToAnchor = folders.Accelerator.relativePathToRoot( 'ModelReferenceCode' );
elseif ( strcmpi( get_param( modelName, 'SystemTargetFile' ), 'raccel.tlc' ) )
    relativePathToAnchor = folders.RapidAccelerator.relativePathToRoot( 'ModelReferenceCode' );
elseif strcmpi( mdlRefTgtType, 'SIM' )
    relativePathToAnchor = folders.Simulation.relativePathToRoot( 'ModelReferenceCode' );
elseif strcmpi( mdlRefTgtType, 'RTW' )
    relativePathToAnchor = folders.CodeGeneration.relativePathToRoot( 'ModelReferenceCode' );
elseif strcmpi( mdlRefTgtType, 'NONE' )
    relativePathToAnchor = folders.CodeGeneration.relativePathToRoot( 'ModelCode' );
else
    assert( false, 'Unrecognised model ref target type' );
end
end






function infoStruct = get_default_info_struct
infoStruct.relativePathToAnchor = '';
infoStruct.modelName = '';
infoStruct.mVersion = 0.0;
infoStruct.modelRefs = {  };
infoStruct.protectedModelRefs = {  };
infoStruct.accelMdlRefs = {  };
infoStruct.normalMdlRefs = {  };
infoStruct.silMdlRefs = {  };
infoStruct.pilMdlRefs = {  };
infoStruct.unresolvedMdlRefs = [  ];
infoStruct.variantObjects = [  ];
infoStruct.variantsFromMask = false;
infoStruct.modelRefsCodeVar = {  };
infoStruct.protectedModelRefsCodeVar = {  };
infoStruct.accelMdlRefsCodeVar = {  };
infoStruct.normalMdlRefsCodeVar = {  };
infoStruct.silMdlRefsCodeVar = {  };
infoStruct.pilMdlRefsCodeVar = {  };
infoStruct.unresolvedMdlRefsCodeVar = [  ];
infoStruct.variantObjectsCodeVar = [  ];
infoStruct.modelRefInfo = '';
infoStruct.modelRefsActiveVar = {  };
infoStruct.protectedModelRefsActiveVar = {  };
infoStruct.accelMdlRefsActiveVar = {  };
infoStruct.normalMdlRefsActiveVar = {  };
infoStruct.silMdlRefsActiveVar = {  };
infoStruct.pilMdlRefsActiveVar = {  };
infoStruct.unresolvedMdlRefsActiveVar = [  ];
infoStruct.variantObjectsActiveVar = [  ];
infoStruct.toFileBlocks = {  };
infoStruct.fromFileBlocks = {  };
infoStruct.hasInstrumentedSignals = false;
infoStruct.modelRefsAll = {  };
infoStruct.modelRefsBuildDirsAll = {  };
infoStruct.protectedModelRefsBuildDirsAll = {  };
infoStruct.protectedModelRefsBuildDirsAllActiveVar = {  };
infoStruct.protectedModelRefsBuildDirsAllCodeVar = {  };
infoStruct.protectedModelRefsWithTopModelXIL = {  };
infoStruct.protectedModelRefsWithTopModelXILActiveVar = {  };
infoStruct.protectedModelRefsWithTopModelXILCodeVar = {  };
infoStruct.modelRefBuildOrder = {  };
infoStruct.clientsOrServers = false;
infoStruct.mdlInfos = {  };
infoStruct.makeCmd = '';
infoStruct.isLibrary = 'No';
infoStruct.linkLibraries = {  };
infoStruct.linkLibrariesFullPaths = {  };
infoStruct.directlinkLibrariesFullPaths = {  };
infoStruct.modelLibName = '';
infoStruct.modelLibFullName = '';
infoStruct.configSetChecksum = '';
infoStruct.configSetWSVarName = '';
infoStruct.designDataLocation = '';
infoStruct.srcDir = '';
infoStruct.srcCoreDir = '';
infoStruct.BuildDir = '';

infoStruct.buildStats = [  ];
infoStruct.rtwSfcnStr = [  ];
infoStruct.allModelsWithCodeProfiling = {  };
infoStruct.topModelIncChecksum = [  ];
infoStruct.sharedSourcesDir = '';
infoStruct.sharedBinaryDir = '';
infoStruct.SourceDirs = {  };
infoStruct.IncludeDirs = {  };
infoStruct.modelInterface = {  };
infoStruct.globalsInfo = {  };
infoStruct.configSet = [  ];
infoStruct.areStatesLogged = false;
infoStruct.mdlDeps = {  };
infoStruct.libDeps = {  };
infoStruct.ssrefDeps = {  };
infoStruct.stateflowRebuildInfoForMATLABFiles = [  ];
infoStruct.mlsysblockRebuildInfoForMATLABSystemDeps = [  ];
infoStruct.dataflowRebuildInfo = [  ];
infoStruct.simHardwareAccelerationInfo = [  ];
infoStruct.rtwSystemTargetFile = '';
infoStruct.mdlRefTgtDir = '';
infoStruct.mdlRefSimDir = '';
infoStruct.matFileSavedWhenMdlWasDirty = false;
infoStruct.computer = '';
infoStruct.checkSum = [  ];
infoStruct.codeGenerationIdentifier = [  ];
infoStruct.sfcnInfo =  - 1;
infoStruct.buildSucceeded = false;
infoStruct.htmlrptLinks = {  };
infoStruct.IsSILDebuggingEnabled = false;
infoStruct.IsExtModeXCP = false;
infoStruct.AUTOSARClientBlockOperationNames = {  };
infoStruct.AUTOSARInvokeOperationConfigSubsystems = {  };
infoStruct.IsAutosarRTEHeaderFileGenerationEnabled = false;
infoStruct.TemplateMakefile = '';
infoStruct.ParameterArgumentNames = '';
infoStruct.TargetExecutableFullName = '';
infoStruct.containsNonInlinedSFcn = false;
infoStruct.signalResolutionControl = 'UseLocalSettings';

infoStruct.genCodeOnly = 0;
infoStruct.IsPortableWordSizesEnabled = false;
infoStruct.isERTTarget = 0;
infoStruct.targetLanguage = 'C';
infoStruct.IsGPUCodegen = false;
infoStruct.targetCompiler = locGetDefaultTargetCompiler(  );
infoStruct.usingVarStepSolver = true;
infoStruct.matFileName = '';
infoStruct.cscChecksums = [  ];
infoStruct.SystemMap = {  };
infoStruct.SourceSubsystemName = '';
infoStruct.hasVariants = false;
infoStruct.unresolvedMdlRefs = struct( 'name', {  }, 'protected', {  }, 'block', {  } );
infoStruct.rebuildChecksums = [  ];
infoStruct.internalMdlDeps = [  ];
infoStruct.modelWorkspaceDeps = [  ];
infoStruct.DataObjectOwnerSetting = struct( 'name', {  }, 'type', {  },  ...
    'rootIOSignal', {  }, 'dataStore', {  }, 'owner', {  }, 'ownerFound', {  } );
infoStruct.DataObjectAutoAndFileScopeSharedness = struct( 'name', {  }, 'type', {  },  ...
    'rootIOSignal', {  }, 'dataStore', {  }, 'dataScope', {  }, 'shared', {  } );
infoStruct.MdlRefSampleTimeMapStruct = {  };


infoStruct.GeneralDataFromTLC = [  ];
infoStruct.interfaceChecksum = [  ];
infoStruct.parameterCheckSum = [  ];
infoStruct.tflCheckSum = [  ];
infoStruct.minfoFileRevision = uint32( 0 );
infoStruct.buildHooks = [  ];
infoStruct.directMdlRefs = {  };
infoStruct.fTopModelStandalone = true;
infoStruct.firstModel = '';
infoStruct.modelHasTunableStructParams = false;
infoStruct.modelReferenceCompileInformationChecksum = '';
infoStruct.rebuildReason = struct( 'date', {  }, 'reason', {  } );
infoStruct.minfoResaveReason = '';
infoStruct.minfoResaveShortReason = '';

if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0
    infoStruct.enableAccessToBaseWorkspace = '';
end

infoStruct.CCDepInfoStructs = struct( 'fullCheckSum', {  }, 'ccInfo', {  } );
infoStruct.sharedCoderDictionaryLocation = '';
infoStruct.sharedCoderDictionaryCheckSum = '';
infoStruct.modelWorkspaceChangedUsingSimInput = false;
infoStruct.signalLoggingChangedUsingSimInput = false;
infoStruct.IsProtectedModelRefSILPILOverride = false;
infoStruct.hasProtectedModelsInXIL = false;
infoStruct.dynamicEnumTypeChecksums = struct( 'name', {  }, 'checksum', [  ] );
end





function targetCompiler = locGetDefaultTargetCompiler(  )
targetCompiler.compStr = '';
targetCompiler.TMFBased = false;
end








function utilStruct = get_target_characteristic( h, isSimTarget, buildHooks,  ...
    fTopModelStandalone )

rtwprivate( 'ec_set_replacement_flag', h.modelName );

if ~isSimTarget

    utilStruct = coder.internal.getDefaultUtilStruct( h.modelName,  ...
        buildHooks,  ...
        h.mdlRefTgtType,  ...
        fTopModelStandalone,  ...
        getActiveConfigSet( h.modelName ) );
else

    if slfeature( 'ModelReferenceHonorsSimTargetLang' )
        utilStruct.targetInfoStruct.SimTargetLang = get_param( getActiveConfigSet( h.modelName ), 'SimTargetLang' );
    end
end


modelCodegenMgr = coder.internal.ModelCodegenMgr.getInstance( h.modelName );
lToolchainOrTMFName = modelCodegenMgr.MCMToolchainOrTMFName;
utilStruct.targetInfoStruct.toolchainOrTMF = lToolchainOrTMFName;

end




function utilsDir = get_utils_dir_name( h, infoStruct, firstModel, buildHooks,  ...
    fTopModelStandalone, checkSharedUtils )

anchorDir = h.anchorDir;
modelName = h.modelName;
targetName = h.targetDirName;

folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( modelName );
if strcmp( targetName, 'raccel' )
    utilsDir = fullfile( anchorDir, folders.Simulation.SharedUtilityCode );
    isSimTarget = true;
else

    switch ( h.mdlRefTgtType )
        case { 'SIM', 'SIM-ACCEL' }
            utilsDir = fullfile( anchorDir, folders.Simulation.SharedUtilityCode );
            isSimTarget = true;
        case 'RTW'
            utilsDir = fullfile( anchorDir, folders.CodeGeneration.SharedUtilityCode );
            isSimTarget = false;
        case 'NONE'


            isSimTarget = slprivate( 'isSimulationBuild', modelName, h.mdlRefTgtType );
            if isSimTarget
                utilsDir = fullfile( anchorDir, folders.Simulation.SharedUtilityCode );
            else
                utilsDir = fullfile( anchorDir, folders.CodeGeneration.SharedUtilityCode );
            end
        otherwise
            DAStudio.error( 'RTW:buildProcess:unknownModelRefTargetType', mdlRefTgtType );
    end
end

utilStruct = get_target_characteristic( h, isSimTarget, buildHooks,  ...
    fTopModelStandalone );





if checkSharedUtils == 1 &&  ...
        strcmp( h.mdlRefTgtType, 'NONE' ) &&  ...
        ~locAnyModelRefsInInfoStruct( infoStruct ) &&  ...
        ~strcmp( get_param( modelName, 'UtilityFuncGeneration' ), 'Shared location' ) &&  ...
        isempty( get_param( modelName, 'ExistingSharedCode' ) )
    rtwprivate( 'rtw_create_directory_path', utilsDir );
    return ;

elseif checkSharedUtils == 2 &&  ...
        strcmp( h.mdlRefTgtType, 'NONE' ) &&  ...
        ~rtw_gen_shared_utils( modelName )
    rtwprivate( 'rtw_create_directory_path', utilsDir );
    return ;
end




hashTblFile = fullfile( utilsDir, 'checksummap.mat' );
isOk = true;
codeCoverageChecksumOk = true;
if ~exist( hashTblFile, 'file' )


    rtwprivate( 'rtw_create_directory_path', utilsDir );
    utilStruct.utilsDirectoryName = '.';
    hashTbl = utilStruct;
    save( hashTblFile, 'hashTbl' );
else


    fileContents = load( hashTblFile );
    comp = coder.internal.SharedUtilsChecksumComparison( modelName, utilsDir, utilStruct, fileContents.hashTbl );
    isOk = ~comp.DifferencesExist;
end




if ~isOk

    hasOtherModels = locAnyModelRefsInInfoStruct( infoStruct );

    if hasOtherModels ...
            && ~strcmp( modelName, firstModel ) ...
            || ( sfpref( 'UseLCC64ForSimulink' ) )

        comp.addSolutionMessege( 'RTW:buildProcess:infoMATFileMgrModelConflict', firstModel );
    else
        comp.addSolutionMessege( 'RTW:buildProcess:sharedUtilsInconsistentFolderFixits', utilsDir, modelName );
    end

    comp.throwError( 'RTW:buildProcess:infoMATFileMgrBuildDirInconsistent',  ...
        modelName,  ...
        utilsDir );
end
if ~codeCoverageChecksumOk
    checksummap = load( hashTblFile );
    checksummap.hashTbl.targetInfoStruct.CodeCoverageChecksum =  ...
        utilStruct.targetInfoStruct.CodeCoverageChecksum;
    save( hashTblFile, '-struct', 'checksummap' );
end


end




function infoStruct = loc_combine_IncludeDirs( IncludeDirs, SourceDirs, infoStruct )


infoStruct.IncludeDirs = union( IncludeDirs, infoStruct.IncludeDirs, 'stable' );
infoStruct.SourceDirs = union( SourceDirs, infoStruct.SourceDirs, 'stable' );
end













function anchorDir = locGetAnchorDir( mdl, mdlRefTgtType )

fgCfg = Simulink.fileGenControl( 'getConfig' );

switch ( mdlRefTgtType )
    case { 'SIM', 'SIM-ACCEL' }
        anchorDir = fgCfg.CacheFolder;
    case 'RTW'
        anchorDir = fgCfg.CodeGenFolder;
    case 'NONE'


        if slprivate( 'isSimulationBuild', mdl, mdlRefTgtType )
            anchorDir = fgCfg.CacheFolder;
        else
            anchorDir = fgCfg.CodeGenFolder;
        end
    otherwise
        DAStudio.error( 'RTW:buildProcess:unknownModelRefTargetType', mdlRefTgtType );
end
end













function markerFile = locGetMarkerFile( mdl, mdlRefTgtType )

folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( mdl );

switch ( mdlRefTgtType )
    case { 'SIM', 'SIM-ACCEL' }
        markerFile = folders.Simulation.MarkerFile;
    case 'RTW'
        markerFile = folders.CodeGeneration.MarkerFile;
    case 'NONE'


        if slprivate( 'isSimulationBuild', mdl, mdlRefTgtType )
            markerFile = folders.Simulation.MarkerFile;
        else
            markerFile = folders.CodeGeneration.MarkerFile;
        end
    otherwise
        DAStudio.error( 'RTW:buildProcess:unknownModelRefTargetType', mdlRefTgtType );
end
end



function targetDirName = i_getTargetDirName( targetDirName,  ...
    mdlRefTgtType, genSet, originalTargetType, modelName )



if isempty( targetDirName )
    if strcmp( mdlRefTgtType, 'NONE' )


        if is_accel( mdlRefTgtType, genSet )
            tgtTypeForBinfoOrMinfo = 'SIM';
        else
            tgtTypeForBinfoOrMinfo = 'RTW';
        end
    else
        tgtTypeForBinfoOrMinfo = mdlRefTgtType;
    end

    tDirName = get_target_dir( modelName, tgtTypeForBinfoOrMinfo );
    targetDirName = tDirName;
end



if ( isequal( originalTargetType, 'SIM-ACCEL' ) )
    folders = Simulink.filegen.internal.FolderConfiguration.getCachedConfig( modelName );
    targetDirName = folders.Simulation.ModelReferenceCode;
end
end



function mdlRefTgtType = i_getMdlRefTgtType( mdlRefTgtType, modelName )









if ( slfeature( 'directEmitCExecution' ) > 0 )







    if ( bdIsLoaded( modelName ) && isequal( get_param( modelName, 'VmBasedExecution' ), 'on' ) )
        mdlRefTgtType = 'NONE';
    end
end


if ( isequal( mdlRefTgtType, 'SIM-ACCEL' ) )
    mdlRefTgtType = 'NONE';
end
end













function newObj = locCreateHobj( modelName, genSet, minfo_or_binfo,  ...
    mdlRefTgtType, varargin )
persistent p;

assert( any( strcmp( mdlRefTgtType, { 'SIM', 'RTW', 'NONE', 'SIM-ACCEL' } ) ),  ...
    'Target type must be one of allowed values' )

assert( any( strcmp( minfo_or_binfo, { 'minfo', 'binfo' } ) ),  ...
    'minfo_or_binfo must be one of allowed values' )

if isempty( p )
    p = inputParser;
    p.addParameter( 'anchorDir', '', @ischar );
    p.addParameter( 'markerFile', '', @ischar );
    p.addParameter( 'fullMatFileName', 'minfo.mat', @ischar );
    p.addParameter( 'matFileDir', '', @ischar );
    p.addParameter( 'targetDirName', '', @ischar );
end
p.parse( varargin{ : } );


originalTargetType = mdlRefTgtType;
mdlRefTgtType = i_getMdlRefTgtType( mdlRefTgtType, modelName );


targetDirName = i_getTargetDirName( p.Results.targetDirName,  ...
    mdlRefTgtType, genSet, originalTargetType, modelName );


if any( strcmp( 'anchorDir', p.UsingDefaults ) )
    anchorDir = locGetAnchorDir( modelName, originalTargetType );
else
    anchorDir = p.Results.anchorDir;
end


if any( strcmp( 'markerFile', p.UsingDefaults ) )
    markerFile = locGetMarkerFile( modelName, mdlRefTgtType );
else
    markerFile = p.Results.markerFile;
end


matFileIsDefault = any( strcmp( 'fullMatFileName', p.UsingDefaults ) );
matFileDirIsDefault = any( strcmp( 'matFileDir', p.UsingDefaults ) );
if ( matFileIsDefault || matFileDirIsDefault )
    [ matFileDir, matFileName ] = loc_getMatFileNames ...
        ( mdlRefTgtType, anchorDir, targetDirName, minfo_or_binfo );
    if matFileIsDefault
        fullMatFileName = matFileName;
    end
else
    matFileDir = p.Results.matFileDir;
    fullMatFileName = p.Results.fullMatFileName;
end



newObj = coder.internal.InfoMat( modelName, mdlRefTgtType, minfo_or_binfo,  ...
    anchorDir, markerFile, fullMatFileName,  ...
    matFileDir, targetDirName );

end

function descendentsWithCodeProfiling = locIdentifyChildModelsWithProfiling ...
    ( h, candidateModelRefs, childTargetType, lGenSettings,  ...
    fXILChildModelsWithProfilingForAccelTop )















descendentsWithCodeProfiling = {  };
for i = 1:length( candidateModelRefs )
    childModel = candidateModelRefs{ i };


    newH = locCreateHobj( childModel,  ...
        lGenSettings,  ...
        'binfo',  ...
        childTargetType,  ...
        'anchorDir', h.anchorDir,  ...
        'markerFile', h.markerFile );
    childInfoStruct = load_method( newH );

    descendentsWithCodeProfiling = [ descendentsWithCodeProfiling ...
        , childInfoStruct.allModelsWithCodeProfiling ];%#ok<AGROW>
end
descendentsWithCodeProfiling = [ descendentsWithCodeProfiling ...
    , fXILChildModelsWithProfilingForAccelTop ];
descendentsWithCodeProfiling = unique( descendentsWithCodeProfiling, 'stable' );
end


function infoStruct = locPopulateInfoStructForMdlRefs ...
    ( h, infoStruct, childModel, childTargetType, lGenSettings )

targetDir = '';

protectedModelReferences = strcmp( childModel, infoStruct.protectedModelRefs );
isProtected = any( protectedModelReferences );
if isProtected && ~isempty( infoStruct.protectedModelRefsBuildDirsAll )

    targetDir = unique( infoStruct.protectedModelRefsBuildDirsAll( protectedModelReferences ), 'stable' );
    assert( isscalar( targetDir ), 'Must have unique build directory' );

    if isempty( targetDir{ 1 } )
        if sl( 'isSimulationBuild', h.modelName, h.mdlRefTgtType )
            targetDir = Simulink.filegen.internal.FolderConfiguration( childModel, false ).Simulation.ModelReferenceCode;
        else
            targetDir = RTW.getBuildDir( childModel, 'ModelRefRelativeBuildDir' );
        end
        infoStruct.protectedModelRefsBuildDirsAll{ protectedModelReferences } = targetDir;
    else
        targetDir = targetDir{ 1 };
    end
end

newH = locCreateHobj( childModel,  ...
    lGenSettings,  ...
    'binfo',  ...
    childTargetType,  ...
    'anchorDir', h.anchorDir,  ...
    'targetDirName', targetDir,  ...
    'markerFile', h.markerFile );

loadConfigSet = 1;
childInfoStruct = load_create_method( newH, childModel, lGenSettings, loadConfigSet );
if isempty( childInfoStruct )




    msg = message( 'RTW:buildProcess:infoMATFileMgrMatFileNotFound', newH.fullMatFileName );
    error( msg );
end


[ ~, childTarget ] = slprivate( 'mdlRefGetTargetName', childModel,  ...
    childTargetType, h.anchorDir, childInfoStruct, false );

if ( ~isempty( dir( childTarget ) ) )
    checksumVal = slprivate( 'file2hash', childTarget );
    infoStruct.rebuildChecksums.childModelTargetChecksums.( childModel ) = checksumVal;
end






if ~isempty( childInfoStruct.modelLibName )
    infoStruct.directlinkLibrariesFullPaths =  ...
        [ infoStruct.directlinkLibrariesFullPaths,  ...
        { childInfoStruct.modelLibFullName } ];

    infoStruct.linkLibrariesFullPaths =  ...
        [ infoStruct.linkLibrariesFullPaths,  ...
        { childInfoStruct.modelLibFullName },  ...
        childInfoStruct.linkLibrariesFullPaths ];

    infoStruct.linkLibraries = [ infoStruct.linkLibraries,  ...
        { childInfoStruct.modelLibName },  ...
        childInfoStruct.linkLibraries ];
end

infoStruct = loc_combine_IncludeDirs( childInfoStruct.IncludeDirs, childInfoStruct.SourceDirs, infoStruct );

infoStruct.htmlrptLinks = unique( [ infoStruct.htmlrptLinks,  ...
    childInfoStruct.htmlrptLinks ] );


if isempty( childInfoStruct.modelLibName )



    [ infoStruct.modelRefsAll, resultIndex ] = setdiff( infoStruct.modelRefsAll,  ...
        childInfoStruct.modelName );
    infoStruct.modelRefsBuildDirsAll = infoStruct.modelRefsBuildDirsAll( resultIndex );
    infoStruct.directMdlRefs = setdiff( infoStruct.directMdlRefs,  ...
        childInfoStruct.modelName );
else
    if ~isProtected
        [ infoStruct.modelRefsAll, iOrder ] = unique( [ infoStruct.modelRefsAll, childInfoStruct.modelRefsAll ], 'stable' );
        infoStruct.modelRefsBuildDirsAll = [ infoStruct.modelRefsBuildDirsAll, childInfoStruct.modelRefsBuildDirsAll ];
        infoStruct.modelRefsBuildDirsAll = infoStruct.modelRefsBuildDirsAll( iOrder );

        [ infoStruct.protectedModelRefs, iOrder ] = unique( [ infoStruct.protectedModelRefs, childInfoStruct.protectedModelRefs ], 'stable' );
        infoStruct.protectedModelRefsBuildDirsAll = [ infoStruct.protectedModelRefsBuildDirsAll, childInfoStruct.protectedModelRefsBuildDirsAll ];
        infoStruct.protectedModelRefsBuildDirsAll = infoStruct.protectedModelRefsBuildDirsAll( iOrder );
    else
        [ infoStruct.protectedModelRefs, iOrder ] = unique( [ infoStruct.protectedModelRefs,  ...
            reshape( childInfoStruct.modelRefsAll, 1, [  ] ), reshape( childInfoStruct.protectedModelRefs, 1, [  ] ) ], 'stable' );
        infoStruct.protectedModelRefsBuildDirsAll = [ infoStruct.protectedModelRefsBuildDirsAll,  ...
            reshape( childInfoStruct.modelRefsBuildDirsAll, 1, [  ] ), reshape( childInfoStruct.protectedModelRefsBuildDirsAll, 1, [  ] ) ];
        infoStruct.protectedModelRefsBuildDirsAll = infoStruct.protectedModelRefsBuildDirsAll( iOrder );

    end

    infoStruct.modelRefBuildOrder = ismember( infoStruct.modelRefsAll, childInfoStruct.modelName );
end




if ~isempty( childInfoStruct.modelInterface ) && ~isempty( childInfoStruct.modelLibName )
    infoStruct.containsNonInlinedSFcn = infoStruct.containsNonInlinedSFcn ||  ...
        childInfoStruct.modelInterface.HasNonInlinedSfcn;
end


infoStruct.toFileBlocks = [ childInfoStruct.toFileBlocks;infoStruct.toFileBlocks ];



fromFileBlocks = [ childInfoStruct.fromFileBlocks;infoStruct.fromFileBlocks ];
blockPath = cellfun( @( ff )ff.blockPath, fromFileBlocks, 'UniformOutput', false );

[ ~, idx ] = unique( blockPath );
infoStruct.fromFileBlocks = fromFileBlocks( sort( idx ) );

if ( childInfoStruct.hasInstrumentedSignals )
    infoStruct.hasInstrumentedSignals = true;
end
end

function out = locAnyModelRefsInInfoStruct( infoStruct )
out = ~isempty( infoStruct.modelRefs ) || ~isempty( infoStruct.protectedModelRefs );
end

function [ internalStruct, internalChecksums, mdlWkspaceStruct, mdlWkspaceChecksums ] = locGetModelDependenciesChecksum( modelName )
mdlDepStruct = get_param( modelName, 'InternalModelDependencies' );

import Simulink.ModelReference.internal.ModelRefParseDependencyOption
[ internalStruct, internalChecksums ] =  ...
    processModelDependenciesChecksum( modelName, mdlDepStruct,  ...
    ModelRefParseDependencyOption.PARSE_NON_MODEL_WORKSPACE );

[ mdlWkspaceStruct, mdlWkspaceChecksums ] =  ...
    processModelDependenciesChecksum( modelName, mdlDepStruct,  ...
    ModelRefParseDependencyOption.PARSE_MODEL_WORKSPACE );
end

function [ oMdlDepStruct, checksums ] = processModelDependenciesChecksum( modelName, iMdlDepStruct, parseOption )
import Simulink.ModelReference.internal.ModelRefParseDependencyOption.pruneDeps
oMdlDepStruct = pruneDeps( parseOption, iMdlDepStruct );
mdlDeps = {  };
depTypes = [  ];
if ~isempty( oMdlDepStruct )
    mdlDeps = { oMdlDepStruct.Dependency };
    depTypes = [ oMdlDepStruct.Type ];
end
parsedDeps = slprivate( 'mdlRefParseUserDeps', modelName, mdlDeps, false, depTypes );

numDeps = length( parsedDeps );
checksums = struct( 'Key', cell( 1, numDeps ), 'Checksum', cell( 1, numDeps ),  ...
    'Type', cell( 1, numDeps ) );
for i = 1:numDeps
    aDep = parsedDeps( i );

    depBase = aDep.Base;
    depActual = aDep.Actual;
    depType = aDep.Type;

    checksum = slprivate( 'file2hash', depActual );

    checksums( i ).Key = depBase;
    checksums( i ).Checksum = checksum;
    checksums( i ).Type = depType.char;
end
end


function ret = constructErrorMessageForTLC( errorMsg )
if isempty( errorMsg )
    ret = 'No error';
else
    ret = errorMsg;
end
end


