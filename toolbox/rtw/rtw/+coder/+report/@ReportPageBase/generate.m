function generate(rpt)
    try
        text=rpt.emitHTML;
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
