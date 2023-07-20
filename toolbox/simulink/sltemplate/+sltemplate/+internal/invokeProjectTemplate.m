function projectManager=invokeProjectTemplate(pathToTemplate,projectFolder,projectName)




    sltemplate.internal.validateProjectTemplate(pathToTemplate);

    try
        projectRoot=matlab.internal.project.creation.fromTemplate(...
        pathToTemplate,projectName,projectFolder);
        projectManager=simulinkproject(projectRoot);
    catch e
        sltemplate.internal.handleProjectException(e);
    end

end
