function app=compareJava(first,second,options)


    error(javachk('jvm'));

    if isComparisonBeingLaunchedFromJava(options)

        builder=com.mathworks.comparisons.compare...
        .ComparisonDefinitionBuilder(options.ComparisonDefinition);%#ok<*JAPIMATHWORKS> 

        type=comparisons.internal.dispatcherutil.getJComparisonType(options.Type);
        builder.setComparisonType(type);

        definition=builder.build();
    else
        definition=comparisons.internal.dispatcherutil...
        .makeDefinitionForTwoWay(first.Path,second.Path,options);
    end

    import comparisons.internal.dispatcherutil.startJavaComparison
    app=startJavaComparison(definition,first,second);
end

function bool=isComparisonBeingLaunchedFromJava(options)


    bool=isfield(options,'ComparisonDefinition');
end
