classdef InitValueChecker<handle






    methods(Static,Access=public)

        function checkInitValue(hModel,userInitValueStr,portDataType,portName)




            if strcmp(userInitValueStr,...
                autosar.ui.comspec.ComSpecPropertyHandler.getComSpecDefaultPropertyValueStr('InitValue'))


                return;
            end
            portDataType=autosar.utils.StripPrefix(portDataType);
            if strcmpi(portDataType,'boolean')
                portDataType='logical';
            end
            if Simulink.data.isSupportedEnumClass(portDataType)
                autosar.validation.InitValueChecker.checkInitValueEnumType(...
                hModel,userInitValueStr,portDataType,portName);
                return;
            end
            [dtExists,dtObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,portDataType);
            if dtExists&&isa(dtObj,'Simulink.Bus')
                autosar.validation.InitValueChecker.checkInitValueBusType(...
                hModel,userInitValueStr,portDataType,portName);
            else
                autosar.validation.InitValueChecker.checkDataTypeCompatibility(...
                hModel,userInitValueStr,portDataType,portName)

                minValue=evalinGlobalScope(hModel,get_param(portName,'OutMin'));
                maxValue=evalinGlobalScope(hModel,get_param(portName,'OutMax'));
                autosar.validation.InitValueChecker.checkInitValueMinMax(...
                userInitValueStr,minValue,maxValue,portName);
            end
        end

    end

    methods(Static,Access=private)
        function checkInitValueBusType(hModel,userInitValueStr,portDataType,portName)




            [~,bus]=autosar.utils.Workspace.objectExistsInModelScope(hModel,portDataType);
            for ii=1:length(bus.Elements)
                busElement=bus.Elements(ii);
                elementDataType=busElement.DataType;
                autosar.validation.InitValueChecker.checkInitValue(...
                hModel,userInitValueStr,elementDataType,portName);
                elementMin=busElement.Min;
                elementMax=busElement.Max;
                autosar.validation.InitValueChecker.checkInitValueMinMax(...
                userInitValueStr,elementMin,elementMax,portName);
            end
        end

        function checkInitValueEnumType(hModel,userInitValueStr,portDataType,portName)


            assert(Simulink.data.isSupportedEnumClass(portDataType),...
            [portDataType,' is not a supported enum class']);
            userInitValue=str2double(userInitValueStr);
            enumProps=Simulink.getMetaClassIfValidEnumDataType(portDataType);
            enumLiterals={enumProps.EnumerationMemberList.Name};
            valueFoundInEnum=false;
            for ii=1:length(enumLiterals)
                if evalinGlobalScope(hModel,...
                    [portDataType,'.',enumLiterals{ii},'.double'])...
                    ==userInitValue

                    valueFoundInEnum=true;
                    break;
                end
            end
            if~valueFoundInEnum

                defaultValue=Simulink.data.getEnumTypeInfo(portDataType,'DefaultValue');
                defaultValueStr=num2str(defaultValue.double);
                autosar.validation.Validator.logError('autosarstandard:validation:valueNotFoundInEnum',...
                userInitValueStr,portDataType,portName,defaultValueStr);
            end
        end

        function checkInitValueMinMax(userInitValueStr,minValue,maxValue,portName)

            userInitValue=str2double(userInitValueStr);
            if~isempty(minValue)&&userInitValue<minValue
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:initValueLessThanMin',...
                userInitValueStr,num2str(minValue),portName);
            end

            if~isempty(maxValue)&&userInitValue>maxValue
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:initValueGreaterThanMax',...
                userInitValueStr,num2str(maxValue),portName);
            end
        end

        function checkDataTypeCompatibility(hModel,userInitValueStr,portDataType,portName)



            userInitValue=str2double(userInitValueStr);
            margin=eps(userInitValue);
            try
                castedValue=cast(userInitValue,portDataType);
                if strcmp(portDataType,'single')

                    margin=eps(castedValue);
                end
            catch

                if existsInGlobalScope(hModel,portDataType)
                    slObj=evalinGlobalScope(hModel,portDataType);
                    if isa(slObj,'Simulink.NumericType')&&slObj.isfixed()
                        castedValue=fi(userInitValue,slObj);

                        margin=eps(castedValue);
                    else
                        autosar.validation.InitValueChecker.handleDataTypeObject(...
                        hModel,slObj,userInitValueStr,portDataType,portName);
                        return;
                    end
                elseif(fixed.internal.type.isNameOfTraditionalFixedPointType(portDataType,false))

                    tmpFiObj=fixdt(portDataType);
                    castedValue=fi(userInitValue,tmpFiObj);

                    margin=eps(castedValue);
                elseif startsWith(portDataType,'fixdt(')

                    slObj=evalinGlobalScope(hModel,portDataType);
                    if isa(slObj,'Simulink.NumericType')&&slObj.isfixed()
                        castedValue=fi(userInitValue,slObj);

                        margin=eps(castedValue);
                    else
                        autosar.validation.InitValueChecker.handleDataTypeObject(...
                        hModel,slObj,userInitValueStr,portDataType,portName);
                        return;
                    end
                else
                    assert(false,['Datatype ',portDataType,' not recognized']);
                end
            end
            if abs(userInitValue-double(castedValue))>=margin
                suggestedValue=Simulink.metamodel.arplatform.getRealStringCompact((double(castedValue)));
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:valueNotRepresentableInType',...
                userInitValueStr,portDataType,portName,...
                suggestedValue);
            end
        end

        function[margin]=handleDataTypeObject(hModel,slObj,userInitValueStr,portDataType,portName)
            margin=[];
            if isa(slObj,'Simulink.AliasType')
                baseType=evalinGlobalScope(hModel,[portDataType,'.BaseType']);
                autosar.validation.InitValueChecker.checkInitValue(...
                hModel,userInitValueStr,baseType,portName);
                return;
            elseif isa(slObj,'Simulink.NumericType')

                portDataType=slObj.DataTypeMode;
                autosar.validation.InitValueChecker.checkInitValue(...
                hModel,userInitValueStr,portDataType,portName);
                return;
            end
        end
    end
end


