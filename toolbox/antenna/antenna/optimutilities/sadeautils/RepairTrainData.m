function[TrainDataSN,TrainDataYN]=RepairTrainData(TrainDataS,TrainDataY)

    remcom=[];
    for cticom=1:size(TrainDataS,1)
        if imag(TrainDataY(cticom,:))~=0
            remcom=[remcom;cticom];
        end
    end
    if sum(size(remcom))~=0
        TrainDataS(remcom,:)=[];
        TrainDataY(remcom,:)=[];
    end

    [TrainDataSN,TrainDataYN]=filtsame(TrainDataS,TrainDataY);
