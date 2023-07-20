function topics=getTopics(modelName,dataType)







    topics={};

    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);

    dataType=regexprep(dataType,'^\w*:\s*','');
    ddsType=dds.internal.simulink.Util.getDDSType(modelName,dataType);
    topicRefs={};
    if~isempty(ddsType)
        for regref=1:ddsType.RegisterTypeRefs.Size
            for topref=1:ddsType.RegisterTypeRefs(regref).TopicRefs.Size
                topicRefs{end+1}=ddsType.RegisterTypeRefs(regref).TopicRefs(topref);
            end
        end
    end

    domainLibs=systemInModel(1).DomainLibraries;
    domainLibNames=keys(domainLibs);
    for ii=1:numel(domainLibNames)
        domainLibName=domainLibNames{ii};
        domainLib=domainLibs{domainLibName};
        domainNames=keys(domainLib.Domains);
        for jj=1:numel(domainNames)
            domainName=domainNames{jj};
            domain=domainLib.Domains{domainName};
            topicNames=keys(domain.Topics);
            for kk=1:numel(topicNames)
                topicName=topicNames{kk};
                topic=domain.Topics{topicName};
                if strcmp(dataType,'auto')||any(cellfun(@(x)x==topic,topicRefs))
                    topics{end+1}=[domainLibName,'/',domainName,'/',topicName];
                end
            end
        end
    end
end
