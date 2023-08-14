function customizationPLCModelAdvisor()
% SL_CUSTOMIZATION - Model Advisor customization for Simulink PLC Coder
%     This function is invoked only when model advisor
%     is opened. Either for the first time it is opened or
%     the first time it is opened after refresh
%     customizations is invoked. Invoked from
%     SLCheckCustomizationServiceImpl::RegisterModelAdvisorCustomizations

% Copyright 2020 The MathWorks, Inc.

    cm = DAStudio.CustomizationManager;

    % Register custom checks for model advisor under By Product
    cm.addModelAdvisorCheckFcn(@definePLCModelAdvisorChecks);

    % Register custom checks for model advisor under By Tasks
    cm.addModelAdvisorTaskFcn(@definePLCModelAdvisorTasks);
end

function definePLCModelAdvisorChecks()
% Callback to register the PLC Model Advisor checks.

    plccoder.modeladvisor.plc_check_list;
end

function definePLCModelAdvisorTasks()
% Callback to register the PLC Model Advisor tasks.

    taskGroups = plccoder.modeladvisor.task_groups;
    plccoder.modeladvisor.plc_task_list(taskGroups);
end
