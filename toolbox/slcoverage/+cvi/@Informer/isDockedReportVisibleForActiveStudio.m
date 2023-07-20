function isVisible=isDockedReportVisibleForActiveStudio()




    isVisible=false;
    dockedReports=cvi.Informer.getDockedReportsForActiveStudio();
    if~isempty(dockedReports)
        isVisible=all(arrayfun(@(dr)dr.isVisible(),dockedReports));
    end
end
