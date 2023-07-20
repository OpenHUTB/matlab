classdef SaveDirtyFilesVisitor<restorepoint.internal.filetypehandler.Visitor




    methods(Access=protected)
        function visitScriptFile(~,fileType)
            fileData=fileType.FileData;
            editorStateData=restorepoint.internal.utils.getMATLABEditorState;
            editorsMap=editorStateData.editorsMap;
            dirtyScript=editorStateData.dirtyMFiles;
            if ismember(fileData.CurrentFullFile,dirtyScript)
                fileEditor=editorsMap(fileData.CurrentFullFile);
                fileEditor.save;
            end
        end

        function visitModelFile(~,fileType)
            fileData=fileType.FileData;
            [~,modelName,~]=fileparts(fileData.CurrentFullFile);
            save_system(modelName);
        end

        function visitDDFile(~,fileType)
            fileData=fileType.FileData;
            ddConnection=Simulink.dd.open(fileData.CurrentFullFile);
            ddConnection.saveChanges;
            ddConnection.close();
        end
    end
end


