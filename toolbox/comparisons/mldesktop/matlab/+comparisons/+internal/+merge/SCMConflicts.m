classdef SCMConflicts





    properties(Access=public)
        targetPath string{mustBeTextScalar}=""
        markConflictsResolvedCallback function_handle=@()[]
    end

    methods
        function obj=SCMConflicts(targetPath,markConflictsResolvedCallback)
            obj.targetPath=targetPath;
            obj.markConflictsResolvedCallback=markConflictsResolvedCallback;
        end
    end
end
