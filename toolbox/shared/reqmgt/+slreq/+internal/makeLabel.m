function label=makeLabel(dataReq)






    if isempty(dataReq)
        label='';

    elseif isa(dataReq,'slreq.data.Requirement')
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
        label=adapter.getSummaryFromDataReq(dataReq);

    else
        error('wrong input argument type in a call to slreq.internal.makeLabel()');
    end
end
