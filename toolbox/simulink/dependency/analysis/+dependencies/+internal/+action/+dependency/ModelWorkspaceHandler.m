classdef ModelWorkspaceHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="ModelWorkspace";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];
            [~,modelName,~]=fileparts(dependency.UpstreamNode.Location{1});

            h=get_param(modelName,'Object');
            children=h.getMixedHierarchicalChildren;
            ws=children{cellfun(@(x)isa(x,"DAStudio.WorkspaceNode"),children)};


            daexplr(ws);
        end
    end
end
