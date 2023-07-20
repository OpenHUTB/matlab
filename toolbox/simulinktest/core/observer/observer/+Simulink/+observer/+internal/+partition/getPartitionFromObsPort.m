function partitionH=getPartitionFromObsPort(obsPortH)
    currentH=obsPortH;
    while 1
        parent=get_param(currentH,"Parent");
        grandparent=get_param(parent,"Parent");
        if grandparent==""

            partitionH=[];
            return;
        elseif isequal(bdroot(grandparent),grandparent)

            break;
        end
        currentH=parent;
    end
    partitionH=parent;
    assert(get_param(partitionH,"ScheduleAs")=="Aperiodic partition");
end
