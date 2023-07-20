

function[builderName,builderFound]=getCompBuilderName(layer,routineObject)


    prefix='dltargets.internal.compbuilder.';

    [compBuilderString,builderFound]=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilder(layer,routineObject);

    builderName=[prefix,compBuilderString];
end