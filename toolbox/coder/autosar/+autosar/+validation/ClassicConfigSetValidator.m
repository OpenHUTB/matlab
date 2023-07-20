classdef ClassicConfigSetValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyMultiInstanceMode(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyMultiInstanceMode(hModel)

            cs=getActiveConfigSet(hModel);

            if strcmp(get_param(cs,'CodeInterfacePackaging'),'Reusable function')

                if~autosar.api.Utils.isMapped(hModel)
                    autosar.validation.Validator.logError('RTW:autosar:expectAutosarInterface');
                end

                if autosar.validation.ExportFcnValidator.isExportFcn(hModel)&&...
                    ~slfeature('AUTOSARExpFcnMultiInstance')
                    msg=DAStudio.message('RTW:autosar:MultiInstanceERTCodeIsConfigured');
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end

                if~strcmp(get_param(cs,'ERTFilePackagingFormat'),'Modular')
                    autosar.validation.Validator.logError('RTW:autosar:MultiInstanceFilePackaging');
                end

                if strcmp(get_param(cs,'InlineParams'),'off')
                    autosar.validation.Validator.logError('RTW:autosar:MultiInstanceNeedsInlineParams');
                end

            end
        end

    end

end


