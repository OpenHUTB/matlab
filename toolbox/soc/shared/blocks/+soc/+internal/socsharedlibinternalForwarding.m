function newData=socsharedlibinternalForwarding(oldData)

    switch oldData.ForwardingTableEntry.('__slOldName__')
    case 'socsharedlib_internal/HWSW Message Send'
        newData=HWSWMessageSendForwarding(oldData);
    end

end

function newData=HWSWMessageSendForwarding(oldData)

    newData.NewBlockPath='';
    newData.NewInstanceData=[];


    newData.NewInstanceData=oldData.InstanceData;

    [~,idx]=intersect({newData.NewInstanceData.Name},'DataTypeStr');
    if idx
        newData.NewInstanceData(idx)=[];
    end
    [~,idx]=intersect({newData.NewInstanceData.Name},'Dimensions');
    if idx
        newData.NewInstanceData(idx)=[];
    end

end