





function inferenceData=extractInferenceData(chartUDDObj,blkHdl)


    reportData=sfprivate('eml_report_manager','report',...
    chartUDDObj.Id,blkHdl,true);
    if~isempty(reportData);
        inferenceData=reportData.inference;
    else
        inferenceData=[];
    end

end
