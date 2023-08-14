function mdlrefs=find_loaded_mdlrefs(modelH)




    modelName=get_param(modelH,'Name');
    mdlrefs=loc_find_mdlrefs_recursion(modelName,{modelName});
    mdlrefs=unique(mdlrefs);
end

function mdlrefs=loc_find_mdlrefs_recursion(modelName,mdlrefs)
    mdlBlks=find_system(modelName,'LookUnderMasks','all',...
    'FollowLinks','on','BlockType','ModelReference');
    mdls=get_param(mdlBlks,'ModelName');
    mdls=unique(mdls);
    for idx=1:length(mdls)
        if bdIsLoaded(mdls{idx})
            mdlrefs=[mdls{idx};loc_find_mdlrefs_recursion(mdls{idx},mdlrefs)];
        end
    end
end