classdef ConfigSetFinalValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyFinal(this,hModel)

            this.verifyMultiTaskingMode(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyMultiTaskingMode(hModel)






            assert(autosar.validation.CompiledModelUtils.isCompiled(hModel));

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
            uddobj=get_param(hModel,'UDDObject');
            singleRate=uddobj.outputFcnHasSinglePeriodicRate();
            delete(sess);

            if~singleRate&&~strcmp(get_param(hModel,'SolverMode'),'SingleTasking')

                if~autosar.api.Utils.isMapped(hModel)
                    autosar.validation.Validator.logError('RTW:autosar:expectAutosarInterface');
                end

            end

        end

    end

end


