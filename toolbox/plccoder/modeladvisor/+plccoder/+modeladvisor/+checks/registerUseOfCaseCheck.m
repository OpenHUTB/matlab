function registerUseOfCaseCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.UseOfCase');
    rec.Title = DAStudio.message('plccoder:modeladvisor:UseOfCaseTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:UseOfCaseTiteTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@N4_UseOfCase,'None','StyleTwo');
    rec.ListViewVisible = false;
    ip = ModelAdvisor.InputParameter; ip.Type = 'Combobox';
    ip.Entries = {'alllowercase';'ALLUPPERCASE';'UpperCamelCase';'lowerCamelCase'};
    ip.setRowSpan([1 1]); ip.setColSpan([1 1]);
    ip2 = ModelAdvisor.InputParameter; ip2.Type = 'Bool';
    ip2.Name = DAStudio.message('plccoder:modeladvisor:UseOfCaseInputName');
    ip2.Value = false;
    ip2.setRowSpan([2 2]); ip2.setColSpan([1 1]);
    rec.setInputParameters({ip,ip2});
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end

function [ResultDescription, ResultDetails] = N4_UseOfCase(system)
% N4: Define the use of case (capitals)

    ResultDescription = {};
    ResultDetails = {};
    mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(0);
    mdladvObj.setCheckResultStatus(true);

    ft = ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message('plccoder:modeladvisor:UseOfCaseCheckText'));
    ft.setTableTitle(DAStudio.message('plccoder:modeladvisor:UseOfCaseTableTitle'));
    ft.setColTitles({'Type', 'Name'});
    ft = plccoder.modeladvisor.helpers.checkPLCBlock(system, ft);

    if strcmp(ft.SubResultStatus, 'Pass')

        ip = mdladvObj.getInputParameters(mdladvObj.getActiveCheck);
        switch ip{1}.Value
          case 'alllowercase'
            evalfcn = 'lower';
          case 'ALLUPPERCASE'
            evalfcn = 'upper';
          case 'UpperCamelCase'
            evalfcn = 'ucamel';
          case 'lowerCamelCase'
            evalfcn = 'lcamel';
          otherwise
            evalfcn = 'test';
        end

        ignorePrefix = ip{2}.Value;
        allObjects = plccoder.modeladvisor.helpers.findAllObjects(system);

        %Root-Level Inports
        ft = checkStyle(ft, evalfcn, allObjects.rlInportsNames, 'Inport',ignorePrefix);

        %Root-Level Outports
        ft = checkStyle(ft, evalfcn, allObjects.rlOutportsNames, 'Outport',ignorePrefix);

        %SF Objects
        ft = checkStyle(ft, evalfcn, allObjects.sfObjectsNames, 'SF Object',ignorePrefix);

        %Data Stores
        ft = checkStyle(ft, evalfcn, allObjects.dataStoresNames, 'DataStore',ignorePrefix);

        %Signals
        ft = checkStyle(ft, evalfcn, allObjects.signalsNames, 'Signal',ignorePrefix);

        %Parameters
        ft = checkStyle(ft, evalfcn, allObjects.parametersNames, 'Parameter',ignorePrefix);
    end

    if strcmp(ft.SubResultStatus, 'Warn')
        mdladvObj.setCheckResultStatus(false);
    end

    ResultDescription{end+1} = ft;
    ResultDetails{end+1} = [];
end

function ft = checkStyle(ft, evalfcn, names, type,ignorePrefix)
    switch evalfcn
      case {'lower','upper'}
        for i = 1:length(names)
            namesn = names{i};
            if ignorePrefix
                dtlist = plccoder.modeladvisor.helpers.getprefixlist;
                matches = cell2mat(cellfun(@(x) startsWith(names{i},x), dtlist.pf, 'Uni', 0));
                if any(matches)
                    namesn = names{i}(length(dtlist.pf{matches})+2:end);
                end
            end
            if (~strcmp(namesn, eval([evalfcn '(namesn)']))) || (sum(isstrprop(namesn,'punct'))~=0)
                ft.addRow({type, names{i}});
                ft.setSubResultStatus('Warn');
                ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:UseOfCaseStatusText'));
            end
        end
      case {'ucamel', 'lcamel'}
        for i = 1:length(names)
            if length(names{i})>=2
                namesn = names{i};
                if ignorePrefix
                    dtlist = plccoder.modeladvisor.helpers.getprefixlist;
                    matches = cell2mat(cellfun(@(x) startsWith(names{i},x), dtlist.pf, 'Uni', 0));
                    if any(matches)
                        namesn = names{i}(length(dtlist.pf{matches})+2:end);
                    end
                end
                isUpper = isstrprop(namesn,'upper');
                if isUpper(1)~=strncmp(evalfcn,'u',1) || any(movmean(isUpper(2:end),3)>=1) || (sum(isstrprop(namesn,'punct'))~=0)
                    ft.addRow({type, names{i}});
                    ft.setSubResultStatus('Warn');
                    ft.setSubResultStatusText(DAStudio.message('plccoder:modeladvisor:UseOfCaseStatusText'));
                end
            end
        end
    end
end

% LocalWords:  UseOfCaseTiteTips alllowercase ALLUPPERCASE ucamel lcamel namesn
