function removeAndDeleteDir(project,directory)




    if isfolder(directory)
        relativePath=strrep(directory,sprintf("%s%s",project.RootFolder,filesep),"");
        if~isempty(project.findFile(relativePath))
            project.removeFile(relativePath);
        end
        rmdir(directory,'s');
    end
end
