function fileInfo=getReportFileInfo(obj)
    ccm=obj.Data;
    allfiles={ccm.FileInfo.Name};
    rptSrcFiles=ccm.reportFileList;
    [~,tf]=intersect(allfiles,rptSrcFiles);
    fileInfo=ccm.FileInfo(tf);
end
