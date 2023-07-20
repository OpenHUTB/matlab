function copier=createCodeMappingCopier(srcSS,copyAllMappings)










    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cDefinitions=hlp.openDD(bdroot(srcSS));
    if strcmp(cDefinitions.owner.context,'model')&&~cDefinitions.owner.isEmpty()
        copier=coder.mapping.internal.LocalDictionaryCodeMappingCopier(srcSS,copyAllMappings);
    else
        copier=coder.mapping.internal.SharedDictionaryCodeMappingCopier(srcSS,copyAllMappings);
    end

end

