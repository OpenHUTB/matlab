function out=getDiagnosticDirectory(modelName)





    [~,writeToFile,overwriteFile]=...
    soc.internal.profile.getHWDiagnosticsOptions(modelName);

    if writeToFile
        subName=DAStudio.message('soc:scheduler:HWDiagFolderPostfix');
        out=soc.internal.profile.getSharedDiagnosticDirName(...
        modelName,subName,overwriteFile);
    else
        out='';
    end
end