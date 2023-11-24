function openReqElement(absoluteReqFilePath,sid)

    slreq.load(fullfile(absoluteReqFilePath));

    slreq.editor;
    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
    status=adapter.highlight(fullfile(absoluteReqFilePath),sid);
    if status==0
        error(message('alm:slreq_handlers:RequirementNotFound',sid,fullfile(absoluteReqFilePath)));
    end

end
