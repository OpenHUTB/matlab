






function result=showDocInReqSet(reqSetName,docName,subDoc)

    result=false;

    if nargin<3
        subDoc='';
    end

    reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);

    if isempty(reqSet)
        rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactNotLoaded',reqSetName);
        return;
    end

    if slreq.editor()
        req=reqSet.findTopNodeById(docName,subDoc);
        if~isempty(req)
            slreq.adapters.SLReqAdapter.navigate(req,[],'standalone');
            result=true;
        end
    end
end



