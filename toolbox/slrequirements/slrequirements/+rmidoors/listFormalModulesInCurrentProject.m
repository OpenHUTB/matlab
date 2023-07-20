function out=listFormalModulesInCurrentProject()
    out=[];
    if rmidoors.isAppRunning()
        hDOORS=rmidoors.comApp();
        rmidoors.invoke(hDOORS,'dmiListFormalModulesInCurrentProject_()');
        out=eval(hDOORS.Result);
    end
end
