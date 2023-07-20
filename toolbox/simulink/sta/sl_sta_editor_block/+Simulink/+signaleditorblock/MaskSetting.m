classdef MaskSetting










    methods(Static)
        function disableMaskInitialization(blockPath)
            if~Simulink.signaleditorblock.MaskSetting.isBlockLocked(blockPath)&&...
                Simulink.signaleditorblock.MaskSetting.isBlockEditable(blockPath)
                preserve_dirty_state=Simulink.PreserveDirtyFlag(bdroot(blockPath),'blockDiagram');
                set_param(blockPath,'DoNotInitMask','on');
                delete(preserve_dirty_state);
            end
        end

        function enableMaskInitialization(blockPath)
            if~Simulink.signaleditorblock.MaskSetting.isBlockLocked(blockPath)&&...
                Simulink.signaleditorblock.MaskSetting.isBlockEditable(blockPath)
                preserve_dirty_state=Simulink.PreserveDirtyFlag(bdroot(blockPath),'blockDiagram');
                set_param(blockPath,'DoNotInitMask','off');
                delete(preserve_dirty_state);
            end
        end

        function isLocked=isBlockLocked(blockPath)
            isLocked=(strcmp(get_param(bdroot(blockPath),'BlockDiagramType'),'library')...
            &&strcmp(get_param(bdroot(blockPath),'Lock'),'on'));
        end
        function isBlockEditable=isBlockEditable(blockPath)


            if strcmp(get_param(bdroot(blockPath),'SimulationStatus'),'stopped')||...
                strcmp(get_param(bdroot(blockPath),'SimulationStatus'),'initializing')||...
                Simulink.signaleditorblock.isFastRestartOn(blockPath)||...
                strcmp(get_param(bdroot(blockPath),'SimulationStatus'),'updating')

                isBlockEditable=true;
            else
                isBlockEditable=false;
            end
        end

    end

end