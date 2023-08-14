function status=getSimStatus(cbinfo)




    modelH=SLStudio.Utils.getModelHandle(cbinfo);
    status=get_param(modelH,'SimulationStatus');
end
