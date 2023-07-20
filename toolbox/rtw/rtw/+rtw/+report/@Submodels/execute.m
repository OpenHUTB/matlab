function execute(obj)
    modelName=cell(size(obj.ModelReferencesReports));
    for k=1:length(obj.ModelReferencesReports)
        reportName=obj.ModelReferencesReports{k};
        modelName{k}=getModelName(reportName);
        obj.addLink(reportName,modelName{k});
    end
    modelsWithoutReport=setdiff(obj.ModelReferences,modelName);
    for k=1:length(modelsWithoutReport)
        tooltip=DAStudio.message('RTW:report:SubmodelWithoutReportTooltip',modelsWithoutReport{k});
        obj.addTextWithTooltip(modelsWithoutReport{k},tooltip);
    end
end
