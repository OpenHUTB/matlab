function onLinkToSelectedTest()






    dasReqs=slreq.app.MainManager.getCurrentViewSelections();
    if~isa(dasReqs,'slreq.das.Requirement')
        return;
    end
    appmgr=slreq.app.MainManager.getInstance();
    linkType_testmgr=rmi.linktype_mgr('resolveByRegName','linktype_rmi_testmgr');
    reqInfo=linkType_testmgr.SelectionLinkFcn(dasReqs,false);
    if isempty(reqInfo)
        return;
    end

    srcInfo=slreq.utils.getRmiStruct(reqInfo);








    if~rmiut.isCompletePath(srcInfo.artifact)
        if~isempty(fileparts(srcInfo.artifact))

            refPath=fileparts(dasReqs.RequirementSet.Filepath);
            srcInfo.artifact=rmiut.absolute_path(srcInfo.artifact,refPath);
        else

            srcInfo.artifact=rmitm.getFilePath(srcInfo.artifact);
        end
    end

    origSrcInfo=srcInfo;


    [~,ext]=rmitm.getFilePath(srcInfo.artifact);
    if strcmp(ext,'.m')






        srcInfo.id=rmiml.RmiMUnitData.getBookmarkForTest(srcInfo.artifact,srcInfo.id);
        srcInfo.domain='linktype_rmi_matlab';
    end


    slreq.uri.ResourcePathHandler.setInteractive(true);
    clp=onCleanup(@()slreq.uri.ResourcePathHandler.setInteractive(false));
    appmgr.notify('SleepUI');
    clp2=onCleanup(@()postUpdate(origSrcInfo,appmgr));
    arrayfun(@(x)createLink(srcInfo,x),dasReqs);

end

function createLink(srcInfo,dasReq)
    try
        dasReq.addLink(srcInfo);
    catch ex
        switch ex.identifier
        case 'Slvnv:slreq:IncomingLinkToJustificationError'
            errordlg(getString(message('Slvnv:slreq:IncomingLinkToJustificationError')),...
            getString(message('Slvnv:rmitm:SelectionLinkingError')),'modal');
        case 'Slvnv:slreq_uri:UnresolvedShortPath'
            errordlg(ex.message,...
            getString(message('Slvnv:rmitm:SelectionLinkingError')),'modal');
        otherwise
            rethrow(ex)
        end
    end
end

function postUpdate(srcInfo,appmgr)
    appmgr.notify('WakeUI');
    appmgr.update();
    rmitm.UpdateNotifier.notifyReqUpdate(srcInfo.artifact,srcInfo.id);
end