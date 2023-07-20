function pathToReqSetFile=getNewReqSetFilePath(userSelectedName,isUI)



    if nargin<2
        isUI=false;
    end

    reqData=slreq.data.ReqData.getInstance;

    if~isempty(userSelectedName)
        reqSetName=userSelectedName;
    else


        reqSetName=reqData.getInstance.getDefaultReqSetName();
    end

    if isUI
        pathToReqSetFile=slreq.das.ReqRoot.promptForReqSetFile([reqSetName,'.slreqx']);
        if isempty(pathToReqSetFile)
            return;
        end

    else

        fDir=fileparts(reqSetName);
        if isempty(fDir)

            pathToReqSetFile=fullfile(pwd,reqSetName);
        elseif~rmiut.isCompletePath(fDir)

            pathToReqSetFile=rmiut.simplifypath(fullfile(pwd,reqSetName));
        else

            pathToReqSetFile=reqSetName;
        end
    end


    pathToReqSetFile=slreq.uri.ensureExtension(pathToReqSetFile);


    try
        slreq.uri.errorOnInvalidReqSetName(pathToReqSetFile);
    catch ex
        if isUI
            msgbox(ex.message,getString(message('Slvnv:slreq:Error')),'error');
            pathToReqSetFile='';
        else
            throwAsCaller(ex);
        end
    end
end




