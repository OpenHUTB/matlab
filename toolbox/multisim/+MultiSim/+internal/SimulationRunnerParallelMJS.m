classdef SimulationRunnerParallelMJS < MultiSim.internal.SimulationRunnerParallelBase
    properties ( Transient, Access = protected )
        LoggingFoldersMap
        LoggingFileToFilepartsMap
        ToFileBlockPathsMap
        IsAnySimUsingLTF
        ModelDepFilesPerHostFolder
    end

    properties ( Constant, Access = private )
        DefaultConfig = MultiSim.internal.SimulationRunnerParallelMJSConfig
        ProjectPerHostFolder = "project"
    end

    methods
        function obj = SimulationRunnerParallelMJS( simMgr, pool, namedargs )
            arguments
                simMgr( 1, 1 )Simulink.SimulationManager
                pool( 1, 1 )parallel.Pool = gcp
                namedargs.Config( 1, 1 )MultiSim.internal.SimulationRunnerParallelMJSConfig = MultiSim.internal.SimulationRunnerParallelMJS.DefaultConfig
            end

            namedargsCell = namedargs2cell( namedargs );
            obj = obj@MultiSim.internal.SimulationRunnerParallelBase( simMgr, pool, namedargsCell{ : } );
            obj.LoggingFoldersMap = containers.Map;
        end
    end


    methods
        function actualSimulationInputs = setup( obj, actualSimulationInputs )


            obj.cacheWorkerInitialDirectory(  );


            obj.loadSimulinkOnWorkers(  );




            obj.LoggingFoldersMap = containers.Map;
            obj.LoggingFileToFilepartsMap = containers.Map;


            obj.setupDataDictionaryCache(  );


            obj.attachFiles(  );

            obj.attachModelDependencies(  );


            obj.attachSetupFcnDependencies(  );
            obj.attachCleanupFcnDependencies(  );


            obj.setupWorkersAndBuild(  );


            updateAttachedFiles( obj.Pool )


            actualSimulationInputs = obj.setupFastRestart( actualSimulationInputs );



            obj.enableFutureCompletedEvent(  );
        end

        function setupSims( obj, simInputs )
            obj.IsAnySimUsingLTF = obj.isAnyLTF( simInputs );
            harnessesAlreadyLoaded = find_system( 'type', 'block_diagram', 'IsHarness', 'on' );
            cleanup = onCleanup( @(  )locCloseHarnesses( harnessesAlreadyLoaded ) );
            if ~bdIsLoaded( simInputs( 1 ).getModelNameForApply )
                simInputs( 1 ).loadModelToRun(  );
            end

            if ~isempty( simInputs( 1 ).PreSimFcn )
                obj.attachFunctionDependenciesToPool( simInputs( 1 ).PreSimFcn );
            end

            if ~isempty( simInputs( 1 ).PostSimFcn )
                obj.attachFunctionDependenciesToPool( simInputs( 1 ).PostSimFcn );
            end


            for i = 1:obj.NumSims
                obj.createWorkerFolders( simInputs( i ) );
            end
        end

        function arg = createExecutionArgs( obj, fh, simInput )
            simInput = obj.setupSimulationInput( simInput );
            modelName = simInput.getModelNameForApply(  );



            runInfo.WorkingDir = obj.WorkingDir;
            runInfo.LoggingFoldersMap = obj.LoggingFoldersMap;
            runInfo.LoggingFileToFilepartsMap = obj.LoggingFileToFilepartsMap;
            if ~isempty( obj.ToFileBlockPathsMap ) && obj.ToFileBlockPathsMap.isKey( modelName )
                runInfo.ToFileBlockPaths = obj.ToFileBlockPathsMap( modelName );
            end
            runInfo.IsAnySimUsingLTF = obj.IsAnySimUsingLTF;
            arg = { fh, simInput, runInfo };
        end

        function addDataToSimFuture( obj, simFuture, simInput )
            simFuture.FinalizeOutputCB =  ...
                @( simOut, runId )obj.copyLoggedFilesFromWorkers(  ...
                simInput, simOut, runId );
        end

        function execFh = executeFcnHandle( ~ )
            execFh = @localExecuteMDCS;
        end

        function cleanup( obj )
            obj.notifyProgress( message( 'Simulink:MultiSim:CleaningupWorkers' ) );


            if ~isa( obj.Pool, 'parallel.Pool' ) || ~isvalid( obj.Pool ) || ~obj.Pool.Connected

                return ;
            end

            delete( obj.FutureCompletedListener );
            obj.FutureCompletedListener = [  ];
            obj.Pool.FevalQueue.hToggleCallbacks( obj.ToggleCallbacksValue );
            obj.runCleanupFcn(  );




            obj.closeProject(  );



            parfevalOnAll( obj.Pool, @bdclose, 0, 'all' );


            if ~isempty( obj.ModelDepFilesPerHostFolder )
                for modelDepFolder = obj.ModelDepFilesPerHostFolder
                    subdir = modelDepFolder;
                    parfevalOnAll( obj.Pool, @(  )rmpath( parallel.pool.getPerHostFolder( subdir ) ), 0 );
                    parallel.pool.deleteFolder( obj.Pool, subdir );
                end
                obj.ModelDepFilesPerHostFolder = [  ];
            end

            obj.resetCurrentDir(  );
            obj.cleanupDataDictionaryCache(  );
            obj.clearSDIRepositoryFile(  );
            obj.showFinalJobDiagnostic(  );
        end

        function cancel( obj, runId )


            if nargin == 1
                runId = [  ];
            end
            obj.cancelFuture( runId );
        end
    end

    methods ( Access = protected )
        function retVal = isAnyLTF( obj, simInputs )

            retVal = isequal( get_param( obj.ModelName, 'LoggingToFile' ), 'on' );
            if retVal
                return ;
            end



            for idx = 1:numel( simInputs )


                retVal = simInputs( idx ).isLTFSetToOn(  );
                if retVal
                    break ;
                end
            end
        end

        function createWorkerFolders( obj, simInput )
            idxStr = num2str( simInput.RunId );


            obj.createLoggingFoldersMap( simInput );



            foldersToCreate = values( obj.LoggingFoldersMap );
            for idx = 1:numel( foldersToCreate )
                wait( parallel.pool.createFolder( obj.Pool,  ...
                    [ foldersToCreate{ idx }, '_run', idxStr ] ) );
            end
        end

        function createLoggingFoldersMap( obj, simInput )
            modelName = simInput.getModelNameForApply(  );
            if ~bdIsLoaded( modelName )
                simInput.loadModelToRun(  );
            end

            if ( isempty( obj.ToFileBlockPathsMap ) )
                obj.ToFileBlockPathsMap = containers.Map;
            end

            modelNameKey = string( modelName );
            if ~obj.ToFileBlockPathsMap.isKey( modelNameKey )
                obj.ToFileBlockPathsMap( modelNameKey ) = [  ];







                Mdls = find_mdlrefs( modelName, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
                for idx = 1:numel( Mdls )
                    modelRef = Mdls{ idx };
                    load_system( modelRef );
                    slObj = get_param( modelRef, 'slobject' );
                    toFileBlks = slObj.getToFileBlockPaths(  );
                    obj.ToFileBlockPathsMap( modelNameKey ) = [ obj.ToFileBlockPathsMap( modelNameKey );toFileBlks ];
                end
            end


            for idx = 1:numel( obj.ToFileBlockPathsMap( modelNameKey ) )

                pathsMap = obj.ToFileBlockPathsMap( modelNameKey );
                currName = simInput.getToFileName( pathsMap{ idx } );
                [ pathstr, fileName, ~ ] = fileparts( currName );



                if isempty( pathstr )
                    pathstr = obj.WorkingDir;
                end

                fileParts = struct( 'Dir', pathstr, 'FileName', fileName );
                obj.LoggingFileToFilepartsMap( currName ) = fileParts;


                folderKeys = keys( obj.LoggingFoldersMap );


                flags = strcmpi( folderKeys, pathstr );
                index = find( flags == 1, 1 );
                if isempty( index )
                    [ ~, tmpName, ~ ] = fileparts( tempname );
                    obj.LoggingFoldersMap( pathstr ) = tmpName;
                end
            end


            if simInput.isLTFSetToOn(  )

                currName = simInput.getLTFName(  );
                [ pathstr, fileName, ~ ] = fileparts( currName );




                if isempty( pathstr )
                    pathstr = obj.WorkingDir;
                end

                fileParts = struct( 'Dir', pathstr, 'FileName', fileName );
                obj.LoggingFileToFilepartsMap( currName ) = fileParts;

                folderKeys = keys( obj.LoggingFoldersMap );
                flags = strcmpi( folderKeys, pathstr );
                index = find( flags == 1, 1 );
                if isempty( index )
                    [ ~, tmpName, ~ ] = fileparts( tempname );
                    obj.LoggingFoldersMap( pathstr ) = tmpName;
                end
            end


            if simInput.isCoverageEnabled(  )
                outputDir = SlCov.CoverageAPI.getCovOutputFullDir( simInput, obj.WorkingDir );
                folderKeys = keys( obj.LoggingFoldersMap );
                flags = strcmpi( folderKeys, outputDir );
                index = find( flags == 1, 1 );
                if isempty( index )
                    [ ~, tmpName, ~ ] = fileparts( tempname );
                    obj.LoggingFoldersMap( outputDir ) = tmpName;
                end
            end
        end

        function newSimOut = copyLoggedFilesFromWorkers( obj, simIn, simOut, runId )
            newSimOut = simOut;
            if isempty( obj.LoggingFoldersMap )

                return ;
            end



            folderKeys = keys( obj.LoggingFoldersMap );





            f = parallel.pool.listFolders( obj.Pool );
            allWorkerFolders = fetchOutputs( f, 'UniformOutput', false );
            if ~isempty( allWorkerFolders )
                allWorkerFolders = allWorkerFolders{ 1 };
            end

            for idx = 1:numel( folderKeys )

                workerFolder = [ obj.LoggingFoldersMap( folderKeys{ idx } ), '_run', num2str( runId ) ];
                if any( strcmp( allWorkerFolders, workerFolder ) )


                    f = parallel.pool.getDataFromPerWorkerFolder( obj.Pool, [ workerFolder, '/.' ] );



                    parallel.pool.writePerFolderData( f, folderKeys{ idx }, false );
                end
            end



            if ( simIn.isLTFSetToOn(  ) )

                currName = simIn.getLTFName(  );
                [ pathstr, name, ext ] = fileparts( currName );

                if isempty( pathstr )
                    pathstr = obj.WorkingDir;
                end

                fileLoc = fullfile( pathstr, [ name, '_', num2str( runId ), ext ] );
                try
                    newSimOut = newSimOut.setDatasetRefMatFileLocation( fileLoc );
                catch ME


                    obj.reportAsWarning( ME );
                end
            end


            if ( simIn.isCoverageEnabled(  ) )
                [ pathstr, name ] = SlCov.CoverageAPI.getCovOutputFullDir( simIn, obj.WorkingDir );
                fileLoc = fullfile( pathstr, [ name, '_', num2str( runId ), '.cvt' ] );
                try
                    newSimOut = setCoverageDataFileLocation( newSimOut, fileLoc );
                catch ME


                    obj.reportAsWarning( ME );
                end
            end
        end

        function simInput = setupSimulationInput( obj, simInput )
            simInput = setupSimulationInput@MultiSim.internal.SimulationRunnerParallelBase( obj, simInput );
        end
    end

    methods ( Access = private )
        function attachModelDependencies( obj )
            projectsToModels = obj.projectsToModelsMap(  );
            projects = projectsToModels.keys;

            for proj = projects
                projectRoot = char( proj );
                models = projectsToModels( projectRoot );


                if ( isempty( projectRoot ) )
                    obj.copyDependenciesOfProjectlessModelsToHosts( models );
                    continue ;
                end


                projectFiles = obj.combineProjectModelDependencies( models );
                obj.setupProjectOnWorkers( projectRoot, projectFiles );
            end
        end

        function copyDependenciesOfProjectlessModelsToHosts( obj, models )



            for currentModel = models
                files = obj.getModelDependencies( currentModel );

                if isempty( files ), continue ;end


                isSingleFile = ~iscell( files );
                if isSingleFile, files = { files };end

                subdir = currentModel + "_files";
                obj.updateModelDepFilesPerHostFolderProperty( subdir );
                obj.createFolderOnHosts( subdir );
                obj.copyFilesToPerHostFolder( files', subdir );
                obj.addPerHostFolderToHostPath( subdir );
            end
        end

        function updateModelDepFilesPerHostFolderProperty( obj, subdir )
            obj.ModelDepFilesPerHostFolder = [ obj.ModelDepFilesPerHostFolder, subdir ];
        end

        function createFolderOnHosts( obj, folder )
            wait( parallel.pool.createFolder( obj.Pool, folder ) );
        end

        function addPerHostFolderToHostPath( obj, folder )
            parfevalOnAll( obj.Pool, @(  )addpath( parallel.pool.getPerHostFolder( folder ) ), 0 );
        end

        function copyFilesToPerHostFolder( obj, files, folder )
            parallel.pool.copyToPerHostFolder( obj.Pool, folder, files );
        end

        function projectModelDeps = combineProjectModelDependencies( obj, models )
            projectModelDeps = string.empty;

            for currentModel = models
                files = obj.getModelDependencies( currentModel );
                projectModelDeps = [ projectModelDeps;string( files ) ];%#ok<AGROW>
            end
        end

        function projectsToModels = projectsToModelsMap( obj )




            modelNames = obj.AllModels;
            projectsToModels = containers.Map;

            for currentModel = modelNames
                projectRoot = MultiSim.internal.projectutils.projectRootForModel( currentModel );

                if ~MultiSim.internal.isProjectLoaded( projectRoot )
                    projectRoot = '';
                end

                if ~projectsToModels.isKey( projectRoot )
                    projectsToModels( projectRoot ) = [  ];
                end

                projectsToModels( projectRoot ) = [ projectsToModels( projectRoot ), currentModel ];
            end
        end

        function files = getModelDependencies( obj, modelName )




            if obj.Options.ManageDependencies
                obj.notifyProgress( message( 'Simulink:MultiSim:IdentifyModelFileDependencies' ) );
                [ files, missing ] = dependencies.fileDependencyAnalysis( modelName );
                if ~isempty( missing )
                    if iscellstr( missing )
                        missing = strjoin( missing, '\n' );
                    end
                    ME = MException( message( 'Simulink:Commands:SimInputMissingFiles', missing ) );
                    obj.reportAsWarning( ME );
                end
                obj.notifyProgress( message( 'Simulink:MultiSim:SendFileDependencies' ) );
            else


                files = {  };
                modelSlx = which( obj.ModelName );
                if ~startsWith( modelSlx, matlabroot )
                    files = { modelSlx };
                end
            end
        end

        function setupProjectOnWorkers( obj, projectRoot, files )
            arguments
                obj
                projectRoot
                files string
            end

            if isempty( files )
                return ;
            end

            projectPerHostFolder = obj.ProjectPerHostFolder;
            obj.ModelDepFilesPerHostFolder = [ obj.ModelDepFilesPerHostFolder, projectPerHostFolder ];
            f = parallel.pool.createFolder( obj.Pool, projectPerHostFolder );
            wait( f );

            archiveName = "archive.zip";
            currentProjectRoot = matlab.project.rootProject;
            [ archiveLocation, filesNotArchived ] = MultiSim.internal.projectutils.createProjectArchiveFromFiles(  ...
                currentProjectRoot, files', archiveName );

            filesToAttach = [ {  }, convertStringsToChars( [ archiveLocation, filesNotArchived ] ) ];
            parallel.pool.copyToPerHostFolder( obj.Pool, projectPerHostFolder, filesToAttach );

            parfevalOnAll( obj.Pool, @(  )addpath( parallel.pool.getPerHostFolder( projectPerHostFolder ) ), 0 );

            obj.notifyProgress( message( 'Simulink:MultiSim:LoadingProjectOnWorkers' ) );
            F = parfevalOnAll( obj.Pool, @locSetupProject, 0, projectPerHostFolder, archiveName );
            wait( F );

            if ~isempty( F.Error )

                ME = MException( message( 'Simulink:MultiSim:ErrorLoadingProjectOnWorkers' ) );
                cause = F.Error( ~cellfun( @isempty, F.Error ) );
                ME = ME.addCause( cause{ 1 } );
                throw( ME );
            end
        end



        function attachPreAndPostSimFcnDependencies( obj, simInput )
            if ~isempty( simInput.PreSimFcn )
                obj.attachFunctionDependenciesToPool( simInput.PreSimFcn );
            end

            if ~isempty( simInput.PostSimFcn )
                obj.attachFunctionDependenciesToPool( simInput.PostSimFcn );
            end
        end

        function attachFunctionDependenciesToPool( obj, fh )
            arguments
                obj
                fh( 1, 1 )function_handle
            end
            files = obj.Config.FunctionDependencyAnalysisHandler( fh );
            obj.Config.AttachFilesToPoolHandler( obj.Pool, files );
        end
    end
end

function out = localExecuteMDCS( fh, simInp, runInfo )
load_system( simInp.ModelName );
simInp = locMakeToFileNamesUniqueParallel( simInp, runInfo );
if runInfo.IsAnySimUsingLTF
    simInp = locMakeLTFFileNamesUniqueParallel( simInp, runInfo );
end
if simInp.isCoverageEnabled(  )
    simInp = SlCov.CoverageAPI.setupSimInputForCoverage( simInp, runInfo.WorkingDir, false );
    simInp = locMakeCoverageDataFileNamesUniqueParallel( simInp, runInfo );
end
out = MultiSim.internal.runSingleSim( fh, simInp );


fs = dir( Simulink.sdi.getSource(  ) );


heuristicSizeInBytes = 10 * 1024 * 1024;
actualSizeInBytes = fs.bytes;
if actualSizeInBytes > heuristicSizeInBytes
    Simulink.sdi.internal.cleanupWorkerAfterParsim(  );
end
end

function simInp = locMakeToFileNamesUniqueParallel( simInp, runInfo )

for idx = 1:numel( runInfo.ToFileBlockPaths )
    currName = simInp.getToFileName( runInfo.ToFileBlockPaths{ idx } );
    fileParts = runInfo.LoggingFileToFilepartsMap( currName );
    origPath = fileParts.Dir;
    name = fileParts.FileName;

    runNumStr = num2str( simInp.RunId );

    locationWorker = parallel.pool.getPerWorkerFolder(  ...
        strcat( runInfo.LoggingFoldersMap( origPath ), '_run', runNumStr ) );

    fname = fullfile( locationWorker, name );
    simMode = simInp.get_param( 'SimulationMode' );
    if startsWith( simMode, 'r', 'IgnoreCase', true )
        fname = [ fname, '_', runNumStr ];
    end
    simInp = simInp.addHiddenBlockParameter( runInfo.ToFileBlockPaths{ idx },  ...
        'FileName', fname );
end
end

function simInp = locMakeLTFFileNamesUniqueParallel( simInp, runInfo )

currName = simInp.getLTFName(  );
if ~runInfo.LoggingFileToFilepartsMap.isKey( currName )
    return ;
end

fileParts = runInfo.LoggingFileToFilepartsMap( currName );
origPath = fileParts.Dir;
name = fileParts.FileName;

runNumStr = num2str( simInp.RunId );

locationWorker = parallel.pool.getPerWorkerFolder(  ...
    [ runInfo.LoggingFoldersMap( origPath ), '_run', runNumStr ] );

fname = fullfile( locationWorker, [ name, '_', runNumStr ] );
simInp = simInp.addHiddenModelParameter( 'LoggingFileName', fname );
end

function simInp = locMakeCoverageDataFileNamesUniqueParallel( simInp, runInfo )

[ origPath, name ] = SlCov.CoverageAPI.getCovOutputFullDir( simInp, runInfo.WorkingDir );
runNumStr = num2str( simInp.RunId );

locationWorker = parallel.pool.getPerWorkerFolder(  ...
    [ runInfo.LoggingFoldersMap( origPath ), '_run', runNumStr ] );

fname = [ name, '_', runNumStr ];
simInp = simInp.addHiddenModelParameter( 'CovDataFileName', fname );
simInp = simInp.addHiddenModelParameter( 'CovOutputDir', locationWorker );
end

function locSetupProject( folderName, archiveName )
locationHost = parallel.pool.getPerHostFolder( folderName );

[ ~, projectTempFolder ] = fileparts( tempname );
projectFolder = fullfile( locationHost, projectTempFolder );
projectArchive = fullfile( locationHost, archiveName );
project = MultiSim.internal.projectutils.openProjectFromArchive( projectArchive, projectFolder );
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
instance.store( 'parsimProject', project );
end

function locCloseHarnesses( harnessesAlreadyLoaded )
loadedHarnesses = find_system( 'type', 'block_diagram', 'IsHarness', 'on' );
harnessesToClose = setdiff( loadedHarnesses, harnessesAlreadyLoaded );
if ~isempty( harnessesToClose )
    close_system( harnessesToClose, 0 );
end
end


