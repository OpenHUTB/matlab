function nesl_validatenames(mdl)





    getModelHandle=pmsl_private('pmsl_modelhandle');
    mdlHandle=getModelHandle(mdl);




    masterBlocks=find_system(mdlHandle,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','PMComponent','Name','Master',...
    'PhysicalDomain','network_engine_domain');


    neBlocks=get_param(masterBlocks,'Parent');


    neBlockNames=get_param(neBlocks,'Name');
    [uniqueNames,uniqueIdx]=unique(neBlockNames);



    if numel(uniqueNames)~=numel(neBlockNames)



        idx=1:numel(neBlockNames);
        duplicateIdx=setdiff(idx,uniqueIdx);
        duplicateNames=neBlockNames(duplicateIdx);


        [~,idx]=intersect(uniqueNames,duplicateNames);


        uniqueBlocks=neBlocks(uniqueIdx);
        duplicateBlocks=neBlocks(duplicateIdx);



        allDuplicateBlocks=[uniqueBlocks(idx),duplicateBlocks{:}];%#ok<NASGU>


        duplicateBlocksString=evalc('disp(allDuplicateBlocks'')');
        error(...
        message('physmod:ne_sli:nesl_validatenames:DuplicateBlocks',...
        duplicateBlocksString));
    end


end
