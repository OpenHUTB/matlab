function[deferredNotification,isLinkSetLoaded]=init(modelH)

    deferredNotification={};
    isLinkSetLoaded=false;

    if rmiut.isBuiltinNoRmi(modelH)
        rmidata.storageModeCache('set',modelH,false);
        return;
    end

    if rmidata.storageModeCache('check',modelH)
        return;
    end
    [isHarnessBD,mainModel]=Simulink.harness.internal.sidmap.isHarnessBDPostLoad(modelH);
    if isHarnessBD
        mainModelMode=rmidata.isExternal(mainModel);
        if mainModelMode

            if rmipref('StoreDataExternally')&&~rmidata.bdHasExternalData(mainModel)
                if rmisl.modelHasEmbeddedReqInfo(modelH)
                    rmidata.storageModeCache('set',mainModel,false);
                    rmidata.storageModeCache('set',modelH,false);
                    return;
                end
            end
        end
        rmidata.storageModeCache('set',modelH,mainModelMode);
        return;
    end

    if rmisl.modelHasEmbeddedReqInfo(modelH)
        if is_slx_format(modelH)
            deferredNotification={message('Slvnv:slreq:DataNeedsUpdating'),message('Slvnv:slreq:UpdateNow')};
        else
            deferredNotification={message('Slvnv:slreq:ExportOrSaveMdlAsSlx'),message('Slvnv:slreq:ExportData'),message('Slvnv:slreq:SaveInSLXFormat')};
        end
        rmidata.storageModeCache('set',modelH,false);

        slreq.data.ReqData.getInstance();

    elseif rmidata.bdHasExternalData(modelH,true)
        rmidata.storageModeCache('set',modelH,true);
        artifact=get_param(modelH,'FileName');
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
        if slreq.internal.isSharedSlreqInstalled()
            lsm=slreq.linkmgr.LinkSetManager.getInstance();
            lsm.addReference(linkSet,linkSet.artifact);

            lsm.onArtifactLoad(artifact);
        end

        if slreq.app.MainManager.hasEditor()
            mgr=slreq.app.MainManager.getInstance();
            if mgr.isChangeInformationEnabled()
                chTracker=mgr.changeTracker;
                chTracker.refresh;
            end
        end
    elseif isempty(get_param(modelH,'FileName'))
        return;

    else
        [isLinkSetLoaded,deferredNotification]=rmidata.loadIfExists(modelH);
        rmidata.storageModeCache('set',modelH,true);
    end
end


function out=is_slx_format(modelH)
    f=get_param(modelH,'FileName');
    [~,~,ext]=fileparts(f);
    out=strcmpi(ext,'.slx');
end
