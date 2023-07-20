function populateAraComDataMembers(codeWriter,m3iInf,applicationType,itemsList,araComType,checkType)





    namespaceStr=autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(...
    m3iInf,namespaceSeparator='::');

    for ii=1:length(itemsList)
        m3iItem=itemsList{ii};
        shortName=m3iItem.Name;
        if checkType&&isempty(m3iItem.Type)
            continue;
        end

        codeWriter.wLine([namespaceStr,applicationType,'::',araComType,'::',...
        shortName,' ',shortName,';']);
    end
end
