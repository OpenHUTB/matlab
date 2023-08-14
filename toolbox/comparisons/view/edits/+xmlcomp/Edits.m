classdef Edits<handle







    properties(GetAccess=public,Dependent)
Filters
LeftFileName
LeftRoot
RightFileName
RightRoot
TimeSaved
Version
    end

    properties(Access=private)
BaseEdits
    end

    methods

        function edits=Edits(baseEdits)
            edits.BaseEdits=baseEdits;
        end

        function filters=get.Filters(edits)
            filters=edits.BaseEdits.Filters;
        end

        function leftFile=get.LeftFileName(edits)
            leftFile=edits.BaseEdits.LeftFileName;
        end

        function leftRoot=get.LeftRoot(edits)
            leftRoot=edits.BaseEdits.LeftRoot;
        end

        function rightFile=get.RightFileName(edits)
            rightFile=edits.BaseEdits.RightFileName;
        end

        function rightRoot=get.RightRoot(edits)
            rightRoot=edits.BaseEdits.RightRoot;
        end

        function timeSaved=get.TimeSaved(edits)
            timeSaved=edits.BaseEdits.TimeSaved;
        end

        function version=get.Version(edits)
            version=edits.BaseEdits.Version;
        end
    end

end
