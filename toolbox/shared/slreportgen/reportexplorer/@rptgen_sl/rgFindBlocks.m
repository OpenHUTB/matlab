function oList=rgFindBlocks(objList,searchDepth,searchTerms)







    if isempty(searchTerms)
        searchTerms={};
    end

    if isempty(searchDepth)
        depthCell={};
    else
        depthCell={'SearchDepth',searchDepth};
    end

    if Simulink.internal.useFindSystemVariantsMatchFilter()

        oList=find_system(objList,...
        depthCell{:},...
        'RegExp','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'Type','\<block\>',...
        searchTerms{:});
    else
        oList=find_system(objList,...
        depthCell{:},...
        'RegExp','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'Type','\<block\>',...
        searchTerms{:});
    end


    sfBlocks=find_system(oList,'SearchDepth',0,'MaskType','Stateflow');


    sfChildren=find_system(sfBlocks,...
    depthCell{:},...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'RegExp','on',...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'Type','\<block\>',...
    searchTerms{:});
    oList=union(setdiff(oList,sfChildren),sfBlocks);

    oList=strrep(oList,char(10),' ');
