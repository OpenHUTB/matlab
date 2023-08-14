


function exportHTML(cbinfo)










    try
        configObj=slci.toolstrip.util.getConfiguration(cbinfo.studio);
    catch ME
        slci.internal.outputMessage(ME,'error');
        return;
    end

    if configObj.getFollowModelLinks()
        reportFile=configObj.getSummaryReportFile();
    else
        reportFile=configObj.getReportFile();
    end

    reportExists=false;

    if exist(reportFile,'file')
        open(reportFile);
        reportExists=true;
    end

    if~reportExists
        stageName='Export';
        modelName=cbinfo.model.Name;
        myStage=slci.internal.turnOnDiagnosticView(stageName,modelName);
        try
            DAStudio.error('Slci:slci:INSPECTION_INCOMPLETE',reportFile);
        catch ME
            slci.internal.outputMessage(ME,'warning');
        end
        myStage.delete;
    end
end