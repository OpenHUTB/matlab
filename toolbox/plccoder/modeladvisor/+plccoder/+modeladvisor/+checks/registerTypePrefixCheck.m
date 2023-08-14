function registerTypePrefixCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.TypePrefixCheck');
    rec.Title = DAStudio.message('plccoder:modeladvisor:TypePrefixCheckTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:TypePrefixCheckTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@N2_TypePrefixCheck,'None','StyleTwo');
    rec.ListViewVisible = false;
    rec.Value = false;
    rec.CallbackContext = 'PostCompile';
    ip = ModelAdvisor.InputParameter; ip.Type = 'PushButton';
    ip.Name = 'Open Keywords File';
    ip.Entries = @plccoder.modeladvisor.helpers.openplckeywordsfile;
    ip.setRowSpan([1 1]); ip.setColSpan([4 4]);
    rec.setInputParameters({ip});
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = N2_TypePrefixCheck(system)
% N2: Define type prefixes for Variables (if used)

    ResultDescription = {};
    ResultDetails = {};
    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:TypePrefixCheckText'));
    ft.setTableTitle(DAStudio.message('plccoder:modeladvisor:TypePrefixCheckTableTitle'));
    ft.setColTitles({'Type', 'Name', 'Data Type', 'Allowed Prefixes'});
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);

    if strcmp(ft.SubResultStatus, 'Pass')
        allObjects = plccoder.modeladvisor.helpers.findAllObjects(system);
        allObjects.rlInportsDataTypes = cellfun(@(x) x.CompiledPortDataTypes.Outport{1},...
                                                allObjects.rlInports,'UniformOutput',false);
        allObjects.rlOutportsDataTypes = cellfun(@(x) x.CompiledPortDataTypes.Inport{1},...
                                                 allObjects.rlOutports,'UniformOutput',false);
        dtlist = plccoder.modeladvisor.helpers.getprefixlist;
        ft = checkDataTypes(ft, allObjects.rlInportsDataTypes,...
                            allObjects.rlInportsNames, dtlist, 'Inport');
        ft = checkDataTypes(ft, allObjects.rlOutportsDataTypes,...
                            allObjects.rlOutportsNames, dtlist, 'Outport');
    end

    if strcmp(ft.SubResultStatus, 'Warn')
        mdladvObj.setCheckResultStatus(false);
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];
end

function ft = checkDataTypes(ft, dataTypes, names, dtlist, type)
    for i = 1:length(dataTypes)
        ind = find(cellfun(@(x) isequal(x,dataTypes{i}), dtlist.dt));
        prefixList = strjoin(dtlist.pf(ind),', ');
        
        noPrefix = true;
        for j = 1:numel(ind)
            if strncmp(dtlist.pf{ind(j)}, names{i}, length(dtlist.pf{ind(j)}))
                noPrefix = false;
            end
        end

        if ~isempty(ind) && noPrefix
            ft.addRow({type, names{i}, dataTypes{i}, prefixList});
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:TypePrefixCheckStatusText'));
        end
    end
end
