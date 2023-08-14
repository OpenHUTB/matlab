function ARAComSkeletonClassWriter(codeWriter,m3iInf,skeletonClassName,...
    skeletonEventList,skeletonMethodList,eventSerializerFilePath,...
    idlFilePath,methodSerializerFilePath,modelName,schemaVersion)







    autosar.mm.mm2ara.com.ARAComSkeletonEventWriter(codeWriter,m3iInf.Name,...
    skeletonEventList,eventSerializerFilePath,idlFilePath);


    autosar.mm.mm2ara.com.RtpsSkeletonMethodSerializerWriter(skeletonClassName,...
    methodSerializerFilePath,skeletonMethodList);


    codeWriter.wBlockStart(['class ',skeletonClassName]);
    codeWriter.wLine('public:');


    codeWriter.wBlockStart([skeletonClassName,...
'(ara::com::InstanceIdentifier instance, ara::com::MethodCallProcessingMode'...
    ,' mode = ara::com::MethodCallProcessingMode::kEvent): '...
    ,'mHndl(instance), mMethodProcMode(mode)']);
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart([skeletonClassName,...
'(ara::core::InstanceSpecifier instanceSpec, ara::com::MethodCallProcessingMode'...
    ,' mode = ara::com::MethodCallProcessingMode::kEvent): '...
    ,'mMethodProcMode(mode)']);
    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wLine('ara::core::Result<ara::com::InstanceIdentifierContainer> vecInstance(ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance->empty())');
        codeWriter.wLine('mHndl.mInstanceID = vecInstance->front();');
    else
        codeWriter.wLine('ara::com::InstanceIdentifierContainer vecInstance(ara::com::runtime::ResolveInstanceIDs(instanceSpec));');
        codeWriter.wBlockStart('if(!vecInstance.empty())');
        codeWriter.wLine('mHndl.mInstanceID = vecInstance.front();');
    end
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart(['virtual ~',skeletonClassName,'()']);
    codeWriter.wLine('StopOfferService();');
    codeWriter.wBlockEnd();


    codeWriter.wLine([skeletonClassName,'(const ',skeletonClassName,'&) = delete;']);
    codeWriter.wLine([skeletonClassName,'& operator =(const ',skeletonClassName,'&) = delete;']);


    codeWriter.wLine([skeletonClassName,'(',skeletonClassName,'&& sklObj) = default;']);
    codeWriter.wLine([skeletonClassName,'& operator =(',skeletonClassName,'&& sklObj) = default;'])


    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart('inline ara::core::Result<void> OfferService()');
    else
        codeWriter.wBlockStart('inline void OfferService()');
    end
    codeWriter.wLine('ara::com::ServiceFactory::CreateService(mHndl);');

    dynMthType=['skeleton_io::',skeletonClassName,'_mthd_dispatcher_t'];

    codeWriter.wLine(['mMethodMiddleware.reset(ara::com::MethodFactory::CreateSkeletonMethod<'...
    ,skeletonClassName,', ',dynMthType,'>(mMethodProcMode, this, mHndl));']);


    if~isempty(skeletonEventList)
        codeWriter.wLine('std::string sTopicName;');
    end


    evntToTopicNameMap=containers.Map;
    m3iModel=autosar.api.Utils.m3iModel(modelName);
    m3iSrvcToPortMappings=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass,true,true);

    evntToSimPortNameMap=containers.Map;
    modelMapping=autosar.api.Utils.modelMapping(modelName);
    outports=modelMapping.Outports;

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

            for jj=1:numel(outports)


                outport=outports(jj);
                portName=outport.MappedTo.Port;
                eventName=outport.MappedTo.Event;
                blockName=outport.Block;
                if strcmp(siToPortMappingObj.Port.Name,portName)
                    if isKey(evntToSimPortNameMap,eventName)
                        blockNames=evntToSimPortNameMap(eventName);
                        blockNames{end+1}=blockName;
                        evntToSimPortNameMap(eventName)=blockNames;
                    else
                        evntToSimPortNameMap(eventName)={blockName};
                    end
                end
            end
        end
    end

    for ii=1:length(skeletonEventList)
        m3iEvnt=skeletonEventList{ii};
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

        dynType=['skeleton_io::',m3iInf.Name,'_',m3iEvnt.Name,'_t'];
        qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(m3iEvnt.Type);
        codeWriter.wLine([m3iEvnt.Name,'.Init(ara::com::EventFactory::CreateSkeletonEvent<'...
        ,qualifiedTypeName,', ',dynType,'>(mHndl, sTopicName));']);
    end
    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wLine('return ara::core::Result<void>::FromValue();');
    end
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('inline void StopOfferService()');
    for ii=1:length(skeletonEventList)
        m3iEvnt=skeletonEventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end
        codeWriter.wLine([m3iEvnt.Name,'.Deinit();']);
    end
    codeWriter.wLine('ara::com::ServiceFactory::DestroyService(mHndl);');
    codeWriter.wBlockEnd();


    autosar.mm.mm2ara.com.populateAraComDataMembers(codeWriter,m3iInf,'skeleton',skeletonEventList,'events',true);


    GenerateMethodSignatures(codeWriter,skeletonMethodList);

    codeWriter.wLine('private:');
    codeWriter.wLine('ara::com::ServiceHandleType mHndl;');
    codeWriter.wLine('ara::com::MethodCallProcessingMode mMethodProcMode;');
    codeWriter.wLine('std::shared_ptr<ara::com::SkeletonMethodMiddlewareBase> mMethodMiddleware;');
    codeWriter.wBlockEnd('',false,true);
end

function GenerateMethodSignatures(codeWriter,skeletonMethodList)

    for ii=1:numel(skeletonMethodList)
        m3iMthd=skeletonMethodList{ii};
        mthdArgs=m3iMthd.Arguments;


        argStr=[];
        outTypes={};
        outArgNames={};
        outTypesEmpty=true;
        for jj=1:mthdArgs.size()
            arg=mthdArgs.at(jj);
            if~isempty(arg.Type)
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)
                    type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);
                    argStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argStr,...
                    ', ',[type,' ',arg.Name]);
                end
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)
                    outTypes{end+1}=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);%#ok<*AGROW>
                    outTypesEmpty=false;
                    outArgNames{end+1}=arg.Name;
                end
            end
        end

        if m3iMthd.FireAndForget||outTypesEmpty
            codeWriter.wLine(['virtual void ',m3iMthd.Name,'(',argStr,') = 0;']);
        else

            codeWriter.wBlockStart(['struct ',m3iMthd.Name,'Output']);
            if~isempty(outTypes)
                for jj=1:numel(outTypes)
                    if~(outTypes{jj}=="")
                        codeWriter.wLine([outTypes{jj},' ',outArgNames{jj},';']);
                    end
                end
            end
            codeWriter.wBlockEnd();
            codeWriter.wLine(';');
            codeWriter.wLine(['virtual ara::core::Future<',m3iMthd.Name,'Output> ',m3iMthd.Name,'(',argStr,') = 0;']);
        end
    end
end



