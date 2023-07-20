function profileDataStruct=runProfile(JTAGMaster,PMInfo,profileDataStruct)
    Data=zeros(1,PMInfo.NumSlots,13);
    TimeStamp(:)=double(JTAGMaster.readmemory(PMInfo.PERF_SCTR,2));
    profileDataStruct.Time=[profileDataStruct.Time;TimeStamp(1,1)+(2^32*TimeStamp(1,2))];
    for slot=1:PMInfo.NumSlots
        DataTemp(:)=JTAGMaster.readmemory(PMInfo.SAMPLED_METRIC_START{slot},13);
        Data(1,slot,:)=DataTemp;
    end
    profileDataStruct.Data=[profileDataStruct.Data;Data];
end
