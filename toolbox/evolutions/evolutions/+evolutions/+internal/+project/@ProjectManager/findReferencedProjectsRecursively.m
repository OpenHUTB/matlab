function findReferencedProjectsRecursively(obj,project)




    projectRefs=project.ProjectReferences;
    for prjRefIdx=1:numel(projectRefs)


        curProjectRef=projectRefs(prjRefIdx);
        curEnabledRef=curProjectRef;
        curPrj=curEnabledRef.Project;
        obj.create(curPrj);
        findReferencedProjectsRecursively(obj,curPrj);
    end
end
