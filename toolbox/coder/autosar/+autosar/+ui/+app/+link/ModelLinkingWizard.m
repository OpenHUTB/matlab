




classdef ModelLinkingWizard<autosar.ui.app.link.ModelLinkingWizardBase

    properties(Hidden,Constant)

        GuiTag='Tag_Autosar_Model_Linker';
    end

    methods
        function env=ModelLinkingWizard(manager,linkInfo)








            env@autosar.ui.app.link.ModelLinkingWizardBase(manager,linkInfo);
        end

        function closeWizard=finish(env)
            import autosar.composition.studio.AUTOSARComponentToModelLinker;
            closeWizard=true;


            env.start_spin();
            c=onCleanup(@()env.stop_spin());

            try
                isUIMode=true;
                compToModelLinker=AUTOSARComponentToModelLinker(env.CompBlkH,env.ModelToLink,isUIMode);



                if env.QFlags.linking
                    compToModelLinker.LinkingFixer.applyFixes(env.ValMsgs);
                end



                if env.QFlags.quickStart
                    env.finishQuickStart();
                end



                valMsgs=compToModelLinker.LinkingValidator.validateRequirements;
                if any(~structfun(@isempty,valMsgs.failures))




                    assert(~isempty(valMsgs.failures.portsFail)&&~isempty(valMsgs.warnings.bepWarn),'An unexpected error during linking fixes occurred.');
                end
            catch mException
                compToModelLinker.LinkingFixer.revertFixes();
                env.stop_spin;
                sldiagviewer.reportError(mException);
                closeWizard=false;
                return;
            end


            compToModelLinker.linkComponentToModel();
        end
    end
end




