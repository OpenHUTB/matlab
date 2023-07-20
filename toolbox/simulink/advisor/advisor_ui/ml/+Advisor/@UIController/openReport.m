function result=openReport(this,fileName)
    result=[];
    if exist(fileName,'file')
        web(fileName);
    else
        error(DAStudio.message('Advisor:ui:advisor_report_error_message'));
    end
end