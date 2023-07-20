function sendScenarioInfo(scenarioDBID,appInstanceID)





    msgTopics=Simulink.sta.ScenarioTopics();

    scenarioRepo=sta.Scenario(scenarioDBID);

    scenarioStructToSend.scenarioinfo.id=scenarioRepo.ID;
    scenarioStructToSend.scenarioinfo.descr=scenarioRepo.Description;
    scenarioStructToSend.scenarioinfo.fullfilename=scenarioRepo.FileName;
    scenarioStructToSend.scenarioinfo.timeofmapping=scenarioRepo.TimeOfMapping;
    scenarioStructToSend.scenarioinfo.model='';

    if scenarioRepo.getModelID~=-1

        ModelRepo=sta.Model(scenarioRepo.getModelID);
        scenarioStructToSend.scenarioinfo.model=ModelRepo.Name;
    end


    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.SCENARIO_CREATE_MLDATX);
    message.publish(fullChannel,scenarioStructToSend);
