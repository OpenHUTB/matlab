function setObjAttribute(moduleIdStr,objNum,attribute,value)




    objNumStr=rmidoors.getNumericStr(objNum,moduleIdStr);


    value=strrep(value,'\','\\');
    value=strrep(value,'"','\"');

    hDoors=rmidoors.comApp();
    cmdStr=['dmiObjSet_("',moduleIdStr,'",',objNumStr,',"',attribute,'","',value,'")'];
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if~isempty(commandResult)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    end
end
