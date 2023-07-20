function data=getDataObject(identifier)





    projectManager=evolutions.internal.project.ProjectManager.get;

    projects=projectManager.Infos;
    for idx=1:numel(projects)
        project=projects(idx);
        data=searchInProject(project,identifier);
        if~isempty(data)

            break;
        end
    end
end

function data=searchInProject(projectInfo,identifier)


    if isequal(projectInfo.Id,identifier)
        data=projectInfo;
        return;
    end

    evolutionTreeManager=projectInfo.EvolutionTreeManager;

    trees=evolutionTreeManager.Infos;
    for idx=1:numel(trees)
        tree=trees(idx);
        if(tree.Id==identifier)

            data=tree;
            break;
        end


        data=searchInChildManager(tree.EvolutionManager,identifier);
        if~isempty(data)
            break;
        end

        data=searchInChildManager(tree.EdgeManager,identifier);
        if~isempty(data)
            break;
        end
    end
    return;

end

function data=searchInChildManager(manager,identifier)

    deData=manager.Infos;
    for idx=1:numel(deData)
        info=deData(idx);
        if isequal(info.Id,identifier)
            data=info;
            return;
        end
    end

    dm=manager.getDependentManager;
    if~isempty(dm)
        for dmIdx=1:numel(dm)
            depManager=dm(dmIdx);
            data=searchInChildManager(depManager,identifier);
            if~isempty(data)
                return;
            end
        end
    end
    data=evolutions.model.AbstractInfo.empty(1,0);

end
