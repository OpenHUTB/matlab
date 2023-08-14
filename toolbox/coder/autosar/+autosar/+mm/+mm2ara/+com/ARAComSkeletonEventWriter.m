function ARAComSkeletonEventWriter(codeWriter,intfName,skeletonEventList,serializerFilePath,idlFilePath)





    codeWriter.wBlockStart('namespace events');


    if slfeature('ARAComMiddleware')==3
        autosar.mm.mm2ara.com.RtpsIdlWriter(skeletonEventList,intfName,idlFilePath,'');
    end
    autosar.mm.mm2ara.com.RtpsSerializerWriter(skeletonEventList,intfName,serializerFilePath,'skeleton','');

    for ii=1:length(skeletonEventList)
        m3iEvnt=skeletonEventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end
        qualifiedTypeName=...
        autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iEvnt.Type);
        codeWriter.wLine(['using ',m3iEvnt.Name,' = ara::com::SkeletonEvent<',qualifiedTypeName,'>;']);
    end

    codeWriter.wBlockEnd('namespace events');
end


