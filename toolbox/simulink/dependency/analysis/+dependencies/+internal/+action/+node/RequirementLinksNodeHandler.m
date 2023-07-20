classdef RequirementLinksNodeHandler<dependencies.internal.action.NodeHandler




    properties(Constant)
        NodeFilter=dependencies.internal.graph.NodeFilter.fileExtension(".slmx");
        DefaultDependencyHandler=dependencies.internal.action.dependency.HiliteBlockHandler;
    end

    methods

        function open(~,node)
            set=slreq.load(node.Location{1});
            open(set.Artifact);
            [~,modelName,ext]=fileparts(set.Artifact);
            if any(ext==[".slx",".mdl"])
                appmgr=slreq.app.MainManager.getInstance();
                modelHandle=get_param(modelName,'Handle');
                if~slreq.utils.isInPerspective(modelHandle)
                    appmgr.togglePerspective(modelHandle,modelHandle);
                end
            end
        end

        function restore=edit(~,~)
            restore=@()[];
        end

        function save(~,~)
        end

        function close(~,~)
        end

    end

end
