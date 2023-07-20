function report=getFailReport(violations,msgCatalogTag)








    assert(~isempty(violations),DAStudio.message('ModelAdvisor:engine:EmptyViolations'));


    [bSubject,bIssue,bReason]=arrayfun(@(x)x.hasProperties,violations);

    bSubject=all(bSubject);
    bIssue=any(bIssue);
    bReason=any(bReason);

    assert(bSubject,DAStudio.message('ModelAdvisor:engine:EmptyViolations'));

    subjects={violations.Subject};
    issues={violations.Issue};
    reasons={violations.Reason};


    if~bIssue&&~bReason
        report=Advisor.Utils.Report.getListReport(subjects,msgCatalogTag);
    elseif~bIssue
        report=Advisor.Utils.Report.getTableReport([subjects(:),reasons(:)],msgCatalogTag);
    elseif~bReason
        report=Advisor.Utils.Report.getTableReport([subjects(:),issues(:)],msgCatalogTag);
    else
        report=Advisor.Utils.Report.getTableReport([subjects(:),issues(:),reasons(:)],msgCatalogTag);
    end
end
