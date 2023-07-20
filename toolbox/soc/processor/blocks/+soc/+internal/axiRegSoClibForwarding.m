function outBlockData=axiRegSoClibForwarding(inBlockData)

    outBlockData.NewBlockPath='';
    outBlockData.NewInstanceData=[];


    outBlockData.NewInstanceData=inBlockData.InstanceData;

    [~,idx]=intersect({outBlockData.NewInstanceData.Name},'BlockingTime');
    if idx
        outBlockData.NewInstanceData(idx)=[];
    end

    [~,idx]=intersect({outBlockData.NewInstanceData.Name},'ReadEventID');
    if idx
        outBlockData.NewInstanceData(idx)=[];
    end

    [~,idx]=intersect({outBlockData.NewInstanceData.Name},'NumberOfBuffers');
    if idx
        outBlockData.NewInstanceData(idx)=[];
    end

    [~,idx]=intersect({outBlockData.NewInstanceData.Name},'RequestEventID');
    if idx
        outBlockData.NewInstanceData(idx)=[];
    end


end