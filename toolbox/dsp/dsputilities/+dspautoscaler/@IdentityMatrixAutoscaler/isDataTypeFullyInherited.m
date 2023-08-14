function result=isDataTypeFullyInherited(h,blkObj,pathItem)%#ok




    if strcmp(blkObj.Inherit,'on')
        result=true;
    else
        result=strncmp(blkObj.dataType,'Inherit',7);
    end
