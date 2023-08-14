function success=mapSLDataType(modelName,m3iObject,slTypeName,choiceOK,ignoreError)







    import Simulink.metamodel.types.CompuMethodCategory;
    import rtw.connectivity.CodeInfoUtils;

    success=0;
    slTypeName=autosar.utils.StripPrefix(slTypeName);

    mprops=meta.class.fromName(slTypeName);
    isCM=false;
    isImpType=false;
    if isa(m3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)
        isCM=true;
    elseif isa(m3iObject,autosar.ui.metamodel.PackageString.ValueTypeClass)&&~m3iObject.IsApplication
        isImpType=true;
    end
    if~isempty(mprops)
        if coder.internal.isSupportedEnumClass(mprops)
            if isCM
                if m3iObject.Category==CompuMethodCategory.TextTable
                    success=1;
                end
            elseif isImpType
                storageType=autosar.mm.util.getStorageTypeFromImpDataType('enumeration',slTypeName,m3iObject);
                origStorageType=Simulink.data.getEnumTypeInfo(slTypeName,'StorageType');
                if~strcmp(storageType,origStorageType)
                    [literalValues,literalNames]=enumeration(slTypeName);
                    literalValues=double(literalValues);

                    defaultValue=literalNames{1};
                    addClassNameToEnumNames=false;
                    headerFile='Rte_Type.h';
                    enumDesc='';

                    ddFile=get_param(modelName,'DataDictionary');

                    slEnumBuilder=autosar.simulink.enum.createEnumBuilder(ddFile);
                    slEnumBuilder.addEnumeration(...
                    slTypeName,literalNames,literalValues,defaultValue,...
                    storageType,addClassNameToEnumNames,enumDesc,headerFile,'Auto');

                    success=1;
                end
            end
        end
    else
        [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slTypeName);
        if~objExists
            if ignoreError
                return;
            end
            if isCM
                DAStudio.error('autosarstandard:common:invalidMappingDataType',slTypeName,'CompuMethod',m3iObject.Name);
            elseif isImpType
                DAStudio.error('autosarstandard:common:invalidMappingDataType',slTypeName,'ImplementationDataType',m3iObject.Name);
            else
                assert(false,'api is not supported for This AUTOSAR element.')
            end
        end
        success=mapSLDataTypeImpl(modelName,m3iObject,slTypeName,slObj,choiceOK);
    end
end

