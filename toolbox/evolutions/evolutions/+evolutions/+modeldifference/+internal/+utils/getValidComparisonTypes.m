function comparisonTypes=getValidComparisonTypes(fileName)




    fileType=evolutions.modeldifference.internal.utils...
    .FileTypeFactory.getFileType(fileName);
    comparisonTypeVisitor=evolutions.modeldifference.internal.utils...
    .GetComparisonTypesVisitor;
    fileType.accept(comparisonTypeVisitor);
    comparisonTypes=comparisonTypeVisitor.ComparisonTypes;

end
