function openUpstream(location,component,type)





    dep=dependencies.internal.report.createDependency(...
    location,component,type);

    dependencies.internal.action.openUpstream(dep);

end