function success=mapSLDataTypeImpl(modelName,m3iObject,slTypeName,slObj,choiceOK)
    import Simulink.metamodel.types.CompuMethodCategory;
    import rtw.connectivity.CodeInfoUtils;

    success=0;
    compuMethodName=m3iObject.Name;
    isCM=false;
    isImpType=false;
    if isa(m3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)
        isCM=true;
    elseif isa(m3iObject,autosar.ui.metamodel.PackageString.ValueTypeClass)&&~m3iObject.IsApplication
        isImpType=true;
    end

    if isa(slObj,'Simulink.AliasType')
        switch slObj.BaseType
        case{'boolean','uint8','int8','uint16','int16','uint32','int32','single','double'}
            if isImpType
                if isa(m3iObject,autosar.ui.metamodel.PackageString.IntegerClass)
                    if m3iObject.IsSigned
                        baseType='sint';
                    else
                        baseType='uint';
                    end
                    baseType=[baseType,num2str(m3iObject.Length.value)];
                    slObj.BaseType=baseType;
                    mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                    success=1;
                elseif isa(m3iObject,autosar.ui.metamodel.PackageString.FloatingPointClass)
                    if m3iObject.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double
                        baseType='double';
                    else
                        baseType='single';
                    end
                    slObj.BaseType=baseType;
                    mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                    success=1;
                elseif isa(m3iObject,autosar.ui.metamodel.PackageString.BooleanClass)
                    slObj.BaseType='boolean';
                    mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                    success=1;
                end
            else
                success=1;
            end
        otherwise
            dtInfo=SimulinkFixedPoint.DTContainerInfo(slTypeName,get_param(modelName,'Object'));
            if dtInfo.isEnum||autosar.utils.Workspace.objectExistsInModelScope(modelName,slObj.BaseType)
                typeName=autosar.utils.StripPrefix(slObj.BaseType);
                success=autosar.mm.util.mapSLDataType(modelName,m3iObject,typeName,choiceOK);
            elseif~isempty(dtInfo.evaluatedNumericType)
                success=mapSLDataTypeImpl(modelName,m3iObject,slTypeName,dtInfo.evaluatedNumericType,choiceOK);
            end
            return;
        end
    else
        if isCM
            if m3iObject.Category==CompuMethodCategory.Identical
                if strcmp(slObj.DataTypeMode,'Single')||strcmp(slObj.DataTypeMode,'Double')
                    success=1;
                elseif~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))
                    if abs(slObj.Bias-0.0)>eps||abs(slObj.Slope-1.0)>eps
                        warning=DAStudio.message('autosarstandard:ui:scalingForDataTypeAlert',slTypeName,...
                        compuMethodName,'identical',CodeInfoUtils.double2str(slObj.Slope),...
                        '1',CodeInfoUtils.double2str(slObj.Bias),'0');
                        if isempty(choiceOK)
                            choice=questdlg(warning,DAStudio.message('autosarstandard:ui:scalingForDataTypeAlertDlgTitle',slTypeName),...
                            'OK','Cancel','OK');
                            switch choice
                            case 'Cancel'
                                success=2;
                                return;
                            end
                        end
                    end
                    slObj.Bias=0.0;
                    slObj.Slope=1.0;
                    mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                    success=1;
                end
            elseif m3iObject.Category==CompuMethodCategory.Linear||m3iObject.Category==CompuMethodCategory.LinearAndTextTable
                [bias,slope,result]=autosar.mm.util.getScalingFromLinearCompuMethod(m3iObject);
                if strcmp(slObj.DataTypeMode,'Single')||strcmp(slObj.DataTypeMode,'Double')
                    if slope==1
                        success=1;
                    end
                elseif~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))
                    if result
                        if abs(slObj.Bias-bias)>eps||abs(slObj.Slope-slope)>eps
                            warning=DAStudio.message('autosarstandard:ui:scalingForDataTypeAlert',slTypeName,...
                            compuMethodName,'linear',CodeInfoUtils.double2str(slObj.Slope),...
                            CodeInfoUtils.double2str(slope),CodeInfoUtils.double2str(slObj.Bias),...
                            CodeInfoUtils.double2str(bias));
                            if isempty(choiceOK)
                                choice=questdlg(warning,DAStudio.message('autosarstandard:ui:scalingForDataTypeAlertDlgTitle',slTypeName),...
                                'OK','Cancel','OK');
                                switch choice
                                case 'Cancel'
                                    return;
                                end
                            end
                        end
                        slObj.Bias=bias;
                        slObj.Slope=slope;
                        mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                    end
                    success=1;
                end
            elseif m3iObject.Category==CompuMethodCategory.TextTable
                if strcmp(slObj.DataTypeMode,'Boolean')
                    success=1;
                end
            end
        elseif isImpType
            if isa(m3iObject,autosar.ui.metamodel.PackageString.IntegerClass)
                if any(m3iObject.Length.value==[8,16,32])
                    slObj.DataTypeMode='Fixed-point: slope and bias scaling';
                    if m3iObject.IsSigned
                        slObj.Signedness='Signed';
                    else
                        slObj.Signedness='Unsigned';
                    end
                else
                    slObj.DataTypeMode='Fixed-point: binary point scaling';
                end
                slObj.WordLength=m3iObject.Length.value;
                mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                success=1;
            elseif isa(m3iObject,autosar.ui.metamodel.PackageString.FloatingPointClass)
                if m3iObject.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double
                    slObj.DataTypeMode='Double';
                else
                    slObj.DataTypeMode='Single';
                end
                mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                success=1;
            elseif isa(m3iObject,autosar.ui.metamodel.PackageString.BooleanClass)
                slObj.DataTypeMode='Boolean';
                mapSLDataTypeAssignment(modelName,slTypeName,slObj);
                success=1;
            end
        end
    end
end

function mapSLDataTypeAssignment(modelName,slTypeName,slObj)



    if~(existsInGlobalScope(modelName,slTypeName)&&isequal(evalinGlobalScope(modelName,slTypeName),slObj))
        assigninGlobalScope(modelName,slTypeName,slObj);
    end
end



