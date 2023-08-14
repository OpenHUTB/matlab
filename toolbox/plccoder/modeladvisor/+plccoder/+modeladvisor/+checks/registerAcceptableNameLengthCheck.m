function registerAcceptableNameLengthCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.AcceptableNameLength');
    rec.Title = DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@N6_AcceptableNameLength,'None','StyleTwo');
    rec.ListViewVisible = false;
    rec.setInputParametersLayoutGrid([1 2]);
    inputParam1 = ModelAdvisor.InputParameter;
    inputParam1.Name = DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthInputName');
    inputParam1.Value='32';
    inputParam1.Type='String';
    inputParam1.Description= DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthInputName');
    inputParam1.setRowSpan([1 1]);
    inputParam1.setColSpan([1 1]);
    rec.setInputParameters({inputParam1});
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = N6_AcceptableNameLength(system)
% N6: Define an acceptable name length
    ResultDescription = {};
    ResultDetails = {};

    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    inputParams = mdladvObj.getInputParameters;
    maxLength = int8(str2num(inputParams{1}.Value));

    if isempty(maxLength)
        mdladvObj.setCheckResultStatus(true);
    end

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthCheckText'));
    ft.setTableTitle(DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthTableTitle'));
    ft.setColTitles({'Type', 'Name'});
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);

    if strcmp(ft.SubResultStatus, 'Pass')
        allObjects = plccoder.modeladvisor.helpers.findAllObjects(system);

        %Root-Level Inports
        ft = checkNames(ft, allObjects.rlInportsNames, maxLength, 'Inport');

        %Root-Level Outports
        ft = checkNames(ft, allObjects.rlOutportsNames, maxLength, 'Outport');

        %SF Objects
        ft = checkNames(ft, allObjects.sfObjectsNames, maxLength, 'SF Object');

        %Data Stores
        ft = checkNames(ft, allObjects.dataStoresNames, maxLength, 'Data Store');

        %Signals
        ft = checkNames(ft, allObjects.signalsNames, maxLength, 'Signal');

        %Parameters
        ft = checkNames(ft, allObjects.parametersNames, maxLength, 'Parameter');
    end

    if strcmp(ft.SubResultStatus, 'Warn')
        mdladvObj.setCheckResultStatus(false);
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];
end

function ft = checkNames(ft, names, maxLength, type)
    for i = 1:length(names)
        if length(names{i}) > maxLength
            ft.addRow({type,names{i}});
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:AcceptableNameLengthStatusText'));
        end
    end
end
