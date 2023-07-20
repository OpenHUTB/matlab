function[activeObjectives,justifiedObjs,isXIL,canApplyFilter]=getActiveAndJustifiedObjectives(sldvData,justifiedObjs)




    isXIL=Sldv.DataUtils.isXilSldvData(sldvData);
    canApplyFilter=~sldvprivate('cannot_apply_filter',sldvData);

    if isempty(justifiedObjs)&&canApplyFilter
        filter=sldvprivate('getFilterFromAutoVerifyData',sldvData.ModelInformation.Name);

        if~isempty(filter)
            justifiedInfo=sldvprivate('getObjectivesJustifiedAfterAnalysis',sldvData,filter);
            justifiedObjs=justifiedInfo.objectives;
        end
    end


    if isempty(justifiedObjs)
        activeObjectives=sldvData.Objectives;
    else
        activeObjectives=[];
        for i=1:length(sldvData.Objectives)
            if isempty(sldvshareprivate('util_get_obj_idx_in_list',...
                sldvData.Objectives(i),justifiedObjs))
                activeObjectives=[activeObjectives,sldvData.Objectives(i)];%#ok<AGROW>
            end
        end
    end
end
