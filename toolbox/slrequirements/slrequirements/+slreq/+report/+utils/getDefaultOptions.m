function out=getDefaultOptions()
    out.reportPath=slreq.report.utils.generateReportName(['slreqrpt_',datestr(now,'YYYYmmDD')]);


    if ispc&&slreq.report.utils.checkApp('.docx')
        extName='docx';
    else
        extName='pdf';
    end

    out.openReport=true;
    out.templatePath=slreq.report.utils.getDefaultTemplatePath(extName);
    out.titleText='';
    if ispc
        out.authors=getenv('USERNAME');
    else
        out.authors=getenv('USER');
    end
    out.includes.toc=true;
    out.includes.publishedDate=true;
    out.includes.revision=true;
    out.includes.properties=true;
    out.includes.links=true;
    out.includes.changeInformation=true;
    out.includes.groupLinksBy='Artifact';
    out.includes.keywords=true;
    out.includes.comments=true;
    out.includes.implementationStatus=true;
    out.includes.verificationStatus=true;
    out.includes.emptySections=false;
    out.includes.rationale=true;
    out.includes.customAttributes=true;
    if reqmgt('rmiFeature','TraceabilityTable')
        out.includes.traceabilityTables=true;
        out.includes.groupTraceabilityTablesBy='ReqSets';
        out.includes.traceabilityTablesLinkTypes='Confirm.Derive.Implement.Refine.Relate.Verify';
    end
end