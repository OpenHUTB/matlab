classdef DeleteSubsytemsWithNoPorts<fxptopo.internal.transformation.TransformInterface





    methods
        function wrapper=transform(~,wrapper)
            g=wrapper.Graph;
            subSystemNodes=find(strcmp(g.Nodes.Type,'SubSystem'));
            subSystemHandles=g.Nodes.Handle(subSystemNodes);
            subSystemPortHandles=get_param(subSystemHandles,'PortHandles');
            if~isempty(subSystemPortHandles)
                if~iscell(subSystemPortHandles)
                    subSystemPortHandles={subSystemPortHandles};
                end
                nodesToDelete=subSystemNodes(cellfun(@(x)isempty(x.Inport)&isempty(x.Outport),subSystemPortHandles));
                g=g.rmnode(nodesToDelete);
            end
            wrapper.Graph=g;
        end
    end
end
