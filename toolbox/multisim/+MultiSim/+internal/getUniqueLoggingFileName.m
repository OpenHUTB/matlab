







function logfileName=getUniqueLoggingFileName(workingDir,fileName,runId)
    validateattributes(fileName,{'char'},{'vector'});


    [pathstr,name,ext]=fileparts(fileName);
    isAbsPath=MultiSim.internal.isAbsolutePath(pathstr);
    if isAbsPath

        logfileName=fullfile(pathstr,[name,'_',num2str(runId),ext]);
    else


        logfileName=fullfile(workingDir,pathstr,[name,'_',num2str(runId),ext]);
    end
end