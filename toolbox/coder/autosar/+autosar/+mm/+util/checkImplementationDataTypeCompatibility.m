function errorCodes=checkImplementationDataTypeCompatibility(modelName,...
    slTypeName,implDataTypeM3iObj)








    implTypeQPath=autosar.api.Utils.getQualifiedName(implDataTypeM3iObj);
    swBaseTypeQPath=autosar.api.Utils.getQualifiedName(implDataTypeM3iObj.SwBaseType);

    errorCodes={};
    slTypeName=autosar.utils.StripPrefix(slTypeName);
    mprops=meta.class.fromName(slTypeName);
    if~isempty(mprops)&&coder.internal.isSupportedEnumClass(mprops)
        if isa(implDataTypeM3iObj,'Simulink.metamodel.types.Integer')
            if implDataTypeM3iObj.Length.value==32&&~implDataTypeM3iObj.IsSigned
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataType'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath];
            elseif~(implDataTypeM3iObj.Length.value==8||...
                implDataTypeM3iObj.Length.value==16||...
                implDataTypeM3iObj.Length.value==32)
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataType'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath];
            end
        elseif~isa(implDataTypeM3iObj,'Simulink.metamodel.types.Enumeration')
            errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataType'];
            errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath];
        end
    else
        [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slTypeName);
        if~objExists
            return
        end
        if isa(slObj,'Simulink.AliasType')
            switch slObj.BaseType
            case 'boolean'
                errorCodes=verifyBooleanDataType(implDataTypeM3iObj,slTypeName,...
                implTypeQPath,swBaseTypeQPath);
            case{'uint8','uint16','uint32','int8','int16','int32'}
                errorCodes=verifyIntegerDataType(implDataTypeM3iObj,slTypeName,...
                slObj.BaseType,implTypeQPath,swBaseTypeQPath);
            case{'single','double'}
                errorCodes=verifyFloatingPointDataType(implDataTypeM3iObj,...
                slTypeName,slObj.BaseType,implTypeQPath,swBaseTypeQPath);
            otherwise
                errorCodes=autosar.mm.util.checkDataTypeCompuMethodCompatibility(...
                modelName,slObj.BaseType,implDataTypeM3iObj);
                return;
            end
        elseif isa(slObj,'Simulink.NumericType')
            if~slObj.IsAlias
                errorCodes=[errorCodes,'RTW:autosar:dataTypeObjectIsAliasFalse'];
                errorCodes=[errorCodes,slTypeName];
                return;
            end
            if strcmp(slObj.DataTypeMode,'Boolean')
                errorCodes=verifyBooleanDataType(implDataTypeM3iObj,slTypeName,...
                implTypeQPath,swBaseTypeQPath);
            elseif~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))
                if strcmp(slObj.Signedness,'Signed')
                    baseTypeName='int';
                else
                    baseTypeName='uint';
                end
                baseTypeName=[baseTypeName,num2str(slObj.WordLength)];
                errorCodes=verifyIntegerDataType(implDataTypeM3iObj,slTypeName,...
                baseTypeName,implTypeQPath,swBaseTypeQPath);
            else
                if strcmp(slObj.DataTypeMode,'Single')
                    baseTypeName='single';
                else
                    baseTypeName='double';
                end
                errorCodes=verifyFloatingPointDataType(implDataTypeM3iObj,slTypeName,...
                baseTypeName,implTypeQPath,swBaseTypeQPath);
            end
        else
            errorCodes=[errorCodes,'autosarstandard:common:mapOnlySupportedType'];
            errorCodes=[errorCodes,'Simulink.NumericType|Simulink enumeration|Simulink.AliasType','ImplementationDataType'];
        end
    end
end

function errorCodes=verifyFloatingPointDataType(implDataTypeM3iObj,slTypeName,...
    baseTypeName,implTypeQPath,swBaseTypeQPath)
    errorCodes={};
    if~isa(implDataTypeM3iObj,'Simulink.metamodel.types.FloatingPoint')
        errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
        errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','IEEE754'];
    else
        if strcmp(baseTypeName,'single')
            if implDataTypeM3iObj.Kind~=Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-SIZE','32'];
            end
        else
            if implDataTypeM3iObj.Kind~=Simulink.metamodel.types.FloatingPointKind.IEEE_Double
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-SIZE','64'];
            end
        end
    end
end

function errorCodes=verifyBooleanDataType(implDataTypeM3iObj,slTypeName,...
    implTypeQPath,swBaseTypeQPath)
    errorCodes={};
    if~isa(implDataTypeM3iObj,'Simulink.metamodel.types.Boolean')
        errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
        errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','BOOLEAN'];
    end
end

function errorCodes=verifyIntegerDataType(implDataTypeM3iObj,slTypeName,...
    baseTypeName,implTypeQPath,swBaseTypeQPath)
    errorCodes={};
    if~(isa(implDataTypeM3iObj,'Simulink.metamodel.types.Integer')...
        ||isa(implDataTypeM3iObj,'Simulink.metamodel.types.FixedPoint'))
        errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
        if baseTypeName(1)=='u'
            errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','NONE'];
        else
            errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','2C'];
        end
    else
        if baseTypeName(1)=='u'
            dataSize=sscanf(baseTypeName,'uint%d');
            if implDataTypeM3iObj.IsSigned
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','NONE'];
            end
        else
            dataSize=sscanf(baseTypeName,'int%d');
            if~implDataTypeM3iObj.IsSigned
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
                errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-ENCODING','2C'];
            end
        end
        if dataSize~=implDataTypeM3iObj.Length.value
            errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleImplDataTypeEncoding'];
            errorCodes=[errorCodes,slTypeName,implTypeQPath,swBaseTypeQPath,'BASE-TYPE-SIZE',num2str(dataSize)];
        end
    end
end

function baseEnumName=getBaseEnumeration(modelName,enumName)
    baseEnumName=[];
    enumName=autosar.utils.StripPrefix(enumName);
    mprops=meta.class.fromName(enumName);
    if~isempty(mprops)&&coder.internal.isSupportedEnumClass(mprops)
        baseEnumName=enumName;
    else
        [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,enumName);
        if objExists&&isa(slObj,'Simulink.AliasType')
            baseEnumName=getBaseEnumeration(modelName,slObj.BaseType);
        end
    end
end


