
function populateConfigSetParameterCache()


    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.configset.customization.ConfigSetDataUtils;


    if~ConfigSetDataUtils.isParameterCacheEmpty()
        return;
    end

    configSetData=configset.internal.getConfigSetStaticData();
    i_SaveComponentData(configSetData);
    i_SavePropertyData(configSetData);

end

function i_SaveComponentData(configSetData)
    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.configset.customization.ConfigSetDataUtils;

    components=configSetData.ComponentList;
    for jj=1:numel(components)
        component=components{jj};



        if strcmp(component.Name,'ConfigSet')
            continue
        end
        key=component.Class;

        path=component.getDisplayName();

        ConfigSetDataUtils.addParameter(key,path,path);
    end

end

function i_SavePropertyData(configSetData)


    properties=configSetData.ParamList;
    cellfun(@addProperty,properties);

    function addProperty(property)
        import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.configset.customization.ConfigSetDataUtils;
        ConfigSetDataUtils.addParameter(...
        property.Name,...
        property.getPrompt(),...
        property.Component...
        );
    end

end
