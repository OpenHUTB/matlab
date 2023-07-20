function result=getEnumTypeInfo(typeName,propName)





















    typeName=convertStringsToChars(typeName);

    propName=convertStringsToChars(propName);


    hClass=Simulink.getMetaClassIfValidEnumDataType(typeName);
    if isempty(hClass)
        DAStudio.error('Simulink:DataType:GetEnumTypeInfoArg1');
    end


    validPropsStr='AddClassNameToEnumNames, DataScope, DefaultValue, Description, HeaderFile, StorageType';

    if~ischar(propName)
        DAStudio.error('Simulink:DataType:GetEnumTypeInfoArg2',validPropsStr);
    end

    switch propName
    case 'AddClassNameToEnumNames'
        result=false;
    case 'DataScope'
        result='Auto';
    case 'DefaultValue'
        enums=enumeration(typeName);
        result=enums(1);
    case{'Description','HeaderFile'}
        result='';
    case 'StorageType'
        result=hClass.SuperclassList.Name;
        if strcmp(result,'Simulink.IntEnumType')
            result='int';
        end

        return
    otherwise
        DAStudio.error('Simulink:DataType:GetEnumTypeInfoArg2',validPropsStr);
    end


    methodName=['get',propName];
    if strcmp(propName,'AddClassNameToEnumNames')
        methodName='addClassNameToEnumNames';
    end

    hMethod=findobj(hClass.MethodList,'Name',methodName,'Static',true);
    if~isempty(hMethod)
        result=feval([typeName,'.',methodName]);
    end
end


