function returnStruct=updateSignalDataMW(appInstanceID,sigName,rootSigID,sigID,interpMode,dataType,dataFromTable,isEnum,isFixDT,forceAxesRedraw,tableID)%#ok<INUSL>





    returnStruct=[];

    returnStruct.workingID=[];
    returnStruct.errorMessage=[];
    IS_INTEGRATING=true;%#ok<NASGU>

    msgTopics=Simulink.sta.EditorTopics();


    baseMsg='staeditor';





    IS_FCN_CALL_UPDATE=false;
    IS_COMPLEXITY_CHANGE=false;%#ok<NASGU>
    IS_DATA_TYPE_CHANGE=false;


    repoUtil=starepository.RepositoryUtility();


    if isFixDT

        for kRow=1:length(dataFromTable)

            for kCol=2:length(dataFromTable{kRow})

                dataFromTable{kRow}{kCol}=dataFromTable{kRow}{kCol}.value;

            end

        end

    end



    if isEnum

        dataType=getMetaDataByName(repoUtil,rootSigID,'EnumName');
        originalDataType=getMetaDataByName(repoUtil,rootSigID,'EnumName');


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
            return;
        end

        warnFlag=warning('query','MATLAB:class:InvalidEnum');
        warning('OFF','MATLAB:class:InvalidEnum');

        [~,dataValues]=getSignalTimeAndDataValues(repoUtil,sigID);
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
    else
        originalDataType=getMetaDataByName(repoUtil,rootSigID,'DataType');
    end


    dataFormat=getMetaDataByName(repoUtil,sigID,'dataformat');
    isDataArray=~isempty(strfind(dataFormat,'dataarray'));%#ok<NASGU,STREMP>

    signalType=getMetaDataByName(repoUtil,sigID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));


    if~WAS_REAL&&strcmpi(dataType,'boolean')

        errMsg=DAStudio.message('sl_sta_repository:sta_repository:nocomplexboolean');

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



    NUM_DATA_POINTS=length(dataFromTable);

    if iscell(dataFromTable)
        PAYLOAD_IS_CELL=true;
        NUM_FLAT_COLUMNS=length(dataFromTable{1});
    else
        PAYLOAD_IS_CELL=false;
        [~,NUM_FLAT_COLUMNS]=size(dataFromTable);
    end


    NUM_FLAT_DATA_COLUMNS=NUM_FLAT_COLUMNS-1;


    timeVals=zeros(NUM_DATA_POINTS,1);


    IS_STRING=false;
    if strcmpi(dataType,'string')
        IS_STRING=true;
        dataVals=repmat("",NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    elseif isEnum

        enumVals=enumeration(dataType);
        dataVals=repmat(enumVals(1),NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    else
        dataVals=zeros(NUM_DATA_POINTS,NUM_FLAT_DATA_COLUMNS);
    end

    if PAYLOAD_IS_CELL
        for kPoint=1:NUM_DATA_POINTS


            isCell=cellfun(@iscell,dataFromTable(kPoint));

            if isCell
                isChar=cellfun(@ischar,dataFromTable{kPoint});


                if IS_STRING||isEnum

                    isChar(2:end)=false;

                end

                if any(isChar)


                    idxOfChar=find(isChar==1);


                    for k=1:length(idxOfChar)


                        switch dataFromTable{kPoint}{idxOfChar(k)}


                        case 'Inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=Inf;


                        case 'inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=Inf;


                        case '-Inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=-Inf;


                        case '-inf'

                            dataFromTable{kPoint}{idxOfChar(k)}=-Inf;


                        case 'NaN'
                            dataFromTable{kPoint}{idxOfChar(k)}=NaN;


                        otherwise

                            idxNaNComplex=regexpi(dataFromTable{kPoint}{idxOfChar(k)},'\w*NaN[ij]$');
                            idxInfComplex=regexpi(dataFromTable{kPoint}{idxOfChar(k)},'\w*Inf[ij]$');

                            idxPlus=strfind(dataFromTable{kPoint}{idxOfChar(k)},'+');
                            idxMinus=strfind(dataFromTable{kPoint}{idxOfChar(k)},'-');

                            if~isempty(idxNaNComplex)

                                tableCellStr=dataFromTable{kPoint}{idxOfChar(k)};
                                tableRealVal=[];%#ok<NASGU>
                                if~isempty(idxPlus)
                                    tableRealVal=tableCellStr((1:idxPlus(end)-1));
                                else
                                    tableRealVal=tableCellStr((1:idxMinus(end)-1));
                                end
                                dataFromTable{kPoint}{idxOfChar(k)}=complex(str2num(tableRealVal),NaN);%#ok<ST2NM>

                            elseif~isempty(idxInfComplex)
                                tableCellStr=dataFromTable{kPoint}{idxOfChar(k)};
                                tableRealVal=[];%#ok<NASGU>
                                if~isempty(idxPlus)
                                    tableRealVal=tableCellStr((1:idxPlus(end)-1));
                                    complexVal=Inf;
                                else
                                    tableRealVal=tableCellStr((1:idxMinus(end)-1));
                                    complexVal=-Inf;
                                end
                                dataFromTable{kPoint}{idxOfChar(k)}=complex(str2num(tableRealVal),complexVal);%#ok<ST2NM>
                            else
                                dataFromTable{kPoint}{idxOfChar(k)}=str2num(dataFromTable{kPoint}{idxOfChar(k)});%#ok<ST2NM>
                            end
                        end

                    end

                end

            end

            if iscell(dataFromTable{kPoint})
                timeVals(kPoint)=dataFromTable{kPoint}{1};

                if IS_STRING
                    cellDataAsVector=dataFromTable{kPoint}(2:end);
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=string(cellDataAsVector);
                elseif isEnum
                    cellDataAsVector=dataFromTable{kPoint}(2:end);
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=cellfun(@eval,strcat([dataType,'.'],cellDataAsVector));
                else
                    cellDataAsVector=cell2mat(dataFromTable{kPoint}(2:end));
                    dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=cellDataAsVector(1:end);
                end


            else
                timeVals(kPoint)=dataFromTable{kPoint}(1);
                dataVals(kPoint,1:NUM_FLAT_DATA_COLUMNS)=dataFromTable{kPoint}(2:NUM_FLAT_COLUMNS);
            end
        end
    else
        timeVals=dataFromTable(:,1);
        dataVals=dataFromTable(:,2:end);
    end




    dataToSet.Time=timeVals;

    rootMetaData=repoUtil.getMetaDataStructure(rootSigID);

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

    dataToSet.Data=dataVals;

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(rootSigID);


    isSignalComplex=~isreal(dataVals)&&~isstring(dataVals);

    IS_COMPLEXITY_CHANGE=(isSignalComplex&&WAS_REAL)||(~WAS_REAL&&~isSignalComplex);

    if IS_COMPLEXITY_CHANGE


        tmpDataVals=reshape(dataVals,1,numel(dataVals));

        ALL_ZERO=all(tmpDataVals==0);

        if(~ALL_ZERO)

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
        else

            dataToSet.Data=complex(dataToSet.Data,dataToSet.Data);
        end
    end

    try
        editSignalData(concreteExtractor,rootSigID,sigID,dataType,dataToSet);

        authoringStruct.dataString='';
        authoringStruct.timeString='';

        repoUtil=starepository.RepositoryUtility();
        repoUtil.setMetaDataByName(rootSigID,'AuthoringInputs',authoringStruct)

        if~IS_FCN_CALL_UPDATE


            IS_DATA_TYPE_CHANGE=~strcmp(dataType,originalDataType);
        end

        if IS_FCN_CALL_UPDATE||...
            IS_COMPLEXITY_CHANGE||...
IS_DATA_TYPE_CHANGE


            setMetaDataByName(repoUtil,sigID,'IS_EDITED',1);
            setMetaDataByName(repoUtil,rootSigID,'IS_EDITED',1);
            oldestParent=repoUtil.getOldestRelative(rootSigID);
            setMetaDataByName(repoUtil,oldestParent,'IS_EDITED',1);
        end

    catch ME_EDIT %#ok<NASGU>

    end




    msgTopics=Simulink.sta.EditorTopics();

    fullChannel=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.SIGNAL_EDIT);%#ok<NASGU>
    fullChannelSigUpdated=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.ID_TO_REPORT);
    message.publish(fullChannelSigUpdated,sigID);



    msg.signaltime=dataToSet.Time;

    [NUM_POINTS,NUM_DATA_COL]=size(dataToSet.Data);
    msg.signaldata=cell(NUM_POINTS,NUM_DATA_COL);


    for kCol=1:NUM_DATA_COL

        msg.signaldata(:,kCol)=slwebwidgets.tableeditor.makeJsonSafe(dataToSet.Data(:,kCol));

        if isFixDT
            theFiType=dataToSet.Data.numerictype;
            for kCell=1:length(msg.signaldata(:,kCol))

                errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(dataPreCast(kCell,kCol),theFiType,rootMetaData.fiOverflowMode,rootMetaData.fiRoundMode);
                msg.signaldata{kCell,kCol}=slwebwidgets.tableeditor.messagemanager.MessageManager.makeFiDataTableStruct(double(dataPreCast(kCell,kCol)),dataToSet.Data(kCell,kCol),errorMeta);
            end
        end
    end

    msg.isdataarray=false;

    for k=1:length(msg.signaltime)

        msgOut.signaldatavalues{k}={msg.signaltime(k),msg.signaldata{k,:}};
    end

    tableTopics=slwebwidgets.tableeditor.TableViewTopics(appInstanceID,tableID);
    fullChannel=tableTopics.serverSideSignalUpdateTopic;
    message.publish(fullChannel,msgOut);

    if forceAxesRedraw
        fullChannel=sprintf('/staeditor%s/%s',appInstanceID,'force_axes_redraw');
        replotIDs=getPlottableSignalIDs(concreteExtractor,rootSigID);

        for k=1:length(replotIDs)
            msgOutRedraw.signalID=replotIDs(k);
            message.publish(fullChannel,msgOutRedraw);
        end
    end
