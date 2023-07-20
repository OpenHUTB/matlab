function[isReqTable,titleStr]=getDescriptionStrAndLinkIfReqTable(sfId)





    isReqTable=false;
    titleStr='';

    try
        chartId=sfprivate('getChartOf',sfId);
        if chartId<=0


            return;
        end

        isReqTable=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
        if~isReqTable||sfId==chartId


            return;
        end

        req=cvi.ReportUtils.getReqTableRow(sfId,chartId);
        if isempty(req)
            return;
        end


        titleStr=getString(message('Slvnv:simcoverage:cvhtml:SFReqTableRow',req.idString,req.summary));
    catch SlCovMEx %#ok<NASGU>
    end
