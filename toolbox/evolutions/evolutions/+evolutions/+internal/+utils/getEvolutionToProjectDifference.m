function[filesNotInProject,filesNotInEvolution]=getEvolutionToProjectDifference(evolutionInfo)




    evolutionBfis=evolutions.internal.utils...
    .getBaseToArtifactsKeyValues(evolutionInfo);
    project=evolutionInfo.Project;


    files={evolutionBfis.File};


    projectFiles=evolutions.internal.utils.getProjectFiles(project);

    treeDataFiles=cellfun(@(x)fileIsPartOfEvolutionData(x,evolutionInfo),projectFiles);
    projectFiles(treeDataFiles)=[];


    filesNotInProject=setdiff(files,projectFiles);
    findNonExistentFile=cellfun(@(x)~isfile(x),filesNotInProject);
    filesNotInProject(findNonExistentFile)=[];


    filesNotInEvolution=setdiff(projectFiles,files);
    findNonExistentFile=cellfun(@(x)isfolder(x),filesNotInEvolution);
    filesNotInEvolution(findNonExistentFile)=[];
end

function tf=fileIsPartOfEvolutionData(file,info)

    relativePath=evolutions.internal.utils.getRelativePathFromProject(info,file);
    fileDirectories=strsplit(relativePath,filesep);

    tf=isequal(fileDirectories{1},'EvolutionTrees');
end

