classdef AdaptiveSetupValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            modelName=get_param(hModel,'Name');
            this.verifyAdaptiveModelSetup(modelName);
            this.verifyR2011FeatureFlag(modelName);
            this.verifyMultiTasking(modelName);
        end

    end

    methods(Static,Access=private)

        function verifyAdaptiveModelSetup(modelName)



            if~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                autosar.validation.Validator.logError('autosarstandard:validation:invalidAdaptiveMapping',modelName);
            end
        end

        function verifyR2011FeatureFlag(modelName)


            if strcmp(get_param(modelName,'AutosarSchemaVersion'),'R20-11')&&...
                slfeature('AutosarAdaptiveR2011')==0
                autosar.validation.Validator.logError('autosarstandard:validation:adaptiveR2011FeatureNotSet');
            end
        end

        function verifyMultiTasking(modelName)


            emt=strcmp(get_param(modelName,'EnableMultiTasking'),'on');
            ct=strcmp(get_param(modelName,'ConcurrentTasks'),'on');

            if(emt&&~ct)
                autosar.validation.Validator.logError('autosarstandard:validation:ConcurrentTasksDisabled',modelName);
            end


            explicitPartitioning=strcmp(get_param(modelName,'ExplicitPartitioning'),'on');
            if explicitPartitioning
                autosar.validation.Validator.logError('autosarstandard:validation:ExplicitPartitioningEnabled',modelName);
            end
        end
    end

end


