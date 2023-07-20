function[errMsgStruct,signalProperties]=qualifyAuthoredSignal(authoredProperties,varargin)




    errMsgStruct=[];
    errMsgStruct.errorTime=[];
    errMsgStruct.errorData=[];
    errMsgStruct.errorConsistency=[];
    errMsgStruct.warnDataTypeConversion=[];

    signalProperties.numSamples='';
    signalProperties.dataType='';
    signalProperties.dimensions='';
    signalProperties.signalType='';

    signalProperties.dimensionsFromRepo='';
    signalProperties.signalTypeFromRepo='';

    signalProperties.proposedDataType='';

    signalProperties.IS_1D=true;
    signalProperties.IS_SCALAR=true;




    if strcmpi(authoredProperties.dataTypeToUse,'logical')
        authoredProperties.dataTypeToUse='boolean';
    end

    try
        timeVal=eval(authoredProperties.timeToUse);
    catch ME_TIME %#ok<NASGU>

        try
            timeVal=evalin('base',authoredProperties.timeToUse);

        catch ME_EVAL_TIME %#ok<NASGU>

            try
                timeVal=slwebwidgets.tableeditor.evalinSimulink(authoredProperties.modelName,authoredProperties.timeToUse);
            catch ME_EVAL_TIME_SL %#ok<NASGU> 
                errMsgStruct.errorTime=DAStudio.message('sl_web_widgets:authorinsert:qualifyTimeNonDoubleScalar');
            end

        end
    end

    if isempty(errMsgStruct.errorTime)
        timeVal=slwebwidgets.AuthorUtility.formatTimeValues(timeVal);

        IS_TIMETABLE=false;
        if~isempty(varargin)
            repoUtil=starepository.RepositoryUtility;
            dataformat=getMetaDataByName(repoUtil,varargin{1},'dataformat');
            if contains(dataformat,'timetable')
                IS_TIMETABLE=true;
            end
        end

        if~IS_TIMETABLE
            errMsgStruct.errorTime=slwebwidgets.AuthorUtility.qualifyTimeValue(timeVal);
        else
            errMsgStruct.errorTime=slwebwidgets.AuthorUtility.qualifyTimeTableTimeValue(timeVal);
        end

        signalProperties.numSamples=num2str(length(timeVal));
    end



    try
        dataValb4_Cast=eval(authoredProperties.dataToUse);
    catch ME_DATA %#ok<NASGU>
        try
            dataValb4_Cast=evalin('base',authoredProperties.dataToUse);
        catch ME_EVAL_DATA %#ok<NASGU>

            try
                dataValb4_Cast=slwebwidgets.tableeditor.evalinSimulink(authoredProperties.modelName,authoredProperties.dataToUse);
            catch ME_EVAL_DATA_SL %#ok<NASGU> 

                errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:qualifyDataNonSimulinkSupport');

                return;
            end
        end
    end

    try

        authoredProperties.dataTypeToUse=starepository.DataTypeHelper.parseDataTypeStringForEnumeration(authoredProperties.dataTypeToUse);

        if strcmpi(authoredProperties.dataTypeToUse,'fcn_call')
            dataVal=double(slwebwidgets.doSLCast(dataValb4_Cast,'int32'));
        else
            dataVal=slwebwidgets.doSLCast(dataValb4_Cast,authoredProperties.dataTypeToUse);
        end



    catch ME_ASSIGN_DATATYPE

        if strcmpi(ME_ASSIGN_DATATYPE.identifier,'MATLAB:class:InvalidEnum')
            errMsgStruct.errorData=ME_ASSIGN_DATATYPE.message;
            return;
        end


        if strcmp(ME_ASSIGN_DATATYPE.identifier,'sl_web_widgets:authorinsert:qualifyDataNonSimulinkSupport')||...
            strcmp(ME_ASSIGN_DATATYPE.identifier,'fixed:fi:licenseCheckoutFailed')
            errMsgStruct.errorData=ME_ASSIGN_DATATYPE.message;
        else
            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:invalidCast');
        end
        return;

    end

    dataVal=slwebwidgets.AuthorUtility.formatDataValues(dataVal);
    errMsgStruct.errorData=slwebwidgets.AuthorUtility.qualifyDataValue(dataVal);
    signalProperties.dataType=class(dataVal);

    if isfi(dataVal)
        signalProperties.dataType=fixdt(dataVal.numerictype);
    end

    if strcmpi(signalProperties.dataType,'logical')

        signalProperties.dataType='boolean';
    elseif isfi(dataVal)
        signalProperties.dataType=fixdt(dataVal.numerictype);
    end

    if~isempty(errMsgStruct.errorTime)||~isempty(errMsgStruct.errorData)
        return;
    end



    if isempty(varargin)
        [signalProperties,errMsgStruct]=slwebwidgets.AuthorUtility.qualifyAuthoredTimeseries(dataVal,timeVal,errMsgStruct);

        if isfi(dataVal)&&isempty(errMsgStruct.errorConsistency)
            [dataTypeProposal,binaryScalingProposal,slopeNBiasScalingProposal]=slwebwidgets.AuthorUtility.proposeDataTypeAllScaling(dataValb4_Cast,eval(authoredProperties.dataTypeToUse));

            if~isempty(dataTypeProposal)
                signalProperties.proposedDataType=dataTypeProposal;
                signalProperties.proposedBinaryScaleDataType=binaryScalingProposal;
                signalProperties.proposedSlopeNBiasDataType=slopeNBiasScalingProposal;
            end

        end


    else


        sigID=varargin{1};

        repoUtil=starepository.RepositoryUtility;


        signalType=getMetaDataByName(repoUtil,sigID,'SignalType');
        WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));



        currentDataType=getMetaDataByName(repoUtil,sigID,'DataType');

        dataformat=getMetaDataByName(repoUtil,sigID,'dataformat');

        currentDimensions=getMetaDataByName(repoUtil,sigID,'Dimension');

        if WAS_REAL
            signalProperties.signalTypeFromRepo=DAStudio.message('sl_sta_general:common:Real');
        else
            signalProperties.signalTypeFromRepo=DAStudio.message('sl_sta_general:common:Complex');
        end
        signalProperties.dimensionsFromRepo=currentDimensions;


        REPO_IS_FIXED_PT=getMetaDataByName(repoUtil,sigID,'isFixDT');

        if isempty(REPO_IS_FIXED_PT)
            REPO_IS_FIXED_PT=false;
        end

        REPO_IS_STRING=strcmp(currentDataType,'string');

        REPO_IS_ENUM=getMetaDataByName(repoUtil,sigID,'isEnum');
        REPO_IS_BUILTIN=(~REPO_IS_FIXED_PT&&~REPO_IS_ENUM&&~REPO_IS_STRING);

        if(REPO_IS_STRING&&~isa(dataVal,'string'))||(REPO_IS_BUILTIN&&isa(dataVal,'string'))
            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:stringDataCannotCast');
            return;
        end


        if contains(dataformat,'timeseries')
            [signalProperties,errMsgStruct]=slwebwidgets.AuthorUtility.qualifyAuthoredTimeseries(dataVal,timeVal,errMsgStruct);



            if~isempty(errMsgStruct.errorConsistency)
                return;
            end
        elseif contains(dataformat,'dataarray')
            [signalProperties,errMsgStruct]=slwebwidgets.AuthorUtility.qualifyAuthoredDataArray(dataVal,timeVal,errMsgStruct);

            if~isempty(errMsgStruct.errorConsistency)||...
                ~isempty(errMsgStruct.errorData)||...
                ~isempty(errMsgStruct.errorTime)
                return;
            end
        elseif contains(dataformat,'timetable')
            errMsgStruct.errorTime=slwebwidgets.AuthorUtility.qualifyTimeTableTimeValue(timeVal);
            [signalProperties,errMsgStruct]=slwebwidgets.AuthorUtility.qualifyAuthoredTimeTable(dataVal,timeVal,errMsgStruct);
            if~isempty(errMsgStruct.errorConsistency)||...
                ~isempty(errMsgStruct.errorData)||...
                ~isempty(errMsgStruct.errorTime)
                return;
            end
        end


        dataValClass=class(dataVal);
        if strcmpi(dataValClass,'logical')%#ok<ISLOG>

            dataValClass='boolean';
        elseif isfi(dataVal)
            dataValClass=fixdt(dataVal.numerictype);
        end

        DOES_DATATYPE_MATCH=strcmpi(dataValClass,currentDataType);

        IS_NOW_REAL=false;

        if strcmp(signalProperties.signalType,getString(message('sl_sta_general:common:Real')))
            IS_NOW_REAL=true;
        end

        DOES_SIGNALTYPE_MATCH=IS_NOW_REAL==WAS_REAL;
        DOES_DIMENSIONS_MATCH=strcmp(signalProperties.comparedim,currentDimensions);

        if~DOES_DATATYPE_MATCH
            errMsgStruct.warnDataTypeConversion=DAStudio.message('sl_web_widgets:authorinsert:reauthorDataTypeWarn',...
            currentDataType,class(dataVal));
        end

        if~DOES_SIGNALTYPE_MATCH
            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:reauthorIncompatible');
            return;
        end

        if~DOES_DIMENSIONS_MATCH
            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:reauthorIncompatible');
        end
    end
