function analyzers=registerDefaultAttributeAnalyzers(~)




    analyzers=[
    dependencies.internal.attribute.createMissingFileAnalyzer
    dependencies.internal.attribute.createMissingProductAnalyzer
    dependencies.internal.attribute.createDerivedFileAnalyzer
    dependencies.internal.attribute.createInvalidFormatAnalyzer
    ];

end
