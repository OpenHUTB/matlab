function projectFileList=getProjectFiles(project)




    projectFiles=project.Files;
    projectFileList=cell.empty;
    for fileIdx=1:numel(projectFiles)
        file=projectFiles(fileIdx).Path;
        file=convertStringsToChars(file);
        projectFileList{end+1}=file;%#ok<AGROW>
    end
end
