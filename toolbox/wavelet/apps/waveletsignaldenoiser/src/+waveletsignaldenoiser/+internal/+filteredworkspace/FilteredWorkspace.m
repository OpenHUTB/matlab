

classdef FilteredWorkspace<sigwebappsutils.internal.filteredworkspace.FilteredWorkspaceBase


    methods
        function isValid=isValidVariable(~,~,value)
            isValid=isa(value,'double')&&isreal(value)&&...
            all(isfinite(value),'all')&&isvector(value)&&numel(value)>1;
        end
    end
end
