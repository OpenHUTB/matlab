
function handleFilterCallback(topModelH,filterFileName,ssid,action,codeCovInfo,explorerGeneratedReport,idx,outcomeIdx,metricName,descr)


    try

        if nargin<5
            codeCovInfo=[];
        end
        if nargin<10
            idx=0;
            outcomeIdx=0;
            metricName='';
            descr='';
        end

        forCode=~isempty(codeCovInfo);

        filterObj=cvi.TopModelCov.getFilterObj(topModelH,explorerGeneratedReport);
        isExplorer=false;
        if isa(filterObj,'cvi.ResultsExplorer.ResultsExplorer')
            filter=filterObj.filterEditor;
            isExplorer=true;
        else
            filter=filterObj;
        end
        filter.initFilterFromFile(filterFileName);
        if strcmpi(action,'showRule')
            if forCode
                ssid=codeCovInfo;
            end

            if~isExplorer
                filter.show(forCode);
                filter.showMetricRule(ssid,idx,outcomeIdx,metricName);
            else
                filterObj.showFilter(forCode);
                filterObj.showFilterMetricRule(ssid,idx,outcomeIdx,metricName);
            end

        else
            if~strcmpi(action,'showFilter')
                if forCode
                    filter.addRemoveInstance(codeCovInfo,[],idx,outcomeIdx,metricName,action);
                else
                    if~isempty(ssid)
                        filter.addRemoveInstance(ssid,descr,idx,outcomeIdx,metricName,action);
                    end
                end
            end
            if~isExplorer
                filter.show(forCode);
            else
                filterObj.showFilter(forCode);
            end
        end
    catch MEx
        rethrow(MEx);
    end
end
