function out=checkIsActive(blockH)




    assert(ishandle(blockH));
    out=false;

    try
        parentH=get_param(get_param(blockH,'Parent'),'Handle');
        out=check_hier(parentH,blockH);
    catch Mex %#ok<NASGU>
    end
end


function out=check_hier(parentH,blockH)
    out=false;

    if~valid_decendent(parentH,blockH)
        return;
    end

    if(parentH==bdroot(parentH))
        out=true;
        return;
    end


    blockH=parentH;
    parentH=get_param(get_param(blockH,'Parent'),'Handle');
    out=check_hier(parentH,blockH);
end


function out=valid_decendent(parentH,blockH)
    blkName=get_param(blockH,'Name');
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        blk=find_system(parentH,...
        'SearchDepth',1,...
        'FindAll','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented','off',...
        'FollowLinks','on',...
        'LookUnderMasks','on',...
        'Name',blkName);
    else
        blk=find_system(parentH,...
        'SearchDepth',1,...
        'FindAll','on',...
        'Variants','ActiveVariants',...
        'IncludeCommented','off',...
        'FollowLinks','on',...
        'LookUnderMasks','on',...
        'Name',blkName);
    end
    out=~isempty(blk)&&any(blk==blockH);
end



