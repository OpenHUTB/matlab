function layoutReport(obj)
import mlreportgen.report.*

% Add title page
titlePage = TitlePage('Title', obj.ReportTitle, ...
                      'Author', obj.AuthorName, ...
                      'PubDate', datestr(now));
    
add(obj.Report, titlePage);

% Add Table of Contents page

toc = TableOfContents;
add(obj.Report, toc);

% Add Report body
obj.addReportBody();

end