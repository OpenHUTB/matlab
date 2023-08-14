function registerNamesToAvoidCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.NamesToAvoid');
    rec.Title = DAStudio.message('plccoder:modeladvisor:NamesToAvoidTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:NamesToAvoidTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@N3_NamesToAvoid,'None','StyleTwo');
    rec.ListViewVisible = false;
    ip = ModelAdvisor.InputParameter; ip.Type = 'PushButton';
    ip.Name = DAStudio.message('plccoder:modeladvisor:NamesToAvoidInputName');
    ip.Entries = @plccoder.modeladvisor.helpers.openplckeywordsfile;
    ip.setRowSpan([1 1]); ip.setColSpan([4 4]);
    rec.setInputParameters({ip});
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = N3_NamesToAvoid(system)
% N3: Define the names to avoid

    ResultDescription = {};
    ResultDetails = {};
    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:NamesToAvoidCheckText'));
    ft.setTableTitle(DAStudio.message('plccoder:modeladvisor:NamesToAvoidTableTitle'));
    ft.setColTitles({'Type', 'Name'});
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);

    if strcmp(ft.SubResultStatus, 'Pass')
        allObjects = plccoder.modeladvisor.helpers.findAllObjects(system);
        keywords = plccoder.modeladvisor.helpers.getkeywordlist;

        %Root-Level Inports
        ft = checkNames(ft, allObjects.rlInportsNames, keywords, 'Inport');

        %Root-Level Outports
        ft = checkNames(ft, allObjects.rlOutportsNames, keywords, 'Outport');

        %SF Objects
        ft = checkNames(ft, allObjects.sfObjectsNames, keywords, 'SF Object');

        %Data Stores
        ft = checkNames(ft, allObjects.dataStoresNames, keywords, 'Data Store');

        %Signals
        ft = checkNames(ft, allObjects.signalsNames, keywords, 'Signal');

        %Parameters
        ft = checkNames(ft, allObjects.parametersNames, keywords, 'Parameter');
    end

    if strcmp(ft.SubResultStatus, 'Warn')
        mdladvObj.setCheckResultStatus(false);
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];

end

function ft = checkNames(ft, names, keywords, type)
    for i = 1:length(names)
        if (sum(matches(keywords,lower(names{i})))>0) && ...
                ~evalin('base',['isa(''' names{i} ''',''Simulink.AliasType'')'])
            ft.addRow({type,names{i}});
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:NamesToAvoidStatusText'));
        end
    end

end
