function refreshModule(module,hDoors)






    if nargin<2
        hDoors=rmidoors.comApp();
    end
    cmdStr=['dmiRefreshModule_("',strtok(module),'")'];
    rmidoors.invoke(hDoors,cmdStr);
end

