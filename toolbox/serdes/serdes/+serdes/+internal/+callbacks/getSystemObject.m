






function systemObject=getSystemObject(rootBlock)
    systemObject=[];


    blocks=find_system(rootBlock,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on','FollowLinks','on',...
    'Type','block','BlockType','MATLABSystem');


    if length(blocks)==1
        systemName=get_param(blocks(1),'System');
        systemObject=eval(systemName);
    end
end
