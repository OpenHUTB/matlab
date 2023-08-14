function newSignalID=insertInput(insertStruct)




    newSignalID=[];


    msgTopics=Simulink.sta.EditorTopics();
    uniqueAppID=insertStruct.appid;

    baseMessageChanel='staeditor';


    msgOut.spinnerID='insertsignal';
    msgOut.spinnerOn=true;

    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);
    msgOut.spinnerOn=false;

    [jsonStruct,arrayOfProps,errMsg]=Simulink.sta.editor.insertSignal(insertStruct);

    if~isempty(errMsg)


        Simulink.sta.publish.throwErrorDialog(baseMessageChanel,uniqueAppID,'sl_sta_general:common:Error',errMsg);


        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);

        return;

    end


    if~isempty(jsonStruct)
        count=1;


        if isempty(insertStruct.parentIDToAssign)
            newSignalID=0;
        else
            newSignalID=zeros(1,length(insertStruct.parentIDToAssign));
        end

        for kItem=1:length(jsonStruct)
            if strcmpi(jsonStruct{kItem}.ParentID,'input')||any(insertStruct.parentIDToAssign==jsonStruct{kItem}.ParentID)



                if strcmp(jsonStruct{kItem}.Type,'ComplexTimeSeries')

                    newSignalID(count)=jsonStruct{kItem}.ComplexID;%#ok<AGROW>
                else

                    newSignalID(count)=jsonStruct{kItem}.ID;%#ok<AGROW>

                end
                count=count+1;
            end
        end


        msgTopics=Simulink.sta.EditorTopics();
        outdata.arrayOfListItems=jsonStruct;

        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SIGNAL_EDIT,outdata);
        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.ITEM_PROP_UPDATE,arrayOfProps);


        msgOut.spinnerID='insertsignal';
        msgOut.spinnerOn=false;
        Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);
    end
end
