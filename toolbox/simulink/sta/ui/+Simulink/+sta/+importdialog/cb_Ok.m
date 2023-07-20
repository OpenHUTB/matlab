function[was_successful,SDIrunID]=cb_Ok(State,appInstanceID)




    was_successful=false;%#ok<NASGU>


    aList=squeeze(State.selectedIndices);

    if(isequal(State.importFrom,'imMatFile')&&~isempty(State.matFile))

        fullFilePath=which(State.matFile);


        if isempty(fullFilePath)

            fullFilePath=State.matFile;
        end

        aFileObj=iofile.STAMatFile(fullFilePath);
    elseif(isequal(State.importFrom,'imBaseWorkspace'))

        aFileObj=iofile.BaseWorkspace();
    else

    end

    [jsonStruct,SDIrunID]=import2Repository(aFileObj,aList,State.startTreeOrder);

    was_successful=true;

    outdata.arrayOfListItems=jsonStruct;
    fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/UIModelData');
    message.publish(fullChannel,outdata);


    msgMap.filename=aFileObj.FileName;
    msgMap.runid=SDIrunID;

    theTopics=Simulink.sta.ScenarioTopics;
    fullChannel=sprintf('/sta%s/%s',appInstanceID,theTopics.SET_RUNID);
    message.publish(fullChannel,msgMap);


end
