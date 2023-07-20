function section=createListSection(headingLevel,title,names,docType)




    section=dependencies.internal.report.DependencyAnalyzerReportPart(docType);
    if isempty(names)
        return
    end
    section.append(mlreportgen.dom.Heading(headingLevel,title));
    section.append(mlreportgen.dom.UnorderedList(sort(unique(names))));
    section=applyMargin(section,docType);
end
