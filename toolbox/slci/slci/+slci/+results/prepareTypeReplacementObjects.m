

function prepareTypeReplacementObjects(config)

    datamgr=config.getDataManager();

    mdl=config.getModelName();
    replacedTypes=slci.internal.buildDataTypeReplacement(mdl);

    datamgr.beginTransaction;
    try
        reader=datamgr.getTypeReplacementReader();

        for k=1:numel(replacedTypes)
            record=replacedTypes(k);
            replTypeObject=slci.results.TypeReplObject(record.SlType,...
            record.CodeGenType);
            replTypeObject.setReplName(record.ReplTypeName);
            replTypeObject.setBaseType(record.BaseType);
            replTypeObject.setDataScope(record.DataScope);
            reader.insertObject(replTypeObject.getKey(),replTypeObject);
        end

        datamgr.commitTransaction;
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
end
