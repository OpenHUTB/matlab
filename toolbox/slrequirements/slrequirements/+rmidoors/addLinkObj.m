function addLinkObj(moduleIdStr,objNum,iconPath,label,navcmd)






    if~ischar(objNum)
        objNum=num2str(objNum);
    end

    if isempty(iconPath)


        navUrl=rmiut.cmdToUrl(navcmd,true);
        if isempty(navUrl)
            return;
        end



        if rmipref('DoorsBacklinkIncoming')
            linkCommand='dmiAddMatlabLinkIncoming_';
        else
            linkCommand='dmiAddMatlabLink_';
        end
        cmdStr=[linkCommand,'("',moduleIdStr,'",',objNum,','...
        ,'"',escape_str(label),'","',escape_str(navUrl),'")'];
    else

        cmdStr=['dmiAddLinkObj_("',moduleIdStr,'",',objNum,','...
        ,'"',escape_str(iconPath),'",'...
        ,'"',escape_str(label),'",'...
        ,'"',escape_str(navcmd),'")'];
    end

    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if strncmp(commandResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    end
end

function str=escape_str(str)
    str=strrep(str,'\','\\');
    str=strrep(str,'"','\"');
end

