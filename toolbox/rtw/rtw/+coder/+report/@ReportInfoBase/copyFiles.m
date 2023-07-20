function copyFiles(srcFolder,srcFiles,destFolder)
    for k=1:length(srcFiles)
        dstFilename=fullfile(destFolder,srcFiles{k});
        srcFilename=fullfile(srcFolder,srcFiles{k});
        coder.internal.coderCopyfile(srcFilename,dstFilename);
    end
end
