function systems=find_system_MAWrapper(system,varargin)









    if Simulink.internal.useFindSystemVariantsMatchFilter()
        systems=find_system(system,'LookUnderMasks','all','FollowLinks','off',...
        'MatchFilter',@Simulink.match.activeVariants,varargin{:});
    else
        systems=find_system(system,'LookUnderMasks','all','FollowLinks','off',varargin{:});
    end
end


