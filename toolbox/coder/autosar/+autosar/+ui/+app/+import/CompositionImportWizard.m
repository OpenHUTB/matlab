




classdef CompositionImportWizard<autosar.ui.app.import.CompImportWizardBase

    properties(Hidden,Constant)

        GuiTag='Tag_Autosar_Composition_Importer';
    end

    methods
        function env=CompositionImportWizard(manager,slSourceH)








            env@autosar.ui.app.import.CompImportWizardBase(manager,slSourceH);
        end

        function closeWizard=finish(env)



            closeWizard=true;


            env.start_spin();
            c=onCleanup(@()env.stop_spin());

            try

                env.verifyCompNameUniqueInCompositionHierachy();
            catch mException
                sldiagviewer.reportError(mException);
                closeWizard=false;
                return;
            end


            [~,compositionName]=autosar.utils.splitQualifiedName(env.CompName);
            msg=DAStudio.message('autosarstandard:editor:ImportingCompositionStage',...
            compositionName);
            importingCompositionStage=env.dispStageInContext(msg);%#ok<NASGU>


            aSLMsgViewer=slmsgviewer.Instance();
            if~isempty(aSLMsgViewer)
                aSLMsgViewer.show();
                slmsgviewer.selectTab(getfullname(env.CompositionHandle));
            end


            try
                cmd='env.createComposition();';
                Simulink.output.evalInContext(cmd);
            catch mException
                sldiagviewer.reportError(mException);
                closeWizard=false;
                return;
            end

            set_param(env.SLSourceH,'Name',compositionName);
        end

        function createComposition(env)
            archObj=autosar.arch.Composition.create(env.SLSourceH);
            okToPushNags=true;
            archObj.importCompositionFromARXML(env.ArxmlImporter,env.CompName,...
            okToPushNags,...
            'DataDictionary',env.DataDictionary,...
            'ModelPeriodicRunnablesAs',env.ModelPeriodicRunnablesAs,...
            'PredefinedVariant',env.PredefinedVariant,...
            'ExcludeInternalBehavior',env.ExcludeInternalBehavior,...
            'ComponentModels',env.ComponentModels);
        end
    end

    methods(Access=private)
        function terminateStage=dispStageInContext(this,msg)

            terminateStage=sldiagviewer.createStage(msg,'ModelName',getfullname(this.CompositionHandle));
        end
    end
end



