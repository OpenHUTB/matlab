





function result=new(reqSetName)

    result=[];

    reqSetName=convertStringsToChars(reqSetName);

    try
        reqSetFilePath=slreq.uri.getNewReqSetFilePath(reqSetName,false);
    catch ex
        throwAsCaller(ex);
    end

    reqData=slreq.data.ReqData.getInstance;


    if~isempty(reqData.getReqSet(reqSetFilePath))
        error(message('Slvnv:slreq:RequirementSetAlreadyLoaded',reqSetFilePath));
    end


    if exist(reqSetFilePath,'file')==2
        error(message('Slvnv:slreq:SavingRequirementSetAbort',reqSetFilePath));
    end


    if~slreq.uri.isWriteable(reqSetFilePath)
        [~,shortName]=fileparts(reqSetFilePath);
        error(message('Slvnv:slreq:ReqSetFileNotWriteable',shortName,reqSetFilePath));
    end



    try


        reqSet=reqData.createAndSaveReqSet(reqSetFilePath);
    catch ex
        throwAsCaller(ex);
    end

    if isempty(reqSet)
        return;
    end


    result=slreq.utils.dataToApiObject(reqSet);
end