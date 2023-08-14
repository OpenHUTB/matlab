function fts=sortObjs(elementsObj,sortMethod,groupMode)
    fts={};
    sortCriteria={};
    sortedObjs={};
    sortedStatus={};

    for i=1:length(elementsObj)
        if elementsObj(i).Type==ModelAdvisor.ResultDetailType.String||(isempty(elementsObj(i).Data)&&elementsObj(i).Type==ModelAdvisor.ResultDetailType.SID)
            if~ismember(sortMethod,{'Subsystem'})
                ft=ModelAdvisor.Report.Utils.processInformationalData(elementsObj(i));
                fts{end+1}=ft;%#ok<AGROW>
                fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            end
            continue;
        end
        foundMatch=false;
        for j=1:length(sortCriteria)
            if ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),sortCriteria{j},'compare')
                sortedObjs{j}{end+1}=elementsObj(i);%#ok<AGROW>
                sortedStatus{j}=elementsObj(i).getViolationStatus;%#ok<AGROW>
                foundMatch=true;
                break;
            end
        end
        if~foundMatch
            sortedObjs{end+1}={elementsObj(i)};%#ok<AGROW>
            sortCriteria{end+1}=ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),'','addIntoCriteria');%#ok<AGROW>
            sortedStatus{end+1}=elementsObj(i).getViolationStatus;%#ok<AGROW>
        end
    end





    if strcmp(sortMethod,'Subsystem')
        [matchProperties,mismatchProperties]=find_match_properties(elementsObj);
        if~isempty(elementsObj)&&isempty(mismatchProperties)&&(elementsObj(1).Type~=ModelAdvisor.ResultDetailType.RootLevelStateflowData)...
            &&(elementsObj(1).Type~=ModelAdvisor.ResultDetailType.SimulinkVariableUsage)

            hasCustomData=any(arrayfun(@(x)~isempty(x.CustomData),elementsObj));

            ft=ModelAdvisor.FormatTemplate('TableTemplate');
            ft=ModelAdvisor.Report.Utils.processBasicData(elementsObj(1),ft,matchProperties);
            ColTitles={getString(message('ModelAdvisor:engine:Subsystem')),getString(message('ModelAdvisor:engine:BlockPath'))};
            if groupMode
                ColTitles=[{getString(message('ModelAdvisor:engine:CheckID'))},ColTitles];
            end
            if hasCustomData
                ColTitles=[ColTitles,{getString(message('Advisor:engine:Description'))}];
            end
            ft.setColTitles(ColTitles);
            for j=1:numel(elementsObj)
                if~isempty(elementsObj(j).Data)
                    if elementsObj(j).IsViolation
                        if elementsObj(j).Type==ModelAdvisor.ResultDetailType.Signal
                            elementsObject=get_param(elementsObj(j).Data,'Object');
                            SubsystemPath=elementsObject.Parent;
                        elseif elementsObj(j).Type==ModelAdvisor.ResultDetailType.RootLevelStateflowData
                            SubsystemPath=elementsObj(j).DetailedInfo.ModelName;
                        else
                            parent=Simulink.ID.getParent(elementsObj(j).Data);
                            if isempty(parent)
                                SubsystemPath=Simulink.ID.getFullName(elementsObj(j).Data);
                            else
                                SubsystemPath=Simulink.ID.getFullName(parent);
                            end
                        end
                        if groupMode
                            ft.addRow({elementsObj(j).CheckID,SubsystemPath,elementsObj(j).Data});
                        else
                            if elementsObj(j).Type==ModelAdvisor.ResultDetailType.RootLevelStateflowData
                                machineSID=Simulink.ID.getSID(elementsObj(j).DetailedInfo.ModelName);
                                fakeSID=[machineSID,':',elementsObj(j).Data];
                                formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,fakeSID);
                                slCB=...
                                ['matlab: modeladvisorprivate hiliteSystem MACHINELEVEL_SID:',...
                                fakeSID];
                                formattedTextObj.setHyperlink(slCB);
                                if hasCustomData
                                    ft.addRow({SubsystemPath,formattedTextObj,elementsObj(i).CustomData});
                                else
                                    ft.addRow({SubsystemPath,formattedTextObj});
                                end
                            else
                                if hasCustomData
                                    ft.addRow({SubsystemPath,elementsObj(j).Data,elementsObj(i).CustomData});
                                else
                                    ft.addRow({SubsystemPath,elementsObj(j).Data});
                                end
                            end
                        end
                    end
                end
            end
            fts{end+1}=ft;
            return
        end
    end

    for i=1:numel(sortedObjs)
        elementsObjs=sortedObjs{i};

        switch sortMethod
        case 'RecommendedAction'
            ft=generate_default_listtemplate_output(elementsObjs);
        case{'Subsystem','Block'}
            if elementsObjs{1}.Type~=ModelAdvisor.ResultDetailType.SID
                ft=generate_default_listtemplate_output(elementsObjs);
            else
                [matchProperties,mismatchProperties]=find_match_properties(elementsObjs);

                if numel(mismatchProperties)==0

                    ft=generate_default_listtemplate_output(elementsObjs);
                else

                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft=ModelAdvisor.Report.Utils.processBasicData(elementsObjs{1},ft,matchProperties);
                    ColTitles=cell(1,numel(mismatchProperties));
                    expression='';
                    for cols=1:numel(mismatchProperties)
                        ColTitles{cols}=loc_i18n(mismatchProperties{cols});
                        expression=[expression,'elementsObjs{j}.',mismatchProperties{cols},','];%#ok<AGROW>
                    end
                    if groupMode
                        ft.setColTitles([{getString(message('ModelAdvisor:engine:CheckID'))},ColTitles,{getString(message('ModelAdvisor:engine:BlockPath'))}]);
                        if~isempty(elementsObjs{1}.Data)
                            expression=['ft.addRow({elementsObjs{j}.CheckID, ',expression,'elementsObjs{j}.Data})'];%#ok<AGROW>
                        elseif~isempty(elementsObjs{1}.FileName)
                            expression=['ft.addRow({elementsObjs{j}.CheckID, ',expression,'elementsObjs{j}.FileName})'];%#ok<AGROW>
                        end
                    else
                        ft.setColTitles([ColTitles,{getString(message('ModelAdvisor:engine:BlockPath'))}]);
                        if~isempty(elementsObjs{1}.Data)
                            expression=['ft.addRow({',expression,'elementsObjs{j}.Data})'];%#ok<AGROW>
                        elseif~isempty(elementsObjs{1}.FileName)
                            expression=['ft.addRow({',expression,'elementsObjs{j}.FileName})'];%#ok<AGROW>
                        end
                    end
                    for j=1:numel(elementsObjs)
                        if~isempty(elementsObjs{j}.Data)
                            if elementsObjs{j}.IsViolation
                                eval(expression);
                            end
                        end
                    end
                end
                if strcmp(sortMethod,'Subsystem')
                    if elementsObjs{1}.Type==ModelAdvisor.ResultDetailType.Signal
                        elementsObject=get_param(elementsObjs{1}.Data,'Object');
                        SubsystemPath=elementsObject.Parent;
                    else
                        SubsystemPath=Simulink.ID.getFullName(Simulink.ID.getParent(elementsObjs{1}.Data));
                    end

                    ft.setCheckText(['<b>',SubsystemPath,':</b><br/>',elementsObjs{1}.Description]);
                    if isempty(ft.SubResultStatusText)
                        ft.setSubResultStatusText(getString(message('ModelAdvisor:engine:IssueForSubsystemBlocks')));
                    end
                else
                    ft.setCheckText(['<b>',getString(message('ModelAdvisor:engine:IssueForBlock',Simulink.ID.getFullName(elementsObjs{1}.Data))),':</b><br/>',elementsObjs{1}.Description]);
                end
            end
        otherwise
        end

        if sortedStatus{i}==ModelAdvisor.CheckStatus.Warning
            ft.setSubResultStatus('Warn');
        elseif(sortedStatus{i}==ModelAdvisor.CheckStatus.Failed)
            ft.setSubResultStatus('Fail');
        elseif(sortedStatus{i}==ModelAdvisor.CheckStatus.Passed)
            ft.setSubResultStatus('Pass');
        else
            ft.setSubResultStatus('None');
        end
        fts{end+1}=ft;%#ok<AGROW>        
    end

    if isempty(fts)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setCheckText(getString(message('ModelAdvisor:engine:NoViolationsFound')));
        fts{1}=ft;
    end

