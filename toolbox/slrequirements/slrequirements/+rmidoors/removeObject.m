function success=removeObject(module,object)










    success=false;

    object=rmidoors.getNumericStr(object,module);

    cmdStr=['dmiDeleteObject_("',strtok(module),'", ',object,')'];

    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if~strncmp(commandResult,'object has descendants',22)&&~strncmp(commandResult,'DMI Error:',10)
        rmidoors.refreshModule(module,hDoors);
        success=true;
    end
end

