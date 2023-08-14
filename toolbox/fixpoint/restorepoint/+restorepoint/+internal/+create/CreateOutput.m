classdef CreateOutput<handle




    properties(GetAccess=public,SetAccess=?restorepoint.internal.Creator)

        Status logical
        FilesToStore cell
        MissingFiles cell
        DirtyFiles cell
        WriteProtectedFiles cell
        WriteProtectedDir cell
    end

    methods
        function obj=CreateOutput
            obj.Status=false;
            obj.FilesToStore=cell.empty;
            obj.MissingFiles=cell.empty;
            obj.DirtyFiles=cell.empty;
            obj.WriteProtectedFiles=cell.empty;
            obj.WriteProtectedDir=cell.empty;
        end
    end
end
