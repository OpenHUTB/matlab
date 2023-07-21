function replacedTypes=getDataTypeReplacement(Config)

    datamgr=Config.getDataManager();
    reader=datamgr.getReader('TYPEREPLACEMENT');
    typeReplObjects=reader.getObjects(reader.getKeys);

    replacedTypes=struct('SlType',{},...
    'CodeGenType',{},...
    'ReplTypeName',{},...
    'BaseType',{},...
    'DataScope',{}...
    );

    for k=1:numel(typeReplObjects)
        typeReplObj=typeReplObjects{k};
        replacedTypes(k).SlType=typeReplObj.getSlType();
        replacedTypes(k).CodeGenType=typeReplObj.getCodeGenType();
        replacedTypes(k).ReplTypeName=typeReplObj.getReplName();
        replacedTypes(k).BaseType=typeReplObj.getBaseType();
        replacedTypes(k).DataScope=typeReplObj.getDataScope();
    end
end
