function removeAndDeleteFile(project,filePath)




    if isfile(filePath)
        relativePath=strrep(filePath,sprintf("%s%s",project.RootFolder,filesep),"");
        if~isempty(project.findFile(relativePath))
            project.removeFile(relativePath);
        end
        delete(filePath);
    end
end