end

function ft=generate_default_listtemplate_output(elementsObjs)
    [matchProperties,~]=find_match_properties({});
    if elementsObjs{1}.Type==ModelAdvisor.ResultDetailType.SimulinkVariableUsage
        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        ft=ModelAdvisor.Report.Utils.processBasicData(elementsObjs{1},ft,matchProperties);
        ft.setColTitles({DAStudio.message('ModelAdvisor:hism:common_column_header_data_objects'),DAStudio.message('ModelAdvisor:hism:common_column_header_source')});
        TableInfo={};
        for j=1:numel(elementsObjs)
            if~isempty(elementsObjs{j}.Data)
                TableInfo{j,1}=elementsObjs{j}.Data;%#ok<AGROW>
                TableInfo{j,2}=ModelAdvisor.Text(elementsObjs{j}.DetailedInfo.SlVarSource);%#ok<AGROW>            
                linkString=ModelAdvisor.Report.Utils.exploreListNodeLink(elementsObjs{j});
                TableInfo{j,2}.setHyperlink(linkString);

            end
        end
        ft.setTableInfo(TableInfo);
        return
    end

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft=ModelAdvisor.Report.Utils.processBasicData(elementsObjs{1},ft,matchProperties);
    for j=1:numel(elementsObjs)
        if~isempty(elementsObjs{j}.Data)
            if(elementsObjs{j}.Type==ModelAdvisor.ResultDetailType.RootLevelStateflowData)
                machineSID=Simulink.ID.getSID(elementsObjs{j}.DetailedInfo.ModelName);
                fakeSID=[machineSID,':',elementsObjs{j}.Data];
                formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,fakeSID);
                slCB=...
                ['matlab: modeladvisorprivate hiliteSystem MACHINELEVEL_SID:',...
                fakeSID];
                formattedTextObj.setHyperlink(slCB);

                ft.setListObj([ft.ListObj,{formattedTextObj}]);
            else
                ft.setListObj([ft.ListObj,{elementsObjs{j}.Data}]);
            end
        elseif~isempty(elementsObjs{j}.DetailedInfo.FileName)
            ft.setListObj([ft.ListObj,{elementsObjs{j}.DetailedInfo.FileName}]);
        end
    end
