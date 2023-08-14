function[was_successful_struct,topLevelIDs]=cb_Ok(State,appInstanceID)






    was_successful_struct.was_successful=false;
    was_successful_struct.errMsg='';

    outdata=[];
    outdataStruct.outdata=outdata;


    if strcmp(State.importFrom,'imBaseWorkspace')

        aList=squeeze(State.selectedIndices);

        if~isempty(aList)

            singalsInBaseWS_ToSave={aList(:).name};

            [~,~,fileExt]=fileparts(State.matFile);

            if isempty(fileExt)||~strcmpi(fileExt,'.mat')
                State.matFile=[State.matFile,'.mat'];
            end

            signalNamesIn=cell(1,length(singalsInBaseWS_ToSave));
            varsOfSignals=[];

            for k=1:length(singalsInBaseWS_ToSave)
                signalNamesIn{k}=singalsInBaseWS_ToSave{k};
                varsOfSignals=[varsOfSignals,' ',singalsInBaseWS_ToSave{k}];
            end

            try


                for kSLDV=1:length(State.filemetrics.SLDVVarNames)

                    sldvVAR_Name=State.filemetrics.SLDVVarNames{kSLDV};
                    sldvVAR=evalin('base',sldvVAR_Name);
                    if isSLDVTestVector(sldvVAR)
                        for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                            sldvDS=sldvsimdata(sldvVAR,kIndex);

                            sldvTestVectorName=[sldvVAR_Name,num2str(kIndex)];

                            assignin('base',sldvTestVectorName,sldvDS);
                        end
                    end
                end

                if State.convertToSLDS
                    [~,dsNameOnFile,~]=fileparts(State.matFile);

                    signalsIn=evalin('base',['{',varsOfSignals,'}']);
                    [aStructToSave,newName,DID_NEED_CONVERSION]=...
                    convertSignalsToDataset(signalsIn,signalNamesIn,dsNameOnFile,State.namesInUse);


                    if DID_NEED_CONVERSION

                        State.selectedIndices(end+1).name=newName;
                        State.selectedIndices(end).children='all';

                        allSigNalsAvailable=fieldnames(aStructToSave);
                        listBeforeConvert={State.selectedIndices(:).name};

                        [isAvailable,~]=ismember(listBeforeConvert,allSigNalsAvailable);

                        State.selectedIndices(~isAvailable)=[];
                    end
                end

            catch ME


                for kSLDV=1:length(State.filemetrics.SLDVVarNames)
                    for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                        evalin('base',['clear ',State.filemetrics.SLDVTransformedNames{kSLDV}{kIndex}]);
                    end
                end

                was_successful_struct.errMsg=DAStudio.message('sl_sta:scenarioconnector:baseimportfilenowrite',State.matFile);
                return;
            end


            for kSLDV=1:length(State.filemetrics.SLDVVarNames)
                for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                    evalin('base',['clear ',State.filemetrics.SLDVTransformedNames{kSLDV}{kIndex}]);
                end
            end


            State.importFrom='imMatFile';
        end
    end

    was_successful=false;%#ok<NASGU>

    aFileObj=iofile.Variable();
    aFileObj.inMemStruct=aStructToSave;

    varNames=fieldnames(aStructToSave);
    for k=1:length(varNames)
        aList(k).name=varNames{k};
        aList(k).children='all';
        aList(k).id=num2str(k);
    end

    jsonStruct=import2Repository(aFileObj,aList,State.startTreeOrder);

    msgTopics=Simulink.sta.EditorTopics();


    repoMgr=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoMgr,appInstanceID);
    theScenarioRepoItem=sta.Scenario(scenarioID);
    topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);

    eng=sdi.Repository(true);
    eng.safeTransaction(@initExternalSources,...
    jsonStruct,...
    scenarioID);

    arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(double(topLevelSignalIDs),[],0);


    for kSig=1:length(arrayOfProps)


        for kJson=1:length(jsonStruct)


            if(arrayOfProps(kSig).id==jsonStruct{kJson}.ID)


                jsonStruct{kJson}.(arrayOfProps(kSig).propertyname)=...
                arrayOfProps(kSig).newValue;
                break;
            end

        end

    end

    outdata.arrayOfListItems=jsonStruct;

    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.SIGNAL_EDIT);
    message.publish(fullChannel,outdata);

    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.ITEM_PROP_UPDATE);
    message.publish(fullChannel,arrayOfProps);

    was_successful_struct.was_successful=true;
    topLevelIDs=[];
    for k=1:length(jsonStruct)

        if ischar(jsonStruct{k}.ParentID)&&...
            strcmpi(jsonStruct{k}.ParentID,'input')

            topLevelIDs(length(topLevelIDs)+1)=jsonStruct{k}.ID;%#ok<AGROW>

        end

    end

end

