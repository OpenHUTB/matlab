function[mdlName,blkSID,blkH]=getBlockFromMapElemStr(mapElemStr)

    colonPos=strfind(mapElemStr,':');
    barPos=strfind(mapElemStr,'|');

    blkSID=mapElemStr(barPos(1)+1:end);
    mdlName=mapElemStr(barPos(1)+1:colonPos(1)-1);
    if bdIsLoaded(mdlName)
        blkH=Simulink.ID.getHandle(blkSID);
    else
        blkH=-1;
    end

end
