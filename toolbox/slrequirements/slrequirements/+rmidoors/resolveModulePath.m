function moduleIdStr=resolveModulePath(myPath,hDoors)




    if nargin<2
        hDoors=rmidoors.comApp();
    end
    rmidoors.invoke(hDoors,['dmiModuleResolvePath_("',myPath,'")']);
    commandResult=hDoors.Result;

    if strncmp(commandResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    else
        moduleIdStr=commandResult;
    end
end
