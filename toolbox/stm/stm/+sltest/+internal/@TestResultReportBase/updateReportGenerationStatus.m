function updateReportGenerationStatus(obj,percent)








    if(obj.ReportGenStatus<2)
        obj.sendMSGToUI(percent,'',false);
    end
end