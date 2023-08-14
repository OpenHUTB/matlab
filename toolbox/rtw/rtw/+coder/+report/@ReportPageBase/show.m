function show(obj)
    tmp=obj.getLinkManager();
    tmp.show(fullfile(obj.ReportFolder,obj.getReportFileName()));
end
