function report=getPassReport(msgCatalogTag)






    report=ModelAdvisor.FormatTemplate('TableTemplate');
    report.setSubTitle(DAStudio.message([msgCatalogTag,'_subtitle']));
    report.setSubResultStatus('Pass');
    report.setSubResultStatusText(DAStudio.message([msgCatalogTag,'_pass']));
end
