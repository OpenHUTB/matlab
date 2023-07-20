classdef DeleteNodesUnderDashBoard<fxptopo.internal.transformation.TransformInterface




    methods
        function container=transform(~,container)
            g=container.Graph;
            allNodesToDelete=[];
            dashBoardNodes=find(strcmp(g.Nodes.Type,'DashboardScope'));
            for ii=1:numel(dashBoardNodes)
                nodesToDelete=find(contains(Simulink.ID.getFullName(g.Nodes.Handle),Simulink.ID.getFullName(g.Nodes.Handle(dashBoardNodes(ii)))));
                allNodesToDelete=[allNodesToDelete;nodesToDelete];%#ok<AGROW>
            end
            g=g.rmnode(allNodesToDelete);
            container.Graph=g;
        end
    end
end