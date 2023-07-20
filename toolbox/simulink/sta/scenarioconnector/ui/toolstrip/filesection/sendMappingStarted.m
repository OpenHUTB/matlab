function sendMappingStarted(jsonStruct,appInstanceID)




    scenarioids=[];

    for kJson=1:length(jsonStruct)

        if strcmp(jsonStruct{kJson}.ParentID,'input')&&strcmp(jsonStruct{kJson}.Type,'DataSet')

            scenarioids=[scenarioids,jsonStruct{kJson}.ID];

        end


    end

    msgTopics=Simulink.sta.ScenarioTopics();

    msgOut.scenarioIds=scenarioids;


    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.SCENARIO_MAPPING_STARTED);
    message.publish(fullChannel,msgOut);
