







function summary=getReqItemSummary(targetInfo)
    persistent slreqAdapter;
    if isempty(slreqAdapter)
        slreqAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
    end
    summary=slreqAdapter.getSummary(targetInfo.doc,targetInfo.id);
end

