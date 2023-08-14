function newSummary=formatResults(summary)




    Config=slci.internal.ReportConfig;
    newSummary(numel(summary),1)=struct;

    for k=1:numel(summary)

        newSummary(k).Model.CONTENT=summary(k).ModelName;
        newSummary(k).Model.ATTRIBUTES=summary(k).ModelFileName;

        newSummary(k).Status.CONTENT=Config.getStatusMessage(summary(k).Status);
        newSummary(k).Status.ATTRIBUTES=summary(k).Status;

        if~isempty(summary(k).ReportFile)
            reportFullFile=summary(k).ReportFile;
            [~,reportFile,ext]=fileparts(reportFullFile);
            reportFileName=[reportFile,ext];
            newSummary(k).Report.CONTENT=reportFileName;

            newSummary(k).Report.ATTRIBUTES=reportFileName;
        else
            newSummary(k).Report.CONTENT='';
            newSummary(k).Report.ATTRIBUTES='';
        end

    end

end
