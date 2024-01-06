function out=renameSubsystemPartitionFixit(bd,partition,scheduleAsFilter,newName,sources)

    out='';

    for i=1:length(sources)
        source=[bd,':',sources{i}];
        blockHandle=Simulink.ID.getHandle(source);

        if strcmp(get_param(blockHandle,'BlockType'),'SubSystem')

            if isempty(scheduleAsFilter)||...
                strcmp(get_param(blockHandle,'ScheduleAs'),scheduleAsFilter)

                assert(strcmp(get_param(blockHandle,'PartitionName'),partition));
                assert(strcmp(out,''));

                out=set_param_action(blockHandle,'PartitionName',newName);
            end
        end
    end

end
