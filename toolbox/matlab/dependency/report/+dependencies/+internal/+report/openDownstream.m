function openDownstream(location,component,type)





    dep=dependencies.internal.report.createDependency(...
    location,component,type);

    dependencies.internal.action.openDownstream(dep);

end
