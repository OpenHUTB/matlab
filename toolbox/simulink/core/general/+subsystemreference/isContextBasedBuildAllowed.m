



function result=isContextBasedBuildAllowed(bd)
    result=bdIsLibrary(bd)||(bdIsSubsystem(bd)&&slfeature('StrongUnitTestForSSRef')>0);
end
