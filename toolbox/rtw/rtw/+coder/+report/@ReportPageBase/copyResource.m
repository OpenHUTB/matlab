function copyResource(rpt,resourceFile,resourceFolder)
    if isempty(resourceFolder)
        resourceFolder=rpt.getResourceFolder;
    end
    folder=rpt.ReportFolder;
    if isempty(folder)
        folder=pwd;
    end
    file=fullfile(folder,resourceFile);
    srcFile=fullfile(resourceFolder,resourceFile);
    coder.internal.coderCopyfile(srcFile,file);
end
