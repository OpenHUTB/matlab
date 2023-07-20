function data=exportSDISignal(sdiSignal,startTime,endTime,uploadSignalIndex)%#ok<INUSD>







    data=sdiSignal.export(startTime,endTime);

