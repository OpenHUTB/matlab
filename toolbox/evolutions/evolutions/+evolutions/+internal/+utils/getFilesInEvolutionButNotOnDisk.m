function[filesNotOnDisk,fileBfis]=getFilesInEvolutionButNotOnDisk(evolutionInfo)




    evolutionBfis=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(evolutionInfo);
    filesNotOnDisk=cell.empty;
    fileBfis=evolutions.model.BaseFileInfo.empty(0,1);
    filesNotOnDiskIdx=1;
    for bfiIdx=1:length(evolutionBfis)
        curBfi=evolutionBfis(bfiIdx);
        curFileFullPath=curBfi.File;
        if~isfile(curFileFullPath)
            filesNotOnDisk{filesNotOnDiskIdx}=curFileFullPath;
            fileBfis(filesNotOnDiskIdx)=curBfi;
            filesNotOnDiskIdx=filesNotOnDiskIdx+1;
        end
    end
end
