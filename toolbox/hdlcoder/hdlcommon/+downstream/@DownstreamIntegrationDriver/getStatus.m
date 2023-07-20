function status=getStatus(obj)


    status=obj.hToolDriver.hEngine.getStageID(obj.hToolDriver.hEngine.CurrentStage);
end
