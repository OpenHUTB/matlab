function checkMLReportGenLicense(rpt)




    try
        open(rpt,slreq.report.utils.getDOMLicenseKeyForReq(class(rpt)));
    catch ex
        if strcmpi(ex.identifier,'mlreportgen:dom_error:unableToCheckoutRptGenLicense')
            ME=MException(message('Slvnv:slreq:ReportGenLicenseError'));
            if isa(rpt,'slreq.report.Report')||isa(rpt,'slreq.report.ReportPart')
                ME=ME.addCause(MException(message('Slvnv:slreq:ReportGenErrorNotDefaultTemplate')));
            end
            throw(ME);
        else
            rethrow(ex);
        end
    end

end
