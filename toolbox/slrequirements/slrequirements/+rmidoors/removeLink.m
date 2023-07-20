function success=removeLink(module,objectNum,destArtifact,destId)



    success=false;
    if~rmidoors.isAppRunning('remove link')
        return;
    end

    objectNum=rmidoors.getNumericStr(objectNum,module);

    cmdStr=['dmiDeleteBacklink_("',strtok(module),'", ',objectNum...
    ,', "',destArtifact,'", "',destId,'")'];

    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if~strncmp(commandResult,'DMI Error:',10)
        rmidoors.refreshModule(module,hDoors);
        success=true;
    end
end


