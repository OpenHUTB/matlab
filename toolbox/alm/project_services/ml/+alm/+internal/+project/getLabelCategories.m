function cats=getLabelCategories(rootFolder)
    proj=alm.internal.project.getProject(rootFolder);

    cats=[];
    if~isempty(proj.Categories)
        cats={proj.Categories.Name};
    end

end
