function section=createFileListSection(this,docType)




    section=dependencies.internal.report.DependencyAnalyzerReportPart(docType);

    if isempty(this.FileNodes)
        return
    end

    title=getResource("FileListTitle");
    section.append(mlreportgen.dom.Heading2(title));

    rows=arrayfun(...
    @(idx)this.getFileListTableRowFromIndex(idx,docType),...
    1:length(this.FileNodes),"UniformOutput",false);
    rows=vertcat(rows{:});

    headerKeys=[
    "FileListNameHeader",...
    "FileListTypeHeader",...
    "FileListProblemsHeader"];
    headers=arrayfun(@getResource,headerKeys);

    fileTable=mlreportgen.dom.FormalTable(headers,rows);
    fileTable=setFileListTableStyle(fileTable);
    section.append(fileTable);

    section=applyMargin(section,docType);
end
