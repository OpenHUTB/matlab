function[TrainDataS,TrainDataY]=GenTrainData_New(popA,valA,D,ui,ns)

    TrainDataX_pool=popA;
    TrainDataY_pool=valA;

    if ns*D>size(popA,1)
        TN=size(popA,1);
    else
        TN=ns*D;
    end


    basepoint=median(ui);
    for i=1:size(TrainDataX_pool,1)
        distance(i)=distvec(TrainDataX_pool(i,:),basepoint');
    end
    [temp,dis_index]=sort(distance);

    distNear_X=TrainDataX_pool(dis_index(1:TN),:);
    distNear_Y=TrainDataY_pool(dis_index(1:TN),:);

    [TrainDataS,TrainDataY]=RepairTrainData(distNear_X,distNear_Y);