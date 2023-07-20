function lines=getFeatureControlScript(layout)





    features=layout.FeatureSet;
    featuresSet=containers.Map;
    lines{1}='  layoutFC = [];';
    for i=1:length(features)
        if~featuresSet.isKey(features{i})
            lines{end+1}=['  layoutFC.',features{i},' = slfeature(''',features{i},''');'];%#ok<*AGROW>
            featuresSet(features{i})=1;
        end
    end
