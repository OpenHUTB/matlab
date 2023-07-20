function processObjectiveForFilter(filter,sldvData,objectiveIdx,linkType,isCalledFromGUI)




    if nargin<5
        isCalledFromGUI=false;
    end

    objective=sldvData.Objectives(objectiveIdx);

    modelObjectIdx=objective.modelObjectIdx;
    if numel(modelObjectIdx)>1&&Sldv.DataUtils.isXilSldvData(sldvData)
        modelObjectIdx=modelObjectIdx(1);
    end
    mdlObject=sldvData.ModelObjects(modelObjectIdx);

    ssid=sldvshareprivate('getModelObjectSidForFilter',mdlObject);

    objType=lower(objective.type);

    isCodeObjective=isfield(objective,'codeLnk')&&~isempty(objective.codeLnk);

    if Sldv.utils.isErrorDetectionObjective(objective)



        objIdxsOfMdlobject=mdlObject.objectives;
        objsOfMdlobject=sldvData.Objectives(objIdxsOfMdlobject);
        sameTypeObjsOfMdlobject=objsOfMdlobject(strcmpi({objsOfMdlobject.type},objType));
        if numel(sameTypeObjsOfMdlobject)==1
            idx=1;
        else

            sortedGoalIds=sort([sameTypeObjsOfMdlobject.goal]);
            idx=find(sortedGoalIds==objective.goal,1,'first');
        end
        ruleType='rte';
        objType=strrep(objType,' ','_');
        outcomeIdx=777;
    elseif Sldv.utils.isTestGenObjectiveForFiltering(objective)

        idx=objective.coveragePointIdx;
        ruleType='metric';
        outcomeIdx=objective.outcomeValue+1;
        if strcmp(objType,'condition')

            outcomeIdx=3-outcomeIdx;
        elseif strcmp(objType,'mcdc')
            if~isCodeObjective
                idx=sldvshareprivate('getMcdcCovObjectiveIndex',sldvData,mdlObject,objective);
                outcomeIdx=objective.coveragePointIdx;
            end
        end
    elseif any(strcmp(objType,{'relationalboundary','test objective'}))&&linkType==2



        rowIdx=[];
        filterKey=ssid;
        if isCodeObjective


            codeFilterInfo=sldv.code.internal.CodeInfoUtils.extractCodeFilterInfo(objective.codeLnk,ssid);
            if~isempty(codeFilterInfo)
                filterKey=codeFilterInfo;
            end
        end
        [isFiltered,prop,~]=filter.isFiltered(filterKey);
        if isFiltered
            rowIdx=filter.showRule(prop);
        end

        if~isFiltered||isempty(rowIdx)
            filter.show(isCodeObjective);
            errordlg(getString(message('Sldv:Filter:RuleNotInFilter')),...
            getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
            'modal');
        end
        return;
    else
        return;
    end

    if linkType==0||linkType==1

        descr=sldvshareprivate('getObjectiveDescrForFilter',ssid,objective);
        if isCodeObjective

            justifyOrViewCodeObjective(filter,objective,ssid,linkType,descr,false,isCalledFromGUI);
        else
            excludeOrJustifyObjective(filter,ruleType,ssid,objType,idx,outcomeIdx,linkType,descr);
        end
    elseif linkType==2||linkType==3

        if isCodeObjective
            justifyOrViewCodeObjective(filter,objective,ssid,linkType,'',true,isCalledFromGUI);
        else
            viewObjective(filter,ruleType,ssid,objType,idx,outcomeIdx,objective.descr);
        end
    end
end

function justifyOrViewCodeObjective(filter,objective,ssid,mode,descr,isView,isCalledFromGUI)
    codeFilterInfo=sldv.code.internal.CodeInfoUtils.extractCodeFilterInfo(objective.codeLnk,ssid);
    if isempty(codeFilterInfo)
        return;
    end


    [isFiltered,prop,~]=filter.isFiltered(codeFilterInfo);
    if isFiltered
        filter.showRule(prop);
        if isCalledFromGUI
            filter.show(true);
        end
        return;
    end

    if isView
        filter.showMetricRule(codeFilterInfo,0,0,'',true);
        filter.show(true);
    else
        if mode==0

            return;
        end
        filter.addRemoveInstance(codeFilterInfo,descr,0,0,'','add');
    end
    if isCalledFromGUI
        filter.show(true);
    end
end

function excludeOrJustifyObjective(filter,ruleType,ssid,objType,objIdx,outcomeIdx,mode,descr)
    assert(any(strcmp(ruleType,{'rte','metric'})));

    rowIdx=[];
    if strcmp(ruleType,'rte')&&filter.hasRteProp
        rowIdx=filter.showRteRule(ssid,objType,objIdx);
    elseif strcmp(ruleType,'metric')&&filter.hasMetricProp
        rowIdx=filter.showMetricRule(ssid,objIdx,outcomeIdx,objType);
    end

    if isempty(rowIdx)

        switch ruleType
        case 'rte'
            filter.addRteFilter(ssid,objType,objIdx,outcomeIdx,mode,'',descr);
        case 'metric'
            filter.addMetricFilter(ssid,objType,objIdx,outcomeIdx,mode,'',descr);
        end
    else
        prop=filter.tableIdxMap(rowIdx).value;
        if prop.mode~=mode

            filter.changeFilterModeCallback(filter.m_dlg,rowIdx,mode);


        end
    end
end

function viewObjective(filter,ruleType,ssid,objType,objIdx,outcomeIdx,objDescr)
    assert(any(strcmp(ruleType,{'rte','metric'})));

    rowIdx=[];
    [isFiltered,prop,~]=filter.isFiltered(ssid);
    if isFiltered
        rowIdx=filter.showRule(prop);
    elseif strcmp(ruleType,'rte')&&filter.hasRteProp
        rowIdx=filter.showRteRule(ssid,objType,objIdx);
    elseif strcmp(ruleType,'metric')
        if filter.hasMetricProp
            rowIdx=filter.showMetricRule(ssid,objIdx,outcomeIdx,objType);
        end
        if isempty(rowIdx)










            [isFiltered,subProps]=filter.isFilteredBySubProp(ssid);
            if isFiltered
                for i=1:numel(subProps)
                    if subProps(i).selectorType==slcoverage.BlockSelectorType.TemporalEvent
                        for j=1:numel(subProps(i).value)
                            if strcmp(subProps(i).value(j).type,'Event')&&...
                                (contains(objDescr,['"',subProps(i).value(j).name,'"'])||contains(objDescr,getString(message('Sldv:goal_label:TrigExpr'))))&&...
                                (contains(objDescr,getString(message('Sldv:goal_label:True')))||contains(objDescr,getString(message('Sldv:goal_label:False'))))
                                rowIdx=filter.showRule(subProps(i));
                            end
                        end
                    end
                end
            end
        end
    end

    if isempty(rowIdx)
        filter.show;
        errordlg(getString(message('Sldv:Filter:RuleNotInFilter')),...
        getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
        'modal');
        return;
    end
end
