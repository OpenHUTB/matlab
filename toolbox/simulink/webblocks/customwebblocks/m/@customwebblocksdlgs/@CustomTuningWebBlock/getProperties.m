function properties=getProperties(widgetId,isLibWidget,model)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    for idx=1:length(dlgs)
        dlgSrc=dlgs(idx).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            break;
        end
    end

    if~isempty(dlgSrc)
        keys=dlgSrc.propMap.keys;
        properties=repmat(struct(),[1,length(keys)]);
        for idx=1:length(keys)
            properties(idx).index=dlgSrc.propMap(idx).index;
            properties(idx).states=dlgSrc.propMap(idx).states;
            properties(idx).stateLabels=dlgSrc.propMap(idx).stateLabels;
        end
    else
        modelName=get_param(bdroot(dlgSrc.blockObj.Handle),'Name');
        properties=utils.getDiscreteKnobInitialPropertiesStruct(modelName,widgetId,isLibWidget);
    end
end