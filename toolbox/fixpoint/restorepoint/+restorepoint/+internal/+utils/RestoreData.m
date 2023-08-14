classdef RestoreData<handle




    properties(GetAccess=public,SetAccess=private)
        Model char
        DirtyMFiles cell
        EditorsMap containers.Map
    end

    properties(GetAccess=public,SetAccess=?restorepoint.internal.restore.RestoreDataStrategy)
        ModelRestoreData restorepoint.internal.utils.ModelRestoreData
        FilesToRestore cell
        FilesThatCannotBeRestored cell
        FullRestoreDir char
        DirtyFilesInModelHierarchy cell
    end

    methods(Access=?restorepoint.internal.restore.RestoreDataStrategy)
        function obj=RestoreData(model)
            obj.Model=model;
            obj.FilesToRestore=cell.empty;
            obj.FilesThatCannotBeRestored=cell.empty;
            obj.DirtyFilesInModelHierarchy=cell.empty;
            editorStateData=restorepoint.internal.utils.getMATLABEditorState;
            obj.DirtyMFiles=editorStateData.dirtyMFiles;
            obj.EditorsMap=editorStateData.editorsMap;
        end
    end

end


