function createProjectFromTestFile(tfObj)



    id=tfObj.id;

    filePath=stm.internal.getTestProperty(id,'testsuite').location;
    matlab.internal.project.creation.fromFile(filePath);
end
