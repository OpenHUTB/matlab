function[vars,blocks]=findVars(system,FollowLinks,LookUnderMasks,varargin)




















    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks);

    try

        if numel(varargin)>=1
            [varargin{:}]=convertStringsToChars(varargin{:});
            allVars=Simulink.findVars(system,'SearchMethod','cached',varargin{:});
        else
            allVars=Simulink.findVars(system,'SearchMethod','cached');
        end



        flags=arrayfun(@(x)any(ismember(x.Users,blocks)),allVars);

        vars=allVars(flags);
    catch e
        if strcmp(e.identifier,'Simulink:Data:SrcMlxNotSupported')
            vars=[];
            return;
        end

        rethrow(e);
    end
end
