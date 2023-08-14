classdef PostRestoreLoadModelState<restorepoint.internal.restore.PostRestoreStrategy




    methods
        function run(obj,allRestoreData)
            filesToRestore=allRestoreData.FilesToRestore;
            restoreData=allRestoreData.ModelRestoreData;
            fullRestoreDir=allRestoreData.FullRestoreDir;


            obj.restoreInMemoryStates(filesToRestore,restoreData);
            obj.restoreUnmodifiedModelState(filesToRestore,restoreData);
            obj.restoreWorkspace(fullRestoreDir,restoreData);
        end
    end

    methods(Static=true,Access=private)
        function restoreInMemoryStates(filesToRestore,restoreData)
            for restoreIdx=1:numel(filesToRestore)
                curRestoreInfo=filesToRestore{restoreIdx};
                restorepoint.internal.restore.PostRestoreLoadModelState.restoreInMemoryState(curRestoreInfo{1},restoreData)
            end
        end

        function restoreInMemoryState(currentFullFile,restoreData)
            [~,currentFileName,fileExtension]=fileparts(currentFullFile);
            switch fileExtension
            case{'.slx','.mdl'}
                restorepoint.internal.restore.PostRestoreLoadModelState.restoreModelState(currentFullFile,currentFileName,restoreData);
            case{'.m','.mlx'}
                restorepoint.internal.restore.PostRestoreLoadModelState.restoreMFileState(currentFullFile,restoreData);
            case '.sldd'
                restorepoint.internal.restore.PostRestoreLoadModelState.restoreDataDictionaryState(currentFullFile);
            end
        end

        function restoreModelState(fullModelFile,modelName,restoreData)
            rd=restoreData.getDataForFile(fullModelFile);






            if~isempty(rd)
                if rd.loadRestoredModel
                    load_system(fullModelFile);
                    if rd.openRestoredModel
                        open_system(modelName);
                    end
                end
            end
        end

        function restoreMFileState(currentFullFile,restoreData)
            rd=restoreData.getDataForFile(currentFullFile);
            if rd.openFile
                edit(currentFullFile);
            end
        end

        function restoreDataDictionaryState(currentFullFile)



            ddConnection=Simulink.dd.open(currentFullFile);
            ddConnection.discardChanges();
            ddConnection.close();
        end

        function restoreUnmodifiedModelState(filesToRestore,restoreData)
            if(numel(filesToRestore)>0)
                restoreFiles=setdiff(restoreData.getOriginalFiles,filesToRestore{1});
            else
                restoreFiles=restoreData.getOriginalFiles;
            end
            for restoreIdx=1:numel(restoreFiles)
                currentFullFile=restoreFiles{restoreIdx};
                [~,~,fileExtension]=fileparts(currentFullFile);
                if(strcmp(fileExtension,'.slx')||strcmp(fileExtension,'.mdl'))
                    restorepoint.internal.restore.PostRestoreLoadModelState.restoreInMemoryState(currentFullFile,restoreData);
                end
            end
        end
        function restoreWorkspace(fullRestoreDir,restoreData)
            restorepoint.internal.utils.restoreWorkspace(fullRestoreDir,restoreData);
        end
    end
end


