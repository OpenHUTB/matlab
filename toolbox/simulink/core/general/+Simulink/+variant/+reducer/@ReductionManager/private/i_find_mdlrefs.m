function[refModels,mdlBlks]=i_find_mdlrefs(modelName,varargin)









    [refModels,mdlBlks]=find_mdlrefs(modelName,...
    'AllLevels',false,...
    'IgnoreVariantErrors',true,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on',...
    'IncludeCommented','off',...
    'LookUnderMasks','all',...
    varargin{:});



    refModels=setdiff(refModels,modelName);

    refModels=refModels(:)';
end


