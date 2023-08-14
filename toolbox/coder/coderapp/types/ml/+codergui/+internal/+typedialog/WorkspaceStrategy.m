

classdef(Abstract)WorkspaceStrategy<handle



    events
WorkspaceChanged
    end

    methods(Abstract)
        requestWorkspaceUpdate(this)

        promise=readInWorkspace(this,varsOrCode)

        promise=writeVariable(this,varName,uniqify,value)
    end
end