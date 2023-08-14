classdef SlAppTypeAttributesGetter<handle







    methods(Static,Access=public)


        function slAppObj=fromDataObj(dataObj)
            slAppObj=autosar.mm.util.SlAppTypeAttributes();
            if isa(dataObj,'Simulink.DataObject')||isa(dataObj,'Simulink.ValueType')
                slMin=dataObj.Min;
                slMax=dataObj.Max;
                slUnit=dataObj.Unit;
                slAppObj=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
            elseif isa(dataObj,'Simulink.Breakpoint')
                slMin=dataObj.Breakpoints.Min;
                slMax=dataObj.Breakpoints.Max;
                slUnit=dataObj.Breakpoints.Unit;
                slAppObj=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
            elseif isa(dataObj,'Simulink.LookupTable')
                slMin=dataObj.Table.Min;
                slMax=dataObj.Table.Max;
                slUnit=dataObj.Table.Unit;
                slAppObj=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
            end
        end



        function slAppObj=fromBlock(blockPath)

            slMin=get_param(blockPath,'OutMin');
            slMax=get_param(blockPath,'OutMax');


            isArgBlock=any(strcmp(get_param(blockPath,'BlockType'),...
            {'ArgIn','ArgOut'}));
            slUnit='';
            if~isArgBlock
                slUnit=get_param(blockPath,'Unit');
            end

            slAppObj=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
        end

        function slAppObj=fromBusElementObj(slObj,modelName)
            [found,slAppObj]=autosar.mm.util.SlAppTypeAttributesGetter.fromTypeString(slObj.DataType,modelName);
            if found
                return;
            end
            slAppObj=autosar.mm.util.SlAppTypeAttributes(slObj.Min,slObj.Max,slObj.Unit);
        end


        function slAppObj=fromPort(portPath,modelName)

            if slfeature('AUTOSARValueType')


                typeStr=get_param(portPath,'OutDataTypeStr');
                [found,slAppObj]=autosar.mm.util.SlAppTypeAttributesGetter.fromTypeString(typeStr,modelName);
                if found
                    return;
                end
            end

            slMin=get_param(portPath,'OutMin');
            slMax=get_param(portPath,'OutMax');
            slUnit=get_param(portPath,'Unit');






            isInputPort=strcmp(get_param(portPath,'BlockType'),'Inport');
            slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMin,modelName);
            slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMax,modelName);
            if isempty(slMinNumeric)&&isempty(slMaxNumeric)
                lh=get_param(portPath,'LineHandles');
                if isInputPort
                    signalHandle=lh.Outport;
                else
                    signalHandle=lh.Inport;
                end

                if~isempty(signalHandle)&&ishandle(signalHandle)
                    slSigDataAttributes=...
                    autosar.mm.util.SlAppTypeAttributesGetter.fromSignal(signalHandle,modelName);
                    slMin=slSigDataAttributes.Min;
                    slMax=slSigDataAttributes.Max;
                    slUnit=slSigDataAttributes.Unit;
                end
            end

            slAppObj=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
        end


        function slAppObj=fromDualScaledParameter(dataObj)
            slAppObj=autosar.mm.util.SlAppTypeAttributes;
            if~isempty(dataObj)
                slAppObj=autosar.mm.util.SlAppTypeAttributes(dataObj.CalibrationMin,...
                dataObj.CalibrationMax,...
                dataObj.Unit);
            end
        end
    end

    methods(Static,Access=private)


        function slAppObj=fromSignal(signalHandle,modelName)
            slAppObj=autosar.mm.util.SlAppTypeAttributes;
            if~isempty(signalHandle)&&ishandle(signalHandle)
                signalName=get_param(signalHandle,'Name');
                if~isempty(signalName)&&get(signalHandle,'MustResolveToSignalObject')
                    [sigObjExists,signalObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,signalName);
                    if sigObjExists
                        slAppObj=autosar.mm.util.SlAppTypeAttributesGetter.fromDataObj(signalObj);
                    end
                end
            end
        end

        function[found,slAppObj]=fromTypeString(typeStr,modelName)
            slAppObj=autosar.mm.util.SlAppTypeAttributes;
            found=false;
            if startsWith(typeStr,'ValueType:')
                typeName=autosar.utils.StripPrefix(typeStr);
                [typeExists,typeObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,typeName);
                if typeExists
                    slAppObj=autosar.mm.util.SlAppTypeAttributesGetter.fromDataObj(typeObj);
                    slAppObj.setName(typeName);
                    slAppObj.setShouldMangle(false);
                    slAppObj.setIsValueType(true);
                    found=true;
                end
            end
        end
    end
end


