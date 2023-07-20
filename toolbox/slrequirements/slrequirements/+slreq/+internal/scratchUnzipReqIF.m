function unzippedLocation=scratchUnzipReqIF(reqifFile)






    scratchDir=fullfile(tempdir,'RMI','scratch');
    if exist(scratchDir,'dir')==7
        rmdir(scratchDir,'s');
    end
    mkdir(scratchDir);
    unzip(reqifFile,scratchDir);
    unzippedFiles=slreq.import.findFilesInFolder(scratchDir,'.reqif');
    if isempty(unzippedFiles)||isempty(regexpi(unzippedFiles{1},'.reqif$'))
        error(message('Slvnv:slreq_import:InvalidReqifFile'));
    else
        unzippedLocation=unzippedFiles{1};
    end
end
