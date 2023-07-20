classdef ReportPart<mlreportgen.dom.LockedDocumentPart


    properties(Access=protected)
        ReportOptions;
        ShowUI;
CachedTemplateNameToReportPartMap
    end
    methods
        function part=ReportPart(rptOrRptParentPart,templatePartName)



            if isKey(rptOrRptParentPart.CachedTemplateNameToReportPartMap,templatePartName)
                cachedPart=rptOrRptParentPart.CachedTemplateNameToReportPartMap(templatePartName);
                superArg={cachedPart,templatePartName};
            else
                superArg={rptOrRptParentPart.Type,rptOrRptParentPart.TemplatePath,templatePartName};
            end


            part=part@mlreportgen.dom.LockedDocumentPart(superArg{:});

            slreq.report.utils.checkMLReportGenLicense(part);

            rptOrRptParentPart.CachedTemplateNameToReportPartMap(templatePartName)=part;
            part.CachedTemplateNameToReportPartMap=rptOrRptParentPart.CachedTemplateNameToReportPartMap;
            part.ReportOptions=rptOrRptParentPart.ReportOptions;
            part.ShowUI=rptOrRptParentPart.ShowUI;
        end
    end


end
