function catalog=getCatalogFromOslcServer(this,loginInfo)

    catalog.projectNames={};
    catalog.projectURIs={};
    catalog.serviceURIs={};

    mfProjectInfos=this.fetchOSLCProjects(loginInfo);
    for ii=1:length(mfProjectInfos)
        mfProjectInfo=mfProjectInfos(ii);
        catalog.projectNames{end+1}=mfProjectInfo.projectName;
        catalog.projectURIs{end+1}=mfProjectInfo.projectUri;
        catalog.serviceURIs{end+1}=mfProjectInfo.serviceUri;
    end

end
