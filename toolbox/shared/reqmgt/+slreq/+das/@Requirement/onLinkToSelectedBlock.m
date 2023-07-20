function onLinkToSelectedBlock()


    dasReqs=slreq.app.MainManager.getCurrentViewSelections();
    if~isa(dasReqs,'slreq.das.Requirement')
        return;
    end
    appmgr=slreq.app.MainManager.getInstance();
    dasReqs(1).IsSleeping=true;
    c=onCleanup(@()setSleepFalse(dasReqs(1)));

    try
        slType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_simulink');
        req=slType.SelectionLinkFcn('',false);

    catch ex %#ok<NASGU>
        return;
    end
    if isempty(req)
        return;
    end
    if length(req)==1&&strncmp(req.description,'ERROR',5)

        rmiut.warnNoBacktrace('Invalid object is selected for linking.')
        return;
    end
    srcInfo=slreq.utils.getRmiStruct(req);
    slreq.uri.ResourcePathHandler.setInteractive(true);
    clp=onCleanup(@()slreq.uri.ResourcePathHandler.setInteractive(false));
    appmgr.notify('SleepUI');
    clp2=onCleanup(@()postUpdate(appmgr));
    arrayfun(@(x)createLink(srcInfo,x),dasReqs);
end


function createLink(srcInfo,dasReq)
    try
        dasReq.addLink(srcInfo);
    catch ex
        switch ex.identifier
        case 'Slvnv:slreq:IsNotFilePath'
            reply=questdlg({...
            getString(message('Slvnv:slreq:MustSaveBeforLinking')),...
            getString(message('Slvnv:slreq:SaveNowAndCompleteLinkQ'))},...
            getString(message('Slvnv:slreq:LinkActionFailed')),...
            getString(message('Slvnv:slreq:SaveNow')),...
            getString(message('Slvnv:slreq:Cancel')),...
            getString(message('Slvnv:slreq:SaveNow')));
            if isempty(reply)||strcmp(reply,getString(message('Slvnv:slreq:Cancel')))
                return;
            else
                save_system(srcInfo.doc);
                dasReq.addLink(source);
            end
        case 'Slvnv:slreq:IncomingLinkToJustificationError'
            errordlg(getString(message('Slvnv:slreq:IncomingLinkToJustificationError')),...
            getString(message('Slvnv:rmitm:SelectionLinkingError')),'modal');
        case 'Slvnv:slreq_uri:UnresolvedShortPath'
            errordlg(ex.message,...
            getString(message('Slvnv:rmitm:SelectionLinkingError')),'modal');
        otherwise
            rethrow(ex);
        end
    end
end

function setSleepFalse(dasReq)
    dasReq.IsSleeping=false;
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end