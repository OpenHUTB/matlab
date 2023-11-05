function app=mergeThreeInJava(theirs,base,mine,options)

    error(javachk('jvm'));

    if isComparisonBeingLaunchedFromJava(options)

        builder=com.mathworks.comparisons.compare...
        .ComparisonDefinitionBuilder(options.ComparisonDefinition);%#ok<*JAPIMATHWORKS> 

        type=comparisons.internal.dispatcherutil.getJComparisonType(options.Type);
        builder.setComparisonType(type);

        definition=builder.build();
    else
        definition=comparisons.internal.dispatcherutil.makeDefinitionForThreeWay(...
        theirs.Path,...
        base.Path,...
        mine.Path,...
options...
        );
    end

    import comparisons.internal.dispatcherutil.startJavaComparison
    app=startJavaComparison(definition,theirs,base,mine);
end

function bool=isComparisonBeingLaunchedFromJava(options)


    bool=isfield(options,'ComparisonDefinition');
end
