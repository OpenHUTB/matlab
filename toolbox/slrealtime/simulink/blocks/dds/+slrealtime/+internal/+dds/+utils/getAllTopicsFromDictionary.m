function topics=getAllTopicsFromDictionary(modelName)






    topics={};
    [~,~,dd]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
    if~isempty(dd)
        ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
        if~isempty(ddsMf0Model)
            systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
            if~isempty(systemInModel)
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
                            topics{end+1}=[domainLibName,'/',domainName,'/',topicName];
                        end
                    end
                end
            end
        end
    end
end


