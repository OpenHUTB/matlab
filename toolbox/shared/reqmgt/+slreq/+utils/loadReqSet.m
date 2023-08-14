function reqSet=loadReqSet(rsName)



    pathToFile=slreq.utils.fullPath(rsName);
    if isempty(pathToFile)
        error(message('Slvnv:slreq:UnableToLocateReqSet',rsName));
    end

    reqSet=slreq.data.ReqData.getInstance.loadReqSet(pathToFile);
end