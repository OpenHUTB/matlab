function ARAComProxyEventWriter(codeWriter,intfName,proxyEventList,serializerFilePath,idlFilePath)





    codeWriter.wBlockStart('namespace events');


    if slfeature('ARAComMiddleware')==3
        autosar.mm.mm2ara.com.RtpsIdlWriter(proxyEventList,intfName,idlFilePath,'');
    end
    autosar.mm.mm2ara.com.RtpsSerializerWriter(proxyEventList,intfName,serializerFilePath,'proxy','');

    for ii=1:length(proxyEventList)
        m3iEvnt=proxyEventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end
        qualifiedTypeName=...
        autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iEvnt.Type);
        codeWriter.wLine(['using ',m3iEvnt.Name,' = ara::com::ProxyEvent<',qualifiedTypeName,'>;']);
    end

    codeWriter.wBlockEnd('namespace events');
end


