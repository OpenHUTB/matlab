classdef StoreElementsStandard<restorepoint.internal.create.StoreElementsStrategy







    methods
        function run(obj,restoreData)

            if~isempty(restoreData.ExistingRestoreDir)
                rmdir(restoreData.ExistingRestoreDir,'s');
            end
            fullRestoreDir=rtwprivate('rtw_create_directory_path',...
            restoreData.RestoreDirectory{1});
            obj.storeFileElements(restoreData,fullRestoreDir);
            obj.saveWorkspace(restoreData,fullRestoreDir);
            restoreDataFile=fullfile(fullRestoreDir,'restoreData.mat');
            save(restoreDataFile,'restoreData');
            restoreData.currentModelRestorePointPath=fullRestoreDir;
        end
    end

    methods(Access=private)
        function storeFileElements(obj,restoreData,fullRestoreDir)
            for fileIdx=1:restoreData.OriginalNumDependencies

                currentFullFile=restoreData.OriginalFiles{fileIdx};
                [~,currentFileName,fileExtension]=fileparts(currentFullFile);
                backupFullFile=...
                obj.generateValidBackupName(fullRestoreDir,currentFileName,fileExtension);
                copyfile(currentFullFile,backupFullFile);
                restoreData.addNewFile(currentFullFile,backupFullFile);
            end
        end

        function saveWorkspace(obj,restoreData,fullRestoreDir)
            workspaceFileName=obj.saveWorkspaceVariables(restoreData,fullRestoreDir);
            restoreData.WorkspaceFile=workspaceFileName;
        end
    end

    methods(Static=true,Access=private)
        function fullFile=generateValidBackupName(restoreDir,fileName,fileExtension)



            fullFile=fullfile(restoreDir,[fileName,fileExtension]);
            while exist(fullFile,'file')
                fullFile=[tempname(restoreDir),fileExtension];
            end
        end

        function backupFullFile=saveWorkspaceVariables(restoreData,fullRestoreDir)
            backupFullFile=char.empty;
            numVars=length(restoreData.OriginalWorkspaceVariables);
            if numVars==0
                return;
            end
            backupFullFile=restorepoint.internal.create.StoreElementsStandard.generateValidBackupName(fullRestoreDir,'workspace','.mat');
            saveString=sprintf('save(''%s'',',backupFullFile);
            numVars=length(restoreData.OriginalWorkspaceVariables);
            for varIdx=1:numVars
                saveString=sprintf('%s ''%s''',saveString,restoreData.OriginalWorkspaceVariables{varIdx});
                if(varIdx<numVars)
                    saveString=sprintf('%s,',saveString);
                end
            end
            saveString=sprintf('%s)',saveString);
            evalin('base',saveString);
        end
    end
end


