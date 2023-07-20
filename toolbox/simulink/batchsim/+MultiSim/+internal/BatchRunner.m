classdef(Abstract)BatchRunner<handle




    properties(SetAccess=protected,Transient=true)

Cluster
ParsimOptions
BatchOptions
WorkDir
    end

    properties(SetAccess=protected)
SimulationInputs
    end

    properties(Access=protected)


BaseWorkspaceVars
SlxcArchive
SimulinkProjectLocation
    end

    properties(Dependent=true)
ModelName
    end

    methods(Abstract,Access=protected)

        makeModelDependenciesAccessible(obj)



        prepareHeadNodeForSimulinkProject(obj)
    end

    methods(Access=protected)
        function cleanup(obj)


            dirCleanup=onCleanup(@()cleanupDirectory(obj.WorkDir));
            if~isempty(obj.SimulinkProjectLocation)
                cleanupProject();
            end
        end
    end

    methods
        function obj=BatchRunner(cluster,simIns,parsimOptions,batchOptions)
            obj.Cluster=cluster;
            obj.SimulationInputs=simIns;
            obj.ParsimOptions=parsimOptions;
            obj.BatchOptions=batchOptions;
        end

        function modelName=get.ModelName(obj)
            mgr=Simulink.SimulationManager(obj.SimulationInputs);
            modelName=mgr.ModelName;
        end

        function job=run(obj)
            obj.setup();
            obj.makeModelDependenciesAccessible();




            obj.ParsimOptions.ManageDependencies=false;
            parsimParams=obj.convertOptionsToCell(obj.ParsimOptions);
            batchParams=obj.convertOptionsToCell(obj.BatchOptions);
            description=message('parallel:convenience:BatchFunctionDescription','batchsim').getString();
            batchJob=batch(obj.Cluster,@batchsim,1,...
            [{obj};parsimParams],batchParams{:},...
            'undoc:ApiTag',Simulink.Simulation.Job.JobTag,...
            'undoc:Tag',description);
            job=Simulink.Simulation.Job(batchJob);
        end
    end

    methods(Access=protected)
        function setup(obj)









            baseWkspVars=[];
            if obj.ParsimOptions.TransferBaseWorkspaceVariables
                baseWkspVars=MultiSim.internal.getBaseWorkspaceVarsAsStruct();
                baseWkspVars=MultiSim.internal.filterNonSerializableVars(baseWkspVars);
            end
            obj.BaseWorkspaceVars=baseWkspVars;







            functionHandles=[{obj.ParsimOptions.SetupFcn},{obj.ParsimOptions.CleanupFcn},...
            {obj.SimulationInputs.PreSimFcn},...
            {obj.SimulationInputs.PostSimFcn}];
            functionFiles=MultiSim.internal.getFilenamesForFunctionHandles(functionHandles);

            functionFiles=functionFiles(~strcmp(functionFiles,''));
            requiredFiles=matlab.codetools.requiredFilesAndProducts(...
            functionFiles);
            obj.BatchOptions.AttachedFiles=[obj.BatchOptions.AttachedFiles,requiredFiles];
        end

        function projectRoot=getProjectRoot(obj)
            projectRoot=MultiSim.internal.projectutils.projectRootForModel(obj.ModelName);
        end
    end

    methods(Access=protected)
        function out=batchsim(obj,varargin)



            workDir=tempname;
            mkdir(workDir);
            obj.WorkDir=workDir;


            if~isempty(obj.SimulinkProjectLocation)
                obj.prepareHeadNodeForSimulinkProject();
            end
            cleanupHeadNodeOC=onCleanup(@()obj.cleanup());

            obj.assignBaseWorkspaceVars();


            modelName=obj.ModelName;
            load_system(modelName);
            modelCloseOC=onCleanup(@()bdclose(modelName));



            obj.assignBaseWorkspaceVars();


            obj.setupCacheFolder();

            cacheCleanupOC=onCleanup(@()Simulink.fileGenControl('reset'));

            out=parsim(obj.SimulationInputs,varargin{:});
        end

        function assignBaseWorkspaceVars(obj)



            if~isempty(obj.BaseWorkspaceVars)
                varNames=fieldnames(obj.BaseWorkspaceVars);
                for i=1:numel(varNames)
                    assignin('base',varNames{i},obj.BaseWorkspaceVars.(varNames{i}));
                end
            end
        end

        function setupCacheFolder(obj)


            workDir=obj.WorkDir;
            cfg=Simulink.fileGenControl('getConfig');
            cfg.CacheFolder=workDir;
            cfg.CodeGenFolder=workDir;







            pool=gcp('nocreate');
            if~isempty(pool)
                wait(parfevalOnAll(pool,@suppressAddpathWarningOnWorkers,0));
            end
            Simulink.fileGenControl('setConfig','config',cfg,'createDir',true);

            if~isempty(pool)
                parfevalOnAll(pool,@restoreAddpathWarningOnWorkers,0);
            end

            [~,slxcArchiveName,~]=fileparts(obj.SlxcArchive);
            if~isempty(slxcArchiveName)
                slxcArchiveLocation=which(slxcArchiveName);
                if~isempty(slxcArchiveLocation)
                    unzip(slxcArchiveLocation,workDir);
                end
            end
        end
    end

    methods(Static,Access=protected)
        function params=convertOptionsToCell(options)














            validateattributes(options,{'struct'},{'scalar'});
            params=[fieldnames(options),struct2cell(options)]';
            params=params(:);
        end
    end
end

function suppressRmpathWarningOnWorkers()
    warningId='MATLAB:rmpath:DirNotFound';
    oldState=warning('off',warningId);
    instance=MultiSim.internal.WorkerTempStorage.getInstance();
    instance.store('rmpathWarningState',oldState.state);
end

function restoreRmpathWarningOnWorkers()
    warningId='MATLAB:rmpath:DirNotFound';
    instance=MultiSim.internal.WorkerTempStorage.getInstance();
    oldState=instance.get('rmpathWarningState');
    warning(oldState,warningId);
end

function suppressAddpathWarningOnWorkers()
    warningId='MATLAB:mpath:nameNonexistentOrNotADirectory';
    oldState=warning('off',warningId);
    instance=MultiSim.internal.WorkerTempStorage.getInstance();
    instance.store('addpathWarningState',oldState.state);
end

function restoreAddpathWarningOnWorkers()
    warningId='MATLAB:mpath:nameNonexistentOrNotADirectory';
    instance=MultiSim.internal.WorkerTempStorage.getInstance();
    oldState=instance.get('addpathWarningState');
    warning(oldState,warningId);
end

function cleanupDirectory(dirName)



    warningId='MATLAB:RMDIR:RemovedFromPath';
    oldState=warning('off',warningId);
    oc=onCleanup(@()warning(oldState.state,warningId));
    pool=gcp('nocreate');
    if~isempty(pool)
        wait(parfevalOnAll(pool,@suppressRmpathWarningOnWorkers,0));
    end
    rmdir(dirName,'s');
    if~isempty(pool)
        parfevalOnAll(pool,@restoreRmpathWarningOnWorkers,0);
    end
end

function cleanupProject()
    proj=slproject.getCurrentProject();
    proj.close();
end


