classdef EditTimeCheckingSetup<handle





    methods(Static=true,Access='public')
        function setup(system)
            e=edittime.ConfigSetListenerManager.getInstance;
            e.addListener(system);
            edittime.EditTimeCheckingSetup.systemcomposersetup(system);
        end
        function cleanup(system)
            e=edittime.ConfigSetListenerManager.getInstance;
            e.removeListener(system);
        end

        function systemcomposersetup(system)
            if(slfeature('ZCMATLABEditTimeChecks')==1&&strcmp(edittime.getAdvisorChecking(bdroot(system)),'on'))
                if(Simulink.internal.isArchitectureModel(bdroot(system)))
                    mdl=systemcomposer.arch.Model(bdroot(system));
                    impl=mdl.getImpl;
                    mfmodel=mf.zero.getModel(impl);

                    mfmodel.addObservingListener(@(report)edittime.util.ZCListener(report,system));
                end
            end
        end
    end
end

