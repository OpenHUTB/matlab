classdef AdaptiveNonClassicValidator<autosar.validation.PhasedValidator





    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyNoBSWBlocks(hModel)
            this.verifyNoSignalInvalidationBlocks(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyNoBSWBlocks(hModel)



            bswBlocks=autosar.bsw.BasicSoftwareCaller.find(hModel);
            if~isempty(bswBlocks)
                modelName=get_param(hModel,'Name');
                bswBlockPaths=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(bswBlocks);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:BSWBlocksInAdaptiveModel',...
                modelName,bswBlockPaths);
            end
        end

        function verifyNoSignalInvalidationBlocks(hModel)





            sigInvBlks=find_system(hModel,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on',...
            'FollowLinks','on',...
            'LookUnderMasks','on',...
            'BlockType','SignalInvalidation');
            if~isempty(sigInvBlks)
                modelName=get_param(hModel,'Name');
                sigInvBlkPaths=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(sigInvBlks);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:SigInvBlocksInAdaptiveModel',...
                modelName,sigInvBlkPaths);
            end
        end
    end

end


