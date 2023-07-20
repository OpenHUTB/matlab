classdef CloseElementVisitor<restorepoint.internal.filetypehandler.Visitor




    methods(Access=protected)
        function visitScriptFile(~,fileType)
            fileData=fileType.FileData;
            editorStateData=restorepoint.internal.utils.getMATLABEditorState;
            editorsMap=editorStateData.editorsMap;
            rd=fileData.RestoreData.getDataForFile(fileData.CurrentFullFile);
            if editorsMap.isKey(fileData.CurrentFullFile)
                rd.openFile=true;
                curEditor=editorsMap(fileData.CurrentFullFile);
                curEditor.closeNoPrompt;
            else
                rd.openFile=false;
            end
            fileData.RestoreData.setDataForFile(fileData.CurrentFullFile,rd);
        end

        function visitModelFile(~,fileType)
            fileData=fileType.FileData;
            [~,modelName,~]=fileparts(fileData.CurrentFullFile);
            if bdIsLoaded(modelName)
                close_system(modelName,0);
            end
        end

        function visitDDFile(~,fileType)
            fileData=fileType.FileData;
            [~,fileName,fileExtention]=fileparts(fileData.CurrentFullFile);
            openDDs=Simulink.data.dictionary.getOpenDictionaryPaths([fileName,fileExtention]);
            if(ismember(fileData.CurrentFullFile,openDDs))

                findDirtyFilesVisitor=restorepoint.internal.filetypehandler.FindDirtyFilesVisitor;
                fileType.accept(findDirtyFilesVisitor)

                if(findDirtyFilesVisitor.IsDirty)
                    ddObj=Simulink.data.dictionary.open([fileName,fileExtention]);
                    discardChanges(ddObj);
                end
                Simulink.data.dictionary.closeAll([fileName,fileExtention]);
            end
        end

        function visitMexFile(~,fileType)
            fileData=fileType.FileData;
            [~,mexFileName,~]=fileparts(fileData.CurrentFullFile);
            evalin('base',sprintf('clear %s',mexFileName));
        end
    end
end


