classdef BatchRunnerNonLocal<MultiSim.internal.BatchRunner




    properties(Constant,Access=private)
        ProjectArchiveName='internalBatchSimArchive.zip'
    end

    methods
        function obj=BatchRunnerNonLocal(cluster,simIns,parsimOptions,batchOptions)
            obj=obj@MultiSim.internal.BatchRunner(cluster,simIns,parsimOptions,batchOptions);
        end
    end

    methods(Access=protected)
        function prepareHeadNodeForSimulinkProject(obj)
            archiveName=obj.ProjectArchiveName;
            archiveDir=getAttachedFilesFolder(archiveName);
            projectArchive=fullfile(archiveDir,archiveName);
            projectFolder=obj.WorkDir;
            MultiSim.internal.projectutils.openProjectFromArchive(projectArchive,projectFolder);
        end

        function makeModelDependenciesAccessible(obj)













            obj.SlxcArchive=MultiSim.internal.getSlxcArchiveForModel(obj.ModelName);

            obj.BatchOptions.AttachedFiles=[obj.BatchOptions.AttachedFiles,obj.SlxcArchive];

            files=obj.getDependencies(obj.ParsimOptions.ManageDependencies);




            modelRootFolder=obj.getProjectRoot();
            currentProjectRoot=matlab.project.rootProject;
            if~isempty(currentProjectRoot)&&modelRootFolder==currentProjectRoot.RootFolder
                archiveName=MultiSim.internal.BatchRunnerNonLocal.ProjectArchiveName;
                [archiveLocation,filesNotArchived]=MultiSim.internal.projectutils.createProjectArchiveFromFiles(...
                currentProjectRoot,files',archiveName);
                filesToAttach=[{},convertStringsToChars([archiveLocation,filesNotArchived])];
                obj.SimulinkProjectLocation=archiveLocation;
            else
                filesToAttach=files';
            end
            obj.BatchOptions.AttachedFiles=[obj.BatchOptions.AttachedFiles,filesToAttach];
        end

        function files=getDependencies(obj,manageDependencies)

            if manageDependencies

                [files,missing]=dependencies.fileDependencyAnalysis(obj.ModelName);


                if~isempty(missing)
                    missing=strjoin([missing,cell.empty],'\n');
                    ME=MException(message('Simulink:Commands:SimInputMissingFiles',missing));
                    MultiSim.internal.reportAsWarning(obj.ModelName,ME);
                end



                files=[files,cell.empty];
            else


                modelSlx=which(obj.ModelName);
                if~startsWith(modelSlx,matlabroot)
                    files={modelSlx};
                else
                    files={};
                end
            end
        end
    end
end


