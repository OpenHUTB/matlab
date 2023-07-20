classdef PreserveDirtyFlag<handle














    properties(SetAccess=private)
        blockDiagram;
        enabled;
    end

    methods
        function obj=PreserveDirtyFlag(block_diagram,~)


            h=get_param(block_diagram,'Handle');
            assert(numel(h)<=1,'No more than one block diagram allowed');
            obj.blockDiagram=h;
            if~isempty(h)
                dm=Simulink.internal.getDirtyFlagManager(h);
                dm.packageDirtyIgnoreStart;
            end
        end
        function delete(obj)
            h=obj.blockDiagram;
            if ishandle(h)
                dm=Simulink.internal.getDirtyFlagManager(h);
                dm.packageDirtyIgnoreStop;
            end
        end
    end
end
