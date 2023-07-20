function sldbg = enterDebug(runTestCfg, tcID)
    % Step into simulation and pause model in state reflected by test case

    % Copyright 2019 The MathWorks, Inc.
    model = runTestCfg.modelToRun;
    sldbg = sltest.testmanager.Debugger(model);

    runTestCfg.SimulationInput = runTestCfg.SimulationInput.setModelParameter( ...
        'SaveFormat', 'Dataset');

    % restore ReturnWorkspaceOutputsName
    sldbg.WorkspaceRestore = stm.internal.util.RestoreVariable(get_param(model, 'ReturnWorkspaceOutputsName'));

    % always open the model when debugging
    open_system(model);

    % restore dirty state of model
    dirty = get_param(model, 'Dirty');
    sldbg.DirtyCleanup = onCleanup(@() set_param(model, 'Dirty', dirty));

    if runTestCfg.runUsingSimIn
        % use TemporaryModelState to apply temporarily SimIn settings for debugging

        % The main model's lock should be turned off before the model can be
        % placed in debug mode. We will restore it back on cleanup.
        mainModel = runTestCfg.SimulationInput.ModelName;
        if strcmp(get_param(mainModel,'Lock'),'on')
            sldbg.LockCleanup = onCleanup(@()Simulink.harness.internal.setBDLock(mainModel, true));
            mainModelDirty = get_param(mainModel, 'Dirty');
            sldbg.MainModelDirtyCleanup = onCleanup(@() set_param(mainModel, 'Dirty', mainModelDirty));
            Simulink.harness.internal.setBDLock(mainModel, false);
        end

        % Logging specification is a hidden property and needs to be
        % explicitly applied
        sldbg.ModelState = Simulink.internal.TemporaryModelState(runTestCfg.SimulationInput,...
            'ApplyHidden', matlab.lang.OnOffSwitchState.on);
        set_param(model, 'Dirty', dirty); % restore as TemporaryModelState will dirty
    end

    % Pause at t=StartTime
    stepperObj = Simulink.SimulationStepper(model);
    stepperObj.forward;
    sldbg.StepperCleanup = onCleanup(@()stm.internal.RunTestConfiguration.stopDebug(stepperObj));

    currSimStatus = get_param(model, 'SimulationStatus');
    % update status if stopped at a breakpoint
    if strcmpi(currSimStatus, 'paused')
        stm.internal.Spinner.updateTestCaseSpinnerLabel(tcID,...
            message('stm:general:PausedAtSLBreakPoint',model).getString, 'Type','stopInDebug');
        resetSpinner = onCleanup(@()stm.internal.Spinner.updateTestCaseSpinnerLabel(tcID,...
            message('stm:general:Running').getString, 'Type','continueRunning'));
    else
        % somehow the model is not paused so probably it errored and we
        % need to throw the errors
        stepperObj.runBlockingNonUIModeWithErrorsThrown();
    end
end
