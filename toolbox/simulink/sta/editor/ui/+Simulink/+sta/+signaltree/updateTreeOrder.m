function arrayOfProps=updateTreeOrder(scenarioIDs,sourceID,destID)





    arrayOfProps=[];


    idxSource=find(scenarioIDs==sourceID);


    idxTarget=find(scenarioIDs==destID);

    isSourceDS=~isempty(idxSource);
    isTargetDS=~isempty(idxTarget);

    if isSourceDS&&isTargetDS


        scenarioIDs(idxSource)=[];

        idx_front=find(scenarioIDs==destID);
        idx_end=idx_front+1;


        repoUtil=starepository.RepositoryUtility();
        sourceTreeOrder=getMetaDataByName(repoUtil,sourceID,'TreeOrder');
        targetTreeOrder=getMetaDataByName(repoUtil,destID,'TreeOrder');

        MOVE_DOWN=sourceTreeOrder<targetTreeOrder;
        MOVE_UP=sourceTreeOrder>targetTreeOrder;


        if MOVE_DOWN

            if idx_end<length(scenarioIDs)
                scenarioIDs=[scenarioIDs(1:idx_front)',sourceID,scenarioIDs(idx_end:length(scenarioIDs))'];
            else
                scenarioIDs=[scenarioIDs(1:idx_front)',sourceID];
            end

        else

            if idx_front-1>0

                scenarioIDs=[scenarioIDs(1:idx_front-1)',sourceID,scenarioIDs(idx_front:length(scenarioIDs))'];
            else
                scenarioIDs=[sourceID,scenarioIDs(1:length(scenarioIDs))'];
            end

        end



        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(scenarioIDs,[],0);
    end
