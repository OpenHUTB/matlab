




function displayResults(aObj,summary)


    tab='        ';
    slci.internal.outputMessage([tab,'==== RESULTS ====',newline],'info');

    if numel(summary)==1



        if~isempty(summary(1).ReportFile)

            reportFullFile=summary(1).ReportFile;

            [~,reportFile,ext]=fileparts(reportFullFile);
            reportFileName=[reportFile,ext];

            if feature('hotlinks')
                reportFileLink=slci.internal.ReportUtil.createFileLink(...
                reportFullFile,...
                reportFileName);
            else
                reportFileLink=reportFullFile;
            end
        else
            reportFileLink='';
        end




        modelName=summary(1).ModelName;
        slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPI_MODELNAME',modelName),newline],'info');

        Config=slci.internal.ReportConfig;
        slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPI_STATUS',...
        Config.getStatusMessage(summary(1).Status)),newline],'info');


        slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPI_REPORT',reportFileLink),newline],'info');

    elseif numel(summary)>1





        summaryReport=aObj.getSummaryReportFile();
        [~,reportFileName,htmlext]=fileparts(summaryReport);
        reportFileName=[reportFileName,htmlext];


        if feature('hotlinks')
            reportFileLink=slci.internal.ReportUtil.createFileLink(...
            summaryReport,reportFileName);
        else
            reportFileLink=summaryReport;
        end
        statusCounts=getStatusCounts(summary);
        statusMap=removeZeroStatus(statusCounts);
        statuses=keys(statusMap);
        numModels=numel(summary);


        for k=1:numel(statuses)
            slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPI',statuses{k}),newline],'info');
            slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPIOF',statusMap(statuses{k}),numModels),newline],'info');
        end
        slci.internal.outputMessage([tab,DAStudio.message('Slci:slci:MESSAGE_CMDAPI_SUMMARYREPORT',reportFileLink),newline],'info');
    end
end

function statusCounts=getStatusCounts(summaryReport)
    statusList=slci.internal.ReportConfig.getTopStatusList();
    numList=numel(statusList);
    initList=num2cell(zeros(1,numList));
    statusCounts=containers.Map(statusList,initList);
    for k=1:numel(summaryReport)
        thisStatus=summaryReport(k).Status;
        statusCounts(thisStatus)=statusCounts(thisStatus)+1;
    end
end

function statusMap=removeZeroStatus(statusCounts)
    statusMap=containers.Map;
    statuses=keys(statusCounts);
    Config=slci.internal.ReportConfig;
    for k=1:numel(statuses)
        thisStatus=statuses{k};
        if statusCounts(thisStatus)>0
            statusText=Config.getStatusMessage(thisStatus);
            statusMap(statusText)=statusCounts(thisStatus);
        end
    end
end
