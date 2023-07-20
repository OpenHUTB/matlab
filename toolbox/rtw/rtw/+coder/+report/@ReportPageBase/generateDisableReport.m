function generateDisableReport(rpt)
    try
        rpt.init;
        rpt.Doc.setTitle(rpt.getTitle());
        rpt.addHeadItems;
        rpt.addTitle;
        rpt.Doc.addItem(rpt.Toc);

        icon=Advisor.Image;
        icon.setImageSource('hilite_warning.png');
        rpt.addItem(icon);
        rpt.addItem(rpt.getDisableMessage());
        text=rpt.Doc.emitHTML;
    catch me



        text=rpt.generateErrorReportPage(me);
    end
    if isempty(rpt.ReportFileName)
        rpt.ReportFileName=rpt.getDefaultReportFileName;
    end
    encoding=rpt.getEncoding;
    fid=fopen(fullfile(rpt.ReportFolder,rpt.ReportFileName),'w','n',encoding);
    fwrite(fid,text,'char');
    fclose(fid);
end
