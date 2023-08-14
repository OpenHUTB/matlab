function tf=isValidItem(domain,artifact,itemId)









    domain=convertStringsToChars(domain);
    artifact=convertStringsToChars(artifact);
    itemId=convertStringsToChars(itemId);


    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(domain);
    tf=adapter.isResolved(artifact,itemId);
end

