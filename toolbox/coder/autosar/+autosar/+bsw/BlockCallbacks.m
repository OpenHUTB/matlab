classdef BlockCallbacks




    methods(Static)
        function demStatusOverrideMaskInit(blkH)

            autosar.api.Utils.autosarlicensed(true);

            autosar.bsw.DemStatusOverride.configureOverrideBlockInternal(blkH);

            autosar.bsw.DemStatusValidator.verifyServiceComponentPresent(blkH);
        end

        function demStatusOverrideLoadBlock(blkH)
            autosar.bsw.DemStatusOverride.updateOverrideBlockMask(blkH);
        end

        function demStatusInjectMaskInit(blkH)

            autosar.api.Utils.autosarlicensed(true);

            autosar.bsw.DemStatusInject.configureInjectBlockInternal(blkH);

            autosar.bsw.DemStatusValidator.verifyServiceComponentPresent(blkH);
        end

        function setConditionsCallback(blkH)
            autosar.bsw.DemStatusInject.setConditions(blkH);
        end

        function propagateParam(block,source,target)


            val=get_param(block,source);
            set_param(block,target,val);
        end

        function demFaultOverrideMaskInit(blkH)

            autosar.api.Utils.autosarlicensed(true);

            autosar.bsw.DemStatusOverride.configureOverrideBlockInternal(blkH);
        end

        function demFaultInjectMaskInit(blkH)

            autosar.api.Utils.autosarlicensed(true);

            autosar.bsw.DemStatusInject.configureInjectBlockInternal(blkH);
        end
    end
end


