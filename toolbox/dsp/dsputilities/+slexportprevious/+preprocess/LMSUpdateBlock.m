function LMSUpdateBlock(obj)




    if isR2021bOrEarlier(obj.ver)




        subsys_msg_NumFilters='EmptySubsystem_NumFilters';
        subsys_msg_AdaptiveFilterMode='EmptySubsystem_AdaptiveFilterMode';
        subsys_err='NewFeaturesNotAvailable';
        blksLMSUpdate=obj.findBlocksWithMaskType('dsp.simulink.LMSUpdate');

        for idx=1:numel(blksLMSUpdate)
            this_block=blksLMSUpdate{idx};
            this_block_handle=getSimulinkBlockHandle(this_block);

            NumFilters=str2double(get_param(this_block_handle,'NumFilters'));
            AdaptiveFilterMode=get_param(this_block_handle,'AdaptiveFilterMode');
            if strcmp(AdaptiveFilterMode,'Adaptive linear combiner')
                obj.replaceWithEmptySubsystem(this_block,subsys_msg_AdaptiveFilterMode,subsys_err);
            elseif NumFilters>1
                obj.replaceWithEmptySubsystem(this_block,subsys_msg_NumFilters,subsys_err);
            end
        end
    end

end
