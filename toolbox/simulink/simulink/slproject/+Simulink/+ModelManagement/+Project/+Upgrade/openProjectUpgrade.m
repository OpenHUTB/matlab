function openProjectUpgrade(projectRoot)




    if nargin<1
        modelHandle=SLM3I.SLDomain.getLastActiveStudioApp.blockDiagramHandle;
        modelName=getfullname(modelHandle);
        modelPath=get_param(modelName,'Filename');
        projectMapper=matlab.internal.project.util.FileToProjectMapper(modelPath);
        projectRoot=projectMapper.ProjectRoot;
    end

    import com.mathworks.toolbox.slproject.project.GUI.upgrade.UpgradeGUILauncher;
    UpgradeGUILauncher.openProjectAndUpgrade(projectRoot);

end

