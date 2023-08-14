classdef Validator<autosar.validation.PhasedValidator




    properties(Access=private)
cleanupObj
    end

    methods(Access=public)

        function verify(this,aiOrModelH,varargin)




            autosar.api.Utils.autosarlicensed(true);

            cleanupVerifier=onCleanup(@()delete(this.cleanupObj));

            p=inputParser;
            p.KeepUnmatched=false;
            p.FunctionName='verify';
            p.addParameter('ValidationPhase','All',@(x)any(validatestring(x,{'Initial','PostProp','Final','All'})));
            p.parse(varargin{:});
            validationPhase=p.Results.ValidationPhase;


            if~autosar.api.Utils.isMappedToAdaptiveApplication(aiOrModelH)
                autosar.validation.ClientServerValidator.checkValidRunnableConfig(aiOrModelH);
            end

            if strcmp(validationPhase,'All')

                this.verifyPhase('Initial',aiOrModelH);







                autosar.validation.Validator.flushMessages();







                if strcmp(autosar.validation.Validator.getValidationLevel(),'full')

                    this.cleanupObj=autosar.validation.CompiledModelUtils.forceCompiledModelForRTW(aiOrModelH);

                    assert(~isempty(this.cleanupObj),'Expected non-empty cleanup object');
                end
            else
                this.verifyPhase(validationPhase,aiOrModelH);
            end
        end

        function verifyPhase(~,validationPhase,hModel)





            autosar.api.Utils.autosarlicensed(true);

            assert((ischar(hModel)||isStringScalar(hModel))||ishandle(hModel),'Expected a model handle object');

            isRefModel=strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW');

            if isRefModel
                autosar.validation.Validator.verifyPhaseReferenceModel(validationPhase,hModel);
            else
                autosar.validation.Validator.verifyPhaseTopModel(validationPhase,hModel);
            end
        end
    end

    methods(Static,Access=private)

        function verifyPhaseTopModel(validationPhase,hModel)

            if~autosar.api.Utils.isMapped(hModel)
                autosar.validation.Validator.logError(...
                'Simulink:Engine:RTWCGAutosarEmptyConfigurationError',getfullname(hModel));
            end


            autosar.validation.Validator.verifyPhaseCommon(validationPhase,hModel);

            if autosar.api.Utils.isMappedToAdaptiveApplication(hModel)
                autosar.validation.Validator.verifyPhaseAdaptivePlatform(validationPhase,hModel);
            else
                autosar.validation.Validator.verifyPhaseClassicPlatform(validationPhase,hModel);
            end
        end

        function verifyPhaseReferenceModel(validationPhase,hModel)


            autosar.validation.Validator.verifyPhaseClassicModelRefPlatform(validationPhase,hModel);
        end


        function verifyPhaseCommon(validationPhase,hModel)
            interfaceDictValidator=autosar.validation.InterfaceDictionaryValidator();
            interfaceDictValidator.verifyPhase(validationPhase,hModel);

            commonConfigSetValidator=autosar.validation.CommonConfigSetValidator();
            commonConfigSetValidator.verifyPhase(validationPhase,hModel);

            commonModelingStylesValidator=autosar.validation.CommonModelingStylesValidator();
            commonModelingStylesValidator.verifyPhase(validationPhase,hModel);

            configSetFinalValidator=autosar.validation.ConfigSetFinalValidator();
            configSetFinalValidator.verifyPhase(validationPhase,hModel);


            clientOperationValidator=autosar.validation.ClientOperationValidator();
            clientOperationValidator.verifyPhase(validationPhase,hModel);

            commonSLPortValidator=autosar.validation.CommonSLPortValidator(hModel);
            commonSLPortValidator.verifyPhase(validationPhase,hModel);

            busPortValidator=autosar.validation.BusPortValidatorAdapter.getBusPortValidator(hModel);
            busPortValidator.verifyPhase(validationPhase,hModel);
        end

        function verifyPhaseClassicModelRefPlatform(validationPhase,hModel)

            classicModelRefValidator=autosar.validation.ClassicModelReferenceValidator();
            classicModelRefValidator.verifyPhase(validationPhase,hModel);
        end

        function verifyPhaseClassicPlatform(validationPhase,hModel)

            classicSlPortValidator=autosar.validation.ClassicSLPortValidator(hModel);
            classicSlPortValidator.verifyPhase(validationPhase,hModel);

            classicModelingStylesValidator=autosar.validation.ClassicModelingStylesValidator();
            classicModelingStylesValidator.verifyPhase(validationPhase,hModel);

            dataObjectValidator=autosar.validation.DataObjectValidator(hModel);
            dataObjectValidator.verifyPhase(validationPhase,hModel);

            classicConfigSetValidator=autosar.validation.ClassicConfigSetValidator();
            classicConfigSetValidator.verifyPhase(validationPhase,hModel);

            if autosar.validation.ExportFcnValidator.isExportFcn(hModel)
                exportFcnValidator=autosar.validation.ExportFcnValidator(hModel);
                exportFcnValidator.verifyPhase(validationPhase,hModel,hModel);
            end


            basicSoftwareValidator=autosar.validation.BasicSoftwareValidator();
            basicSoftwareValidator.verifyPhase(validationPhase,hModel);

            classicMappingValidator=autosar.validation.ClassicMappingValidator(hModel);
            classicMappingValidator.verifyPhase(validationPhase,hModel);

            classicSwAddrMethodValidator=autosar.validation.ClassicSwAddrMethodValidator();
            classicSwAddrMethodValidator.verifyPhase(validationPhase,hModel);



            clientServerValidator=autosar.validation.ClientServerValidator();
            clientServerValidator.verifyPhase(validationPhase,hModel);

            classicMetaModelValidator=autosar.validation.ClassicMetaModelValidator();
            classicMetaModelValidator.verifyPhase(validationPhase,hModel);


            internalTriggerValidator=autosar.validation.InternalTriggerValidator();
            internalTriggerValidator.verifyPhase(validationPhase,hModel);
        end

        function verifyPhaseAdaptivePlatform(validationPhase,hModel)

            adaptiveSetupValidator=autosar.validation.AdaptiveSetupValidator();
            adaptiveSetupValidator.verifyPhase(validationPhase,hModel);

            adaptiveConfigSetValidator=autosar.validation.AdaptiveConfigSetValidator();
            adaptiveConfigSetValidator.verifyPhase(validationPhase,hModel);

            adaptiveSlPortValidator=autosar.validation.AdaptiveSLPortValidator(hModel);
            adaptiveSlPortValidator.verifyPhase(validationPhase,hModel);

            adaptiveMappingValidator=autosar.validation.AdaptiveMappingValidator();
            adaptiveMappingValidator.verifyPhase(validationPhase,hModel);

            adaptiveEventCommunicationValidator=autosar.validation.AdaptiveEventCommunicationValidator();
            adaptiveEventCommunicationValidator.verifyPhase(validationPhase,hModel);

            adaptiveNonClassicValidator=autosar.validation.AdaptiveNonClassicValidator();
            adaptiveNonClassicValidator.verifyPhase(validationPhase,hModel);

            adaptiveSLFunctionValidator=autosar.validation.AdaptiveSLFunctionValidator();
            adaptiveSLFunctionValidator.verifyPhase(validationPhase,hModel);

            adaptiveMethodsValidator=autosar.validation.AdaptiveMethodsValidator();
            adaptiveMethodsValidator.verifyPhase(validationPhase,hModel);

            if slfeature('SubsystemTriggeredOnMessage')
                adaptiveModelingStyleValidator=autosar.validation.AdaptiveModelingStylesValidator();
                adaptiveModelingStyleValidator.verifyPhase(validationPhase,hModel);
            end

            adaptiveValidator=autosar.validation.AdaptiveMetaModelValidator();
            adaptiveValidator.verifyPhase(validationPhase,hModel);
        end
    end

    methods(Static)
        function level=getValidationLevel()


            canCompileModelForRTW=autosar.validation.Validator.codersAvailable();
            if canCompileModelForRTW
                level='full';
            else
                level='partial';
            end
        end
    end

    methods(Static,Access=private)
        function codersAvail=codersAvailable()


            [ecoderLicCheckoutSuccess,errMsg]=license('checkout','RTW_Embedded_Coder');%#ok<ASGLU>
            ecoderAvailable=ecoderLicCheckoutSuccess&&ecoderinstalled;
            [slCoderLicCheckoutSuccess,errMsg]=license('checkout','Real-Time_Workshop');%#ok<ASGLU>
            slCoderAvailable=slCoderLicCheckoutSuccess&&dig.isProductInstalled('Simulink Coder');
            codersAvail=ecoderAvailable&&slCoderAvailable;
        end
    end

    methods(Static,Access=public)


















        function logError(id,varargin)
            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            msgStream.createError(id,varargin);
        end

        function logErrorAndFlush(id,varargin)
            autosar.validation.Validator.logError(id,varargin{:});
            autosar.validation.Validator.flushMessages();
        end

        function logWarning(id,varargin)
            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            msgStream.createWarning(id,varargin);
        end

        function flushMessages()
            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            msgStream.flush('autosarstandard:validation:ValidationError');
        end
    end
end


