function[CC]=configureForSinglesConversion(CC)



    CC.ConfigInfo.F2FConfig=internal.float2fixed.F2FConfig();
    CC.ConfigInfo.F2FConfig.DoubleToSingle=true;
    coder.internal.initializeF2FConfig(CC.ConfigInfo.F2FConfig,CC.ConfigInfo);

    for i=1:numel(CC.Project.EntryPoints)
        CC.Project.EntryPoints(i).InputTypes=coder.internal.makeDoubleTypesSingle(CC.Project.EntryPoints(i).InputTypes);
    end


    CC.Project.InitialGlobalValues=coder.internal.makeDoubleTypesSingle(CC.Project.InitialGlobalValues);

    if isprop(CC.ConfigInfo,'HighlightPotentialDataTypeIssues')
        CC.ConfigInfo.HighlightPotentialDataTypeIssues=true;
    elseif isprop(CC.Project,'FeatureControl')
        CC.Project.FeatureControl.HighlightPotentialDataTypeIssues=true;
    end

    dtsLibPath=[matlabroot,'/toolbox/coder/float2fixed/dtslib/'];
    addpath(dtsLibPath);
end
