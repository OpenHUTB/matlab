function reportResults=returnResultsOnError(aObj,displayResultFlag)




    dm=aObj.getDataManager(aObj.getModelName);


    reportResults.ModelName=aObj.getModelName();
    if dm.hasMetaData('ModelFileName')
        if isempty(dm.getMetaData('ModelFileName'))
            reportResults.ModelFileName='';
        else
            reportResults.ModelFileName=dm.getMetaData('ModelFileName');
        end
    else
        reportResults.ModelFileName='';
    end

    reportResults.Status=slci.internal.ReportConfig.getTopErrorStatus();
    reportResults.ReportFile='';
    if displayResultFlag
        aObj.displayResults(reportResults);
    end
end
