classdef CommonConfigSetValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyNotAcceleratorMode(hModel);
            this.verifyConfigSet(hModel);
        end

    end

    methods(Static,Access=public)
        function isReusable=isCodeInterfacePackagingReusable(hModel)
            isReusable=strcmp(get_param(hModel,'CodeInterfacePackaging'),'Reusable function');
        end
    end


    methods(Static,Access=private)

        function verifyNotAcceleratorMode(hModel)

            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                autosar.validation.Validator.logError('RTW:autosar:accelSimForbiddenForAUTOSAR')
            end

        end

        function verifyConfigSet(hModel)

            cs=getActiveConfigSet(hModel);


            isCompliant=strcmp(get_param(cs,'AutosarCompliant'),'on');
            if~isCompliant
                msg=DAStudio.message('RTW:autosar:nonAutosarCompliant');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end


            targetLang=get_param(cs,'TargetLang');
            mapping=autosar.api.Utils.modelMapping(hModel);
            if strcmp(targetLang,'C')&&...
                isa(mapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:ClassicModelSetupAdaptiveMapping',...
                get_param(hModel,'Name'));
            elseif strcmp(targetLang,'C++')&&...
                isa(mapping,'Simulink.AutosarTarget.ModelMapping')
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:AdaptiveModelSetupClassicMapping',...
                get_param(hModel,'Name'));
            end

            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            if(32<=maxShortNameLength)&&(maxShortNameLength<=128)

            else
                msg=DAStudio.message('RTW:autosar:invalidMaxShortNameLength',maxShortNameLength,32,128);
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if strcmp(get_param(cs,'CombineOutputUpdateFcns'),'off')
                msg=DAStudio.message('RTW:autosar:combineOutputUpdate');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if strcmp(get_param(cs,'SupportContinuousTime'),'on')
                msg=DAStudio.message('RTW:autosar:noContinuousTimeSupport');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if strcmp(get_param(cs,'SupportNonInlinedSFcns'),'on')
                msg=DAStudio.message('RTW:autosar:noNonInlinedSFcnsSupport');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if strcmp(get_param(cs,'RateTransitionBlockCode'),'Function')
                msg=DAStudio.message('RTW:autosar:noRtbOutlinedSupport');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if strcmp(get_param(cs,'SFInvalidInputDataAccessInChartInitDiag'),'none')
                msg=DAStudio.message('autosarstandard:validation:autosarSFInvalidInputDataAccessInChartInitDiagSetToNone');
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            if~autosar.validation.ExportFcnValidator.isExportFcn(hModel)&&...
                ~strcmp(get_param(cs,'SampleTimeConstraint'),'STIndependent')...
                &&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')

                if strcmp(get_param(cs,'AutoInsertRateTranBlk'),'on')
                    msg=DAStudio.message('autosarstandard:validation:autoInsertRateTranBlk');
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                elseif~strcmp(get_param(cs,'MultiTaskRateTransMsg'),'error')
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:MultiTaskRateTransMsgNotError',getfullname(hModel));
                end
            end
        end
    end

end


