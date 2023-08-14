function isBuildSpec=isBuildSpec(buildSpec)




    validBuildSpecs={'','StandaloneRTWTarget','ModelReferenceTarget',...
    'ModelReferenceSimTarget','ModelReferenceProtectedSimTarget',...
    'ModelReferenceRTWTarget','ModelReferenceRTWTargetOnly',...
    'ModelReferenceCoderTarget','ModelReferenceCoderTargetOnly',...
    'StandaloneCoderTarget','CleanTopModel'};

    isBuildSpec=any(strcmp(buildSpec,validBuildSpecs));

end
