function hasMismatchedConfigsets(Model)







    mdls=find_mdlrefs(Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    numMdls=length(mdls);
    if numMdls>1
        try
            evalc(['slbuild(''',Model,''',''StandaloneCoderTarget'',''OnlyCheckConfigsetMismatch'',true)']);
        catch ME
            DAStudio.error('SimulinkFixedPoint:designCostEstimation:notReadyForCodegen',...
            Model);
        end
    end
end