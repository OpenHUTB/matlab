function outStructCastAndReauthor=castAndReauthorSignal(msgIn,varargin)




    signalInfo=msgIn.signalInfoForCast;

    builtinDataTypeStrings=slwebwidgets.BuiltInSlDataTypes.getDataTypeStrings;

    tableID=msgIn.tableID;


    dataTypeString=signalInfo.dataType;
    PRE_FI_OVERRIDE=false;


    if~any(strcmp(builtinDataTypeStrings,...
        dataTypeString))&&isempty(enumeration(dataTypeString))

        dTObject=eval(dataTypeString);
        if any(strcmp(class(dTObject),{'Simulink.NumericType','embedded.numerictype'}))

            [~,dataValsToCast]=slwebwidgets.author.getTimeAndDataFromExpression(...
            msgIn.infoForReauthor.timeEntry,msgIn.infoForReauthor.dataEntry);

            castedDataVals=fi(dataValsToCast,dTObject);

            if~strcmpi(dataTypeString,fixdt(castedDataVals.numerictype))
                signalInfo.dataType=fixdt(castedDataVals.numerictype);
                msgIn.infoForReauthor.dataTypeToUse=signalInfo.dataType;
                PRE_FI_OVERRIDE=true;
            end
        end

    end

    signalInfo.tableID=tableID;

    outStructCast=slwebwidgets.tableeditor.castSignal(signalInfo,varargin{:});

    reauthorInfo=msgIn.infoForReauthor;


    if~isempty(outStructCast.idToReplaceRootSignal)
        reauthorInfo.rootSignalID=outStructCast.idToReplaceRootSignal;
        reauthorInfo.signalID=outStructCast.idToReplaceWorkingSignal;
    end

    if isfield(outStructCast,'fullyspecifiedDataType')
        reauthorInfo.dataTypeToUse=outStructCast.fullyspecifiedDataType;
    end

    if PRE_FI_OVERRIDE
        outStructCast.fullyspecifiedDataType=reauthorInfo.dataTypeToUse;
    end


    reauthorInfo.tableID=tableID;
    outStructReauthor=slwebwidgets.author.reauthorSignal(reauthorInfo);%#ok<NASGU>


    outStructCastAndReauthor=outStructCast;
