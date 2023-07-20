classdef AdaptiveConfigSetValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyIncludeMdlTerminateFcnForProvidedServices(hModel);
            this.verifyTargetLanguageStandard(hModel);
        end

    end

    methods(Static,Access=private)
        function verifyIncludeMdlTerminateFcnForProvidedServices(hModel)



            if autosar.validation.AdaptiveConfigSetValidator.isModelProvidingService(hModel)&&...
                strcmp(get_param(hModel,'IncludeMdlTerminateFcn'),'off')
                autosar.validation.Validator.logError('autosarstandard:validation:provideServiceRequiredMdlTerminateFcn',...
                get_param(hModel,'Name'));
            end
        end

        function verifyTargetLanguageStandard(hModel)


            targetLangStd=get_param(hModel,'TargetLangStandard');
            if strcmp(targetLangStd,'C++03 (ISO)')
                autosar.validation.Validator.logError('RTW:autosar:targetLangStandardAdaptive',...
                get_param(hModel,'Name'),targetLangStd);
            end
        end
    end

    methods(Static,Access=public)
        function isProvidingService=isModelProvidingService(hModel)



            mapping=autosar.api.Utils.modelMapping(hModel);
            isProvidingService=...
            ~isempty(mapping.Outports)||~isempty(mapping.ServerPorts);
        end
    end

end


