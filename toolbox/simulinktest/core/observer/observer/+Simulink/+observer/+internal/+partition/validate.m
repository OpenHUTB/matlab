function validate(obsModel)




    obsModel=string(get_param(obsModel,"Name"));
    obsH=get_param(obsModel,"Handle");


    conditionalObs=Simulink.observer.internal.getConditionalSubsystemObserverPortBlocks(obsH);
    assert(~isempty(conditionalObs));


    partitions=arrayfun(@(obs)getAperiodicPartition(obs,obsModel),conditionalObs);


    verifyOneObsPortPerAperiodicPartition(partitions);
    verifyUniquePartitionNames(partitions);
end

function partition=getAperiodicPartition(conditionalObs,obsModel)
    partition=[];
    block=conditionalObs;
    while block
        block=get_param(block,"Parent");
        if block==obsModel

            blockPath=getfullname(conditionalObs);
            error(message("Simulink:Observer:NoPartition",blockPath,bdroot(blockPath)));
        elseif get_param(block,"BlockType")=="SubSystem"&&...
            get_param(block,"ScheduleAs")=="Aperiodic partition"
            partition=get_param(block,"Handle");
            return;
        end
    end
end

function verifyOneObsPortPerAperiodicPartition(partitions)

    [uniquePartitions,ia]=unique(partitions);
    if numel(partitions)~=numel(uniquePartitions)
        dupIdx=setdiff(1:numel(partitions),ia);
        dupPartition=partitions(dupIdx(1));
        blockPath=getfullname(dupPartition);
        error(message("Simulink:Observer:InvalidPartition",blockPath,bdroot(blockPath)));
    end
end

function verifyUniquePartitionNames(partitions)

    partitionNames=string(get_param(partitions,"PartitionName"));
    [uniquePartitionNames,ia]=unique(partitionNames);
    if numel(partitionNames)~=numel(uniquePartitionNames)
        dupIdx=setdiff(1:numel(partitionNames),ia);
        dupPartitionName=partitionNames(dupIdx(1));
        blockPath=getfullname(partitions(ia(1)));
        open_system(blockPath,"Parameter");
        error(message("Simulink:Observer:PartitionNamesMustBeUnique",dupPartitionName,blockPath));
    end
end
