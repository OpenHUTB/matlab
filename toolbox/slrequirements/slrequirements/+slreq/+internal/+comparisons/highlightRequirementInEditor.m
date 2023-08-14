function highlightRequirementInEditor(requirementSetName,sid,requirementSetPath)


    reqData=slreq.data.ReqData.getInstance;


    reqSet=reqData.getReqSet(requirementSetName);

    if isempty(reqSet)
        if exist(requirementSetPath,'file')==2

            reqData.loadReqSet(requirementSetPath);
        end
    end

    slreq.adapters.SLReqAdapter.navigate(requirementSetPath,sid,'standalone','select');
end
