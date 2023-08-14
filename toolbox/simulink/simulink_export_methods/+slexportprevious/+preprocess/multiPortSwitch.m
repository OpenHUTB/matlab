function multiPortSwitch(obj)







    blkType='MultiPortSwitch';

    if isR2010aOrEarlier(obj.ver)
        MPSwitchBlks=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'BlockType',blkType);

        if(isempty(MPSwitchBlks))
            return;
        end

        for i=1:length(MPSwitchBlks)
            blk=MPSwitchBlks{i};

            portOrder=get_param(blk,'DataPortOrder');

            if(strcmp(portOrder,'Specify indices'))


                obj.replaceWithEmptySubsystem(blk);
            end
        end
    end
