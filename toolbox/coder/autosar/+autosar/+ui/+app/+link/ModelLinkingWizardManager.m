



classdef ModelLinkingWizardManager<handle

    properties(Access=private)
ModelToLinkingWizardMap
    end

    methods(Access=private)
        function obj=ModelLinkingWizardManager()



            obj.ModelToLinkingWizardMap=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods(Static,Access=private)
        function manager=instance()



            persistent singleton

            if isempty(singleton)
                manager=autosar.ui.app.link.ModelLinkingWizardManager();
                singleton=manager;

            else
                manager=singleton;
            end
        end
    end

    methods(Access=public)
        function linkingWizard=getModelLinkingWizard(this,compBlkH)
            linkingWizard=this.ModelToLinkingWizardMap(compBlkH);
        end
    end

    methods(Static)
        function launchWizard(linkInfo)





            manager=autosar.ui.app.link.ModelLinkingWizardManager.instance();

            compBlkH=linkInfo.compBlkH;




            if manager.ModelToLinkingWizardMap.isKey(compBlkH)
                linkingWizard=manager.getModelLinkingWizard(compBlkH);
                linkingWizard.Gui.Dlg.show;
            else


                linkingWizard=autosar.ui.app.link.ModelLinkingWizard(manager,linkInfo);
                manager.ModelToLinkingWizardMap(compBlkH)=linkingWizard;


                linkingWizard.Gui.start;
            end
        end

        function unregisterModelLinkingWizard(compBlkH)






            manager=autosar.ui.app.link.ModelLinkingWizardManager.instance();

            if manager.ModelToLinkingWizardMap.isKey(compBlkH)
                manager.ModelToLinkingWizardMap.remove(compBlkH);
            end
        end
    end
end


