function copyCodeMappings(srcSS,dstMdl,inportMappings,subsystemCopyStrategy)










    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cDefinitions=hlp.openDD(bdroot(srcSS));
    if strcmp(cDefinitions.owner.context,'model')&&~cDefinitions.owner.isEmpty()
        copier=coder.mapping.internal.LocalDictionaryCodeMappingCopier(srcSS,dstMdl,inportMappings,subsystemCopyStrategy);
    else
        copier=coder.mapping.internal.SharedDictionaryCodeMappingCopier(srcSS,dstMdl,inportMappings,subsystemCopyStrategy);
    end
    copier.CopyCodeMappings();

end

