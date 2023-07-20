function justifiedInfo=getObjectivesJustifiedAfterAnalysis(sldvData,filter)



    justifiedInfo.objectives=[];
    justifiedInfo.rationales={};

    if isempty(filter)
        return;
    end

    isXIL=Sldv.DataUtils.isXilSldvData(sldvData);

    for i=1:length(sldvData.Objectives)
        objective=sldvData.Objectives(i);

        modelObjectIdx=objective.modelObjectIdx;
        if isXIL&&numel(modelObjectIdx)>1
            modelObjectIdx=modelObjectIdx(1);
        end
        modelObject=sldvData.ModelObjects(modelObjectIdx);

        if strcmpi(objective.type,'Range')||...
            any(strcmpi(objective.status,{'Excluded','Justified'}))
            continue;
        end

        [isFiltered,filteringMode,rationale]=getFilteredInfo(modelObject,objective,sldvData,filter);
        if isFiltered&&filteringMode==1
            justifiedInfo.objectives=[justifiedInfo.objectives,objective];
            justifiedInfo.rationales=[justifiedInfo.rationales,{rationale}];
        end
    end
end

function[isFiltered,filteringMode,rationale]=getFilteredInfo(modelObject,objective,data,filter)
    isFiltered=false;
    filteringMode=-1;
    rationale='';

    ssid=sldvshareprivate('getModelObjectSidForFilter',modelObject);


    isCodeObjective=isfield(objective,'codeLnk')&&~isempty(objective.codeLnk);
    if isCodeObjective
        codeFilterInfo=sldv.code.internal.CodeInfoUtils.extractCodeFilterInfo(objective.codeLnk,ssid);
        if isempty(codeFilterInfo)
            return
        end
    end

    [isFiltered,prop,rationale]=filter.isFiltered(ssid);
    if isFiltered
        filteringMode=prop.mode;
        return;
    end

    if Sldv.utils.isErrorDetectionObjective(objective)&&~isCodeObjective
        objIdxsOfMdlobject=modelObject.objectives;
        objsOfMdlobject=data.Objectives(objIdxsOfMdlobject);
        sameTypeObjsOfMdlobject=objsOfMdlobject(strcmpi({objsOfMdlobject.type},objective.type));
        if length(sameTypeObjsOfMdlobject)==1
            idx=1;
        else

            sortedGoalIds=sort([sameTypeObjsOfMdlobject.goal]);
            idx=find(sortedGoalIds==objective.goal,1,'first');
        end

        prop=getObjectFilteredByRte(filter,ssid,...
        strrep(lower(objective.type),' ','_'),...
        idx);
    elseif Sldv.utils.isTestGenObjectiveForFiltering(objective)
        idx=objective.coveragePointIdx;
        outcomeIdx=objective.outcomeValue+1;
        objType=lower(objective.type);
        if strcmp(objType,'condition')

            outcomeIdx=3-outcomeIdx;
        elseif strcmp(objType,'mcdc')
            if~isCodeObjective
                idx=sldvshareprivate('getMcdcCovObjectiveIndex',data,modelObject,objective);
                outcomeIdx=objective.coveragePointIdx;
            end
        end
        if isCodeObjective
            prop=getCodeObjectFilteredByMetric(filter,...
            codeFilterInfo,...
            objType);
        else
            prop=getObjectFilteredByMetric(filter,ssid,...
            objType,...
            idx,...
            outcomeIdx);
        end
    end

    if isempty(prop)
        return;
    end

    isFiltered=true;
    filteringMode=prop.value.mode;
    rationale=prop.value.rationale;
end


