function registerMaxInOutCheck()
% --- CP23: Define maximum number of input/output/in-out variables of a POU

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.MaxInOut');
    rec.Title = DAStudio.message('plccoder:modeladvisor:MaxInOutTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:MaxInOutTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@CP23_MaxInOut,'None','StyleTwo');
    rec.ListViewVisible = false;
    rec.setInputParametersLayoutGrid([1 2]);
    inputParam1 = ModelAdvisor.InputParameter;
    inputParam1.Name = DAStudio.message('plccoder:modeladvisor:MaxInOutInputName');
    inputParam1.Value='20';
    inputParam1.Type='String';
    inputParam1.Description= DAStudio.message('plccoder:modeladvisor:MaxInOutInputDescription');
    inputParam1.setRowSpan([1 1]);
    inputParam1.setColSpan([1 1]);
    rec.setInputParameters({inputParam1});
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = CP23_MaxInOut(system)

    ResultDescription = {};
    ResultDetails = {};

    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    inputParams = mdladvObj.getInputParameters;
    maxNo = int8(str2double(inputParams{1}.Value));

    if isempty(maxNo)
        mdladvObj.setCheckResultStatus(true);
    end

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:MaxInOutCheckText'));
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);
    if strcmp(ft.SubResultStatus, 'Pass')
        ports = get_param(system,'Ports');
        if (ports(1) + ports(2)) > maxNo
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:MaxInOutSubStatusText', num2str(maxNo)));
            ft.setRecAction(DAStudio.message('plccoder:modeladvisor:MaxInOutRecAction'));
            mdladvObj.setCheckResultStatus(false);
        end
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];
end

% LocalWords:  CP POU
