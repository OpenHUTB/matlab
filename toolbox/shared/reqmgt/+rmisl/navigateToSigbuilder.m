function navigateToSigbuilder(blockH,tabIdx)

    try
        open_system(blockH);
        signalbuilder(blockH,'activegroup',tabIdx);
    catch Mex
        if any(strcmp(Mex.identifier,...
            {'Simulink:Engine:CallbackEvalErr',...
            'Simulink:Harness:LockedBDForHarness'}))

            warndlg(...
            getString(message('Slvnv:rmi:navigate:CannotOpenSigbWhenLocked')),...
            getString(message('Slvnv:rmi:navigate:NavigationError')));
        else
            rethrow(Mex);
        end
    end
end
