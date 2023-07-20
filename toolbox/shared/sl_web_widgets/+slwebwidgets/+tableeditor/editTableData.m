function[wasSuccessful,errMsg]=editTableData(signalID,timesToRemove,dataValuesToKeep,varargin)















    errMsg='';
    wasSuccessful=false;

    repoUtil=starepository.RepositoryUtility();

    appInstanceID=varargin{1};

    [mRows,nCols]=size(timesToRemove);


    if iscell(timesToRemove)

        timesToRemoveTemp=zeros(mRows,1);

        for kTime=1:length(timesToRemoveTemp)

            if ischar(timesToRemove{kTime})

                timesToRemoveTemp(kTime)=str2double(timesToRemove{kTime});
            else
                timesToRemoveTemp(kTime)=timesToRemove{kTime};
            end

        end
        timesToRemove=timesToRemoveTemp;
    end



    try

        if~isempty(dataValuesToKeep)

            baseMsg='staeditor';
            msgTopics=Simulink.sta.EditorTopics();


            if dataValuesToKeep.isEnum

                dataType=getMetaDataByName(repoUtil,signalID,'EnumName');



                whichEnum=which(dataType);

                if isempty(whichEnum)
                    returnStruct.errorMessage=DAStudio.message('sl_sta:editor:enumNotOnPath',dataType);

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.DIAGNOSTICS_DLG);
                    slwebwidgets.errordlgweb(fullChannel,...
                    'sl_sta_general:common:Error',...
                    returnStruct.errorMessage);

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.SPINNER);
                    msgOut.spinnerID='TableViewRequestSpinner';
                    msgOut.spinnerOn=false;
                    message.publish(fullChannel,msgOut);


                    fullChannel_rollback=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.ROLL_BACK_WORK_AREA_ACTION);
                    msgoutRollback.errMsg=returnStruct.errorMessage;
                    message.publish(fullChannel_rollback,msgoutRollback);
                    return;
                end

                warnFlag=warning('query','MATLAB:class:InvalidEnum');
                warning('OFF','MATLAB:class:InvalidEnum');

                [~,dataValues]=getSignalTimeAndDataValues(repoUtil,dataValuesToKeep.channelID);
                warning(warnFlag.state,'MATLAB:class:InvalidEnum');

                if~isenum(dataValues)
                    returnStruct.errorMessage=DAStudio.message('sl_sta:editor:enumModified',dataType);

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.DIAGNOSTICS_DLG);
                    slwebwidgets.errordlgweb(fullChannel,...
                    'sl_sta_general:common:Error',...
                    returnStruct.errorMessage);

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.SPINNER);
                    msgOut.spinnerID='TableViewRequestSpinner';
                    msgOut.spinnerOn=false;
                    message.publish(fullChannel,msgOut);



                    fullChannel_rollback=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.ROLL_BACK_WORK_AREA_ACTION);
                    msgoutRollback.errMsg=returnStruct.errorMessage;
                    message.publish(fullChannel_rollback,msgoutRollback);
                    return;
                end
            end

            [timeVals,dataVals]=slwebwidgets.tableeditor.convertClientSideDataToTimeAndData(dataValuesToKeep.dataValuesToKeep,dataValuesToKeep.dataType,dataValuesToKeep.isEnum,dataValuesToKeep.isFixDT);



            signalType=getMetaDataByName(repoUtil,signalID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));


            isSignalComplex=~isreal(dataVals)&&~isstring(dataVals);

            IS_COMPLEXITY_CHANGE=(isSignalComplex&&WAS_REAL)||(~WAS_REAL&&~isSignalComplex);

            if IS_COMPLEXITY_CHANGE


                tmpDataVals=reshape(dataVals,1,numel(dataVals));

                ALL_ZERO=all(tmpDataVals==0);

                if(~ALL_ZERO)

                    if~WAS_REAL



                        dataVals=complex(dataVals,0);
                    else


                        errMsg=DAStudio.message('sl_sta:editor:changeSignalType');

                        fullChannel=sprintf('/%s%s/%s',baseMsg,...
                        appInstanceID,...
                        msgTopics.DIAGNOSTICS_DLG);
                        slwebwidgets.errordlgweb(fullChannel,...
                        'sl_sta_general:common:Error',...
                        errMsg);

                        fullChannel=sprintf('/%s%s/%s',baseMsg,...
                        appInstanceID,...
                        msgTopics.SPINNER);
                        msgOut.spinnerID='TableViewRequestSpinner';
                        msgOut.spinnerOn=false;
                        message.publish(fullChannel,msgOut);


                        fullChannel_rollback=sprintf('/%s%s/%s',baseMsg,...
                        appInstanceID,...
                        msgTopics.ROLL_BACK_WORK_AREA_ACTION);
                        msgoutRollback.errMsg=errMsg;
                        message.publish(fullChannel_rollback,msgoutRollback);

                        return;
                    end
                else


                    dataVals=complex(dataVals,dataVals);
                end
            end

            dataType=dataValuesToKeep.dataType;
            [mRows,nCols]=size(dataVals);

            rootMetaData=repoUtil.getMetaDataStructure(signalID);
            if contains(dataType,'fixdt')
                dataPreCast=dataVals;


                dataVals=slwebwidgets.doSLCast(dataVals,rootMetaData.numerictype);
            else

                dataCastFcn=str2func(dataType);

                try



                    dataVals=dataCastFcn(dataVals);
                catch ME_CAST
                    returnStruct.errorMessage=ME_CAST.message;

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.DIAGNOSTICS_DLG);
                    slwebwidgets.errordlgweb(fullChannel,...
                    'sl_sta_general:common:Error',...
                    returnStruct.errorMessage);

                    fullChannel=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.SPINNER);
                    msgOut.spinnerID='TableViewRequestSpinner';
                    msgOut.spinnerOn=false;
                    message.publish(fullChannel,msgOut);


                    fullChannel_rollback=sprintf('/%s%s/%s',baseMsg,...
                    appInstanceID,...
                    msgTopics.ROLL_BACK_WORK_AREA_ACTION);
                    msgoutRollback.errMsg=returnStruct.errorMessage;
                    message.publish(fullChannel_rollback,msgoutRollback);

                    return;
                end
            end



        end
    catch ME
        errMsg=ME.message;
        return;
    end


    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(signalID);
    concreteExtractor.removeDataPointByTime(signalID,timesToRemove);





    if~isempty(dataValuesToKeep)
        for kRow=1:mRows

            if isa(concreteExtractor,'starepository.repositorysignal.FunctionCall')



                for kFcnCallEventNum=1:dataVals(kRow)
                    addDataPointByTime(concreteExtractor,signalID,timeVals(kRow),timeVals(kRow));
                end
            else

                addDataPointByTime(concreteExtractor,signalID,timeVals(kRow),dataVals(kRow,1:end));
            end


        end
    end


    authoringStruct.dataString='';
    authoringStruct.timeString='';
    repoUtil.setMetaDataByName(signalID,'AuthoringInputs',authoringStruct);



    wasSuccessful=true;
    fullChannel=sprintf('/staeditor%s/%s',appInstanceID,'force_axes_redraw');

    replotIDs=getPlottableSignalIDs(concreteExtractor,signalID);
    for k=1:length(replotIDs)
        msgOutRedraw.signalID=replotIDs(k);
        message.publish(fullChannel,msgOutRedraw);
    end
