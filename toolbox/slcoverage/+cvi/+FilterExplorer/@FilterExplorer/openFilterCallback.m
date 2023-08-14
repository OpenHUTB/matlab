
function filterExplorer=openFilterCallback(filterCtxUUID,filterUUID,cvdataId,viewCmd,topModelName,fileName,forCode)



    try
        if nargin<5
            topModelName='';

        end
        if nargin<6
            fileName='';
        end
        if nargin<7
            forCode=false;
        end
        ctxInfo.filterCtxId=filterCtxUUID;
        ctxInfo.filterReportViewCmd=viewCmd;
        ctxInfo.cvdId=cvdataId;
        ctxInfo.topModelName=topModelName;
        ctxInfo.filterFileName=fileName;
        filterExplorer=cvi.FilterExplorer.FilterExplorer.getFilterExplorer(ctxInfo);


        if isempty(filterExplorer)
            cvi.TopModelCov.handleFilterCallback(topModelName,fileName,'','show',[],false);
            return;
        end
        filterExplorer.triggerStartCallback();

        filterObj=filterExplorer.findFilterFromReportCallback(filterUUID,fileName);
        if~isempty(filterObj)
            filterExplorer.showFilter(filterObj.getUUID,forCode);
        else
            filterExplorer.show();
        end
    catch MEx
        rethrow(MEx);
    end
end
