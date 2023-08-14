function outStruct=castSignal(signalInfo,varargin)




    outStruct.idToOriginalValues=[];
    outStruct.idToReplaceRootSignal=[];
    outStruct.idToReplaceWorkingSignal=[];
    outStruct.jsonStructOfReplacement={};
    outStruct.errorMessage=[];

    rootSigID=signalInfo.rootSigID;
    sigID=signalInfo.sigID;
    newDataType=starepository.DataTypeHelper.parseDataTypeStringForEnumeration(signalInfo.dataType);

    appInstanceID=signalInfo.appInstanceID;

    tableID=signalInfo.tableID;

    SEND_TABLE_DATA=true;

    if isfield(signalInfo,'SEND_TABLE_DATA')
        SEND_TABLE_DATA=signalInfo.SEND_TABLE_DATA;
    end


    repoUtil=starepository.RepositoryUtility();
    signalType=getMetaDataByName(repoUtil,sigID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(rootSigID);


    dataPrecast=getDataForSetByID(concreteExtractor,rootSigID);

    try
        byPassFiCheck=false;


        if isenum(dataPrecast.Data)

            try
                castedVals=slwebwidgets.doSLCast(double(dataPrecast.Data),newDataType);
            catch ME_ENUMPRECAST

                if strcmp(ME_ENUMPRECAST.identifier,'MATLAB:class:InvalidEnum')
                    byPassFiCheck=true;
                end

            end
        else
            try
                castedVals=slwebwidgets.doSLCast(dataPrecast.Data,newDataType);
            catch ME_CANTCONVERT



                if~isreal(dataPrecast.Data)&&strcmp(ME_CANTCONVERT.identifier,'MATLAB:class:InvalidEnum')
                    outStruct.errorMessage=DAStudio.message('sl_web_widgets:tableview:complexToEnum');
                    return;
                elseif(strcmp(ME_CANTCONVERT.identifier,...
                    'MATLAB:class:CannotConvert')&&...
                    isfi(dataPrecast.Data))||strcmp(ME_CANTCONVERT.identifier,'MATLAB:class:InvalidEnum')
                    byPassFiCheck=true;
                elseif strcmp(ME_CANTCONVERT.identifier,'MATLAB:nologicalcomplex')
                    outStruct.errorMessage=ME_CANTCONVERT.message;
                    return;
                end
            end
        end



        if~byPassFiCheck&&isfi(castedVals)

            if~strcmpi(newDataType,fixdt(castedVals.numerictype))

                newDataType=fixdt(castedVals.numerictype);
                outStruct.fullyspecifiedDataType=newDataType;

            end

        end
    catch ME_CAST_ERR

        outStruct.errorMessage=ME_CAST_ERR.message;
        return;
    end


    [signalIDToOriginalValues,jsonStructOfReplacement]=cast(concreteExtractor,rootSigID,WAS_REAL,newDataType);

    childrenIds=repoUtil.getChildrenIDsInSiblingOrder(signalIDToOriginalValues);
    if~isempty(childrenIds)
        signalIDToOriginalValues=[signalIDToOriginalValues,childrenIds];
    end

    outStruct.idToOriginalValues=signalIDToOriginalValues;

    if~isempty(jsonStructOfReplacement)
        outStruct.jsonStructOfReplacement=jsonStructOfReplacement;
        outStruct.idToReplaceRootSignal=jsonStructOfReplacement{1}.ID;
        outStruct.idToReplaceWorkingSignal=jsonStructOfReplacement{1}.ID;
        setMetaDataByName(repoUtil,jsonStructOfReplacement{1}.ID,'IS_EDITED',1);


        slwebwidgets.tableeditor.replaceSignalServerSide(rootSigID,jsonStructOfReplacement,appInstanceID);


    else
        setMetaDataByName(repoUtil,rootSigID,'IS_EDITED',1);
    end


    if isempty(varargin)

        if~SEND_TABLE_DATA
            return;
        end

        if isempty(jsonStructOfReplacement)


            fullChannel=sprintf('/staeditor%s/%s',appInstanceID,'item/propertyupdate');
            replotIDs=getIDsForPropertyUpdates(concreteExtractor,rootSigID);
            itemPropertyUpdates=cell(size(replotIDs));

            for k=1:length(replotIDs)
                itemPropertyUpdates{k}.id=replotIDs(k);
                itemPropertyUpdates{k}.propertyname='DataType';
                itemPropertyUpdates{k}.newValue=newDataType;
            end

            message.publish(fullChannel,itemPropertyUpdates);

        end

        idxForFixdtProps=rootSigID;
        if~isempty(jsonStructOfReplacement)

            idxForFixdtProps=outStruct.idToReplaceRootSignal;


            aValue=getADataValue(concreteExtractor,outStruct.idToReplaceRootSignal);

            dataInfo.dataToSet=dataPrecast;
            dataInfo.isFixDT=isfi(aValue);

            if isenum(dataInfo.dataToSet.Data)&&dataInfo.isFixDT


                dataPrecast.Data=double(dataPrecast.Data);
                dataInfo.dataToSet.Data=double(dataInfo.dataToSet.Data);
            end
        else

            aValue=getADataValue(concreteExtractor,rootSigID);

            dataInfo.dataToSet=dataPrecast;
            dataInfo.isFixDT=isfi(aValue);
        end

        if dataInfo.isFixDT
            dataInfo.dataToSet=dataPrecast;
            dataInfo.numericTypeValue=aValue.numerictype;
            dataInfo.rootMetaData.fiOverflowMode=getMetaDataByName(concreteExtractor,idxForFixdtProps,'fiOverflowMode');
            dataInfo.rootMetaData.fiRoundMode=getMetaDataByName(concreteExtractor,idxForFixdtProps,'fiRoundMode');
        else
            dataInfo.dataToSet=getDataForSetByID(concreteExtractor,rootSigID);
        end

        if isempty(jsonStructOfReplacement)
            dataInfo.rootSigID=rootSigID;
        else
            dataInfo.rootSigID=jsonStructOfReplacement{1}.ID;
            enumDataPostSet=getDataForSetByID(concreteExtractor,dataInfo.rootSigID);
            dataInfo.dataToSet=enumDataPostSet;
        end
        dataInfo.tableID=tableID;
        slwebwidgets.tableeditor.publishTableUpdate(appInstanceID,dataInfo);

        return;

    end


    idToOriginalValues=varargin{1};

    setDataByID(concreteExtractor,rootSigID,idToOriginalValues);


    fullChannel=sprintf('/staeditor%s/%s',appInstanceID,'force_axes_redraw');

    replotIDs=getPlottableSignalIDs(concreteExtractor,rootSigID);

    for k=1:length(replotIDs)
        msgOutRedraw.signalID=replotIDs(k);
        message.publish(fullChannel,msgOutRedraw);
    end

    dataPostSet=getDataForSetByID(concreteExtractor,rootSigID);


    aValue=getADataValue(concreteExtractor,rootSigID);

    dataInfo.dataToSet=dataPostSet;

    dataInfo.isFixDT=isfi(aValue);

    if dataInfo.isFixDT
        dataInfo.dataToSet=dataPrecast;
        dataInfo.numericTypeValue=aValue.numerictype;
        dataInfo.rootMetaData.fiOverflowMode=getMetaDataByName(concreteExtractor,rootSigID,'fiOverflowMode');
        dataInfo.rootMetaData.fiRoundMode=getMetaDataByName(concreteExtractor,rootSigID,'fiRoundMode');
    end
    dataInfo.rootSigID=rootSigID;
    dataInfo.tableID=tableID;
    slwebwidgets.tableeditor.publishTableUpdate(appInstanceID,dataInfo);
