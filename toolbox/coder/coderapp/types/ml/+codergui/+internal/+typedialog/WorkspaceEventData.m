classdef(Sealed)WorkspaceEventData<event.EventData




    properties(SetAccess=immutable)
WorkspaceInfo
IsMajorChange
Stack
    end

    methods
        function this=WorkspaceEventData(whosInfo,stack,major)
            this.WorkspaceInfo=whosInfo;
            this.IsMajorChange=major;
            this.Stack=stack;
        end
    end
end
