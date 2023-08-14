
function errorCodes=checkDataTypeCompuMethodCompatibility(modelName,...
    slTypeName,compuMethodM3iObj,validate)









    import Simulink.metamodel.types.CompuMethodCategory;
    import autosar.mm.util.ExternalToolInfoAdapter;

    errorCodes={};
    slTypeName=autosar.utils.StripPrefix(slTypeName);
    mprops=meta.class.fromName(slTypeName);
    if~isempty(mprops)&&coder.internal.isSupportedEnumClass(mprops)
        if compuMethodM3iObj.Category~=CompuMethodCategory.TextTable
            if validate
                errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                errorCodes=[errorCodes,'Enumeration',slTypeName,compuMethodM3iObj.Name,...
                autosar.mm.util.compuMethodCategoryToString(compuMethodM3iObj.Category)];
            else
                errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,...
                autosar.mm.util.compuMethodCategoryToString(compuMethodM3iObj.Category),'TextTable'];
            end
        else
            if~validate
                if~isEnumCompatibleToCompuMethod(slTypeName,compuMethodM3iObj)
                    errorCodes=[errorCodes,'autosarstandard:common:compuMethodCategoryChangeNotAllowed'];
                    errorCodes=[errorCodes,'CompuMethod',compuMethodM3iObj.Name,'Simulink DataTypes',slTypeName];
                end
            end
        end
    else
        [slObjExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slTypeName);
        if~slObjExists
            return;
        end
        if isa(slObj,'Simulink.NumericType')
            if~slObj.IsAlias
                errorCodes=[errorCodes,'RTW:autosar:dataTypeObjectIsAliasFalse'];
                errorCodes=[errorCodes,slTypeName];
                return;
            end
        end
        errorCodes=checkDataTypeCompuMethodCompatibilityImpl(modelName,slTypeName,slObj,compuMethodM3iObj,validate);
    end
end

