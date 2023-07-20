function success=removeLinks(src_module,src_object,dest_module,dest_object)



    success=false;
    if~rmidoors.isAppRunning('remove link')
        return;
    end

    src_object=rmidoors.getNumericStr(src_object,src_module);

    if nargin>2

        dest_object=rmidoors.getNumericStr(dest_object,dest_module);
        cmdStr=['dmiDeleteLink_("',strtok(src_module),'", ',src_object...
        ,', "',strtok(dest_module),'", ',dest_object,')'];
    else

        cmdStr=['dmiDeleteLinks_("',strtok(src_module),'", ',src_object,')'];
    end

    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if~strncmp(commandResult,'DMI Error:',10)
        if nargin>2



            rmidoors.refreshModule(src_module,hDoors);
            rmidoors.refreshModule(dest_module,hDoors);
        end
        success=true;
    end
end


