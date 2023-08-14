function[ssBlockHs,ivAndModelBlockHs]=getAllSubsystemModelAndIVBlocksInModel(modelOrSS,searchType)












    ssBlockHs=[];
    ivAndModelBlockHs=[];

    modelOrSS=get_param(modelOrSS,'Handle');

    if~strcmp('block_diagram',get_param(modelOrSS,'Type'))&&...
        strcmp('SubSystem',get_param(modelOrSS,'BlockType'))&&...
        ~Simulink.variant.utils.isSubsystemReadable(modelOrSS)
        return;
    end

    persistent findOpts;
    if Simulink.internal.useFindSystemVariantsMatchFilter()


        matchFilter=[];
        switch searchType
        case 'ActiveVariants'
            matchFilter=@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices;
        case 'ActivePlusCodeVariants'
            matchFilter=@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices;
        end

        if isempty(findOpts)
            findOpts=Simulink.FindOptions(...
            'SearchDepth',1,...
            'IncludeCommented',false,...
            'LookUnderMasks','All',...
            'FollowLinks',true,...
            'LookInsideSubsystemReference',true,...
            'RegExp',true,...
            'MatchFilter',matchFilter);
        else
            findOpts.MatchFilter=matchFilter;
        end
    else

        if isempty(findOpts)
            findOpts=Simulink.FindOptions(...
            'SearchDepth',1,...
            'IncludeCommented',false,...
            'LookUnderMasks','All',...
            'FollowLinks',true,...
            'LookInsideSubsystemReference',true,...
            'RegExp',true,...
            'Variants',searchType);
        elseif~strcmp(searchType,findOpts.Variants)
            findOpts.Variants=searchType;
        end
    end

    unredableSSHs=[];

    sysHs=Simulink.findBlocksOfType(...
    modelOrSS,'SubSystem',...
    findOpts);
    while~isempty(sysHs)
        sysH=sysHs(1);
        sysHs(1)=[];

        if~Simulink.variant.utils.isSubsystemReadable(sysH)
            unredableSSHs(end+1,1)=sysH;%#ok<AGROW>
            continue;
        end

        ssBlockHs(end+1,1)=sysH;%#ok<AGROW>



        newSysHs=Simulink.findBlocksOfType(...
        sysH,'SubSystem',...
        findOpts);

        sysHs=[sysHs;newSysHs];%#ok<AGROW>
    end

    ivAndModelBlockHs=Simulink.findBlocksOfType([modelOrSS;ssBlockHs],'^(ModelReference|VariantSink|VariantSource|VariantPMConnector)$',findOpts);

    if slfeature('PhysmodVariantConnector')<1


        ivAndModelBlockHs(strcmp(get_param(ivAndModelBlockHs,'BlockType'),'VariantPMConnector'))=[];
    end
    ssBlockHs=[ssBlockHs;unredableSSHs];

end


