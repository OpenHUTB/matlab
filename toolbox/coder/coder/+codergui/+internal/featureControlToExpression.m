function expr=featureControlToExpression(featureControl)
    persistent defaultValues;
    if isempty(defaultValues)
        defaultObj=coder.internal.FeatureControl();
        propNames=properties(defaultObj);
        propVals=cell(size(propNames));
        for i=1:numel(propNames)
            propVals{i}=defaultObj.(propNames{i});
        end
        defaultValues=[propNames,propVals]';
    end

    tokens={};
    for pair=defaultValues
        value=featureControl.(pair{1});
        if~isequal(value,pair{2})
            if islogical(value)
                value=double(value);
            end
            tokens(end+1:end+2)={['''',pair{1},''''],mat2str(value)};
        end
    end

    if~isempty(tokens)
        expr=['{',strjoin(tokens,', '),'}'];
    else
        expr='';
    end
end