function serviceUrl=setProject(this,projName)

    if isempty(this.projCatalog)

        oslc.Project.getProjectNames();
    end

    idx=find(strcmp(this.projCatalog(:,1),projName));
    if isempty(idx)
        error('Slvnv:oslc:ProjectAreaNameInvalid',projName);
    else
        serviceUrl=this.projCatalog{idx,2};
    end
    if~strcmp(this.projectName,projName)
        this.projectName=projName;
        this.updateProjectQueryUrl();
    end
end
