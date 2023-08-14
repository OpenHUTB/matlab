



classdef CompImportWizardManager<handle

    properties(Access=private)
ModelToImporterWizardMap
    end

    methods(Access=private)
        function obj=CompImportWizardManager()



            obj.ModelToImporterWizardMap=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods(Static,Access=private)
        function manager=instance()



            persistent singleton

            if isempty(singleton)
                manager=autosar.ui.app.import.CompImportWizardManager();
                singleton=manager;

            else
                manager=singleton;
            end
        end
    end

    methods(Static)
        function importWizard(slSourceH)






            manager=autosar.ui.app.import.CompImportWizardManager.instance();


            if manager.ModelToImporterWizardMap.isKey(slSourceH)
                importerWizard=manager.ModelToImporterWizardMap(slSourceH);
                importerWizard.Gui.Dlg.show;
            else




                assert(autosar.arch.Utils.isSubSystem(slSourceH)||...
                autosar.arch.Utils.isBlockDiagram(slSourceH),...
                '%s is not a block or model',getfullname(slSourceH));

                if autosar.composition.Utils.isComponentBlock(slSourceH)
                    importerWizard=autosar.ui.app.import.ComponentImportWizard(manager,slSourceH);
                else
                    assert(autosar.composition.Utils.isCompositionBlock(slSourceH)||...
                    autosar.composition.Utils.isModelInCompositionDomain(slSourceH),...
                    '%s is not a composition block or model',getfullname(slSourceH));
                    importerWizard=autosar.ui.app.import.CompositionImportWizard(manager,slSourceH);
                end
                manager.ModelToImporterWizardMap(slSourceH)=importerWizard;
                importerWizard.Gui.start;
            end
        end
        function unregisterImportWizard(slSourceH)







            manager=autosar.ui.app.import.CompImportWizardManager.instance();

            if manager.ModelToImporterWizardMap.isKey(slSourceH)
                manager.ModelToImporterWizardMap.remove(slSourceH);
            end
        end
    end
end


