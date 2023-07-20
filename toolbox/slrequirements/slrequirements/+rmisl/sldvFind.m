function[dvItems,reqTable]=sldvFind(sys)

    if ischar(sys)
        sysH=get_param(sys,'Handle');
    else
        sysH=sys;
    end

    assBlocks=find_system(sysH,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on','BlockType','Assertion');
    dvSubsystems=find_system(sysH,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on',...
    'MaskType','VerificationSubsystem');
    dvBlocks=find_system(sysH,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on',...
    'Regexp','on','MaskType','^Design Verifier ');

    if~isempty(dvBlocks)
        dvTypes=get_param(dvBlocks,'MaskType');
    end

    allHandles=[assBlocks;dvSubsystems;dvBlocks];
    allTypes=[...
    repmat({'Assertion Block'},length(assBlocks),1);...
    repmat({'Verification Subsystem'},length(dvSubsystems),1);...
    dvTypes];

    allParents=get_param(get_param(allHandles,'Parent'),'Handle');
    if iscell(allParents)
        parentH=[allParents{:}]';
    else
        parentH=allParents;
    end

    dvItems={allHandles,allTypes,parentH};

    if nargout==2
        reqTable=makeTable(dvItems);
    else
        reqTable={};
    end

end

function reqTable=makeTable(dvItems)
    totalItems=size(dvItems{:,1},1);
    reqTable=cell(totalItems+1,3);

end


