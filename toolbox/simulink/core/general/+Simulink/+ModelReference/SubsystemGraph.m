classdef SubsystemGraph<Simulink.ModelReference.BlockGraph
    methods(Static,Access=public)
        function g=create(subsys)
            g=Simulink.ModelReference.SubsystemGraph(...
            Simulink.ModelReference.Conversion.Utilities.getHandles(subsys));
        end
    end


    methods(Access=protected)
        function this=SubsystemGraph(subsys)
            this@Simulink.ModelReference.BlockGraph(subsys);
        end
    end


    methods(Static,Access=protected)
        function v=getBlockInfo(currentBlock)
            v=struct('ID',currentBlock,...
            'Type',get_param(currentBlock,'BlockType'),...
            'Commented',~strcmpi(get_param(currentBlock,'Commented'),'off'),...
            'HasMask',strcmp(get_param(currentBlock,'mask'),'on'),...
            'SelfModifiableMask',strcmp(get_param(currentBlock,'MaskSelfModifiable'),'on'));
        end
    end

end
