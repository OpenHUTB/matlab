function saveModule(moduleIdStr)




    hDoors=rmidoors.comApp();
    cmdStr=['save(module(itemFromID("',moduleIdStr,'")))'];
    rmidoors.invoke(hDoors,cmdStr);

end

