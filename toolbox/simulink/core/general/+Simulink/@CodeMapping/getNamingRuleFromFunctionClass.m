function[namingRule,useSimulinkDefault]=getNamingRuleFromFunctionClass(mapObj,mdlH,defaultsCategory)




    namingRule='';
    useSimulinkDefault=false;
    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(mdlH);
    if~strcmp(mappingType,'CppModelMapping')
        if~isempty(mapObj.FunctionReference)
            if isempty(mapObj.FunctionReference.FunctionClass)

                useSimulinkDefault=true;
            elseif~isempty(mapObj.FunctionReference.FunctionClass.UUID)

                fcnClassName=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateNameFromUuid(...
                mdlH,mapObj.FunctionReference.FunctionClass.UUID,defaultsCategory);
                hlp=coder.internal.CoderDataStaticAPI.getHelper();
                dataDict=get_param(mdlH,'EmbeddedCoderDictionary');
                if isempty(dataDict)
                    dataDict=get_param(mdlH,'DataDictionary');
                end
                if isempty(dataDict)
                    dd=hlp.openDD(mdlH);
                else
                    dd=hlp.openDD(dataDict);
                end
                cdType=Simulink.CodeMapping.getCoderDataTypeForFunctionCategory(mapObj.ParentMapping,defaultsCategory);

                fc=hlp.findEntry(dd,cdType,fcnClassName);
                if~isempty(fc)
                    namingRule=hlp.getProp(fc,'FunctionName');
                end
            end
        end
    end
end
