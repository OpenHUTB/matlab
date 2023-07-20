function openRequirementsFile(requirementsFileName,requirementsFilePath)




    reqData=slreq.data.ReqData.getInstance;
    sid=[];

    [~,name,ext]=fileparts(requirementsFilePath);
    switch(ext)
    case '.slreqx'


        reqSet=reqData.getReqSet(requirementsFileName);

        if isempty(reqSet)
            if exist(requirementsFilePath,'file')==2

                reqSet=reqData.loadReqSet(requirementsFilePath);
            end
        end

        if~isempty(reqSet)

            slreq.adapters.SLReqAdapter.navigate(reqSet,sid,'standalone','select');
        end
    case '.slmx'


        linkSet=reqData.getLoadedLinkSetByName(name);
        if isempty(linkSet)
            if exist(requirementsFilePath,'file')==2

                linkSet=reqData.loadLinkSet([name,'.slmx'],requirementsFilePath);
            end
        end

        if~isempty(linkSet)

            mgr=slreq.app.MainManager.getInstance;





            if isempty(mgr.requirementsEditor)||~mgr.requirementsEditor.isVisible()
                mgr.openRequirementsEditor();
            end


            linksetUuid=linkSet.getUuid();
            slreq.app.CallbackHandler.selectObjectByUuid(linksetUuid,'standalone');


            mgr.requirementsEditor.show();
        end

    end

end