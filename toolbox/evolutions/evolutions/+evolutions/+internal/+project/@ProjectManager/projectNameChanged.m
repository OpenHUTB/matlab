function projectNameChanged(project)





    projectManager=evolutions.internal.project.ProjectManager.get;

    projectInfo=getProjectInfoFromPath(projectManager,project);
    if~isempty(projectInfo)
        setWorkingEvolutionName(projectInfo);
    end
end

function setWorkingEvolutionName(projectInfo)

    trees=projectInfo.EvolutionTreeManager.Infos;

    for idx=1:numel(trees)
        tree=trees(idx);
        workingEvolution=tree.EvolutionManager.WorkingEvolution;
        workingEvolution.setName(convertStringsToChars(workingEvolution.Project.Name));
        tree.save;
        evolutions.internal.session.EventHandler.publish('TreeChanged',...
        evolutions.internal.ui.GenericEventData(tree));
    end

end
