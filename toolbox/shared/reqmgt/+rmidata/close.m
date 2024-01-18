function close(modelH)

    if~slreq.data.ReqData.exists()
        rmidata.storageModeCache('remove',modelH);
        return;
    end
    artifactPath=slreq.resolveArtifactPath(modelH,'linktype_rmi_simulink');
    if~isempty(artifactPath)
        slreq.close(artifactPath);
    end
    if slreq.app.MainManager.exists()
        slreq.app.MainManager.modelCloseCallback(modelH);
    end
    rmidata.storageModeCache('remove',modelH);

    if rmi.isInstalled()&&strcmp(get_param(modelH,'ReqHilite'),'on')
        rmi.Informer.closeModel(get_param(modelH,'Name'));
    end

end

