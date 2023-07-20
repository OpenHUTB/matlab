function [ResultDescription, ResultDetails] = C1_Comments(system)
% C1: Comments shall describe the intention of the code

%   Copyright 2020 The MathWorks, Inc.

    ResultDescription = {};
    ResultDetails = {};

    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:CommentsCheckText'));
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);

    if strcmp(ft.SubResultStatus, 'Pass')
        % check if a comment exists as a block description
        if ~isempty(get_param(system,'Description'))
            ft.setSubResultStatus('Pass');
        else
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:CommentsStatusText'));
            ft.setRecAction(DAStudio.message('plccoder:modeladvisor:CommentsRecAction'));
            mdladvObj.setCheckResultStatus(false);
        end
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];
end
