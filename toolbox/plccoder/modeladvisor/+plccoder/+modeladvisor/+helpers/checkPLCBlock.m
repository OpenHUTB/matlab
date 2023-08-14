function ft = checkPLCBlock(system, ft)
%

%   Copyright 2020 The MathWorks, Inc.

    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    system = mdladvObj.filterResultWithExclusion(system);

    if isempty(system)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText('The subsystem is excluded for this Model Advisor check');
        ft.setRecAction('Include the subsystem for this check');
    else
        if strcmp(get_param(system,'Type'),'block_diagram')
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText('This check is not intended for the root level of the model');
            ft.setRecAction('Run this check for the subsystem level');
        else
            if ~strcmp(get_param(system,'TreatAsAtomicUnit'),'on')
                ft.setSubResultStatus('Warn');
                ft.setSubResultStatusText('"Treat as atomic unit" is not set');
                ft.setRecAction('Enable "Treat as atomic unit"');
            else
                ft.setSubResultStatus('Pass');
            end
        end
    end
