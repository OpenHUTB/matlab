function setModuleAttribute(moduleIdStr,attribute,value)




    hDoors=rmidoors.comApp();
    cmdStr=['dmiModuleSet_("',moduleIdStr,'","',attribute,'","',value,'")'];
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if~isempty(commandResult)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    end
end
