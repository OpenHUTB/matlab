function report=getListReport(listOfViolations,msgCatalogTag)






    report=ModelAdvisor.FormatTemplate('ListTemplate');
    report.setSubTitle(DAStudio.message([msgCatalogTag,'_subtitle']));
    report.setSubBar(false);
    report.setSubResultStatus('Warn');
    report.setSubResultStatusText(DAStudio.message([msgCatalogTag,'_warn']));
    report.setRecAction(DAStudio.message([msgCatalogTag,'_recAction']));
    report.setListObj(listOfViolations);

end

