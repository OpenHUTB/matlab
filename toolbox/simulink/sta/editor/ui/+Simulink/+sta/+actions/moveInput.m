function arrayOfProps=moveInput(moveStruct)




    msgTopics=Simulink.sta.EditorTopics();



    msgOut.spinnerID='move_signal';
    msgOut.spinnerOn=true;

    baseMessageChanel='staeditor';
    uniqueAppID=moveStruct.appid;
    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);


    msgOut.spinnerOn=false;
    nSignals=length(moveStruct.selected_id);
    tmpArrayOfProps=cell(1,nSignals);
    for k=1:nSignals
        tmpArrayOfProps{k}=Simulink.sta.signaltree.moveItem(moveStruct.selected_id(k),...
        moveStruct.MOVE_UP,'',uniqueAppID);
    end

    arrayOfProps=tmpArrayOfProps{end};



    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.ITEM_PROP_UPDATE,arrayOfProps);
    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);

end
