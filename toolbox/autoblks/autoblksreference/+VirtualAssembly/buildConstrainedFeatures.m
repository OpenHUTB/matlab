


function Output=buildConstrainedFeatures(ProductCatalogData)


    components=ProductCatalogData.FeatureParameters;
    n_components=length(components);


    for i=1:n_components
        ComponentName=components{i}.Feature;
        ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
        Output.(ComponentNameNoSpace).Name=ComponentName;
        Output.(ComponentNameNoSpace).Options=components{i}.FeatureVariant;
        Output.(ComponentNameNoSpace).Value=components{i}.FeatureVariant(1);
        Output.(ComponentNameNoSpace).default.Options=components{i}.FeatureVariant;
    end



