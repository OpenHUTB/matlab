classdef MergeIntoTarget





    properties(Access=public)
        targetPath string{mustBeTextScalar}=""
        postMergeCallback function_handle=@()[]
    end

    methods
        function obj=MergeIntoTarget(targetPath,postMergeCallback)
            obj.targetPath=targetPath;
            obj.postMergeCallback=postMergeCallback;
        end
    end
end
