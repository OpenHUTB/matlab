function[models,projects,pinnedItems,pinningIsEnabled]=loadSimulinkHistory




    models=slhistory.getMRUList();

    projects=i_loadMRUSimulinkProjects();

    pinnedItems=slhistory.getMRUList(slhistoryListType.Favorites);

    pinningIsEnabled=...
    numel(pinnedItems)<slhistory.getListMaxSize(slhistoryListType.Favorites);

end

function projects=i_loadMRUSimulinkProjects()
    projects=slhistory.getMRUList(slhistoryListType.Projects);

    if isempty(projects)
        i_migrateProjectsToSimulinkHistory();

        projects=slhistory.getMRUList(slhistoryListType.Projects);
    end

end

function flag=i_projectIsInFavoritesList(prjFile)
    flag=any(contains(...
    slhistory.getMRUList(slhistoryListType.Favorites),prjFile));
end

function i_migrateProjectsToSimulinkHistory()




    projects=com.mathworks.toolbox.slproject.project.RecentProjectList.getRecentProjects();

    iterator=projects.iterator;

    while(iterator.hasNext())
        file=iterator.next;
        prjFile=i_getPrjFile(file);

        if~isempty(prjFile)


            if~i_projectIsInFavoritesList(prjFile)
                slhistory.add(prjFile,slhistoryListType.Projects);
            end
        end
    end
end


function prjFile=i_getPrjFile(jProjectFolder)

    prjFile=[];

    if~jProjectFolder.exists()
        return;
    end

    jPrjLauncherFile=...
    com.mathworks.toolbox.slproject.project.ProjectLauncherFile.getExistingLauncherFile(jProjectFolder);

    if~isempty(jPrjLauncherFile)
        prjFile=char(jPrjLauncherFile.getPath());
    end

end
