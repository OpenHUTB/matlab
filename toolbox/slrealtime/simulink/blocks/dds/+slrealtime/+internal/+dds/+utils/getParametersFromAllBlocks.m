function values=getParametersFromAllBlocks(modelName,blkType,paramName)







    values={};
    so=Simulink.FindOptions('FollowLinks',true,'LookUnderMasks','all',...
    'IncludeCommented',false);
    if Simulink.internal.useFindSystemVariantsMatchFilter()

        so.MatchFilter=@Simulink.match.activeVariants;
    else



        so.Variants='ActiveVariants';
    end

    bh=Simulink.findBlocks(modelName,'MaskType',blkType,so);
    if~isempty(bh)
        currvalues=get_param(bh,paramName);
        values=[values;currvalues];
    end

end
