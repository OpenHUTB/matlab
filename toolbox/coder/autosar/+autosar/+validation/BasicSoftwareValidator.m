classdef BasicSoftwareValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyBasicSoftwareMapping(hModel);
        end

        function verifyPostProp(this,hModel)


            this.verifyBasicSoftwareMapping(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyBasicSoftwareMapping(hModel)


            mapping=autosar.api.Utils.modelMapping(hModel);
            for index=1:length(mapping.FunctionCallers)
                blockMapping=mapping.FunctionCallers(index);

                if autosar.bsw.BasicSoftwareCaller.isBSWCallerBlock(blockMapping.Block)
                    if~strcmp(blockMapping.MappedTo.ClientPort,get_param(blockMapping.Block,'PortName'))||...
                        ~strcmp(blockMapping.MappedTo.Operation,get_param(blockMapping.Block,'Operation'))
                        autosar.validation.Validator.logError('autosarstandard:validation:basicSoftwareMappingSyncNeeded');
                    end
                end
            end
        end

    end

end


