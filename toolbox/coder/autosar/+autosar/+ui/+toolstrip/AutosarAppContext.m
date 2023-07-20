classdef AutosarAppContext<coder.internal.toolstrip.CoderAppContext





    methods
        function obj=AutosarAppContext(app,cbinfo)
            assert(strcmp(app.name,'autosarApp'));
            obj@coder.internal.toolstrip.CoderAppContext(app,cbinfo);
        end

        function guardAppName=getGuardAppName(~)
            guardAppName='Autosar';
        end

        function updateTypeChain(obj)
            type=coder.internal.toolstrip.util.getOutputType(obj.ModelH);
            switch type
            case 'autosar'
                obj.OutputTypeContext='autosarCodeContext';
            case 'autosar_adaptive'
                obj.OutputTypeContext='autosarAdaptiveCodeContext';
            otherwise
                obj.OutputTypeContext='customCodeContext';
            end
            updateTypeChain@coder.internal.toolstrip.CoderAppContext(obj);
            if Simulink.CodeMapping.isMappedToAutosarSubComponent(obj.ModelH)
                obj.TypeChain{end+1}='autosarSubComponentContext';
            else
                obj.TypeChain{end+1}='autosarComponentContext';
            end
        end

        function checkoutLicense(~)




            licenses={'autosar_blockset'};
            for i=1:length(licenses)
                builtin('_license_checkout',licenses{i},'quiet');
            end
        end

        function preOpen(~,cbinfo)
            modelName=cbinfo.model.Name;
            [isMapped,modelMapping]=autosar.api.Utils.isMapped(modelName);
            if~isMapped


                autosar.ui.toolstrip.AutosarAppContext.preWizardLaunchChecks(modelName);


                autosar.ui.app.quickstart.WizardManager.wizard(modelName);




                try
                    autosar.api.create(modelName,'init');
                catch


                end
            else
                if strcmp(get_param(modelName,'AutosarCompliant'),'off')


                    if isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
                        set_param(modelName,'SystemTargetFile','autosar_adaptive.tlc');
                    else
                        set_param(modelName,'SystemTargetFile','autosar.tlc');
                    end
                else




                end
            end
        end
    end

    methods(Static,Access=private)
        function preWizardLaunchChecks(modelName)


            interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
            if~isempty(interfaceDicts)



                autosar.validation.InterfaceDictionaryValidator.checkSingleInterfaceDict(...
                modelName,interfaceDicts);
            end
        end
    end
end


