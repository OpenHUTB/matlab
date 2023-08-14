

classdef FilteredWorkspace<sigwebappsutils.internal.filteredworkspace.FilteredWorkspaceBase


    methods
        function isValid=isValidVariable(~,~,value)




            isValid=isa(value,'double')&&isreal(value)&&~any(isnan(value),'all')&&any(isfinite(value),'all')&&isvector(value)&&numel(value)>1;
        end
    end
end
