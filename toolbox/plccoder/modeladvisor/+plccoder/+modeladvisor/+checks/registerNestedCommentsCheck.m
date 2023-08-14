function registerNestedCommentsCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.NestedComments');
    rec.Title = DAStudio.message('plccoder:modeladvisor:NestedCommentsTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:NestedCommentsTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@C3_NestedComments,'None','StyleTwo');
    rec.ListViewVisible = false;
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = C3_NestedComments(system)
% C3: Avoid nested comments
    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    [ResultDescription, ResultDetails] = plccoder.modeladvisor.helpers.C1_Comments(system);

    ResultDescription{1}.setCheckText(DAStudio.message('plccoder:modeladvisor:NestedCommentsStatusText'));

    if strcmp(ResultDescription{1}.SubResultStatus,'Pass')

        desc = get_param(system,'Description');
        indCC = strfind(desc,'*)');

        if ~isempty(regexp(desc,'\n')) && ~isempty(indCC)
            ResultDescription{1}.setSubResultStatus('Warn');
            ResultDescription{1}.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:NestedCommentsSubStatusText'));
            ResultDescription{1}.setRecAction(DAStudio.message('plccoder:modeladvisor:NestedCommentsRecAction'));
            mdladvObj.setCheckResultStatus(false);
        end
    end
end
