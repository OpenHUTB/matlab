

classdef FilteredWorkspace<sigwebappsutils.internal.filteredworkspace.FilteredWorkspaceBase


    methods
        function isValid=isValidVariable(~,~,value)
            isValid=(isa(value,'double')||isa(value,'single'))...
            &&isreal(value)&&~any(isnan(value),'all')...
            &&all(isfinite(value),'all')&&isvector(value)...
            &&numel(value)>1;
        end
    end
end
