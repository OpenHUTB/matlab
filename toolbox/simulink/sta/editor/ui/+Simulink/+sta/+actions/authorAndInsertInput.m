function[newSignalID,parentIDToAssign]=authorAndInsertInput(authorStruct)





    msgTopics=Simulink.sta.EditorTopics();

    msgOut.spinnerID='insertsignal';
    msgOut.spinnerOn=true;

    uniqueAppID=authorStruct.appid;
    baseMessageChanel='staeditor';

    theScenarioID=authorStruct.scenarioid;

    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);





    if~isfield(authorStruct,'modelName')||isempty(authorStruct.modelName)
        [timeToUse,dataToUse]=Simulink.sta.editor.getTimeAndDataFromExpression(...
        authorStruct.timeEntry,authorStruct.dataEntry);
    else
        [timeToUse,dataToUse]=Simulink.sta.editor.getTimeAndDataFromExpression(...
        authorStruct.timeEntry,authorStruct.dataEntry,authorStruct.modelName);
    end

    dataToUse=slwebwidgets.doSLCast(dataToUse,authorStruct.dataTypeToUse);



    interpVal='linear';
    if isfield(authorStruct,'interpValue')
        interpVal=authorStruct.interpValue;
    end

    varToInsert=SignalEditorUtil.createSignalVariable(...
    authorStruct.objecttype,timeToUse,dataToUse,'',interpVal);


    parentIDToAssign=authorStruct.parentIDToAssign;


    if isempty(parentIDToAssign)
        parentIDToAssign=0;
    end


    aSigName=authorStruct.signalName;

    currentTreeOrderMax=authorStruct.currentTreeOrderMax;
    jsonStruct={};
    arrayOfProps=[];

    newSignalID=zeros(1,length(parentIDToAssign));
    for kParent=1:length(parentIDToAssign)

        if parentIDToAssign(kParent)==0
            aSigName=Simulink.sta.editor.uniqueSignalNameUnderInput(theScenarioID,aSigName);
        else

            aSigName=Simulink.sta.editor.uniqueSignalNameUnderSignal(parentIDToAssign(kParent),aSigName);

        end


        itemFactory=starepository.factory.createSignalItemFactory(aSigName,varToInsert);

        item=itemFactory.createSignalItem;

        if iscell(authorStruct.parentFullName)
            parentFullName=authorStruct.parentFullName{kParent};
        else
            parentFullName=authorStruct.parentFullName;
        end


        fileName=authorStruct.filename;


        [tmpJsonStruct,tmpArrayOfProps]=Simulink.sta.editor.createSignalInRepositoryUnderParent(...
        item,fileName,currentTreeOrderMax,theScenarioID,parentIDToAssign(kParent),parentFullName);

        newSignalID(kParent)=tmpJsonStruct{1}.ID;

        if isfield(tmpJsonStruct{1},'ComplexID')
            newSignalID(kParent)=tmpJsonStruct{1}.ComplexID;
        end


        authoringStruct.dataString=authorStruct.dataEntry;
        authoringStruct.timeString=authorStruct.timeEntry;
        authoringStruct.dataTypeString=authorStruct.dataTypeToUse;

        repoUtil=starepository.RepositoryUtility();
        repoUtil.setMetaDataByName(tmpJsonStruct{1}.ID,'AuthoringInputs',authoringStruct);

        if isfield(tmpJsonStruct{1},'ComplexID')
            repoUtil.setMetaDataByName(tmpJsonStruct{1}.ComplexID,'AuthoringInputs',authoringStruct);
        end

        currentTreeOrderMax=currentTreeOrderMax+length(tmpJsonStruct);
        if isempty(jsonStruct)
            jsonStruct=tmpJsonStruct;
        else
            newJson={jsonStruct{1,:},tmpJsonStruct{1,:}};
            jsonStruct=newJson;
        end

        if isempty(arrayOfProps)
            arrayOfProps=tmpArrayOfProps;
        else
            newArrayOfProps=[arrayOfProps,tmpArrayOfProps];
            arrayOfProps=newArrayOfProps;
        end
    end


    outdata.arrayOfListItems=jsonStruct;
    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SIGNAL_EDIT,outdata);
    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.ITEM_PROP_UPDATE,arrayOfProps);


    msgOut.spinnerID='insertsignal';
    msgOut.spinnerOn=false;
    Simulink.sta.publish.publishMessage(baseMessageChanel,uniqueAppID,msgTopics.SPINNER,msgOut);

end
