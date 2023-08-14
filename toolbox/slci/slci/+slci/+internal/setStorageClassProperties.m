
























function prop=setStorageClassProperties(aModelName,scName)
    prop=slci.WSVarInfo;

    prop.Alias='';
    prop.StorageClass=scName;

    switch scName
    case 'Model default'
        prop.StorageClass='SimulinkGlobal';
        prop.DataAccess='Struct';
        prop.DataInit='Auto';
        prop.CSCType='FlatStructure';
    case 'SimulinkGlobal'
        prop.DataAccess='Struct';
        prop.DataInit='Auto';
        prop.CSCType='FlatStructure';
    case 'ExportedGlobal'
        prop.DataAccess='Direct';
        prop.DataInit='Auto';
        prop.CSCType='Unstructured';
    case 'ImportedExtern'
        prop.DataAccess='Direct';
        prop.DataInit='None';
        prop.CSCType='Unstructured';
    case 'ImportedExternPointer'
        prop.DataAccess='Pointer';
        prop.DataInit='None';
        prop.CSCType='Unstructured';
    case{'GetSet','Volatile','ImportFromFile','ExportToFile','FileScope'}
        prop=slci.internal.getCustomStorageClassProperties(aModelName,...
        'Simulink',...
        scName);
    case{'Global','StructConst','StructVolatile'}
        prop=slci.internal.getCustomStorageClassProperties(aModelName,...
        'mpt',...
        scName);

    otherwise


        aPattern='(?<cscname>\w+)\s+[(](?<packagename>\w+)[)]';
        result=regexp(scName,aPattern,'names');
        if~isempty(result)...
            &&~isempty(result.cscname)...
            &&~isempty(result.packagename)
            prop=slci.internal.getCustomStorageClassProperties(aModelName,...
            result.packagename,...
            result.cscname);
        end

    end

end

