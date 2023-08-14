function closeModule(modulepath,doSave)



    hDoors=rmidoors.comApp();

    if nargin<2


        hDoors.runStr(['dmiModuleClose("',modulepath,'")']);

    else


        moduleId=strtok(modulepath);
        if doSave
            hDoors.runStr(['dmiModuleCloseByID("',moduleId,'",true)']);
        else
            hDoors.runStr(['dmiModuleCloseByID("',moduleId,'",false)']);
        end
    end
end
