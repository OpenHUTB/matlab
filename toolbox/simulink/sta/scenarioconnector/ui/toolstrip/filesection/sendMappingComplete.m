function sendMappingComplete(isError,appInstanceID)




    msgTopics=Simulink.sta.ScenarioTopics();

    msgOut.status=isError;


    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.SCENARIO_MAPPING_COMPLETED);
    message.publish(fullChannel,msgOut);
