function modificationInfo=getModificationInfo(moduleId,itemId)




    modulePrefix=rmidoors.getModulePrefix(moduleId);
    doorsId=refIdToDoorsId(itemId,modulePrefix);
    hDoors=rmidoors.comApp();
    modificationInfo=populateModificationInfoFromDOORS(hDoors,moduleId,doorsId);





    modificationInfo.createdOn=erase(modificationInfo.createdOn,'HH:mm:ss ');
    modificationInfo.modifiedOn=erase(modificationInfo.modifiedOn,'HH:mm:ss ');
end

function doorsId=refIdToDoorsId(refId,modulePrefix)
    if refId(1)=='#'
        doorsId=strrep(refId,['#',modulePrefix],'');
    elseif~isempty(modulePrefix)
        doorsId=strrep(refId,modulePrefix,'');
    else
        doorsId=refId;
    end
end

function modificationInfoStruct=populateModificationInfoFromDOORS(hDoors,moduleId,doorsId)
    cmdStr=['dmiObjGetModificationInfo_("',moduleId,'",',doorsId,')'];
    rmidoors.invoke(hDoors,cmdStr);
    doorsResult=hDoors.Result;
    if strncmp(doorsResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',doorsResult));
    else
        modifictionInfoTable=eval(doorsResult);
        modificationInfoStruct.id=doorsId;
        for i=1:size(modifictionInfoTable,1)
            modificationInfoStruct.(modifictionInfoTable{i,1})=modifictionInfoTable{i,2};
        end
    end
end

