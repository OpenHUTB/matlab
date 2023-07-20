function[fiDataObj,errMsg]=getFixedPointValue(userEnteredValue,sigID)




    if ischar(userEnteredValue)||isstring(userEnteredValue)||iscellstr(userEnteredValue)
        userEnteredValue=str2double(string(userEnteredValue));
    end
    repoUtil=starepository.RepositoryUtility;
    metaData=repoUtil.getMetaDataStructure(sigID);

    fiDataObj=cell(length(userEnteredValue),1);
    errMsg=cell(length(userEnteredValue),1);
    for id=1:length(userEnteredValue)
        try
            errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(userEnteredValue(id),...
            eval(metaData.DataType),metaData.fiOverflowMode,metaData.fiRoundMode);

            fiDataObj{id}=slwebwidgets.tableeditor.messagemanager.MessageManager.makeFiDataTableStruct(...
            userEnteredValue(id),double(errorMeta.fiValue),errorMeta);
        catch ME_FI
            fiDataObj{id}=[];
            errMsg{id}=ME_FI.message;
        end
    end

    if length(fiDataObj)==1
        fiDataObj=fiDataObj{1};
    end

    if length(errMsg)==1
        errMsg=errMsg{1};
    end

end

