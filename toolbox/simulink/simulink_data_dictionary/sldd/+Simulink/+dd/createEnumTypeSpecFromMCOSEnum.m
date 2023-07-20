function ddEnumTypeSpec=createEnumTypeSpecFromMCOSEnum(enumClassName)






    hEnumClass=Simulink.getMetaClassIfValidEnumDataType(enumClassName);
    if isempty(hEnumClass)
        DAStudio.error('Simulink:DataType:GetEnumTypeInfoArg1');
    end

    ddEnumTypeSpec=Simulink.data.dictionary.EnumTypeDefinition;


    enumeralList=hEnumClass.EnumerationMemberList;
    assert(~isempty(enumeralList));
    [enumerals,~]=enumeration(enumClassName);
    ddEnumTypeSpec.setEnumName(1,enumeralList(1).Name);
    ddEnumTypeSpec.setEnumValue(1,num2str(double(enumerals(1))));
    ddEnumTypeSpec.setEnumDescription(1,enumeralList(1).Description);
    for idx=2:length(enumeralList)
        ddEnumTypeSpec.appendEnumeral(...
        enumeralList(idx).Name,...
        num2str(double(enumerals(idx))),...
        enumeralList(idx).Description);
    end


    storageType=Simulink.data.getEnumTypeInfo(enumClassName,'StorageType');
    ddEnumTypeSpec.Description=Simulink.data.getEnumTypeInfo(enumClassName,'Description');
    ddEnumTypeSpec.DataScope=Simulink.data.getEnumTypeInfo(enumClassName,'DataScope');
    ddEnumTypeSpec.HeaderFile=Simulink.data.getEnumTypeInfo(enumClassName,'HeaderFile');
    ddEnumTypeSpec.DefaultValue=Simulink.data.getEnumTypeInfo(enumClassName,'DefaultValue').char;
    if~strcmp(storageType,'int')
        ddEnumTypeSpec.StorageType=storageType;
    end
    ddEnumTypeSpec.AddClassNameToEnumNames=...
    Simulink.data.getEnumTypeInfo(enumClassName,'AddClassNameToEnumNames');


end
