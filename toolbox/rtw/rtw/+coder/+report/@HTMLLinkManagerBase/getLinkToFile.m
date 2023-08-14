function out=getLinkToFile(obj,rptFileName,fullFileName)
    htmlFileName=obj.getHTMLFileName(fullFileName);
    out=coder.report.ReportInfoBase.getRelativePathToFile(htmlFileName,rptFileName);
end
