classdef InternalTriggerValidator<autosar.validation.PhasedValidator




    methods(Access=protected)
        function verifyInitial(this,hModel)
            modelName=getfullname(hModel);
            internalTrigBlocks=autosar.blocks.InternalTriggerBlock.findInternalTriggerBlocks(modelName);
            if isempty(internalTrigBlocks)
                return
            end

            this.verifyExportFunctionModel(modelName,internalTrigBlocks);
            this.verifyCallingContext(modelName);
        end
    end

    methods(Static,Access=private)
        function verifyExportFunctionModel(modelName,internalTrigBlocks)


            if~autosar.validation.ExportFcnValidator.isExportFcn(modelName)
                autosar.validation.Validator.logError('autosarstandard:validation:InternalTriggerBlockNotInExportFcnModel',...
                getfullname(internalTrigBlocks{1}));
            end
        end

        function verifyCallingContext(modelName)

            irtBlocks=[autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(modelName)...
            ,autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks(modelName)...
            ,autosar.utils.InitResetTermFcnBlock.findResetFunctionBlocks(modelName)];
            for i=1:length(irtBlocks)
                irtBlock=irtBlocks{i};
                internalTrigBlocks=autosar.blocks.InternalTriggerBlock.findInternalTriggerBlocks(irtBlock);
                if~isempty(internalTrigBlocks)
                    autosar.validation.Validator.logError('autosarstandard:validation:InternalTriggerBlockInIRT',...
                    getfullname(internalTrigBlocks{1}),getfullname(irtBlock));
                end
            end
        end

    end
end


