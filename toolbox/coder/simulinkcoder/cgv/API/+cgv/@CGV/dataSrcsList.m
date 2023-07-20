function list=dataSrcsList(sdie,dataRunID)



    count=sdie.getSignalCount(dataRunID);
    list=cell(1,count);
    for i=1:count
        data=sdie.getSignal(dataRunID,i);
        list{i}=data.DataSource;
    end
end
