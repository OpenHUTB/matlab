function boolVal=isHierarchicalDomain(cbinfo)




    boolVal=(isa(cbinfo.domain,'SLM3I.SLDomain')||isa(cbinfo.domain,'StateflowDI.SFDomain'));
end
