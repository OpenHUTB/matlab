function report=getReport(violations,msgCatalogTag)






    if isempty(violations)
        report=Advisor.Utils.Report.getPassReport(msgCatalogTag);
    else
        report=Advisor.Utils.Report.getFailReport(violations,msgCatalogTag);
    end
end
