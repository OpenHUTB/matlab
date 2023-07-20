classdef ToolboxBlocksHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="SourceBlock";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            location=dependency.UpstreamComponent.Path;
            hilite_system(location,"find");
            open_system(location,"mask");
            unhilite=@()hilite_system(location,"none");
        end
    end
end
