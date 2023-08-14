function updateProjectQueryUrl(this)



    this.projectQuery='';
    idx=find(strcmp(this.projCatalog(:,1),this.projectName));
    if~isempty(idx)
        serviceUrl=this.projCatalog{idx,2};
        projectRDF=this.get(serviceUrl);
        this.projectQuery=oslc.Project.getQueryBase(projectRDF);
    end
end
