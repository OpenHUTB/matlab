function blockList=pmsl_verifylibrarylinks(mdl)








    if~isa(mdl,'Simulink.BlockDiagram')
        mdl=get_param(mdl,'Object');
    end





















    allBlocks=find_system(mdl.Handle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','Type','block');

    physicalDomainBlocks=find_system(allBlocks,'SearchDepth',0,...
    'regexp','on','PhysicalDomain','.');

    linkStatus=pmsl_linkstatus(physicalDomainBlocks);
    idx=strcmp(linkStatus,'inactive')|strcmp(linkStatus,'')|...
    strcmp(linkStatus,'none');
    blockList=physicalDomainBlocks(idx);
    blocksWithImplicitLinks=physicalDomainBlocks(strcmp(linkStatus,'implicit'));

    blockTypesRegex=lGetBlockTypesRegex();
    if~isempty(blockTypesRegex)
        coreBlocks=find_system(allBlocks,'SearchDepth',0,...
        'regexp','on','BlockType',blockTypesRegex);
        linkStatus=pmsl_linkstatus(coreBlocks);

        idx=strcmp(linkStatus,'inactive')|strcmp(linkStatus,'')|...
        strcmp(linkStatus,'none')|strcmp(linkStatus,'implicit');
        coreBlockList=coreBlocks(idx);
    else
        coreBlockList=[];
    end









    domains=get_param(blockList,'PhysicalDomain');
    blocksInNeDomain=blockList(strcmpi(domains,'network_engine_domain'));
    blocksInMechDomain=blockList(strcmpi(domains,'mechanical'));
    blocksInPowersysDomain=blockList(strcmpi(domains,'powersysdomain'));

    blocksWithImplicitLinksInNeDomain=blocksWithImplicitLinks(...
    strcmpi(get_param(blocksWithImplicitLinks,'PhysicalDomain'),...
    'network_engine_domain'));















    neBlockType=get_param(blocksInNeDomain,'BlockType');
    pmComponentIdx=strcmp(neBlockType,'PMComponent');
    pmComponentBlocks=blocksInNeDomain(pmComponentIdx);
    topLevelPmComponentNeBlocks=cell2mat(get_param(get_param(pmComponentBlocks,'Parent'),'Handle'));
    topLevelNonPmComponentNeBlocks=blocksInNeDomain(~pmComponentIdx);



    blocksWithBrokenLinks=[blocksInMechDomain;blocksInPowersysDomain;...
    topLevelNonPmComponentNeBlocks;topLevelPmComponentNeBlocks;...
    coreBlockList;blocksWithImplicitLinksInNeDomain];

    blockList=pmsl_sanitizename(getfullname(unique(blocksWithBrokenLinks)));

    if~iscell(blockList)
        blockList={blockList};
        return;
    end

    blockList=sort(blockList);
end

function blockTypesRegex=lGetBlockTypesRegex()


    blockTypesRegex=char(join(string(pmsl_getblocktypes()),"|"));
end





