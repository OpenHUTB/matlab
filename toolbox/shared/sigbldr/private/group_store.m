function UD=group_store(UD)






    dsIdx=UD.current.dataSetIdx;

    UD.dataSet(dsIdx).timeRange=[UD.common.minTime,UD.common.maxTime];
    UD.dataSet(dsIdx).displayRange=UD.common.dispTime;
    UD.dataSet(dsIdx).activeDispIdx=fliplr(unique([UD.axes.channels]));
