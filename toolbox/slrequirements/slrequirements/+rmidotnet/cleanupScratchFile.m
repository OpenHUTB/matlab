function cleanupScratchFile(docObj)




    scratchFolder=fullfile(tempdir,'RMI','scratch');
    if startsWith(docObj.sFile,scratchFolder)
        docObj.hDoc.Close();
        delete(docObj.sFile);
    end
end
