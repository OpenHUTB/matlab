function ARAComProxyClassWriter(codeWriter,m3iInf,proxyClassName,...
    proxyEventList,proxyMethodList,eventSerializerFilePath,idlFilePath,methodSerializerFilePath,modelName,schemaVersion)






    autosar.mm.mm2ara.com.ARAComProxyEventWriter(codeWriter,m3iInf.Name,...
    proxyEventList,eventSerializerFilePath,idlFilePath);


    autosar.mm.mm2ara.com.ARAComProxyMethodWriter(codeWriter,m3iInf.Name,...
    proxyMethodList,methodSerializerFilePath,modelName);

    codeWriter.wBlockStart(['class ',proxyClassName]);
    codeWriter.wLine('private:');
    codeWriter.wLine('ara::com::ServiceHandleType mHandle;');

    codeWriter.wLine('public:');

    codeWriter.wLine('using HandleType = ara::com::ServiceHandleType;');



    mthdInitStr='';
    for ii=1:length(proxyMethodList)
        mthdInitStr=[mthdInitStr,', ',proxyMethodList{ii}.Name,'(handle)'];%#ok<AGROW>
    end
    codeWriter.wBlockStart(['explicit ',proxyClassName,...
    '(const HandleType& handle): mHandle(handle)',mthdInitStr]);


    if~isempty(proxyEventList)
        codeWriter.wLine('std::string sTopicName;');
    end


    evntToTopicNameMap=containers.Map;
    m3iModel=autosar.api.Utils.m3iModel(modelName);
    m3iSrvcToPortMappings=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass,true,true);

    evntToSimPortNameMap=containers.Map;
    modelMapping=autosar.api.Utils.modelMapping(modelName);
    inports=modelMapping.Inports;

    for kk=1:m3iSrvcToPortMappings.size()
        siToPortMappingObj=m3iSrvcToPortMappings.at(kk);
        m3iSrvcIntfDepl=siToPortMappingObj.ServiceInstance.Deployment;
        if isempty(siToPortMappingObj.Port)||~siToPortMappingObj.Port.isvalid()||isempty(m3iSrvcIntfDepl)||~isequal(m3iSrvcIntfDepl.ServiceInterface,m3iInf)
            continue;
        end
        m3iEvntDeplSeq=m3iSrvcIntfDepl.EventDeployment;
        if isa(m3iSrvcIntfDepl,'Simulink.metamodel.arplatform.manifest.DdsServiceInterfaceDeployment')

            for jj=1:m3iEvntDeplSeq.size()
                m3iEvntDepl=m3iEvntDeplSeq.at(jj);




                ddsTopicName=m3iEvntDepl.getExternalToolInfo('DDSTopicName').externalId;
                if isempty(ddsTopicName)
                    ddsTopicName=m3iEvntDepl.TopicName;
                end
                evntToTopicNameMap(m3iEvntDepl.Event.Name)=ddsTopicName;
            end

            for jj=1:numel(inports)


                inport=inports(jj);
                portName=inport.MappedTo.Port;
                eventName=inport.MappedTo.Event;
                blockName=inport.Block;
                if strcmp(siToPortMappingObj.Port.Name,portName)
                    if isKey(evntToSimPortNameMap,eventName)
                        blockNames=evntToSimPortNameMap(eventName);
                        blockNames{end+1}=blockName;%#ok<AGROW>
                        evntToSimPortNameMap(eventName)=blockNames;
                    else
                        evntToSimPortNameMap(eventName)={blockName};
                    end
                end
            end

        end
    end


    for ii=1:length(proxyEventList)
        m3iEvnt=proxyEventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end

        if evntToTopicNameMap.isKey(m3iEvnt.Name)
            codeWriter.wLine(['sTopicName = "',evntToTopicNameMap(m3iEvnt.Name),'";']);
            if evntToSimPortNameMap.isKey(m3iEvnt.Name)
                blockNames=evntToSimPortNameMap(m3iEvnt.Name);
                for jj=1:numel(blockNames)
                    disp(DAStudio.message('autosarstandard:code:topicNameForBlock',blockNames{jj},evntToTopicNameMap(m3iEvnt.Name)));
                end
            end
        else
            codeWriter.wLine(['sTopicName = "',m3iEvnt.Name,'";']);
        end

        dynType=['proxy_io::',m3iInf.Name,'_',m3iEvnt.Name,'_t'];
        qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iEvnt.Type);
        codeWriter.wLine([m3iEvnt.Name,'.Init(ara::com::EventFactory::CreateProxyEvent<'...
        ,qualifiedTypeName,', ',dynType,'>(handle, sTopicName));']);
    end
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart(['virtual ~',proxyClassName,'()']);
    for ii=1:length(proxyEventList)
        m3iEvnt=proxyEventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end
        codeWriter.wLine([m3iEvnt.Name,'.Deinit();']);
    end
    codeWriter.wBlockEnd();


    codeWriter.wLine([proxyClassName,'(const ',proxyClassName,'&) = delete;']);
    codeWriter.wLine([proxyClassName,'& operator =(const ',proxyClassName,'&) = delete;']);


    codeWriter.wLine([proxyClassName,'(',proxyClassName,'&&) = default;']);
    codeWriter.wLine([proxyClassName,'& operator =(',proxyClassName,'&&) = default;'])


    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart(['static inline ara::core::Result<ara::com::ServiceHandleContainer<',proxyClassName,...
        '::HandleType>> FindService(ara::com::InstanceIdentifier instance = ara::com::InstanceIdentifier::Any)']);
    else
        codeWriter.wBlockStart(['static inline ara::com::ServiceHandleContainer<',proxyClassName,...
        '::HandleType> FindService(ara::com::InstanceIdentifier instance = ara::com::InstanceIdentifier::Any)']);
    end
    codeWriter.wLine(['ara::com::ServiceHandleContainer<',proxyClassName,'::HandleType> retResult;']);
    codeWriter.wLine('retResult.push_back(ara::com::ServiceFactory::FindService(instance));');
    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wLine(['return ara::core::Result<ara::com::ServiceHandleContainer<',proxyClassName,'::HandleType>>{retResult};']);
    else
        codeWriter.wLine('return retResult;');
    end
    codeWriter.wBlockEnd();


    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart(['static inline ara::core::Result<ara::com::ServiceHandleContainer<',proxyClassName,...
        '::HandleType>> FindService(ara::core::InstanceSpecifier instanceSpec)']);
        codeWriter.wLine(['ara::com::ServiceHandleContainer<',proxyClassName,'::HandleType> retResult;']);
        codeWriter.wLine('ara::core::Result<ara::com::InstanceIdentifierContainer> vecInstance (ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance->empty())');
        codeWriter.wLine('retResult = FindService(vecInstance->front()).Value();');
        codeWriter.wBlockMiddle('else');
        codeWriter.wLine('retResult = FindService(ara::com::InstanceIdentifier::Any).Value();');
        codeWriter.wBlockEnd();
        codeWriter.wLine(['return ara::core::Result<ara::com::ServiceHandleContainer<',proxyClassName,'::HandleType>>{retResult};']);
    else
        codeWriter.wBlockStart(['static inline ara::com::ServiceHandleContainer<',proxyClassName,...
        '::HandleType> FindService(ara::core::InstanceSpecifier instanceSpec)']);
        codeWriter.wLine(['ara::com::ServiceHandleContainer<',proxyClassName,'::HandleType> retResult;']);
        codeWriter.wLine('ara::com::InstanceIdentifierContainer vecInstance(ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance.empty())');
        codeWriter.wLine('retResult = FindService(vecInstance.front());');
        codeWriter.wBlockMiddle('else');
        codeWriter.wLine('retResult = FindService(ara::com::InstanceIdentifier::Any);');
        codeWriter.wBlockEnd();
        codeWriter.wLine('return retResult;');
    end
    codeWriter.wBlockEnd();


    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart(['static inline ara::core::Result<ara::com::FindServiceHandle> StartFindService(ara::com::FindServiceHandler<',...
        proxyClassName,'::HandleType> handler, ara::com::InstanceIdentifier instance = ara::com::InstanceIdentifier::Any)']);
        codeWriter.wLine('return ara::core::Result<ara::com::FindServiceHandle>{ara::com::ServiceFactory::StartFindService(handler, instance)};');
    else
        codeWriter.wBlockStart(['static inline ara::com::FindServiceHandle StartFindService(ara::com::FindServiceHandler<',...
        proxyClassName,'::HandleType> handler, ara::com::InstanceIdentifier instance = ara::com::InstanceIdentifier::Any)']);
        codeWriter.wLine('return ara::com::ServiceFactory::StartFindService(handler, instance);');
    end
    codeWriter.wBlockEnd();


    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart(['static inline ara::core::Result<ara::com::FindServiceHandle> StartFindService(ara::com::FindServiceHandler<',...
        proxyClassName,'::HandleType> handler, ara::core::InstanceSpecifier instanceSpec)']);
        codeWriter.wLine('ara::com::FindServiceHandle retHandle;')
        codeWriter.wLine('ara::core::Result<ara::com::InstanceIdentifierContainer> vecInstance (ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance->empty())');
        codeWriter.wLine('retHandle = StartFindService(handler, vecInstance->front()).Value();');
        codeWriter.wBlockMiddle('else');
        codeWriter.wLine('retHandle = StartFindService(handler, ara::com::InstanceIdentifier::Any).Value();');
        codeWriter.wBlockEnd();
        codeWriter.wLine('return ara::core::Result<ara::com::FindServiceHandle>{retHandle};');
    else
        codeWriter.wBlockStart(['static inline ara::com::FindServiceHandle StartFindService(ara::com::FindServiceHandler<',...
        proxyClassName,'::HandleType> handler, ara::core::InstanceSpecifier instanceSpec)']);
        codeWriter.wLine('ara::com::FindServiceHandle retHandle;')
        codeWriter.wLine('ara::com::InstanceIdentifierContainer vecInstance(ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance.empty())');
        codeWriter.wLine('retHandle = StartFindService(handler, vecInstance.front());');
        codeWriter.wBlockMiddle('else');
        codeWriter.wLine('retHandle = StartFindService(handler, ara::com::InstanceIdentifier::Any);');
        codeWriter.wBlockEnd();
        codeWriter.wLine('return retHandle;');

    end
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('static inline void StopFindService(ara::com::FindServiceHandle handle)');
    codeWriter.wLine('ara::com::ServiceFactory::StopFindService(handle);');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart([proxyClassName,'::HandleType GetHandle() const']);
    codeWriter.wLine('return mHandle;');
    codeWriter.wBlockEnd();

    autosar.mm.mm2ara.com.populateAraComDataMembers(codeWriter,m3iInf,'proxy',proxyEventList,'events',true);
    autosar.mm.mm2ara.com.populateAraComDataMembers(codeWriter,m3iInf,'proxy',proxyMethodList,'methods',false);

    codeWriter.wBlockEnd('',false,true);
end


