classdef Creator<handle




    properties(GetAccess=public,SetAccess=private)
CreateDataStrategy
CalculatePathStrategy
FileDependencyStrategy
VariableDependencyStrategy
StoreElementsStrategy
    end

    properties(GetAccess=public,SetAccess=public)
        ContinueRunOnMissingFiles logical
    end

    methods
        function obj=Creator(createConfiguration)
            validateattributes(createConfiguration,...
            {'restorepoint.internal.create.CreateConfigurationInterface'},{'nonempty'})
            obj.CreateDataStrategy=createConfiguration.CreateDataStrategy;
            obj.CalculatePathStrategy=createConfiguration.CalculatePathStrategy;
            obj.FileDependencyStrategy=createConfiguration.FileDependencyStrategy;
            obj.VariableDependencyStrategy=createConfiguration.VariableDependencyStrategy;
            obj.StoreElementsStrategy=createConfiguration.StoreElementsStrategy;
            obj.ContinueRunOnMissingFiles=false;
        end


        function createOutput=run(obj)

            createOutput=restorepoint.internal.create.CreateOutput;
            restoreData=obj.CreateDataStrategy.run;
            obj.CalculatePathStrategy.run(restoreData);
            obj.FileDependencyStrategy.run(restoreData);


            stopOnMissingElements=(~isempty(restoreData.OriginalMissingFiles)&&(obj.ContinueRunOnMissingFiles==false));
            designInvalid=(stopOnMissingElements==true)||~isempty(restoreData.OriginalDirtyFiles);
            nothingToSave=(restoreData.OriginalNumDependencies==0)&&...
            (numel(restoreData.OriginalWorkspaceVariables)==0);
            if~(designInvalid||nothingToSave)
                obj.VariableDependencyStrategy.run(restoreData);
                obj.StoreElementsStrategy.run(restoreData);
                restorePaths=...
                restorepoint.internal.utils.SessionInformationManager.getRestorePointPaths;
                restorePaths.addToRestorePaths(restoreData.currentModelRestorePointPath);
                createOutput.Status=true;
            end
            obj.prepareOutput(createOutput,restoreData);
        end
    end

    methods(Static=true,Access=private)
        function prepareOutput(output,restoreData)
            output.FilesToStore=restoreData.OriginalFiles;
            output.MissingFiles=restoreData.OriginalMissingFiles;
            output.DirtyFiles=restoreData.OriginalDirtyFiles;
            [output.WriteProtectedFiles,output.WriteProtectedDir]=...
            restorepoint.internal.utils.checkFilePermissions(restoreData.OriginalFiles);
        end
    end
end


