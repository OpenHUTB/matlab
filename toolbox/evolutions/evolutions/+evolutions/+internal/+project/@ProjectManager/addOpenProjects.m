function addOpenProjects(obj)




    p=obj.TopLevelProject;

    obj.create(p);

    obj.findReferencedProjectsRecursively(p);

    obj.setProjectObserver;
end

