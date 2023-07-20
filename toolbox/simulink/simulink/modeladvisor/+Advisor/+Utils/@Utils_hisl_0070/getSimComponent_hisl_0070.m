function simComponent=getSimComponent_hisl_0070(system,opts)




    if opts.link2ContainerOnly


        blocks=get_param(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',opts.lookUnderMask,'FollowLinks',opts.followLinks,'BlockType','SubSystem'),'handle');
        if iscell(blocks)
            blocks=cell2mat(blocks);
        end
        sysH=get_param(system,'handle');
        if~any(ismember(blocks,sysH))
            blocks=[blocks;sysH];
        end


        area=get_param(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','annotation','AnnotationType','area_annotation'),'handle');
        if iscell(area)
            area=cell2mat(area);
        end
        simComponent=[blocks;area];

    else


        simComponent=get_param(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',opts.lookUnderMask,'FollowLinks',opts.followLinks,'type','block'),'handle');
        simComponent=cell2mat(simComponent);
    end
end
