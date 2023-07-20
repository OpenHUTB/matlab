function addPage(obj,page)
    if~isa(page,'coder.report.ReportPageBase')
        return
    end
    obj.Pages{end+1}=page;
end
