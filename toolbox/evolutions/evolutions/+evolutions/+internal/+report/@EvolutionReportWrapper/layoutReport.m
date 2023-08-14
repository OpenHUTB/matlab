function layoutReport(obj)





    titlePage=mlreportgen.report.TitlePage('Title',obj.ReportTitle,...
    'Author',obj.AuthorName,...
    'PubDate',datestr(now));

    add(obj.Report,titlePage);


    toc=mlreportgen.report.TableOfContents;
    add(obj.Report,toc);

end

