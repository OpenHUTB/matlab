

function deleteDirectoryContents(directoryName,skipDeletingLog)



    dircontents=dir(directoryName);
    isDirectory=[dircontents.isdir];



    filesOnly=dircontents(~isDirectory);
    filesOnlyNames=arrayfun(@(X)[directoryName,filesep,X.name],filesOnly,'UniformOutput',false);



    if skipDeletingLog
        filesOnlyNames(strcmp(filesOnlyNames,[directoryName,filesep,'variant_reducer.log']))=[];
    end

    cellfun(@delete,filesOnlyNames);



    directoriesOnly=dircontents(isDirectory);
    directoriesOnly((strcmp({dircontents.name},'.')|strcmp({dircontents.name},'..')))=[];
    directoriesOnlyNames=arrayfun(@(X)[directoryName,filesep,X.name],directoriesOnly,'UniformOutput',false);

    cellfun(@(X)rmdir(X,'s'),directoriesOnlyNames);
end

