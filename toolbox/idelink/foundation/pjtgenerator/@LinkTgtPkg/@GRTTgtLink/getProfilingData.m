function rawData=getProfilingData(h,IDE_Obj)







    numTimerTasks=read(IDE_Obj,address(IDE_Obj,'numTimerTasks'),'uint16');
    rawData.tMax=double(read(IDE_Obj,address(IDE_Obj,'tMax'),'int16',numTimerTasks));
    rawData.oRunMax=double(read(IDE_Obj,address(IDE_Obj,'oRunMax'),'int16',numTimerTasks));
    rawData.numPoints=double(read(IDE_Obj,address(IDE_Obj,'numPoints'),'uint32'));
    rawData.loggedData=double(read(IDE_Obj,address(IDE_Obj,'loggedData'),'int32',rawData.numPoints));
    timePerTickUnits=double(read(IDE_Obj,address(IDE_Obj,'timerPsPerTick'),'uint32'));
