function checkSDI(data,modelName)





    sdiRun=Simulink.sdi.getCurrentSimulationRun(modelName,'',false);
    if~isempty(sdiRun)&&contains(modelName,sdiRun.Model)
        data.sdiRunId=sdiRun.id;
        setTag(data,sprintf('Run %d',sdiRun.RunIndex));
    end

end
