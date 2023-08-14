function reportRuleCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,topModelName,filterFileName,action,ssid,codeCovInfo,idx,outcomeIdx,metricName,descr)




    try
        if nargin<9
            codeCovInfo=[];
        end
        if nargin<10
            idx=0;
            outcomeIdx=0;
            metricName='';
            descr=[];
        end

        ctxInfo.filterCtxId=filterCtxUUID;
        ctxInfo.filterReportViewCmd=viewCmd;
        ctxInfo.cvdId=cvdataId;
        ctxInfo.topModelName=topModelName;
        ctxInfo.filterFileName=filterFileName;

        filterExplorer=cvi.FilterExplorer.FilterExplorer.getFilterExplorer(ctxInfo);

        if isempty(filterExplorer)
            cvi.TopModelCov.handleFilterCallback(topModelName,filterFileName,ssid,action,codeCovInfo,false,idx,outcomeIdx,metricName,descr);
            return;
        end

        wasNotVisible=filterExplorer.triggerStartCallback();
        if wasNotVisible
            filterExplorer.show();
        end
        if strcmpi(action,'add')||strcmpi(action,'addByProp')
            filterObj=filterExplorer.getSelectedFilter();
            if(isempty(filterObj)||wasNotVisible)&&~isempty(filterExplorer.filters)


                [filterObj,isCancelled]=filterExplorer.promptFilterSelection();
                if isCancelled
                    return;
                end
            end
            if isempty(filterObj)
                filterObj=filterExplorer.newFilter();
            end
        else
            filterObj=filterExplorer.findFilterFromReportCallback(filterUUID,filterFileName);
        end

        if isempty(filterObj)
            return;
        end
        forCode=~isempty(codeCovInfo);
        if strcmpi(action,'showRule')||strcmpi(action,'showByProp')
            if forCode
                ssid=codeCovInfo;
            end
            filterExplorer.showFilterRule(filterObj.getUUID,ssid,idx,outcomeIdx,metricName,forCode);
        else
            if strcmpi(action,'add')||strcmpi(action,'remove')
                if forCode
                    filterObj.addRemoveInstance(codeCovInfo,[],idx,outcomeIdx,metricName,action);
                else
                    if~isempty(ssid)
                        filterObj.addRemoveInstance(ssid,descr,idx,outcomeIdx,metricName,action);
                    end
                end
            elseif strcmpi(action,'addByProp')||strcmpi(action,'removeByProp')
                action=action(1:end-6);

                filterObj.addRemoveByProp(action,ssid);
            end
            filterExplorer.showFilter(filterObj.getUUID,forCode);
        end
    catch MEx
        rethrow(MEx);
    end
end
