function val=isTaskConfigurationInUse(this)
    bdObj=get_param(this.ParentDiagram,'Object');
    explr=DeploymentDiagram.getexplorer('name',bdObj.Name);
    val=bdObj.isHierarchySimulating||...
    (~isempty(explr)&&explr.isFrozen);

