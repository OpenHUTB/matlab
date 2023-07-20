classdef(Sealed)TmpFilePath











    properties(Constant,Hidden)
        EDITOR_FILE_TAG='EditorFileInfo';
    end

    methods(Static)
        function editorFolderInfo=get(editorId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.eval.TmpFilePath
            import matlab.internal.language.TempFileInfo

            editorFolderInfo=EODataStore.getEditorField(editorId,TmpFilePath.EDITOR_FILE_TAG);


            if~TmpFilePath.isValidFolderInfo(editorFolderInfo)
                tempFolderPath=matlab.internal.editor.eval.TempFolder.getInstance().getFolderOnPath();
                editorFolderInfo=TempFileInfo(editorId,tempFolderPath);

                EODataStore.setEditorField(editorId,TmpFilePath.EDITOR_FILE_TAG,editorFolderInfo)
            end
        end

        function delete(editorId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.eval.TmpFilePath
            folderInfo=EODataStore.getEditorField(editorId,TmpFilePath.EDITOR_FILE_TAG);
            delete(folderInfo);
            EODataStore.setEditorField(editorId,TmpFilePath.EDITOR_FILE_TAG,[]);
        end

        function resetTempFolder(editorId)
            import matlab.internal.editor.eval.TempFolder
            import matlab.internal.editor.eval.TmpFilePath
            TempFolder.getInstance().reset();
            TmpFilePath.delete(editorId);
        end
    end

    methods(Static,Access=private)
        function validFlag=isValidFolderInfo(editorFolderInfo)
            validFlag=~isempty(editorFolderInfo)&&isvalid(editorFolderInfo);
        end
    end
end

