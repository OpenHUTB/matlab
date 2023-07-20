function fixReqTableDescriptors(allChartCvIds)







    try
        for chartCvId=allChartCvIds
            chartSfId=cv('get',chartCvId,'.handle');
            if~Stateflow.ReqTable.internal.isRequirementsTable(chartSfId)
                continue;
            end

            allSlsfobjCvIds=cv('DecendentsOf',chartCvId);
            for slsfobjCvId=allSlsfobjCvIds
                cvi.SFReqTable.fixReqRowDescriptors(chartSfId,slsfobjCvId);
            end
        end
    catch Mex
        rethrow(Mex);
    end

