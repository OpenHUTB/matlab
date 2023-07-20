

function[excluded_sysclone,flag]=excludedSyswithTriggerPorts(excluded_sysclone,aCloneCandidate,excludeName)

    flag=false;
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','TriggerPort');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains trigger port';
        flag=true;
        return;
    end
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','EnablePort');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains enable port';
        flag=true;
        return;
    end
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','StateControl');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains state control port';
        flag=true;
        return;
    end
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','StateEnablePort');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains state enable port';
        flag=true;
        return;
    end
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','ResetPort');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains reset port';
        flag=true;
        return;
    end
    portsName=find_system(aCloneCandidate,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','ActionPort');
    if~isempty(portsName)&&~isKey(excluded_sysclone,excludeName)
        excluded_sysclone(excludeName)='Contains action port';
        flag=true;
        return;
    end
end