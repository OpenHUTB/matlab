



classdef WizardManager<handle

    properties(Access=private)
ModelToQuickStartWizardMap
    end

    methods(Access=private)
        function obj=WizardManager()



            obj.ModelToQuickStartWizardMap=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods(Static,Access=private)
        function manager=instance()



            persistent singleton

            if isempty(singleton)
                manager=autosar.ui.app.quickstart.WizardManager();
                singleton=manager;

            else
                manager=singleton;
            end
        end
    end

    methods(Static)
        function wizard(model)





            manager=autosar.ui.app.quickstart.WizardManager.instance();

            modelH=get_param(model,'Handle');


            if manager.ModelToQuickStartWizardMap.isKey(modelH)
                quickStartWizard=manager.ModelToQuickStartWizardMap(modelH);
                quickStartWizard.Gui.Dlg.show;

            else
                quickStartWizard=autosar.ui.app.quickstart.Wizard(manager,model);
                manager.ModelToQuickStartWizardMap(modelH)=quickStartWizard;
                quickStartWizard.Gui.start;

            end
        end
        function unregisterQuickStartWizard(model)




            manager=autosar.ui.app.quickstart.WizardManager.instance();
            model=get_param(model,'Handle');


            if manager.ModelToQuickStartWizardMap.isKey(model)
                manager.ModelToQuickStartWizardMap.remove(model);
            end
        end
    end
end


