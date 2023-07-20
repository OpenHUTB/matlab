function AliasObjectList=createAliasTypes(AliasArray)





    AliasObjectList=struct('AliasTypeName',{},'AliasTypeObject',{},...
    'HeaderFilePath',{});
    if isempty(AliasArray)
        return
    end
    for i=1:numel(AliasArray)
        AliasObjectList(i).AliasTypeName=AliasArray(i).Name;
        tempAliasObject=Simulink.AliasType;
        tempAliasObject.BaseType=AliasArray(i).BaseType;
        tempAliasObject.DataScope='Imported';
        tempAliasObject.HeaderFile=AliasArray(i).HeaderFile;
        AliasObjectList(i).AliasTypeObject=tempAliasObject;
        AliasObjectList(i).HeaderFilePath=AliasArray(i).HeaderFilePath;
    end

end
