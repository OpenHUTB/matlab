function projects=getRecentProjects()



    setting=settings().slhistory.MostRecentlyUsedSimulinkProjects;
    projectsAsCell=setting.ActiveValue;
    projects=string(projectsAsCell(:));

    existIndices=arrayfun(@(x)logical(exist(x,'file')),projects);
    projects=projects(logical(existIndices));
end

