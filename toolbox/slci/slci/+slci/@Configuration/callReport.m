function reportSummary=callReport(aObj)





    aObj.setInspectProgressBarLabel('Report');

    if aObj.getVerbose()
        m=message('Slci:report:StartReportGen');
        disp(m.getString);
    end

    slci.Configuration.deleteReportFile(aObj.getSummaryReportFile());
    try
        reportSummary=aObj.genReport;
    catch ME
        aObj.HandleException(ME);
        reportSummary=aObj.returnResultsOnError(false);
    end

    formattedSummary=slci.Configuration.formatResults(reportSummary);
    aObj.genSummaryReport(formattedSummary);

    if aObj.getVerbose()
        m=message('Slci:report:EndReportGen');
        disp(m.getString);
    end




    if isempty(aObj.getShowReport())
        showReport=aObj.getDefaultShowReport();
    else
        showReport=aObj.getShowReport();
    end
    if showReport
        aObj.launchReport(formattedSummary);
    end


    if strcmpi(aObj.getDisplayResults,'Summary')
        aObj.displayResults(reportSummary);
    end


    aObj.getDataManager().discardData();
end

