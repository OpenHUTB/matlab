function out=currentProject(hDOORS)

    rmidoors.invoke(hDOORS,'dmiUtilCurrentProject_()');
    out=hDOORS.Result;
end
