


function name=getName(rootFolder)
    proj=alm.internal.project.getProject(rootFolder);

    if~isempty(proj)
        name=proj.Name;
    else
        error(message('alm:project:ProjectNotLoaded',rootFolder));
    end
end
