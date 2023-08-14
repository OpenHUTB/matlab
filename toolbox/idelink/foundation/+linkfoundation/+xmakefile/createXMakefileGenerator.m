function generator=createXMakefileGenerator(configName,templateId,projectName,projectType)





    generator=[];
    configuration=linkfoundation.xmakefile.XMakefileConfiguration.getConfiguration(configName);
    template=linkfoundation.xmakefile.XMakefileTemplate.getTemplate(templateId);
    if(~isobject(configuration)||~configuration.isValid())
        if(isempty(configName))
            configName='<EMPTY>';
        end
        linkfoundation.xmakefile.raiseException('Functions','createXMakefileProject','Configuration','',configName);
    end

    if(~isobject(template)||~template.isValid())
        if(isempty(templateId))
            templateId='<EMPTY>';
        end
        linkfoundation.xmakefile.raiseException('Functions','createXMakefileProject','Template','',templateId);
    end

    try
        generator=linkfoundation.xmakefile.XMakefileGenerator(configuration,template,projectName,projectType);
    catch ex
        linkfoundation.xmakefile.raiseException('Functions','createXMakefileProject','',ex);
    end

end
