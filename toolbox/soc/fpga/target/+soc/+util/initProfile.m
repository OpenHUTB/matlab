function profileDataStruct=initProfile(JTAGMaster,PMInfo)
    profileDataStruct.Time=zeros(1,1);
    profileDataStruct.Data=zeros(1,PMInfo.NumSlots,13);


    JTAGMaster.writememory(PMInfo.PERF_CR,uint32(0));


    JTAGMaster.writememory(PMInfo.PERF_CR,uint32(2));


    TimeStamp(:)=double(JTAGMaster.readmemory(PMInfo.PERF_SCTR,2));
    profileDataStruct.Time(1,:)=TimeStamp(1,1)+(2^32*TimeStamp(1,2));
    for slot=1:PMInfo.NumSlots
        DataTemp(:)=JTAGMaster.readmemory(PMInfo.SAMPLED_METRIC_START{slot},13);
        profileDataStruct.Data(1,slot,:)=DataTemp;
    end
end