function[wasSuccess,errMsg,returnIDs]=duplicateSignal(inArgStruct)





    signalIdsToCopy=inArgStruct.signalIdstoCopy;
    currentTreeOrderMax=inArgStruct.currentTreeOrderMax;
    fileName=inArgStruct.fileName;
    appInstanceID=inArgStruct.appInstanceID;
    baseMsg=inArgStruct.baseMsg;

    N=length(signalIdsToCopy);

    returnIDs=-1*ones(1,N);


    repoUtil=starepository.RepositoryUtility();


    repoManager=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);


    for k=1:N

        sigIDToCopy=signalIdsToCopy(k);

        parentSignalId=repoUtil.getParent(sigIDToCopy);


        if parentSignalId==0||strcmpi(parentSignalId,'input')

            allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);
            nScenarios=length(allScenario_IDS);
            namesCantBeUsed=cell(1,nScenarios);

            for kScenario=1:nScenarios
                namesCantBeUsed{kScenario}=repoUtil.getSignalLabel(allScenario_IDS(kScenario));
            end

        else


            meta=repoUtil.getMetaDataStructure(parentSignalId);
            if~strcmpi(meta.dataformat,'dataset')


                siblingIds=repoUtil.getChildrenIDsInSiblingOrder(parentSignalId);

                nSibling=length(siblingIds);
                namesCantBeUsed=cell(1,nSibling);

                for kSibling=1:nSibling
                    namesCantBeUsed{kSibling}=repoUtil.getSignalLabel(siblingIds(kSibling));
                end
            else

                namesCantBeUsed={};
            end
        end


        [wasSuccess,errMsg,returnIDs(k)]=Simulink.sta.editor.copySignal(sigIDToCopy,namesCantBeUsed,currentTreeOrderMax,fileName,appInstanceID,baseMsg,false,true);

        if~wasSuccess
            return;
        end

    end



    msgTopics=Simulink.sta.EditorTopics();
    allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);
    arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(double(allScenario_IDS),[],0);
    fullChannelPropUpdated=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.ITEM_PROP_UPDATE);
    message.publish(fullChannelPropUpdated,arrayOfProps);