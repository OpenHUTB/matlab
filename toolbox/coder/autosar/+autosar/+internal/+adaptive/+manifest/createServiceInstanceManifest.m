function createServiceInstanceManifest(modelName,buildDir)










    m3iModel=autosar.api.Utils.m3iModel(modelName);
    serviceInstanceToPortMapping=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
    Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass);
    portStructure.requiredPorts=containers.Map;
    portStructure.providedPorts=containers.Map;
    portStructure.instanceSpecifierToInstanceIds=containers.Map;

    apiObj=autosar.api.getAUTOSARProperties(modelName);
    isInstSpecifier=strcmp(apiObj.get('XmlOptions','IdentifyServiceInstance'),'InstanceSpecifier');


    for ii=1:serviceInstanceToPortMapping.size()
        siToPortMapping=serviceInstanceToPortMapping.at(ii);

        si=siToPortMapping.ServiceInstance;


        instanceID='';
        classSI=class(si);



        switch classSI
        case 'Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance'
            if si.Deployment.adminData.isvalid()
                instanceID=si.Deployment.adminData.sdg.at(1).gid;
            end
            binding='UD';
            portStructure.requiredPorts=addSiToPortStructure(portStructure.requiredPorts,instanceID,instanceID,binding);
            if isInstSpecifier
                instanceSpecifier=getInstanceSpecifier(apiObj,siToPortMapping.Port.Name,'RequiredPort');
                portStructure.instanceSpecifierToInstanceIds=addInstIdToInstSpecifier(portStructure.instanceSpecifierToInstanceIds,instanceSpecifier,instanceID);
            end

        case 'Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance'
            if si.Deployment.adminData.isvalid()
                instanceID=si.Deployment.adminData.sdg.at(1).gid;
            end
            binding='UD';
            portStructure.providedPorts=addSiToPortStructure(portStructure.providedPorts,instanceID,instanceID,binding);
            if isInstSpecifier
                instanceSpecifier=getInstanceSpecifier(apiObj,siToPortMapping.Port.Name,'ProvidedPort');
                portStructure.instanceSpecifierToInstanceIds=addInstIdToInstSpecifier(portStructure.instanceSpecifierToInstanceIds,instanceSpecifier,instanceID);
            end

        case 'Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance'
            instanceID=num2str(si.InstanceId);
            domainID=si.DomainId;
            binding='DDS';
            portStructure.requiredPorts=addSiToPortStructure(portStructure.requiredPorts,instanceID,domainID,binding);
            if isInstSpecifier
                instanceSpecifier=getInstanceSpecifier(apiObj,siToPortMapping.Port.Name,'RequiredPort');
                portStructure.instanceSpecifierToInstanceIds=addInstIdToInstSpecifier(portStructure.instanceSpecifierToInstanceIds,instanceSpecifier,instanceID);
            end

        case 'Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance'
            instanceID=num2str(si.InstanceId);
            domainID=si.DomainId;
            binding='DDS';
            portStructure.providedPorts=addSiToPortStructure(portStructure.providedPorts,instanceID,domainID,binding);

            if isInstSpecifier
                instanceSpecifier=getInstanceSpecifier(apiObj,siToPortMapping.Port.Name,'ProvidedPort');
                portStructure.instanceSpecifierToInstanceIds=addInstIdToInstSpecifier(portStructure.instanceSpecifierToInstanceIds,instanceSpecifier,instanceID);
            end
        otherwise
            error('Error in ServiceInstance Manifest Creation');
        end
    end


    siManifestFullFilePath=[buildDir.CodeGenFolder,filesep,'ServiceInstanceManifest.json'];
    autosar.internal.adaptive.manifest.createJSONfileFromStruct(portStructure,siManifestFullFilePath);
end

function portMap=addSiToPortStructure(portMap,instanceID,domainID,binding)
    if isKey(portMap,instanceID)
        portMap(instanceID).Binding{end+1}=binding;
    else

        temp=struct();
        temp.Binding={binding};
        temp.DomainId=domainID;
        portMap(instanceID)=temp;
    end
end

function instanceIdMap=addInstIdToInstSpecifier(instanceIdMap,instanceSpecifier,instanceId)
    if isKey(instanceIdMap,instanceSpecifier)
        instanceIdMap(instanceSpecifier).InstanceID{end+1}=instanceId;
    else

        temp=struct();
        temp.InstanceID={instanceId};
        instanceIdMap(instanceSpecifier)=temp;
    end
end

function instanceSpecifier=getInstanceSpecifier(apiObj,portName,portType)
    componentQualifiedName=apiObj.get('XmlOptions','ComponentQualifiedName');
    portQualifiedName=apiObj.find(componentQualifiedName,portType,...
    'Name',portName,'PathType','FullyQualified');
    instanceSpecifier=[portQualifiedName{1},'/',apiObj.get(portQualifiedName{1},'InstanceSpecifier')];
end
