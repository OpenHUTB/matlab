function val = setConcurrentExecution(modelName)
% SETCONCURRENTEXECUTION Set the model to enable concurrent execution of
% tasks for multicore ARM Cortex-A platforms.
% 
% If some blocks in the model do not support the concurrent execution of
% tasks, the model is left unchanged and return value is false.
%
% Example:
%   % Set the model "modelName" to allow concurrent execution of tasks for 
%   val =  codertarget.arm_cortex_a.internal.setConcurrentExecution(modelName);
%   

%  Copyright 2015-2017 The MathWorks, Inc.


load_system(modelName);

% If the model is in SingleTasking mode or auto, give a message saying 
% the model should support multi-tasking mode to enable concurrent execution
if ( strcmpi(get_param(modelName, 'SolverMode'), 'SingleTasking') )
    DAStudio.message('arm_cortex_a:utils:ModelNotMultiTask',modelName);
    val = false;
    return;
end

sess = Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
delSession = onCleanup(@()delete(sess));
try
    % Try to initialize the Simulink session by turning on errors for
    % Multi-tasking subsystem - this is a modeling constraint for
    % Concurrent Execution.
    warnState = warning('off','Simulink:SampleTime:SlowEnableToFastSubsys');
    warnState2 = warning('off','Simulink:SampleTime:FixedStepSizeHeuristicWarn');
    resetWarn = onCleanup(@()warning(warnState.state, warnState.identifier));
    resetWarn2 = onCleanup(@()warning(warnState2.state, warnState2.identifier));
    multiTaskDSMMsgStat = get_param(modelName, 'MultiTaskDSMMsg');
    multiTaskCondExecSysMsg = get_param(modelName, 'MultiTaskCondExecSysMsg');
    set_param(modelName, 'MultiTaskDSMMsg',             'error');
    set_param(modelName, 'MultiTaskCondExecSysMsg',     'error');
    bd = Simulink.CMI.CompiledBlockDiagram(sess, modelName);
    sess.init(bd);
    val = bd.isModelConcurrTaskCompatible(sess);
    sess.term(bd);
    if (val == true)
        % Configure model for Concurrent Execution
        set_param(modelName, 'EnableConcurrentExecution',   'on');
        set_param(modelName, 'ConcurrentTasks',             'on');
    end
catch ME %#ok<NASGU>
    set_param(modelName,'MultiTaskDSMMsg',multiTaskDSMMsgStat);
    set_param(modelName,'MultiTaskCondExecSysMsg',multiTaskCondExecSysMsg);
    val = false;
end