end

function[matchProperties,mismatchProperties]=find_match_properties(Objs)
    Properties={'Description','Title','Information','Status','RecAction'};
    matchProperties=Properties;
    mismatchProperties={};
    if iscell(Objs)
        for i=2:numel(Objs)
            for j=1:numel(matchProperties)
                if~strcmp(Objs{i}.(matchProperties{j}),Objs{1}.(matchProperties{j}))
                    mismatchProperties{end+1}=matchProperties{j};%#ok<AGROW>
                end
            end
            matchProperties=setdiff(matchProperties,mismatchProperties);
        end
    else
        for i=2:numel(Objs)
            for j=1:numel(matchProperties)
                if~strcmp(Objs(i).(matchProperties{j}),Objs(1).(matchProperties{j}))
                    mismatchProperties{end+1}=matchProperties{j};%#ok<AGROW>
                end
            end
            matchProperties=setdiff(matchProperties,mismatchProperties);
        end
    end
end

function i18nMessage=loc_i18n(propertyName)
    switch propertyName
    case 'Description'
        i18nMessage=getString(message('ModelAdvisor:engine:Description'));
    case 'RecAction'
        i18nMessage=getString(message('ModelAdvisor:engine:RecommendedAction'));
    otherwise
        i18nMessage=propertyName;
    end
end