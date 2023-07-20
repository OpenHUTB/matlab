classdef DeleteNodesInLinkedMaskedBlocks<fxptopo.internal.transformation.TransformInterface




    methods
        function wrapper=transform(~,wrapper)
            g=wrapper.Graph;
            maskedSubsystemNodes=find(g.Nodes.IsLink&~strcmp(g.Nodes.MaskType,''));
            allNodesToDelete=[];
            for ii=1:numel(maskedSubsystemNodes)
                sysName=Simulink.ID.getFullName(g.Nodes.SID{maskedSubsystemNodes(ii)});
                if~strcmp(wrapper.CurrentSystem,sysName)
                    nodesToDelete=find(contains(Simulink.ID.getFullName(g.Nodes.SID),sysName));
                    nodesToDelete=nodesToDelete(nodesToDelete~=maskedSubsystemNodes(ii));
                    allNodesToDelete=[allNodesToDelete;nodesToDelete];%#ok<AGROW>
                end
            end
            g=g.rmnode(allNodesToDelete);
            wrapper.Graph=g;
        end
    end
end
