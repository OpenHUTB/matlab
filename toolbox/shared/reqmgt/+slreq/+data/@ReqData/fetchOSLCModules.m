function modules=fetchOSLCModules(this,projectInfo)





    modules=[];


    currentProjName=oslc.Project.currentProject();
    if strcmp(currentProjName,projectInfo.name)
        sessionConfigUrl=oslc.getSessionConfigUri(projectInfo.name);
    else
        sessionConfigUrl='';
    end


    fromServer=this.repository.fetchModules(projectInfo.uri,sessionConfigUrl);

    if isempty(fromServer)

        return;
    end

    totalModules=numel(fromServer);
    titles=cell(totalModules,1);
    URIs=cell(totalModules,1);
    IDs=cell(totalModules,1);
    descriptions=cell(totalModules,1);
    for i=1:totalModules
        titles{i}=fromServer(i).title;
        URIs{i}=fromServer(i).uri;
        IDs{i}=num2str(fromServer(i).identifier);
        descriptions{i}=fromServer(i).description;
    end


    [sortedTitles,sortIdx]=sort(titles);
    modules=struct();
    modules.title=sortedTitles;
    modules.uri=URIs(sortIdx);
    modules.id=IDs(sortIdx);
    modules.description=descriptions(sortIdx);
end