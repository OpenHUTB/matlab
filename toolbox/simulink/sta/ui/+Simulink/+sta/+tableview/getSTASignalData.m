function msg=getSTASignalData(signalID,appID)


    tableTopics=Simulink.sta.tableview.TableViewTopics(appID);


    repoUtil=starepository.RepositoryUtility();


    eng=sdi.Repository(true);


    complexStr=getMetaDataByName(repoUtil,signalID,'SignalType');
    dataFormat=getMetaDataByName(repoUtil,signalID,'dataformat');


    isFcnCall=~isempty(strfind(dataFormat,'functioncall'));
    isDataArray=~isempty(strfind(dataFormat,'dataarray'));

    dataType=getMetaDataByName(repoUtil,signalID,'EnumName');

    IS_ENUM=false;
    if~isempty(dataType)
        IS_ENUM=true;
    end


    if isFcnCall


        [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,signalID);


        uniqueVals=unique(dataValues);
        newDataVals=zeros(length(uniqueVals),1);


        for k=1:length(uniqueVals)

            sumOfTimeVal=cumsum(dataValues==uniqueVals(k));

            newDataVals(k)=sumOfTimeVal(end);

        end

        timeValues=uniqueVals;
        dataValues=newDataVals;


        msg.signaltime=Simulink.sta.tableview.makeJsonSafe(timeValues);
        msg.signaldata=Simulink.sta.tableview.makeJsonSafe(dataValues);
        msg.isdataarray=false;


    elseif isDataArray


        childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,signalID);


        [timeValues,dataValues]=getSignalTimeAndDataValues(...
        repoUtil,childIDsInOrder(1));


        msg.signaltime=Simulink.sta.tableview.makeJsonSafe(timeValues);
        msg.signaldata0=Simulink.sta.tableview.makeJsonSafe(dataValues);

        for k=1:length(childIDsInOrder)-1

            [~,dataValues]=getSignalTimeAndDataValues(...
            repoUtil,childIDsInOrder(k+1));

            msg.(['signaldata',num2str(k)])=Simulink.sta.tableview.makeJsonSafe(dataValues);
        end
        msg.isdataarray=true;
        msg.numcolumns=length(childIDsInOrder);



    else
        warnFlag=warning('query','MATLAB:class:InvalidEnum');
        warning('OFF','MATLAB:class:InvalidEnum');

        if strcmpi(complexStr,DAStudio.message('sl_sta_general:common:Complex'))

            parentID=eng.getSignalParent(signalID);
            [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,parentID);
        else

            [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,signalID);
        end
        warning(warnFlag.state,'MATLAB:class:InvalidEnum');

        IS_ENUM_VALS=isenum(dataValues);
        if IS_ENUM_VALS

            dataValues=int32(dataValues);
        elseif IS_ENUM&&~IS_ENUM_VALS

            fullChannel=sprintf('/staeditor%s/%s',appID,tableTopics.REPORT_TABLE_ERROR);
            errMsg.closeTableView=true;
            errMsg.errorMessage=DAStudio.message('sl_sta:editor:enumModified',dataType);
            message.publish(fullChannel,errMsg);
            msg.signaltime=[];
            msg.signaldata=[];
            msg.isdataarray=[];
            msg.id=[];
            msg.order=[];
            return;
        end


        msg.signaltime=Simulink.sta.tableview.makeJsonSafe(timeValues);
        msg.signaldata=Simulink.sta.tableview.makeJsonSafe(dataValues);
        msg.isdataarray=false;

    end



    msg.id=0:(length(dataValues)-1);
    msg.order=0:(length(dataValues)-1);



    if isfield(msg,'signaldata')&&isstring(msg.signaldata{1})

        for kStr=1:length(msg.signaldata)

            msg.signaldata{kStr}=char(msg.signaldata{kStr});

        end

    end

    fullChannel=tableTopics.serverSideSignalUpdateTopic;
    message.publish(fullChannel,msg);

end


