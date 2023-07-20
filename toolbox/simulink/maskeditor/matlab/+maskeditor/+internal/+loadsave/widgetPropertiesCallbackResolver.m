function aConfigFile=widgetPropertiesCallbackResolver(aConfigFile,aContext)

    commonPropertiesStruct=aConfigFile.common_properties;
    commonPropFields=fieldnames(commonPropertiesStruct);
    for k=1:numel(commonPropFields)
        property=commonPropertiesStruct.(commonPropFields{k});
        if(isfield(property,'visible'))
            [resolvedValue,needToSetValue]=resolveVisibleConfigProperty(property,aContext,property.propertyId,'');
            if needToSetValue
                aConfigFile.common_properties.(commonPropFields{k}).visible=resolvedValue;
            end
        end
    end

    allWidgetPropertiesStruct=aConfigFile.widget_properties;
    allWidgetFields=fieldnames(allWidgetPropertiesStruct);
    for i_Widgets=1:numel(allWidgetFields)
        widgetPropCellArray=allWidgetPropertiesStruct.(allWidgetFields{i_Widgets});
        for i_Prop=1:length(widgetPropCellArray)
            if isstruct(widgetPropCellArray{i_Prop})
                property=widgetPropCellArray{i_Prop};
                if(isfield(property,'visible'))
                    [resolvedValue,needToSetValue]=resolveVisibleConfigProperty(property,aContext,property.propertyId,...
                    allWidgetFields{i_Widgets});
                    if needToSetValue
                        aConfigFile.widget_properties.(allWidgetFields{i_Widgets}){i_Prop}.visible=resolvedValue;
                    end
                end
            end
        end
    end
end

function[resolvedValue,needToSetValue]=resolveVisibleConfigProperty(property,aContext,propertyId,widgetType)
    resolvedValue='true';
    needToSetValue=false;
    visibleConfig=property.visible;
    if strcmp(visibleConfig,'true')||strcmp(visibleConfig,'false')
        resolvedValue=visibleConfig;
        return;
    end
    evaluatedVisibility=eval([visibleConfig,'(aContext, propertyId, widgetType)']);
    needToSetValue=true;
    if(evaluatedVisibility==true||evaluatedVisibility==false)
        resolvedValue=string(evaluatedVisibility);
    end
end