function attachMCOSListeners(h,mcosObj)






    mcosObj=mcosObj{1};
    assert(~isempty(h.MCOSListeners));
    assert(isa(mcosObj,'Simulink.DistributedTarget.Mapping'));

    h.MCOSListeners{end+1}=addlistener(...
    mcosObj,'MappingEntityDeleted',@(h,e)DeploymentDiagram.refreshME(h,e));

    h.MCOSListeners{end+1}=addlistener(...
    mcosObj,'MappingEntityAdded',@(h,e)DeploymentDiagram.refreshME(h,e));

    h.MCOSListeners{end+1}=addlistener(...
    mcosObj,'ComponentMapChanged',@(h,e)DeploymentDiagram.refreshME(h,e));
