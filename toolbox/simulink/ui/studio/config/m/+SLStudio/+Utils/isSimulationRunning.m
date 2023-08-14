function result=isSimulationRunning(cbinfo)




    modelH=SLStudio.Utils.getModelHandle(cbinfo);
    result=~strcmp(SLStudio.Utils.getSimStatus(cbinfo),'stopped')||~strcmp(get_param(modelH,'RapidAcceleratorSimStatus'),'inactive');
end
