function createSimulinkProject(projectTemplateFilePath,folder,name)


    sltemplate.internal.validateProjectTemplate(projectTemplateFilePath);

    try
        projectManager=sltemplate.internal.invokeProjectTemplate(...
        projectTemplateFilePath,folder,name);


        sltemplate.ui.StartPage.hide();

        if~matlab.internal.project.util.useWebFrontEnd
            com.mathworks.toolbox.slproject.project.GUI.createfromfile.ShowWelcomeToolAction.show(...
            java.io.File(projectManager.RootFolder));
        end

    catch exception
        sltemplate.internal.handleProjectException(exception);
    end
end
