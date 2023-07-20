classdef AdaptiveSLFunctionValidator<autosar.validation.PhasedValidator





    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyNoGlobalSimulinkFunctionBlocks(hModel)
        end

    end

    methods(Static,Access=private)

        function verifyNoGlobalSimulinkFunctionBlocks(hModel)





            slFunctionBlks=find_system(hModel,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all',...
            'blocktype','SubSystem',...
            'IsSimulinkFunction','on');

            globalSlFunctionBlks=slFunctionBlks(...
            arrayfun(@(x)~(autosar.validation.ExportFcnValidator.isScopedSimulinkFunction(x)...
            ||autosar.validation.ExportFcnValidator.isPortScopedSimulinkFunction(x)),...
            slFunctionBlks));

            if~isempty(globalSlFunctionBlks)
                modelName=get_param(hModel,'Name');
                slFuncBlkPaths=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(globalSlFunctionBlks);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:SLFuncBlocksInAdaptiveModel',...
                modelName,slFuncBlkPaths);
            end
        end
    end

end


