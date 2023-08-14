classdef FindDirtyFilesVisitor<restorepoint.internal.filetypehandler.Visitor




    properties(SetAccess=private,GetAccess=public)
IsDirty
    end

    methods
        function obj=FindDirtyFilesVisitor
            obj.IsDirty=false;
        end
    end

    methods(Access=protected)
        function visitScriptFile(obj,fileType)
            fileData=fileType.FileData;
            editorStateData=restorepoint.internal.utils.getMATLABEditorState;
            dirtyScript=editorStateData.dirtyMFiles;
            if ismember(fileData.CurrentFullFile,dirtyScript)
                obj.IsDirty=true;
            end
        end

        function visitModelFile(obj,fileType)
            fileData=fileType.FileData;
            [~,modelName,~]=fileparts(fileData.CurrentFullFile);
            if bdIsLoaded(modelName)&&bdIsDirty(modelName)
                obj.IsDirty=true;
            end
        end

        function visitDDFile(obj,fileType)
            fileData=fileType.FileData;
            if exist(fileData.CurrentFullFile,'file')
                ddConnection=Simulink.dd.open(fileData.CurrentFullFile);
                obj.IsDirty=ddConnection.hasUnsavedChanges;
                ddConnection.close();
            end
        end
    end
end


