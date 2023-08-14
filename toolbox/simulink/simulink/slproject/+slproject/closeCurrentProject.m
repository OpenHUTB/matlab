function closeCurrentProject()






    try
        proj=slproject.getCurrentProject();
        proj.close();
    catch exception


        if~strcmp(exception.identifier,'MATLAB:project:api:NoProjectCurrentlyLoaded')...
            &&~strcmp(exception.identifier,'MATLAB:project:api:ProjectRootFolderNotFound')
            exception.rethrow
        end
    end

end


