function FrequencyDomainFIRFilter(obj)




    if isR2017bOrEarlier(obj.ver)

        blks=obj.findBlocksWithMaskType('dsp.simulink.FrequencyDomainFIRFilter',...
        'NumeratorDomain','Frequency');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            subsys_msg=DAStudio.message('dsp:system:FrequencyDomainFIRFilter:EmptySubsystem_FreqDomain');
            subsys_err=DAStudio.message('dsp:system:Shared:NewFeaturesNotAvailable');
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end