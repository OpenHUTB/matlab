function[newSignalID,parentID,jsonStruct,arrayOfProps]=pasteInput(pasteStruct)




    if isfield(pasteStruct,'publishmessages')
        publishmessages=pasteStruct.publishmessages;
    else
        publishmessages=true;
    end


    msgTopics=Simulink.sta.EditorTopics();

    uniqueAppID=pasteStruct.appid;

    baseMessageChanel='staeditor';


    msgOut.spinnerID='insertsignal';
    msgOut.spinnerOn=true;

    if publishmessages
        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);
    end

    msgOut.spinnerOn=false;

    scenarioID=pasteStruct.scenarioID;
    sigIDToCopy=pasteStruct.clipBoardID;
    signalIDToInsertInto=pasteStruct.selectedID;







    nCopyIds=length(sigIDToCopy);
    nParentIds=length(signalIDToInsertInto);
    NPastedSignals=nCopyIds*nParentIds;

    allJsons=cell(1,NPastedSignals);
    allProps=cell(1,NPastedSignals);
    newSignalID=-1*ones(1,NPastedSignals);
    parentID=cell(1,NPastedSignals);
    currentCount=1;
    for kSigID=1:nCopyIds
        for kParent=1:nParentIds

            if currentCount==NPastedSignals
                isreorder=true;
            else
                isreorder=false;
            end
            [allJsons{currentCount},allProps{currentCount}]=Simulink.sta.editor.copyAndPaste(scenarioID,...
            sigIDToCopy(kSigID),signalIDToInsertInto(kParent),isreorder);

            newSignalID(currentCount)=allJsons{currentCount}{1}.ID;

            if isfield(allJsons{currentCount}{1},'ComplexID')
                newSignalID=allJsons{currentCount}{1}.ComplexID;
            end

            parentID{currentCount}=allJsons{currentCount}{1}.ParentID;
            currentCount=currentCount+1;
        end
    end

    jsonStruct=[allJsons{:}];
    arrayOfProps=[allProps{:}];
    outdata.arrayOfListItems=jsonStruct;


    if publishmessages
        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SIGNAL_EDIT,outdata);


        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.ITEM_PROP_UPDATE,arrayOfProps);


        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);
    end

end

