function slxcArchive=getSlxcArchiveForModel(modelName)





    slxcArchive='';
    slxcFiles=MultiSim.internal.getSlxcFilesForModel(modelName);
    if~isempty(slxcFiles)
        slxcArchiveName='internalSlxcArchive.zip';
        slxcArchiveDir=tempname;
        slxcArchive=fullfile(slxcArchiveDir,slxcArchiveName);
        mkdir(slxcArchiveDir);
        zip(slxcArchive,slxcFiles);
    end
end