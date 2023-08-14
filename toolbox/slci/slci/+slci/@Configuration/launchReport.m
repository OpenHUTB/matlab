


function launchReport(aObj,reportSummary)



    if numel(reportSummary)>1
        if exist(aObj.getSummaryReportFile(),'file')
            open(aObj.getSummaryReportFile());
        end
    else
        if exist(aObj.getReportFile(),'file')
            open(aObj.getReportFile());
        end
    end

end
