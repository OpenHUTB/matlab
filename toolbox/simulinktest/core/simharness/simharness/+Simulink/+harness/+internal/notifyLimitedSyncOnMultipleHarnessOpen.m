function notifyLimitedSyncOnMultipleHarnessOpen(systemModel)






    harnessList=Simulink.harness.internal.getHarnessList(systemModel,'loaded');

    if(slfeature('MultipleHarnessOpen')>0)&&(length(harnessList)>1)
        bdHandle=get_param(systemModel,'Handle');
        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        for i=1:numel(allStudios)
            if(allStudios(i).App.blockDiagramHandle==bdHandle)

                activeEditor=allStudios(i).App.getActiveEditor();

                activeEditor.deliverInfoNotification('Simulink:Harness:LimitedSynchronizationDueToMultipleHarnessOpen',...
                DAStudio.message('Simulink:Harness:LimitedSynchronizationDueToMultipleHarnessOpen'));
            end
        end
    end
end
