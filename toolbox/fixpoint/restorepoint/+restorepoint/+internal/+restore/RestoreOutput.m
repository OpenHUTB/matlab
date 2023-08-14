classdef RestoreOutput<handle




    properties(GetAccess=public,SetAccess=?restorepoint.internal.Restorer)

        Status logical
        FilesToRestore cell
        MissingDirectories cell
        WriteProtectedFiles cell
        WriteProtectedDir cell
        FilesThatCannotBeRestored cell
    end

    methods
        function obj=RestoreOutput
            obj.Status=false;
            obj.FilesToRestore=cell.empty;
            obj.MissingDirectories=cell.empty;
            obj.WriteProtectedFiles=cell.empty;
            obj.WriteProtectedDir=cell.empty;
            obj.FilesThatCannotBeRestored=cell.empty;
        end
    end
end