function errorCodes=checkDataTypeCompuMethodCompatibilityImpl(modelName,...
    slTypeName,slObj,compuMethodM3iObj,validate)
    import Simulink.metamodel.types.CompuMethodCategory;
    import autosar.mm.util.ExternalToolInfoAdapter;

    errorCodes={};

    if isa(slObj,'Simulink.ValueType')
        [slObjExists,slValueTypeObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slObj.DataType);
        if slObjExists
            errorCodes=checkDataTypeCompuMethodCompatibilityImpl(modelName,slTypeName,slValueTypeObj,compuMethodM3iObj,validate);
            return;
        end
        baseType=slObj.DataType;
    elseif isa(slObj,'Simulink.AliasType')
        baseType=slObj.BaseType;
    end

    if isa(slObj,'Simulink.AliasType')||isa(slObj,'Simulink.ValueType')
        switch baseType
        case{'boolean','uint8','int8','uint16','int16','uint32','int32','single','double'}
            if compuMethodM3iObj.Category==CompuMethodCategory.Linear
                [bias,slope]=autosar.mm.util.getScalingFromLinearCompuMethod(compuMethodM3iObj);
                if any(strcmp(baseType,{'single','double'}))

                    if slope~=1
                        if validate
                            errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleNonIdenticalScaling'];
                            errorCodes=[errorCodes,'Simulink.AliasType',slTypeName,compuMethodM3iObj.Name,'Linear','CompuMethod'];
                        else
                            errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                            errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Linear','Identical'];
                        end
                    end
                elseif any(strcmp(baseType,{'uint8','int8','uint16','int16','uint32','int32'}))
                    if bias~=0&&slope~=1
                        if validate
                            errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleNonIdenticalScaling'];
                            errorCodes=[errorCodes,'Simulink.AliasType',slTypeName,compuMethodM3iObj.Name,'Linear','CompuMethod'];
                        else
                            errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                            errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Linear','Identical'];
                        end
                    end
                else
                    if bias~=0||slope~=1
                        if validate
                            errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                            errorCodes=[errorCodes,'Simulink.AliasType',slTypeName,compuMethodM3iObj.Name,'Linear'];
                        else
                            errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                            errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Linear','TextTable'];
                        end
                    end
                end
            elseif compuMethodM3iObj.Category==CompuMethodCategory.TextTable
                if validate
                    if~strcmp(baseType,'boolean')
                        errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                        errorCodes=[errorCodes,'Simulink.AliasType',slTypeName,compuMethodM3iObj.Name,'TextTable'];
                    end
                else
                    if~strcmp(baseType,'boolean')
                        errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                        errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'TextTable','Identical'];
                    end
                end
            elseif compuMethodM3iObj.Category==CompuMethodCategory.RatFunc
                if validate
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,'Simulink.AliasType',slTypeName,compuMethodM3iObj.Name,autosar.mm.util.compuMethodCategoryToString(compuMethodM3iObj.Category)];
                else
                    if strcmp(baseType,'boolean')
                        errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                        errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'RatFunc','TextTable'];
                    else
                        errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                        errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'RatFunc','Identical'];
                    end
                end
            end
        otherwise
            dtInfo=SimulinkFixedPoint.DTContainerInfo(slTypeName,get_param(modelName,'Object'));
            if dtInfo.isEnum
                typeName=autosar.utils.StripPrefix(baseType);
                errorCodes=autosar.mm.util.checkDataTypeCompuMethodCompatibility(...
                modelName,typeName,compuMethodM3iObj,validate);
            elseif autosar.utils.Workspace.objectExistsInModelScope(modelName,baseType)||...
                ~isempty(dtInfo.evaluatedNumericType)
                errorCodes=checkDataTypeCompuMethodCompatibilityImpl(...
                modelName,slTypeName,dtInfo.evaluatedNumericType,compuMethodM3iObj,validate);
            end
            return;
        end
    elseif isa(slObj,'Simulink.NumericType')
        if compuMethodM3iObj.Category==CompuMethodCategory.Identical
            if strcmp(slObj.DataTypeMode,'Boolean')


                if validate
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,'Boolean',slTypeName,compuMethodM3iObj.Name,'Identical'];
                else

                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Identical','TextTable'];
                end
            elseif~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))&&validate
                if abs(slObj.Bias-0.0)>eps||abs(slObj.Slope-1.0)>eps


                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleNonIdenticalScaling'];
                    errorCodes=[errorCodes,'Fixed-point',slTypeName,compuMethodM3iObj.Name,'Identical','data type'];
                end
            end
        elseif compuMethodM3iObj.Category==CompuMethodCategory.Linear
            [bias,slope]=autosar.mm.util.getScalingFromLinearCompuMethod(compuMethodM3iObj);
            if strcmp(slObj.DataTypeMode,'Single')||strcmp(slObj.DataTypeMode,'Double')
                if slope~=1
                    if validate
                        errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleNonIdenticalScaling'];
                        errorCodes=[errorCodes,slObj.DataTypeMode,slTypeName,compuMethodM3iObj.Name,'Linear','CompuMethod'];
                    else
                        errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                        errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Linear','Identical'];
                    end
                end
            elseif~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))
                [externalRef,val]=autosar.mm.arxml.Exporter.isExternalReference(compuMethodM3iObj);
                if externalRef&&val==1&&validate


                    if abs(slObj.Bias-bias)>eps
                        errorCodes=[errorCodes,'autosarstandard:common:validateUnmatchedScaling'];
                        errorCodes=[errorCodes,'Fixed-point',slTypeName,compuMethodM3iObj.Name,'Linear',...
                        'bias',num2str(slObj.Bias),'bias',num2str(bias)];
                    elseif abs(slObj.Slope-slope)>eps
                        errorCodes=[errorCodes,'autosarstandard:common:validateUnmatchedScaling'];
                        errorCodes=[errorCodes,'Fixed-point',slTypeName,compuMethodM3iObj.Name,'Linear',...
                        'slope',num2str(slObj.Slope),'slope',num2str(slope)];
                    end
                end
            else

                if validate
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,'Boolean',slTypeName,compuMethodM3iObj.Name,'Linear'];
                else

                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'Linear','TextTable'];
                end
            end
        elseif compuMethodM3iObj.Category==CompuMethodCategory.TextTable
            if validate
                if strcmp(slObj.DataTypeMode,'Single')||strcmp(slObj.DataTypeMode,'Double')
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slObj.DataTypeMode,slTypeName,compuMethodM3iObj.Name,'TextTable'];
                elseif~strcmp(slObj.DataTypeMode,'Boolean')
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,'Fixed-point',slTypeName,compuMethodM3iObj.Name,'TextTable'];
                end
            else
                if~strcmp(slObj.DataTypeMode,'Boolean')
                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'TextTable','Identical/Linear'];
                end
            end
        elseif compuMethodM3iObj.Category==CompuMethodCategory.RatFunc
            if validate
                if~isempty(strfind(slObj.DataTypeMode,'Fixed-point:'))
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,'Fixed-point',slTypeName,compuMethodM3iObj.Name,autosar.mm.util.compuMethodCategoryToString(compuMethodM3iObj.Category)];
                else
                    errorCodes=[errorCodes,'autosarstandard:common:validateIncompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slObj.DataTypeMode,slTypeName,compuMethodM3iObj.Name,autosar.mm.util.compuMethodCategoryToString(compuMethodM3iObj.Category)];
                end
            else
                if strcmp(slObj.DataTypeMode,'Boolean')
                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodCategory'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'RatFunc','TextTable'];
                elseif strcmp(slObj.DataTypeMode,'Single')||strcmp(slObj.DataTypeMode,'Double')
                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'RatFunc','Identical'];
                else
                    errorCodes=[errorCodes,'autosarstandard:common:incompatibleCompuMethodScaling'];
                    errorCodes=[errorCodes,slTypeName,compuMethodM3iObj.Name,'RatFunc','Linear'];
                end
            end
        end
    else
        errorCodes=[errorCodes,'autosarstandard:common:mapOnlySupportedType'];
        errorCodes=[errorCodes,'Simulink.NumericType|Simulink enumeration|Simulink.AliasType','CompuMethod'];
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


function compatible=isEnumCompatibleToCompuMethod(slTypeName,compuMethodM3iObj)
    compatible=true;
    [literalNames,literalValues,result]=autosar.mm.util.getLiteralsFromTextTableCompuMethods(compuMethodM3iObj);
    if result
        [enumVals,enumNames]=enumeration(slTypeName);
        if numel(literalNames)~=numel(enumNames)
            compatible=false;
        else


            if Simulink.data.getEnumTypeInfo(slTypeName,'AddClassNameToEnumNames')
                enumNamesWithClassName=cellfun(@(x)[slTypeName,'_',x],enumNames,'UniformOutput',false);
            else
                enumNamesWithClassName=[];
            end
            for ii=1:numel(literalNames)
                index=strcmp(literalNames{ii},enumNames);
                if~any(index)
                    if~isempty(enumNamesWithClassName)
                        index=strcmp(literalNames{ii},enumNamesWithClassName);
                        if~any(index)
                            compatible=false;
                            return;
                        end
                    else
                        compatible=false;
                        return;
                    end
                elseif enumVals(ii)~=literalValues(index)
                    compatible=false;
                    return;
                end
            end
        end
    end
end


