function open=askToOpenProjectUpgrade(modelPath,projectRoot,projectToClose)




    [~,modelName,modelExt]=slfileparts(modelPath);
    try
        jRootFolder=java.io.File(projectRoot);
        project=com.mathworks.toolbox.slproject.project.managers.ProjectManagerBase.loadProject(jRootFolder);
        projectName=char(project.getName());
    catch
        projectName=DAStudio.message('SimulinkUpgradeAdvisor:advisor:noTitle','<','>');
    end
    prompt=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmOpenProjectUpgradeDialogQuestion',[modelName,modelExt],projectName);
    if~isempty(projectToClose)
        prompt=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmChangeProjectUpgradeDialogQuestion',prompt,projectToClose);
    end

    title=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmOpenProjectUpgradeDialogTitle');
    accept=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmOpenProjectUpgradeDialogAccept');
    decline=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmOpenProjectUpgradeDialogDecline');
    cancel=DAStudio.message('SimulinkUpgradeAdvisor:advisor:ConfirmOpenProjectUpgradeDialogCancel');

    answer=questdlg(...
    prompt,title,...
    accept,decline,cancel,...
accept...
    );

    open=true;
    if strcmp(answer,accept)

        Simulink.ModelManagement.Project.Upgrade.openProjectUpgrade(projectRoot);
    elseif strcmp(answer,decline)
        open=false;
    end

end

