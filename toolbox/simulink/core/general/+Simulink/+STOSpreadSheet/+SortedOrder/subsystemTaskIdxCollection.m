function[taskIdVec,systemIdx]=subsystemTaskIdxCollection(subsys)


    sList=get_param(subsys,'TaskList');

    taskIdVec=zeros(1,length(sList))*(-1);

    for count=1:length(sList)
        taskIdVec(count)=sList(count).TaskIndex;
    end

    systemIdx=get_param(subsys,'SystemIndex');