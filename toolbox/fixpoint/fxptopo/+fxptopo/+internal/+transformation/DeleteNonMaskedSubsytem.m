classdef DeleteNonMaskedSubsytem<fxptopo.internal.transformation.TransformInterface




    methods
        function wrapper=transform(~,wrapper)
            g=wrapper.Graph;
            g=g.rmnode(find(strcmp(g.Nodes.Type,'SubSystem')&strcmp(g.Nodes.MaskType,'')));%#ok<FNDSB>
            wrapper.Graph=g;
        end
    end
end
