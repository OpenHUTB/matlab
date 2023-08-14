




function tf=isDefinedDomain(domain)
    domainDef=rmi.linktype_mgr('resolveByRegName',domain);
    tf=~isempty(domainDef);
end
