classdef ManifestUtilities<handle








    properties(Access=private)
Model
m3iModel
modelName
m3iComp
maxShortNameLength
siDeploymentPkgname
adaptivePlatformSIPkgName
siToPortMappingPkgName
defProcessQualPath
defProcessName
processPkgName
defProcessDesignQualPath
defProcessDesignName
processDesignPkgName
functionGroupSetPkgName
machinePkgName
defMachineName
bindingType
reqSrvcInstType
provSrvcInstType
portToEventMap
portToMethodMap
m3iSrvcInstToPortMappingSeqObj
dltLogChnlToProcMappingPkgName
    end
    properties(Access=private,Constant)
        numOfPerStateTimeout=6;
        numStateDepStartConfig=1;
    end

    properties(Constant,Access=public)


        SupportedProperties={{'InstanceIdentifier','string'}};
    end

    methods(Access=private)
        function self=ManifestUtilities(model,m3iComp)
            self.Model=get_param(model,'Handle');
            self.m3iModel=autosar.api.Utils.m3iModel(self.Model);
            self.modelName=get_param(self.Model,'Name');


            self.bindingType='DDS';

            if nargin==2
                self.m3iComp=m3iComp;
            else
                self.m3iComp=autosar.api.Utils.m3iMappedComponent(self.modelName);
            end


            self.portToMethodMap=self.getAutosarPortToMethodMap();

            self.portToEventMap=self.getAutosarPortToEventMap();

            if strcmp(self.bindingType,'UD')
                self.reqSrvcInstType='RequiredUserDefinedServiceInstance';
                self.provSrvcInstType='ProvidedUserDefinedServiceInstance';
            elseif strcmp(self.bindingType,'DDS')
                self.reqSrvcInstType='DdsRequiredServiceInstance';
                self.provSrvcInstType='DdsProvidedServiceInstance';
            end

            self.maxShortNameLength=autosar.internal.adaptive.manifest.ManifestUtilities.getMaxShortNameLength(self.modelName);

            self.defProcessName=arxml.arxml_private('p_create_aridentifier',...
            'DefaultInstance',self.maxShortNameLength);
            self.processPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_Processes'],self.maxShortNameLength);
            self.defProcessQualPath=['/',self.processPkgName,'/',self.defProcessName];

            self.defProcessDesignName=arxml.arxml_private('p_create_aridentifier',...
            'DefaultProcessDesign',self.maxShortNameLength);
            self.processDesignPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_ProcessDesigns'],self.maxShortNameLength);
            self.defProcessDesignQualPath=['/',self.processDesignPkgName,'/',self.defProcessDesignName];

            self.adaptivePlatformSIPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_ServiceInstances'],self.maxShortNameLength);
            self.siToPortMappingPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_ServiceInstanceToPortMappings'],self.maxShortNameLength);
            self.siDeploymentPkgname=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_Deployments'],self.maxShortNameLength);
            self.functionGroupSetPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_FunctionGroupSet'],self.maxShortNameLength);
            self.machinePkgName=arxml.arxml_private('p_create_aridentifier',...
            'Machines',self.maxShortNameLength);
            self.defMachineName=arxml.arxml_private('p_create_aridentifier',...
            'Host',self.maxShortNameLength);
            self.dltLogChnlToProcMappingPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_DltLogChannelToProcessMapping'],self.maxShortNameLength);


        end

        function fillManifestMetamodel(self,varargin)








            t=M3I.Transaction(self.m3iModel);


            [mdgPkgName,defModeDeclGrpName]=autosar.internal.adaptive.manifest.ManifestUtilities.getModeDeclPkgAndGroupNames(self.modelName);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,mdgPkgName);
            mdgObj=self.addModeDeclGrpToModeDeclGrpPkg(mdgPkgName,...
            defModeDeclGrpName);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Off',1);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Startup',2);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Running',3);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Idle',4);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Shutdown',5);
            self.addModeDeclarationToModeDeclGrp(mdgPkgName,...
            defModeDeclGrpName,'Restart',6);
            self.addInitRefForModeDeclGrp(mdgPkgName,defModeDeclGrpName,'Running');


            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.machinePkgName);
            mName=self.addMachineToMachinePackage(self.machinePkgName,self.defMachineName,60,60);


            mdgElement=self.addRemoveFunctionGroup(mName,mdgObj);

            self.addOSModuleInstantiationAndResourceGroupToMachine(...
            self.machinePkgName,self.defMachineName,'HostOsInstantiation',...
            'DefaultResourceGroup',4096000000,100);
            defLogChannelName='DefaultDltLogChannel';
            logLevel='Warn';
            logMode='Console';
            logTracePath='';
            applicationDesc=['Log messages for adaptive application ',self.modelName];
            applicationId=self.getRandomNumber();
            self.addLogAndTraceModuleInstantiationAndDltLogChannelToMachine(...
            self.machinePkgName,self.defMachineName,'LogAndTraceInstantiation',...
            defLogChannelName,logLevel,logTracePath,logMode,...
            applicationDesc,...
            applicationId);

            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Off',60,60);
            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Startup',60,60);
            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Running',60,60);
            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Idle',60,5);
            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Shutdown',60,60);
            self.addPerStateTimeoutToMachine(self.machinePkgName,...
            self.defMachineName,'Restart',120,60);


            execPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_','Executable'],self.maxShortNameLength);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,execPkgName);
            self.addExecutableToExecutablePackage(execPkgName,self.modelName,...
            'BuildTypeDebug','UsesLogging');


            startupConfigSetPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_StartupConfigSets'],self.maxShortNameLength);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,startupConfigSetPkgName);

            startupConfigSetName=arxml.arxml_private('p_create_aridentifier',...
            'DefaultStartupConfigSet',self.maxShortNameLength);
            startupConfigNameRR=arxml.arxml_private('p_create_aridentifier',...
            'StartupConfigRR',self.maxShortNameLength);
            startupConfigNameFifo=arxml.arxml_private('p_create_aridentifier',...
            'StartupConfigFifo',self.maxShortNameLength);
            startupConfigNameOther=arxml.arxml_private('p_create_aridentifier',...
            'StartupConfigOther',self.maxShortNameLength);

            self.addStartupConfigSetToStartupConfigSetPkg(...
            startupConfigSetPkgName,startupConfigSetName);
            self.addStartupConfigToStartupConfigSet(...
            startupConfigSetPkgName,startupConfigSetName,...
            startupConfigNameRR,'SchedulingPolicyRoundRobin',32);
            self.addStartupConfigToStartupConfigSet(...
            startupConfigSetPkgName,startupConfigSetName,...
            startupConfigNameFifo,'SchedulingPolicyFifo',32);
            self.addStartupConfigToStartupConfigSet(...
            startupConfigSetPkgName,startupConfigSetName,...
            startupConfigNameOther,'SchedulingPolicyOther',32);


            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.processPkgName);
            defLogChannelName='LogTraceDefaultLogLevel';
            self.addProcessToProcessPackage(self.processPkgName,...
            self.defProcessName,defLogChannelName,logLevel,logTracePath,logMode,...
            applicationDesc,applicationId,execPkgName,self.modelName);
            self.addStateDependentStartupConfigToProcess(...
            self.processPkgName,self.defProcessName,'StartupConfig',...
            startupConfigNameRR,'ResourceGroup','DefaultResourceGroup',...
            'FunctionGroupState','DummyName','Mode','Running',...
            'groupElement',mdgElement);


            ptomMappingPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_ProcessToMachineMappingSet'],self.maxShortNameLength);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,ptomMappingPkgName);
            self.addProToMachMapSetAndProToMachMapToProToMachMapSetPkg(...
            ptomMappingPkgName,self.machinePkgName,self.processPkgName,...
            'ProcessToMachineMappingSet','DefaultMapping',self.defMachineName,...
            self.defProcessName);


            self.addRemoveDltLogChannelToProcessMapping();


            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siDeploymentPkgname);



            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.adaptivePlatformSIPkgName);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siToPortMappingPkgName);

            self.setupServiceInstaceMetaModel(varargin{:});
            t.commit();

            metaClass=self.getMetaClassForCategory('ServiceInstanceToPortMapping');
            siToPortMappingPkg=autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siToPortMappingPkgName);
            self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
        end

        function addProcessDesignAndItsReferencesIfEmpty(self)




            t=M3I.Transaction(self.m3iModel);
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.processDesignPkgName);

            pdObj=self.findOrCreateProcessDesignInProcessDesignPackage(self.processDesignPkgName,...
            self.defProcessDesignName);



            if isempty(self.m3iSrvcInstToPortMappingSeqObj)
                metaClass=self.getMetaClassForCategory('ServiceInstanceToPortMapping');
                siToPortMappingPkg=autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siToPortMappingPkgName);
                self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
            end
            for i=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                siToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(i);
                if isempty(siToPortMapping.ProcessDesign)
                    siToPortMapping.ProcessDesign=pdObj;
                end
            end


            processes=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
            Simulink.metamodel.arplatform.manifest.Process.MetaClass);
            for i=1:processes.size()
                process=processes.at(i);
                if isempty(process.ProcessDesign)
                    process.ProcessDesign=pdObj;
                end
            end
            t.commit();
        end

        function addSeqAttribsForObj(self,objPath,propType,propName,varargin)
            m3iObj=autosar.mm.Model.findObjectByName(self.m3iModel,objPath).at(1);

            if m3iObj.getMetaClass.getProperty(propType).isComposite
                cObj=feval(m3iObj.getMetaClass.getProperty(propType).type.qualifiedName,self.m3iModel);
                cObj.Name=propName;

                if strcmp(m3iObj.getMetaClass.getProperty(propType).upper,'1')
                    m3iObj.(propType)=cObj;
                else
                    m3iObj.(propType).append(cObj);
                end
            end
            if~isempty(varargin)
                propObjPath=[objPath,'/',propName];
                self.setNonSeqAttribsForObj(propObjPath,varargin{:});
            end
        end

        function path=getFullPathForM3IObj(self,category,varargin)



            path='';
            metaClass=self.getMetaClassForCategory(category);
            seqObj=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,metaClass,true);

            if~isempty(seqObj)
                if~isempty(varargin)
                    [PName,PVal]=self.parseInputParams(varargin{:});
                    lenPName=length(PName);

                    for ii=1:lenPName
                        if strcmp(PName{ii},'Name')||strcmp(PName{ii},'name')
                            lenSeq=seqObj.size();

                            for jj=1:lenSeq
                                if strcmp(seqObj.at(jj).Name,PVal{ii})
                                    path=regexprep(seqObj.at(jj).qualifiedNameWithSeparator('/'),'^AUTOSAR','');
                                    break;
                                end
                            end
                            break;
                        end
                    end
                else
                    lenSeq=seqObj.size();
                    path=cell(0,lenSeq);
                    for ii=1:lenSeq
                        path{ii}=regexprep(seqObj.at(ii).qualifiedNameWithSeparator('/'),'^AUTOSAR','');
                    end
                end
            end
        end

        function m3iChildObj=addManifestPackageElement(self,pkgPath,pkgElemName,pkgElemType,varargin)

            autosar.api.Utils.checkQualifiedName(...
            self.Model,[pkgPath,'/',pkgElemName],'absPathShortName');


            m3iParentObj=autosar.mm.Model.getOrAddARPackage(self.m3iModel,pkgPath);

            childMetaClass=self.getMetaClassForCategory(pkgElemType);

            m3iChildObj=feval(childMetaClass.qualifiedName,self.m3iModel);
            m3iChildObj.Name=pkgElemName;
            m3iParentObj.('packagedElement').append(m3iChildObj);
        end

        function m3iElem=addModeDeclGrpToModeDeclGrpPkg(self,...
            modeDeclarationGroupPackageName,ModeDeclGrpName)
            mDGName=['/',modeDeclarationGroupPackageName,'/',ModeDeclGrpName];
            m3iSeq=autosar.mm.Model.findObjectByName(self.m3iModel,mDGName);
            if(m3iSeq.size()==0)
                m3iElem=self.addManifestPackageElement(['/',modeDeclarationGroupPackageName],...
                ModeDeclGrpName,'ModeDeclarationGroup');
            else
                m3iElem=m3iSeq.at(1);
            end
            self.markElementAsManifestARXML(m3iElem);
        end

        function addModeDeclarationToModeDeclGrp(self,...
            modeDeclarationGroupPackageName,ModeDeclGrpName,...
            ModeDeclName,Value)

            mDGName=['/',modeDeclarationGroupPackageName,'/',ModeDeclGrpName];
            mDName=[mDGName,'/',ModeDeclName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,mDName).size()==0)
                self.addSeqAttribsForObj(mDGName,'Mode',ModeDeclName,'Value',Value);
            end
        end

        function addInitRefForModeDeclGrp(self,modeDeclarationGroupPackageName,...
            ModeDeclGrpName,ModeDeclRef)

            mDGName=['/',modeDeclarationGroupPackageName,'/',ModeDeclGrpName];
            mDName=self.getFullPathForM3IObj('ModeDeclaration','Name',ModeDeclRef);

            mdObj=autosar.mm.Model.findObjectByName(self.m3iModel,mDName).at(1);

            self.setNonSeqAttribsForObj(mDGName,'InitialMode',mdObj);
        end

        function instanceID=getInstID(self,varargin)
            if~isempty(varargin)
                [pName,pVal]=self.parseInputParams(varargin{:});
                if strcmp(pName{1},'InstanceId')
                    instanceID=pVal{1};
                end
            else
                instanceID=self.getUnusedNumFromSequence(self.getSeqOfInstId(self.m3iModel,self.bindingType));
            end
        end

        function eDQPath=getEventDeployementQualifiedPath(self,sIDQPath,eventName)

            eventDeploymentName=arxml.arxml_private('p_create_aridentifier',['Deployment_',eventName],self.maxShortNameLength);
            eDQPath=[sIDQPath,'/',eventDeploymentName];
        end

        function mDQPath=getMethodDeployementQualifiedPath(self,sIDQPath,methodName)

            methodDeploymentName=arxml.arxml_private('p_create_aridentifier',['Deployment_',methodName],self.maxShortNameLength);
            mDQPath=[sIDQPath,'/',methodDeploymentName];
        end

        function sIDQPath=getServiceInterfaceDeploymentQualifiedPath(self,serviceInterfaceDeploymentName)

            sIDQPath=['/',self.siDeploymentPkgname,'/',serviceInterfaceDeploymentName];
        end

        function aPSIQPath=getServiceInstanceQualifiedPath(self,adapPlatformServInstName)

            aPSIQPath=['/',self.adaptivePlatformSIPkgName,'/',adapPlatformServInstName];
        end

        function validInstanceId=getvalidInstanceIdForDDS(self,instanceId,srvcInstObj)
            instanceId=self.replaceSpecialChars(instanceId);
            [isValid,~]=autosar.validation.AutosarUtils.checkServiceInstanceId(instanceId,class(srvcInstObj));
            if isValid
                validInstanceId=str2double(instanceId);
            else
                DAStudio.error('autosarstandard:ui:validateServiceInstanceId',class(srvcInstObj));
            end
        end

        function topicName=getValidTopicName(self,instanceId,eventName,eDQPath)
            topicName=eventName;
            if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))<49
                eventName=self.replaceSpecialChars(eventName);
                eventDplObj=autosar.mm.Model.findObjectByName(self.m3iModel,eDQPath).at(1);
                [isValid,~]=autosar.validation.AutosarUtils.checkDdsIdentifier([eventName,'-',num2str(instanceId)],class(eventDplObj));
                if isValid
                    topicName=eventName;
                end
            end
        end

        function setupDeploymentClass(self,sIDQPath,instanceId,prtObj)

            if strcmp(self.bindingType,'UD')
                self.addElementRecursiveToPackage(self.m3iModel,sIDQPath,'adminData',...
                'sdg','DummyNameToIgnore','gid',...
                instanceId);
            elseif strcmp(self.bindingType,'DDS')
                if self.portToEventMap.isKey(prtObj.Name)
                    mappedEvents=self.portToEventMap(prtObj.Name);
                    for ii=1:numel(mappedEvents)
                        self.addSeqAttribsForObj(sIDQPath,'EventDeployment',['Deployment_',mappedEvents{ii}])
                        eDQPath=self.getEventDeployementQualifiedPath(sIDQPath,mappedEvents{ii});
                        eventObj=self.getEventObj(prtObj,mappedEvents{ii});
                        topicName=self.getValidTopicName(instanceId,mappedEvents{ii},eDQPath);
                        self.setNonSeqAttribsForObj(eDQPath,'Event',eventObj,'TopicName',topicName,'TransportProtocol','Tcp');
                    end
                end


                if self.portToMethodMap.isKey(prtObj.Name)
                    mappedMethods=self.portToMethodMap(prtObj.Name);
                    for ii=1:numel(mappedMethods)
                        self.addSeqAttribsForObj(sIDQPath,'MethodDeployment',['Deployment_',mappedMethods{ii}])
                        mDQPath=self.getMethodDeployementQualifiedPath(sIDQPath,mappedMethods{ii});
                        methodObj=self.getMethodObj(prtObj,mappedMethods{ii});
                        self.setNonSeqAttribsForObj(mDQPath,'Method',methodObj,'TransportProtocol','Tcp');
                    end
                end
            end
        end

        function addSrvIfcDplToSrvIfcDplPkg(self,serviceInterfaceDeploymentPackagename,...
            servIfDplConcreteClassType,servIfDplName,prtObj,varargin)

            sIDQPath=self.getServiceInterfaceDeploymentQualifiedPath(servIfDplName);

            instanceId=self.getInstID(varargin{:});

            depObjSeq=autosar.mm.Model.findObjectByName(self.m3iModel,sIDQPath);
            if(depObjSeq.size()==0)
                self.addManifestPackageElement(['/',serviceInterfaceDeploymentPackagename],...
                servIfDplName,servIfDplConcreteClassType);
                self.setNonSeqAttribsForObj(sIDQPath,'ServiceInterface',prtObj.Type);
                self.setupDeploymentClass(sIDQPath,instanceId,prtObj)
            else
                if strcmp(self.bindingType,'UD')
                    self.setInstanceIDForDeployment(depObjSeq.at(1),instanceId);
                end
            end
        end

        function eventObj=getEventObj(~,portObj,eventName)


            eventObj='';
            if~isempty(portObj)&&portObj.isvalid()&&~isempty(portObj.Interface)
                m3iEventSeq=portObj.Interface.Events;
                for jj=1:m3iEventSeq.size()
                    if isequal(m3iEventSeq.at(jj).Name,eventName)
                        eventObj=m3iEventSeq.at(jj);
                        break;
                    end
                end
            end
        end

        function addDdsEventInfo(self,serviceInstanceToPortMapping,eventName)



            sIDQPath=self.getServiceInterfaceDeploymentQualifiedPath(serviceInstanceToPortMapping.ServiceInstance.Deployment.Name);
            evtDplName=arxml.arxml_private('p_create_aridentifier',['Deployment_',eventName],self.maxShortNameLength);
            self.addSeqAttribsForObj(sIDQPath,'EventDeployment',evtDplName);
            eDQPath=self.getEventDeployementQualifiedPath(sIDQPath,eventName);
            instanceId=self.getInstanceIDFromSrvcInstObj(serviceInstanceToPortMapping.ServiceInstance);
            eventObj=self.getEventObj(serviceInstanceToPortMapping.Port,eventName);
            topicName=self.getValidTopicName(instanceId,eventName,eDQPath);
            self.setNonSeqAttribsForObj(eDQPath,'Event',eventObj,'TopicName',topicName,'TransportProtocol','Tcp')
            aPSIQPath=self.getServiceInstanceQualifiedPath(serviceInstanceToPortMapping.ServiceInstance.Name);
            eDObj=autosar.mm.Model.findObjectByName(self.m3iModel,eDQPath).at(1);
            self.addElementRecursiveToPackage(self.m3iModel,aPSIQPath,'EventQosProps','QosProfile','RELIABLE','EventDeployment',eDObj);
        end

        function methodObj=getMethodObj(~,portObj,methodName)


            methodObj='';
            if~isempty(portObj)&&portObj.isvalid()&&~isempty(portObj.Interface)
                m3iMethodSeq=portObj.Interface.Methods;
                for jj=1:m3iMethodSeq.size()
                    if isequal(m3iMethodSeq.at(jj).Name,methodName)
                        methodObj=m3iMethodSeq.at(jj);
                        break;
                    end
                end
            end
        end

        function addDdsMethodInfo(self,serviceInstanceToPortMapping,methodName)



            sIDQPath=self.getServiceInterfaceDeploymentQualifiedPath(serviceInstanceToPortMapping.ServiceInstance.Deployment.Name);
            mthDplName=arxml.arxml_private('p_create_aridentifier',['Deployment_',methodName],self.maxShortNameLength);
            self.addSeqAttribsForObj(sIDQPath,'MethodDeployment',mthDplName);
            mDQPath=self.getMethodDeployementQualifiedPath(sIDQPath,methodName);
            methodObj=self.getMethodObj(serviceInstanceToPortMapping.Port,methodName);
            self.setNonSeqAttribsForObj(mDQPath,'Method',methodObj,'TransportProtocol','Tcp')
            aPSIQPath=self.getServiceInstanceQualifiedPath(serviceInstanceToPortMapping.ServiceInstance.Name);
            mDObj=autosar.mm.Model.findObjectByName(self.m3iModel,mDQPath).at(1);
            self.addElementRecursiveToPackage(self.m3iModel,aPSIQPath,'MethodQosProps','QosProfile','RELIABLE','MethodDeployment',mDObj);
        end

        function addDdsQosPropsToServiceInstance(self,fieldName,instanceId,aPSIQPath,sIDObj)


            m3iEvtDeplSeq=sIDObj.EventDeployment;
            for ii=1:m3iEvtDeplSeq.size()
                eDObj=m3iEvtDeplSeq.at(ii);
                self.addElementRecursiveToPackage(self.m3iModel,aPSIQPath,'EventQosProps','QosProfile','RELIABLE','EventDeployment',eDObj);
            end


            m3iMthDeplSeq=sIDObj.MethodDeployment;
            for ii=1:m3iMthDeplSeq.size()
                mDObj=m3iMthDeplSeq.at(ii);
                self.addElementRecursiveToPackage(self.m3iModel,aPSIQPath,'MethodQosProps','QosProfile','RELIABLE','MethodDeployment',mDObj);
            end
            srvcInstObj=autosar.mm.Model.findObjectByName(self.m3iModel,aPSIQPath).at(1);
            instanceId=self.getvalidInstanceIdForDDS(instanceId,srvcInstObj);
            self.setNonSeqAttribsForObj(aPSIQPath,fieldName,instanceId);
        end

        function[adapPlatformServInstName,srvIntfDeplName,deploymentType,fieldName]=getDeploymentNames(self,index,diffSuffix)

            if strcmp(self.bindingType,'UD')
                adapPlatformServInstName=arxml.arxml_private('p_create_aridentifier',['UserDefinedSI_',diffSuffix,num2str(index)],self.maxShortNameLength);
                srvIntfDeplName=arxml.arxml_private('p_create_aridentifier',['UserDefinedDeployment_',diffSuffix,num2str(index)],self.maxShortNameLength);
                deploymentType='UserDefinedServiceInterfaceDeployment';
                fieldName='';
            elseif strcmp(self.bindingType,'DDS')
                adapPlatformServInstName=arxml.arxml_private('p_create_aridentifier',['DdsSI_',diffSuffix,num2str(index)],self.maxShortNameLength);
                srvIntfDeplName=arxml.arxml_private('p_create_aridentifier',['DdsDeployment_',diffSuffix,num2str(index)],self.maxShortNameLength);
                deploymentType='DdsServiceInterfaceDeployment';
                fieldName='InstanceId';
            end
        end

        function addDplSrvInstPrtMapping(self,diffSuffix,...
            srvInstType,prtObj,index,varargin)



            srvInstPortMapName=arxml.arxml_private('p_create_aridentifier',['Mapping_',diffSuffix,num2str(index)],self.maxShortNameLength);
            sIPMName=['/',self.siToPortMappingPkgName,'/',srvInstPortMapName];

            [adapPlatformServInstName,srvIntfDeplName,deploymentType,fieldName]=self.getDeploymentNames(index,diffSuffix);

            aPSIQPath=self.getServiceInstanceQualifiedPath(adapPlatformServInstName);

            sIDQPath=self.getServiceInterfaceDeploymentQualifiedPath(srvIntfDeplName);


            self.addSrvIfcDplToSrvIfcDplPkg(self.siDeploymentPkgname,...
            deploymentType,srvIntfDeplName,prtObj,varargin{:});


            if(autosar.mm.Model.findObjectByNameAndMetaClass(self.m3iModel,aPSIQPath,self.getMetaClassForCategory('AdaptivePlatformServiceInstance'),true).size()==0)
                self.addManifestPackageElement(['/',self.adaptivePlatformSIPkgName],...
                adapPlatformServInstName,srvInstType);
                if strcmp(self.bindingType,'DDS')
                    depObjSeq=autosar.mm.Model.findObjectByName(self.m3iModel,sIDQPath);
                    instanceId=self.getInstID(varargin{:});
                    self.addDdsQosPropsToServiceInstance(fieldName,instanceId,aPSIQPath,depObjSeq.at(1));
                end
                sidObj=autosar.mm.Model.findObjectByName(self.m3iModel,sIDQPath).at(1);
                self.setNonSeqAttribsForObj(aPSIQPath,'Deployment',sidObj);
            end


            if(autosar.mm.Model.findObjectByNameAndMetaClass(self.m3iModel,sIPMName,self.getMetaClassForCategory('ServiceInstanceToPortMapping'),true).size()==0)
                self.addManifestPackageElement(['/',self.siToPortMappingPkgName],...
                srvInstPortMapName,'ServiceInstanceToPortMapping');
                pObj=autosar.mm.Model.findObjectByName(self.m3iModel,self.defProcessQualPath).at(1);
                apsiObj=autosar.mm.Model.findObjectByName(self.m3iModel,aPSIQPath).at(1);

                self.addElementRecursiveToPackage(self.m3iModel,sIPMName,'PortPrototype',...
                'Port',prtObj);

                self.setNonSeqAttribsForObj(sIPMName,'Process',pObj,...
                'ServiceInstance',apsiObj);
            end
        end

        function setupServiceInstaceMetaModel(self,varargin)






            stPIndex=1;
            stRIndex=1;
            if~isempty(varargin)
                [PName,PVal]=self.parseInputParams(varargin{:});
                for ii=1:length(PName)
                    if strcmp(PName{ii},'Port')
                        portObj=PVal{ii};
                    end
                    if strcmp(PName{ii},'InstanceId')
                        instId=PVal{ii};
                    end
                end

                if isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                    prefix='PP';
                    stPIndex=stPIndex+1;
                    self.addDplSrvInstPrtMapping(prefix,self.provSrvcInstType,...
                    portObj,1,'InstanceId',instId);
                else
                    prefix='RP';
                    stRIndex=stRIndex+1;
                    self.addDplSrvInstPrtMapping(prefix,self.reqSrvcInstType,...
                    portObj,1,'InstanceId',instId);
                end
            end


            for ii=1:self.m3iComp.RequiredPorts.size()
                if~isempty(varargin)
                    if portObj==self.m3iComp.RequiredPorts.at(ii)
                        continue;
                    end
                end




                self.addDplSrvInstPrtMapping('RP',self.reqSrvcInstType,...
                self.m3iComp.RequiredPorts.at(ii),stRIndex);
                stRIndex=stRIndex+1;
            end


            for ii=1:self.m3iComp.ProvidedPorts.size()
                if~isempty(varargin)
                    if portObj==self.m3iComp.ProvidedPorts.at(ii)
                        continue;
                    end
                end
                self.addDplSrvInstPrtMapping('PP',self.provSrvcInstType,...
                self.m3iComp.ProvidedPorts.at(ii),stPIndex);
                stPIndex=stPIndex+1;
            end
        end

        function destroySrvInstToPortMapObj(~,mapObj)
            mapObj.ServiceInstance.Deployment.destroy();
            mapObj.ServiceInstance.destroy();
            mapObj.destroy();
        end

        function largestNum=getLargestIntUnusedInSrvInstPortMapping(self,portType)

            if strcmp(portType,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                seqObjKey='Mapping_PP';
            else
                seqObjKey='Mapping_RP';
            end
            seqObj={seqObjKey};
            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                if isa(self.m3iSrvcInstToPortMappingSeqObj.at(ii).Port,portType)
                    seqObj{end+1}=self.m3iSrvcInstToPortMappingSeqObj.at(ii).Name;%#ok<AGROW>
                end
            end

            tNum=regexp(genvarname(seqObjKey,seqObj),'\d','match');
            largestNum=[tNum{:}];
        end

        function cleanAndSyncManifestMetaModel(self)


            metaClass=self.getMetaClassForCategory('ServiceInstanceToPortMapping');

            inPortNameToObjMap=containers.Map;
            outPortNameToObjMap=containers.Map;


            for ii=1:self.m3iComp.RequiredPorts.size()
                if~inPortNameToObjMap.isKey(self.m3iComp.RequiredPorts.at(ii).Name)
                    inPortNameToObjMap(self.m3iComp.RequiredPorts.at(ii).Name)=...
                    self.m3iComp.RequiredPorts.at(ii);
                end
            end


            for ii=1:self.m3iComp.ProvidedPorts.size()
                if~outPortNameToObjMap.isKey(self.m3iComp.ProvidedPorts.at(ii).Name)
                    outPortNameToObjMap(self.m3iComp.ProvidedPorts.at(ii).Name)=...
                    self.m3iComp.ProvidedPorts.at(ii);
                end
            end
            t=M3I.Transaction(self.m3iModel);

            [mdgPkgName,defModeDeclGrpName]=autosar.internal.adaptive.manifest.ManifestUtilities.getModeDeclPkgAndGroupNames(self.modelName);
            mDGName=['/',mdgPkgName,'/',defModeDeclGrpName];
            mName=['/',self.machinePkgName,'/',self.defMachineName];
            mdgObj=autosar.mm.Model.findObjectByName(self.m3iModel,mDGName).at(1);



            self.addRemoveFunctionGroup(mName,mdgObj);


            self.addRemoveDltModule(mName);


            self.addRemoveDltLogChannelToProcessMapping();



            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                m3iSrvcInstToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                if~m3iSrvcInstToPortMapping.Port.isvalid()
                    self.destroySrvInstToPortMapObj(m3iSrvcInstToPortMapping);
                elseif isempty(m3iSrvcInstToPortMapping.Port)
                    self.destroySrvInstToPortMapObj(m3iSrvcInstToPortMapping);
                elseif(~inPortNameToObjMap.isKey(m3iSrvcInstToPortMapping.Port.Name)&&...
                    ~outPortNameToObjMap.isKey(m3iSrvcInstToPortMapping.Port.Name))
                    self.destroySrvInstToPortMapObj(m3iSrvcInstToPortMapping);
                else
                    continue;
                end
            end

            siToPortMappingPkg=autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siToPortMappingPkgName);
            self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);

            mappedInports=containers.Map;
            mappedOutports=containers.Map;

            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                siToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                if isa(siToPortMapping.Port,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                    if~mappedOutports.isKey(siToPortMapping.Port.Name)
                        mappedOutports(siToPortMapping.Port.Name)='';
                    end
                else
                    if~mappedInports.isKey(siToPortMapping.Port.Name)
                        mappedInports(siToPortMapping.Port.Name)='';
                    end
                end
            end





            allMappedInports=inPortNameToObjMap.keys;
            for ii=1:numel(allMappedInports)
                if~mappedInports.isKey(allMappedInports{ii})
                    self.addDplSrvInstPrtMapping('RP',...
                    self.reqSrvcInstType,...
                    inPortNameToObjMap(allMappedInports{ii}),...
                    self.getLargestIntUnusedInSrvInstPortMapping(...
                    'Simulink.metamodel.arplatform.port.ServiceRequiredPort'));
                    self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
                end
            end


            allMappedOutports=outPortNameToObjMap.keys;
            for ii=1:numel(allMappedOutports)
                if~mappedOutports.isKey(allMappedOutports{ii})
                    self.addDplSrvInstPrtMapping('PP',...
                    self.provSrvcInstType,...
                    outPortNameToObjMap(allMappedOutports{ii}),...
                    self.getLargestIntUnusedInSrvInstPortMapping(...
                    'Simulink.metamodel.arplatform.port.ServiceProvidedPort'));
                    self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
                end
            end

            if strcmp(self.bindingType,'DDS')
                self.cleanAndSyncSIMMForEvnts();
                self.cleanAndSyncSIMMForMthds();
            end

            t.commit();
        end

        function cleanAndSyncSIMMBasedOnPrtForEvnts(self,portTypeSeq,portToEventMapFromModelMapping,portToEventMapFromMetaModel)



            portToEventRemoveMap=containers.Map;
            portToEventAddMap=containers.Map;

            for ii=1:portTypeSeq.size()
                eventsFromModelMapping={};
                eventsFromDeployment={};
                portName=portTypeSeq.at(ii).Name;
                if portToEventMapFromModelMapping.isKey(portName)
                    eventsFromModelMapping=portToEventMapFromModelMapping(portName);
                end
                if portToEventMapFromMetaModel.isKey(portName)
                    eventsFromDeployment=portToEventMapFromMetaModel(portName);
                end
                evtsToAdd=setdiff(eventsFromModelMapping,eventsFromDeployment);
                if~isempty(evtsToAdd)
                    portToEventAddMap(portName)=evtsToAdd;
                end
                evtsToRemove=setdiff(eventsFromDeployment,eventsFromModelMapping);
                if~isempty(evtsToRemove)
                    portToEventRemoveMap(portName)=evtsToRemove;
                end
            end

            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                serviceInstanceToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                portName=serviceInstanceToPortMapping.Port.Name;

                if portToEventRemoveMap.isKey(portName)
                    events=portToEventRemoveMap(portName);
                else
                    events={};
                end
                indices=[];
                for kk=1:serviceInstanceToPortMapping.ServiceInstance.EventQosProps.size()
                    eventQosProps=serviceInstanceToPortMapping.ServiceInstance.EventQosProps.at(kk);
                    if~eventQosProps.EventDeployment.Event.isvalid()||...
                        (any(strcmp(events,eventQosProps.EventDeployment.Event.Name)))

                        indices(end+1)=kk;
                    elseif eventQosProps.EventDeployment.Event.isvalid()&&...
                        (strcmp(eventQosProps.EventDeployment.Name,...
                        arxml.arxml_private('p_create_aridentifier',['Deployment_',eventQosProps.EventDeployment.Event.Name],self.maxShortNameLength))==0)


                        eventQosProps.EventDeployment.Name=arxml.arxml_private('p_create_aridentifier',['Deployment_',eventQosProps.EventDeployment.Event.Name],self.maxShortNameLength);
                    end
                end
                if~isempty(indices)



                    indices=flip(indices);
                    for kk=1:numel(indices)
                        eventQosProps=serviceInstanceToPortMapping.ServiceInstance.EventQosProps.at(indices(kk));
                        eventQosProps.EventDeployment.destroy();
                        eventQosProps.destroy();
                    end
                end
                if portToEventAddMap.isKey(portName)


                    events=portToEventAddMap(portName);
                    for ll=1:numel(events)
                        self.addDdsEventInfo(serviceInstanceToPortMapping,events{ll});
                    end
                end
            end
        end

        function cleanAndSyncSIMMBasedOnPrtForMthds(self,portTypeSeq,portToMethodMapFromModelMapping,portToMethodMapFromMetaModel)



            portToMethodsRemoveMap=containers.Map;
            portToMethodsAddMap=containers.Map;

            for ii=1:portTypeSeq.size()
                methodsFromModelMapping={};
                methodsFromDeployment={};
                portName=portTypeSeq.at(ii).Name;
                if portToMethodMapFromModelMapping.isKey(portName)
                    methodsFromModelMapping=portToMethodMapFromModelMapping(portName);
                end
                if portToMethodMapFromMetaModel.isKey(portName)
                    methodsFromDeployment=portToMethodMapFromMetaModel(portName);
                end
                mthdsToAdd=setdiff(methodsFromModelMapping,methodsFromDeployment);
                if~isempty(mthdsToAdd)
                    portToMethodsAddMap(portName)=mthdsToAdd;
                end
                mthdsToRemove=setdiff(methodsFromDeployment,methodsFromModelMapping);
                if~isempty(mthdsToRemove)
                    portToMethodsRemoveMap(portName)=mthdsToRemove;
                end
            end

            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                serviceInstanceToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                portName=serviceInstanceToPortMapping.Port.Name;


                sIDQPath=self.getServiceInterfaceDeploymentQualifiedPath(serviceInstanceToPortMapping.ServiceInstance.Deployment.Name);
                sIDObj=autosar.mm.Model.findObjectByName(self.m3iModel,sIDQPath);
                if sIDObj.size()>0
                    for jj=1:sIDObj.size()
                        sIDElem=sIDObj.at(jj);
                        if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))>=49
                            if sIDElem.TransportProtocol.size()==0
                                self.setNonSeqAttribsForObj(sIDQPath,'TransportProtocol','Tcp');
                            end
                        else
                            if sIDElem.TransportProtocol.size()>0
                                sIDElem.TransportProtocol.clear();
                            end
                        end
                    end
                end



                methodsFromModelMapping={};
                if portToMethodMapFromModelMapping.isKey(portName)
                    methodsFromModelMapping=portToMethodMapFromModelMapping(portName);
                end

                for i=1:length(methodsFromModelMapping)
                    methodName=methodsFromModelMapping{i};
                    mDQPath=self.getMethodDeployementQualifiedPath(sIDQPath,methodName);
                    methodObj=autosar.mm.Model.findObjectByName(self.m3iModel,mDQPath);
                    if methodObj.size()>0
                        methodElem=methodObj.at(1);
                        if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))>=49
                            if methodElem.TransportProtocol.size()>0
                                methodElem.TransportProtocol.clear();
                            end
                        else
                            if methodElem.TransportProtocol.size()==0
                                self.setNonSeqAttribsForObj(mDQPath,'TransportProtocol','Tcp')
                            end
                        end
                    end
                end

                if portToMethodsRemoveMap.isKey(portName)
                    methods=portToMethodsRemoveMap(portName);
                else
                    methods={};
                end
                indices=[];
                for kk=1:serviceInstanceToPortMapping.ServiceInstance.MethodQosProps.size()
                    methodQosProps=serviceInstanceToPortMapping.ServiceInstance.MethodQosProps.at(kk);
                    if~methodQosProps.MethodDeployment.Method.isvalid()||...
                        (any(strcmp(methods,methodQosProps.MethodDeployment.Method.Name)))


                        indices(end+1)=kk;
                    elseif methodQosProps.MethodDeployment.Method.isvalid()&&...
                        (strcmp(methodQosProps.MethodDeployment.Name,...
                        arxml.arxml_private('p_create_aridentifier',['Deployment_',methodQosProps.MethodDeployment.Method.Name],self.maxShortNameLength))==0)


                        methodQosProps.MethodDeployment.Name=arxml.arxml_private('p_create_aridentifier',['Deployment_',methodQosProps.MethodDeployment.Method.Name],self.maxShortNameLength);
                    end
                end
                if~isempty(indices)



                    indices=flip(indices);
                    for kk=1:numel(indices)
                        methodQosProps=serviceInstanceToPortMapping.ServiceInstance.MethodQosProps.at(indices(kk));
                        methodQosProps.MethodDeployment.destroy();
                        methodQosProps.destroy();
                    end
                end
                if portToMethodsAddMap.isKey(portName)


                    methods=portToMethodsAddMap(portName);
                    for ll=1:numel(methods)
                        self.addDdsMethodInfo(serviceInstanceToPortMapping,methods{ll});
                    end
                end
            end
        end

        function portToEventMapFromMetaModel=getAutosarPortToEventMappingFromMetaModel(self)

            portToEventMapFromMetaModel=containers.Map;
            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                m3iSvrcInstToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                eventDplySeq=m3iSvrcInstToPortMapping.ServiceInstance.Deployment.EventDeployment;
                for jj=1:eventDplySeq.size()
                    if eventDplySeq.at(jj).Event.isvalid()
                        eventName=eventDplySeq.at(jj).Event.Name;
                        if~portToEventMapFromMetaModel.isKey(m3iSvrcInstToPortMapping.Port.Name)
                            portToEventMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name)={eventName};
                        else
                            values=portToEventMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name);
                            portToEventMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name)=[values,{eventName}];
                        end
                    end
                end
            end
        end

        function portToMethodMapFromMetaModel=getAutosarPortToMethodMappingFromMetaModel(self)

            portToMethodMapFromMetaModel=containers.Map;
            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                m3iSvrcInstToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                methodDplySeq=m3iSvrcInstToPortMapping.ServiceInstance.Deployment.MethodDeployment;
                for jj=1:methodDplySeq.size()
                    methodDplyObj=methodDplySeq.at(jj);
                    if methodDplyObj.Method.isvalid()
                        methodName=methodDplyObj.Method.Name;
                        if~portToMethodMapFromMetaModel.isKey(m3iSvrcInstToPortMapping.Port.Name)
                            portToMethodMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name)={methodName};
                        else
                            values=portToMethodMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name);
                            portToMethodMapFromMetaModel(m3iSvrcInstToPortMapping.Port.Name)=[values,{methodName}];
                        end
                    end
                end
            end
        end

        function cleanAndSyncSIMMForEvnts(self)
            mapping=autosar.api.Utils.modelMapping(self.modelName);
            requiredportNameToEventNameMap=self.getAutosarPortToEventMapping(mapping.Inports);
            providedportNameToEventNameMap=self.getAutosarPortToEventMapping(mapping.Outports);
            portToEventMapFromMetaModel=self.getAutosarPortToEventMappingFromMetaModel();
            self.cleanAndSyncSIMMBasedOnPrtForEvnts(self.m3iComp.RequiredPorts,requiredportNameToEventNameMap,portToEventMapFromMetaModel);
            self.cleanAndSyncSIMMBasedOnPrtForEvnts(self.m3iComp.ProvidedPorts,providedportNameToEventNameMap,portToEventMapFromMetaModel);
        end

        function cleanAndSyncSIMMForMthds(self)
            mapping=autosar.api.Utils.modelMapping(self.modelName);
            requiredportNameToMethodNameMap=self.getAutosarPortToMethodMapInternal(mapping.ClientPorts);
            providedportNameToMethodNameMap=self.getAutosarPortToMethodMapInternal(mapping.ServerPorts);
            portToMethodMapFromMetaModel=self.getAutosarPortToMethodMappingFromMetaModel();
            self.cleanAndSyncSIMMBasedOnPrtForMthds(self.m3iComp.RequiredPorts,requiredportNameToMethodNameMap,portToMethodMapFromMetaModel);
            self.cleanAndSyncSIMMBasedOnPrtForMthds(self.m3iComp.ProvidedPorts,providedportNameToMethodNameMap,portToMethodMapFromMetaModel);
        end

        function instanceID=getInstanceIDFromSrvcInstObj(~,srvcInstObj)
            instanceID='';
            if isa(srvcInstObj,'Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance')||...
                isa(srvcInstObj,'Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance')
                if srvcInstObj.Deployment.adminData.isvalid()
                    instanceID=srvcInstObj.Deployment.adminData.sdg.at(1).gid;
                end
            elseif isa(srvcInstObj,'Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance')||...
                isa(srvcInstObj,'Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance')
                instanceID=num2str(srvcInstObj.InstanceId);
            else
                assert(false,'Need to handle this case.');
            end
        end

        function instanceID=getInstanceIDFromDeploymentObj(~,dplObj)
            instanceID='';
            if isa(dplObj,'Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment')
                if dplObj.adminData.isvalid()
                    instanceID=dplObj.adminData.sdg.at(1).gid;
                end
            end
        end

        function setInstanceIDForDeployment(self,dplObj,instanceID)
            if dplObj.adminData.isvalid()
                dplObj.adminData.sdg.at(1).gid=instanceID;
            else
                self.addElementRecursiveToPackageByObj(self.m3iModel,dplObj,'adminData',...
                'sdg','DummyNameToIgnore','gid',instanceID);
            end
        end

        function instanceID=getInstanceIDForPort(self,portObj)
            instanceID='';
            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                serviceInstanceToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                if serviceInstanceToPortMapping.Port==portObj
                    instanceID=self.getInstanceIDFromSrvcInstObj(serviceInstanceToPortMapping.ServiceInstance);
                    break;
                end
            end
        end

        function setInstanceIDForPort(self,portObj,instanceID)
            bFoundMatch=false;
            for ii=1:self.m3iSrvcInstToPortMappingSeqObj.size()
                serviceInstanceToPortMapping=self.m3iSrvcInstToPortMappingSeqObj.at(ii);
                if serviceInstanceToPortMapping.Port==portObj
                    bFoundMatch=true;
                    if strcmp(self.bindingType,'UD')&&isa(serviceInstanceToPortMapping.ServiceInstance.Deployment,'Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment')
                        deploymentObj=serviceInstanceToPortMapping.ServiceInstance.Deployment;
                        [error,instanceID]=autosar.internal.adaptive.manifest.ManifestUtilities.validateServiceInstance(instanceID,'InstanceIdentifier');
                        if error
                            DAStudio.error('autosarstandard:validation:errorIdentifyServiceInstance',...
                            self.modelName,'InstanceIdentifier');
                        else
                            self.setInstanceIDForDeployment(deploymentObj,instanceID);
                        end
                        break;
                    elseif strcmp(self.bindingType,'DDS')&&(isa(serviceInstanceToPortMapping.ServiceInstance,'Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance')||...
                        isa(serviceInstanceToPortMapping.ServiceInstance,'Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance'))
                        validInstanceId=self.getvalidInstanceIdForDDS(instanceID,serviceInstanceToPortMapping.ServiceInstance);
                        serviceInstanceToPortMapping.ServiceInstance.InstanceId=validInstanceId;
                        break;
                    else
                        assert(false,'Need to handle this case.');
                    end
                end
            end


            if~bFoundMatch
                if isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                    sfx='PP';
                    srvPortType='Simulink.metamodel.arplatform.port.ServiceProvidedPort';
                    self.addDplSrvInstPrtMapping(sfx,...
                    self.provSrvcInstType,portObj,self.getLargestIntUnusedInSrvInstPortMapping(...
                    srvPortType),'InstanceId',instanceID);

                else
                    sfx='RP';
                    srvPortType='Simulink.metamodel.arplatform.port.ServiceRequiredPort';
                    self.addDplSrvInstPrtMapping(sfx,...
                    self.reqSrvcInstType,portObj,self.getLargestIntUnusedInSrvInstPortMapping(...
                    srvPortType),'InstanceId',instanceID);
                end
                siToPortMappingPkg=autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.siToPortMappingPkgName);
                self.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass,true);

            end
        end

        function addProToMachMapSetAndProToMachMapToProToMachMapSetPkg(self,...
            processToMachineMappingPackageName,machinePackageName,...
            processPackageName,ProcessToMachineMappingSetName,...
            ProcessToMachineMappingName,MachineRef,ProcessRef)

            pTMMSName=['/',processToMachineMappingPackageName,'/',ProcessToMachineMappingSetName];
            pTMMName=[pTMMSName,'/',ProcessToMachineMappingName];
            mName=['/',machinePackageName,'/',MachineRef];
            pName=['/',processPackageName,'/',ProcessRef];

            if(autosar.mm.Model.findObjectByName(self.m3iModel,pTMMSName).size()==0)
                self.addManifestPackageElement(['/',processToMachineMappingPackageName],...
                ProcessToMachineMappingSetName,'ProcessToMachineMappingSet');
            end

            if(autosar.mm.Model.findObjectByName(self.m3iModel,pTMMName).size()==0)
                self.addSeqAttribsForObj(pTMMSName,'ProcessToMachineMapping',...
                ProcessToMachineMappingName);

                mObj=autosar.mm.Model.findObjectByName(self.m3iModel,mName).at(1);
                pObj=autosar.mm.Model.findObjectByName(self.m3iModel,pName).at(1);
                self.setNonSeqAttribsForObj(pTMMName,'Machine',mObj,...
                'Process',pObj);
            end
        end

        function addDltLogChannelToProcessMapPkg(self,dltLogChnlToProcMappingPkgName,...
            dltLogChnlToProcMappingName,machinePackageName,processPackageName,MachineRef,ProcessRef)
            dltLogChnlToProcMappinPath=['/',dltLogChnlToProcMappingPkgName,'/',dltLogChnlToProcMappingName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,dltLogChnlToProcMappinPath).size()==0)
                self.addManifestPackageElement(['/',dltLogChnlToProcMappingPkgName],...
                dltLogChnlToProcMappingName,'DltLogChannelToProcessMapping');
                mName=['/',machinePackageName,'/',MachineRef];
                pName=['/',processPackageName,'/',ProcessRef];


                mObj=autosar.mm.Model.findObjectByName(self.m3iModel,mName).at(1);
                pObj=autosar.mm.Model.findObjectByName(self.m3iModel,pName).at(1);
                dltLogChnlObj=mObj.LogAndTraceInstantiation.at(1).DltLogChannel.at(1);
                self.setNonSeqAttribsForObj(dltLogChnlToProcMappinPath,'DltLogChannel',dltLogChnlObj,'Process',pObj);
            end
        end


        function addStartupConfigSetToStartupConfigSetPkg(self,...
            startupConfigSetPackageName,startupConfigSetName)

            sCSName=['/',startupConfigSetPackageName,'/',startupConfigSetName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,sCSName).size()==0)
                self.addManifestPackageElement(['/',startupConfigSetPackageName],startupConfigSetName,'StartupConfigSet');
            end
        end

        function addStartupConfigToStartupConfigSet(self,...
            startupConfigSetPackageName,startupConfigSetName,...
            startupConfigName,schedPolicy,schedPrio)

            sCSName=['/',startupConfigSetPackageName,'/',startupConfigSetName];
            sCName=[sCSName,'/',startupConfigName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,sCName).size()==0)
                self.addSeqAttribsForObj(sCSName,'StartupConfig',startupConfigName,...
                'SchedulingPolicy',schedPolicy,'SchedulingPriority',schedPrio);
            end
        end

        function addEnvironmentVarToStartupConfig(self,startupConfigName,...
            key,value)

            sTCName=self.getFullPathForM3IObj('StartupConfig','Name',startupConfigName);

            self.addElementRecursiveToPackage(self.m3iModel,sTCName,'EnvironmentVariable',...
            'Key',key,'Value',value);
        end

        function addStartupOptionToStartupConfig(self,startupConfigName,...
            optArg,optKind,optName)

            sTCName=self.getFullPathForM3IObj('StartupConfig','Name',startupConfigName);

            self.addElementRecursiveToPackage(self.m3iModel,sTCName,'StartupOption',...
            'OptionArgument',optArg,'OptionKind',optKind,'OptionName',optName);
        end

        function mName=addMachineToMachinePackage(self,machinePackageName,...
            machineName,defEnterTimeout,defExitTimeout)

            mName=['/',machinePackageName,'/',machineName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,mName).size()==0)
                self.addManifestPackageElement(['/',machinePackageName],machineName,'Machine');

                self.setNonSeqAttribsForObj(mName,...
                'DefaultApplicationEnterTimeout',defEnterTimeout,...
                'DefaultApplicationExitTimeout',defExitTimeout);

            end
        end

        function addFunctionGroupSet(self,fcnGrpPackageName,fcGrpName,mdgObj)

            fName=['/',fcnGrpPackageName,'/',fcGrpName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,fName).size()==0)
                self.addManifestPackageElement(['/',fcnGrpPackageName],fcGrpName,'FunctionGroupSet');
                self.addSeqAttribsForObj(fName,'FunctionGroup',strcat(fcGrpName,...
                '_','ModeDeclarationGroupElement'),'ModeGroup',mdgObj);
            end
        end

        function addOSModuleInstantiationAndResourceGroupToMachine(self,...
            machinePackageName,machineName,oSMInstName,resGrpName,...
            rGMemUsage,rGCPUUsage)

            mName=['/',machinePackageName,'/',machineName];
            oSMName=[mName,'/',oSMInstName];

            if(autosar.mm.Model.findObjectByName(self.m3iModel,oSMName).size()==0)
                self.addSeqAttribsForObj(mName,'OsModuleInstantiation',oSMInstName);
            end

            rGName=[oSMName,'/',resGrpName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,rGName).size()==0)
                self.addSeqAttribsForObj(oSMName,'ResourceGroup',resGrpName,...
                'MemUsage',rGMemUsage,'CpuUsage',rGCPUUsage);
            end
        end

        function addLogAndTraceModuleInstantiationAndDltLogChannelToMachine(self,...
            machinePackageName,machineName,lAndTInstName,dltChannelName,...
            lLevel,lTracePath,lTLMode,applicationDesc,...
            applicationId)

            mName=['/',machinePackageName,'/',machineName];
            lAndTChannelName=[mName,'/',lAndTInstName];

            if(autosar.mm.Model.findObjectByName(self.m3iModel,lAndTChannelName).size()==0)
                self.addSeqAttribsForObj(mName,'LogAndTraceInstantiation',lAndTInstName);
            end

            logChannelName=[lAndTChannelName,'/',dltChannelName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,logChannelName).size()==0)
                self.addSeqAttribsForObj(lAndTChannelName,'DltLogChannel',dltChannelName,...
                'LogTraceDefaultLogLevel',lLevel,...
                'LogTraceFilePath',lTracePath,'LogTraceLogMode',lTLMode,...
                'ApplicationDesc',applicationDesc,...
                'ApplicationId',applicationId);
            end
        end

        function addPerStateTimeoutToMachine(self,machinePackageName,...
            machineName,modeDeclRef,enterTimeoutValue,exitTimeoutValue)

            mDName=self.getFullPathForM3IObj('ModeDeclaration','Name',modeDeclRef);
            mName=['/',machinePackageName,'/',machineName];

            mObj=autosar.mm.Model.findObjectByName(self.m3iModel,mName).at(1);
            mdObj=autosar.mm.Model.findObjectByName(self.m3iModel,mDName).at(1);
            if(mObj.PerStateTimeout.size<autosar.internal.adaptive.manifest.ManifestUtilities.numOfPerStateTimeout)
                self.addElementRecursiveToPackage(self.m3iModel,mName,'PerStateTimeout',...
                'State',mdObj,'EnterTimeout',enterTimeoutValue,...
                'ExitTimeout',exitTimeoutValue);
            end
        end

        function addProcessToProcessPackage(self,processPackageName,...
            processName,defLogChannelName,lLevel,lTracePath,lTLMode,lTProcessDesc,...
            lTProcessId,executablePackageName,execRef)

            pName=['/',processPackageName,'/',processName];
            eName=['/',executablePackageName,'/',execRef];

            if(autosar.mm.Model.findObjectByName(self.m3iModel,pName).size()==0)
                self.addManifestPackageElement(['/',processPackageName],...
                processName,'Process');

                eObj=autosar.mm.Model.findObjectByName(self.m3iModel,eName).at(1);

                self.setNonSeqAttribsForObj(pName,defLogChannelName,lLevel,...
                'LogTraceFilePath',lTracePath,'LogTraceLogMode',lTLMode,...
                'LogTraceProcessDesc',lTProcessDesc,...
                'LogTraceProcessId',lTProcessId,'Executable',eObj);
            end
        end

        function pdObj=findOrCreateProcessDesignInProcessDesignPackage(self,processDesignPkgName,...
            processDesignName)

            pdName=['/',processDesignPkgName,'/',processDesignName];
            processDesigns=autosar.mm.Model.findObjectByName(self.m3iModel,pdName);
            if(processDesigns.size()==0)
                pdObj=self.addManifestPackageElement(['/',processDesignPkgName],...
                processDesignName,'ProcessDesign');

                eObj=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
                Simulink.metamodel.arplatform.manifest.Executable.MetaClass).at(1);

                self.setNonSeqAttribsForObj(pdName,'Executable',eObj);
            else
                pdObj=processDesigns.at(1);
            end

        end

        function addStateDependentStartupConfigToProcess(self,...
            processPackageName,processName,varargin)

            pName=['/',processPackageName,'/',processName];

            for ii=2:length(varargin)
                if strcmp(varargin{ii-1},'Mode')
                    tPath=self.getFullPathForM3IObj('ModeDeclaration',...
                    'Name',varargin{ii});
                    varargin{ii}=autosar.mm.Model.findObjectByName(self.m3iModel,tPath).at(1);
                elseif strcmp(varargin{ii-1},'groupElement')
                    tPath=self.getFullPathForM3IObj('ModeDeclarationGroupElement',...
                    'Name',varargin{ii});
                    varargin{ii}=autosar.mm.Model.findObjectByName(self.m3iModel,tPath).at(1);
                elseif strcmp(varargin{ii-1},'ResourceGroup')
                    tPath=self.getFullPathForM3IObj('ResourceGroup',...
                    'Name',varargin{ii});
                    varargin{ii}=autosar.mm.Model.findObjectByName(self.m3iModel,tPath).at(1);
                elseif strcmp(varargin{ii-1},'StartupConfig')
                    tPath=self.getFullPathForM3IObj('StartupConfig',...
                    'Name',varargin{ii});
                    varargin{ii}=autosar.mm.Model.findObjectByName(self.m3iModel,tPath).at(1);
                end
            end

            pObj=autosar.mm.Model.findObjectByName(self.m3iModel,pName).at(1);
            if(pObj.StateDependentStartupConfig.size<autosar.internal.adaptive.manifest.ManifestUtilities.numStateDepStartConfig)
                self.addElementRecursiveToPackage(self.m3iModel,pName,...
                'StateDependentStartupConfig',varargin{:});
            end
        end

        function addExecutableToExecutablePackage(self,execPkgName,...
            executableName,bType,loggingBehavior)

            eName=['/',execPkgName,'/',executableName];
            if(autosar.mm.Model.findObjectByName(self.m3iModel,eName).size()==0)
                self.addManifestPackageElement(['/',execPkgName],executableName,'Executable');
                self.setNonSeqAttribsForObj(eName,'BuildType',bType);
                self.setNonSeqAttribsForObj(eName,'LoggingBehavior',loggingBehavior);
            end

            rootSWComponentName=arxml.arxml_private('p_create_aridentifier',...
            [executableName,'_','RootSwComponentPrototype'],self.maxShortNameLength);

            cName=['/',execPkgName,'/',executableName,'/',rootSWComponentName];

            if(autosar.mm.Model.findObjectByName(self.m3iModel,cName).size()==0)
                self.addSeqAttribsForObj(eName,'RootSwComponentPrototype',rootSWComponentName);
                appNameCell=self.getFullPathForM3IObj('AdaptiveApplication');
                applObj=autosar.mm.Model.findObjectByName(self.m3iModel,appNameCell{1}).at(1);
                self.setNonSeqAttribsForObj(cName,'ApplicationType',applObj);
            end
        end

        function setNonSeqAttribsForObj(self,objPath,varargin)


            m3iObj=autosar.mm.Model.findObjectByName(self.m3iModel,objPath).at(1);
            self.setNonSeqAttribsForM3iObj(m3iObj,varargin{:});
        end

        function portNameToMethodNameMap=getAutosarPortToMethodMap(self)

            mapping=autosar.api.Utils.modelMapping(self.modelName);
            portMappings=[mapping.ClientPorts,mapping.ServerPorts];
            portNameToMethodNameMap=autosar.internal.adaptive.manifest.ManifestUtilities.getAutosarPortToMethodMapInternal(portMappings);
        end

        function portNameToEventNameMap=getAutosarPortToEventMap(self)

            mapping=autosar.api.Utils.modelMapping(self.modelName);
            portMappings=[];
            if~isempty(mapping.Outports)
                portMappings=[portMappings,mapping.Outports];
            end
            if~isempty(mapping.Inports)
                portMappings=[portMappings,mapping.Inports];
            end
            portNameToEventNameMap=autosar.internal.adaptive.manifest.ManifestUtilities.getAutosarPortToEventMapping(portMappings);
        end

        function addRemoveDltLogChannelToProcessMapping(self)


            if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))>=49
                autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.dltLogChnlToProcMappingPkgName);
                self.addDltLogChannelToProcessMapPkg(...
                self.dltLogChnlToProcMappingPkgName,'DltLogChannelToProcessMapping',self.machinePkgName,self.processPkgName,...
                self.defMachineName,self.defProcessName);
            else

                dltLogChnlToProcMappingPkg=autosar.mm.Model.getArPackage(self.m3iModel,self.dltLogChnlToProcMappingPkgName);
                if dltLogChnlToProcMappingPkg.isvalid()
                    dltLogChannelToProcMappingName=['/',self.dltLogChnlToProcMappingPkgName,'/DltLogChannelToProcessMapping'];
                    dltLogChannelToProcMappingObjs=autosar.mm.Model.findObjectByName(dltLogChnlToProcMappingPkg,dltLogChannelToProcMappingName);
                    for ii=1:dltLogChannelToProcMappingObjs.size()
                        curElem=dltLogChannelToProcMappingObjs.at(ii);
                        if curElem.isvalid()
                            curElem.destroy();
                        end
                    end
                    dltLogChnlToProcMappingPkg.destroy();
                end
            end
        end

        function addRemoveDltModule(self,mName)


            pName=['/',self.processPkgName,'/',self.defProcessName];
            logLevel='Warn';
            logMode='Console';
            logTracePath='';
            applicationDesc=['Log messages for adaptive application ',self.modelName];
            applicationId=self.getRandomNumber();
            if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))>=49


                defLogChannelName='DefaultDltLogChannel';
                self.addLogAndTraceModuleInstantiationAndDltLogChannelToMachine(...
                self.machinePkgName,self.defMachineName,'LogAndTraceInstantiation',...
                defLogChannelName,logLevel,logTracePath,logMode,...
                applicationDesc,...
                applicationId);


                pSeq=autosar.mm.Model.findObjectByName(self.m3iModel,pName);
                if(pSeq.size()>0)
                    pObj=pSeq.at(1);
                    pObj.LogTraceProcessDesc='';
                end
            else

                pSeq=autosar.mm.Model.findObjectByName(self.m3iModel,pName);
                if(pSeq.size()>0)
                    pObj=pSeq.at(1);
                    if isempty(pObj.LogTraceProcessDesc)
                        self.setNonSeqAttribsForObj(pName,'LogTraceProcessDesc',applicationDesc);
                    end
                end


                ltInstObjs=autosar.mm.Model.findObjectByName(self.m3iModel,[mName,'/LogAndTraceInstantiation']);
                for ii=1:ltInstObjs.size()
                    curElem=ltInstObjs.at(ii);
                    if curElem.isvalid()
                        curElem.destroy();
                    end
                end
            end
        end

        function mdgElement=addRemoveFunctionGroup(self,mName,mdgObj)



            fcGrpName='DefaultFunctionGroupSet';
            if arxml.convertReleaseToSchema(get_param(self.modelName,'AutosarSchemaVersion'))>=49

                mdgElement=[fcGrpName,'_ModeDeclarationGroupElement'];
                autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.functionGroupSetPkgName);
                self.addFunctionGroupSet(self.functionGroupSetPkgName,fcGrpName,mdgObj);


                machineObj=autosar.mm.Model.findObjectByName(self.m3iModel,mName).at(1);
                for ii=1:machineObj.FunctionGroup.size()
                    curElem=machineObj.FunctionGroup.at(ii);
                    if curElem.isvalid()
                        curElem.destroy();
                    end
                end


                pathToMdgObj=['/',self.functionGroupSetPkgName,'/',fcGrpName];

            else

                mdgElement=[self.defMachineName,'_ModeDeclarationGroupElement'];
                mdgElemObj=autosar.mm.Model.findObjectByName(self.m3iModel,[mName,'/',mdgElement]);
                if(mdgElemObj.size()==0)
                    self.addSeqAttribsForObj(mName,'FunctionGroup',strcat(self.defMachineName,...
                    '_','ModeDeclarationGroupElement'),'ModeGroup',mdgObj);
                end


                functionGroupSetPkg=autosar.mm.Model.getArPackage(self.m3iModel,self.functionGroupSetPkgName);
                if functionGroupSetPkg.isvalid()
                    fName=['/',self.functionGroupSetPkgName,'/',fcGrpName];
                    fcnGrpSetM3iObjs=autosar.mm.Model.findObjectByName(functionGroupSetPkg,fName);
                    if fcnGrpSetM3iObjs.size()>0
                        fcnGrpSetM3iObj=fcnGrpSetM3iObjs.at(1);
                        for ii=1:fcnGrpSetM3iObj.FunctionGroup.size()
                            curElem=fcnGrpSetM3iObj.FunctionGroup.at(ii);
                            if curElem.isvalid()
                                curElem.destroy();
                            end
                        end
                        fcnGrpSetM3iObj.destroy();
                    end
                    functionGroupSetPkg.destroy();
                end

                pathToMdgObj=mName;
            end

            self.addgroupElementToStateDependentStartupConfig([pathToMdgObj,'/',mdgElement]);
        end

        function addgroupElementToStateDependentStartupConfig(self,pathToMdgElement)


            pName=['/',self.processPkgName,'/',self.defProcessName];
            pObj=autosar.mm.Model.findObjectByName(self.m3iModel,pName);
            if(pObj.size()>0)
                pElem=pObj.at(1);
                mdgObjs=autosar.mm.Model.findObjectByName(self.m3iModel,pathToMdgElement);
                if mdgObjs.size()>0
                    scObj=pElem.StateDependentStartupConfig;
                    if(scObj.size()>0)
                        scElem=scObj.at(1);
                        fgStateObjs=scElem.FunctionGroupState;
                        for jj=1:fgStateObjs.size()
                            fgStateObjs.at(jj).('groupElement')=mdgObjs.at(1);
                        end
                    end
                end
            end
        end
    end

    methods(Access=private,Static)
        function found=fillManifestMetamodelIfEmpty(mfstObj,varargin)






            found=autosar.mm.Model.findObjectByName(mfstObj.m3iModel,mfstObj.defProcessQualPath).size()>0;
            if~found
                mfstObj.fillManifestMetamodel(varargin{:});
            else

                if(autosar.mm.Model.findObjectByMetaClass(mfstObj.m3iModel,...
                    Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance.MetaClass).size()>0)||...
                    (autosar.mm.Model.findObjectByMetaClass(mfstObj.m3iModel,...
                    Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance.MetaClass).size()>0)
                    mfstObj.bindingType='UD';
                    mfstObj.reqSrvcInstType='RequiredUserDefinedServiceInstance';
                    mfstObj.provSrvcInstType='ProvidedUserDefinedServiceInstance';
                else
                    mfstObj.bindingType='DDS';
                    mfstObj.reqSrvcInstType='DdsRequiredServiceInstance';
                    mfstObj.provSrvcInstType='DdsProvidedServiceInstance';
                end
            end
            mfstObj.addProcessDesignAndItsReferencesIfEmpty();
        end

        function addElementRecursiveToPackageByObj(m3iModel,pObj,PropertyName,varargin)








            cClassQualName=pObj.getMetaClass.getProperty(PropertyName).type.qualifiedName;

            cObj=feval(cClassQualName,m3iModel);
            if strcmp(pObj.getMetaClass.getProperty(PropertyName).upper,'1')
                pObj.(PropertyName)=cObj;
            else
                pObj.(PropertyName).append(cObj);
            end
            [PName,PVal]=autosar.internal.adaptive.manifest.ManifestUtilities.parseInputParams(varargin{:});

            parentCObjList={cObj};
            for ii=1:length(PName)





                for jj=numel(parentCObjList):-1:1
                    curParentObj=parentCObjList{jj};
                    if~isempty(curParentObj.getMetaClass.getProperty(PName{ii}))
                        cObj=curParentObj;
                        break;
                    end
                end

                if cObj.getMetaClass.getProperty(PName{ii}).isComposite
                    ccObj=feval(cObj.getMetaClass.getProperty(PName{ii}).type.qualifiedName,m3iModel);
                    if strcmp(cObj.getMetaClass.getProperty(PName{ii}).upper,'1')
                        cObj.(PName{ii})=ccObj;
                    else
                        cObj.(PName{ii}).append(ccObj);
                    end

                    isElement=false;
                    supClass=cObj.getMetaClass.getProperty(PName{ii}).type.superClass;
                    while~isempty(supClass)
                        if strcmp(supClass.at(1).name,'Element')
                            isElement=true;
                            break
                        end
                        supClass=supClass.at(1).superClass;
                    end
                    if~isElement
                        ccObj.Name=PVal{ii};
                    end
                    cObj=ccObj;
                    parentCObjList{end+1}=cObj;%#ok<AGROW>
                else
                    if isempty(cObj.getMetaClass.getProperty(PName{ii}).association)
                        if isa(cObj.getMetaClass.getProperty(PName{ii}).type,'M3I.ImmutableEnumeration')
                            propertyVal=feval([cObj.getMetaClass.getProperty(PName{ii}).type.qualifiedName,'.',PVal{ii}]);
                        else
                            propertyVal=PVal{ii};
                        end
                        cObj.(PName{ii})=propertyVal;
                    else
                        if strcmp(cObj.getMetaClass.getProperty(PName{ii}).upper,'1')
                            cObj.(PName{ii})=PVal{ii};
                        else
                            cObj.(PName{ii}).append(PVal{ii});
                        end
                    end
                end
            end
        end

        function addElementRecursiveToPackage(m3iModel,FullQualifiedPackageName,...
            PropertyName,varargin)


            pObj=autosar.mm.Model.findObjectByName(m3iModel,FullQualifiedPackageName).at(1);
            autosar.internal.adaptive.manifest.ManifestUtilities.addElementRecursiveToPackageByObj(m3iModel,pObj,PropertyName,varargin{:});
        end

        function setNonSeqAttribsForM3iObj(m3iObj,varargin)


            if~isempty(varargin)
                [PName,PVal]=autosar.internal.adaptive.manifest.ManifestUtilities.parseInputParams(varargin{:});
                lenPName=length(PName);

                for ii=1:lenPName
                    if isa(m3iObj.getMetaClass.getProperty(PName{ii}).type,'M3I.ImmutableEnumeration')
                        propertyVal=feval([m3iObj.getMetaClass.getProperty(PName{ii}).type.qualifiedName,'.',PVal{ii}]);
                    elseif~isempty(m3iObj.getMetaClass.getProperty(PName{ii}).association)
                        propertyVal=PVal{ii};
                    else
                        propertyVal=PVal{ii};
                    end

                    if strcmp(m3iObj.getMetaClass.getProperty(PName{ii}).upper,'1')
                        m3iObj.(PName{ii})=propertyVal;
                    else
                        m3iObj.(PName{ii}).append(propertyVal);
                    end
                end
            end
        end

        function retSeqId=addNewBindSrvcInstAndDeployment(srvcInstToPortMapObj,...
            m3iModel,srvcInstType,seqId,dplType,curBindingType,targetBindingType)





            srvInstPath=autosar.api.Utils.getQualifiedName(srvcInstToPortMapObj.ServiceInstance.containerM3I);
            deployPath=autosar.api.Utils.getQualifiedName(srvcInstToPortMapObj.ServiceInstance.Deployment.containerM3I);
            retSeqId=seqId;


            dplObj=autosar.internal.adaptive.manifest.ManifestUtilities.addPackageableElement(m3iModel,...
            deployPath,srvcInstToPortMapObj.ServiceInstance.Deployment.Name,dplType);


            srvcInstObj=autosar.internal.adaptive.manifest.ManifestUtilities.addPackageableElement(m3iModel,...
            srvInstPath,srvcInstToPortMapObj.ServiceInstance.Name,srvcInstType);


            if strcmp(curBindingType,'DDS')
                tempInstId=srvcInstToPortMapObj.ServiceInstance.InstanceId;
            else
                adminSdg=srvcInstToPortMapObj.ServiceInstance.Deployment.adminData.sdg.at(1);
                tempInstId=adminSdg.gid;
            end
            [isValid,~]=autosar.validation.AutosarUtils.checkServiceInstanceId(tempInstId,class(srvcInstToPortMapObj.Port));
            if isValid
                instanceId=tempInstId;
            else
                instanceId=autosar.internal.adaptive.manifest.ManifestUtilities.getUnusedNumFromSequence(seqId);
                retSeqId{end+1}=['x',instanceId];
            end

            if strcmp(targetBindingType,'DDS')

                autosar.internal.adaptive.manifest.ManifestUtilities.setNonSeqAttribsForM3iObj(srvcInstObj,...
                'InstanceId',str2double(instanceId),'Deployment',dplObj);
            else

                autosar.internal.adaptive.manifest.ManifestUtilities.addElementRecursiveToPackageByObj(m3iModel,dplObj,'adminData',...
                'sdg','DummyNameToIgnore','gid',instanceId);


                autosar.internal.adaptive.manifest.ManifestUtilities.setNonSeqAttribsForM3iObj(srvcInstObj,'Deployment',dplObj);
            end


            srvcInstToPortMapObj.ServiceInstance.Deployment.destroy();
            srvcInstToPortMapObj.ServiceInstance.destroy();


            srvcInstToPortMapObj.ServiceInstance=srvcInstObj;
        end

        function countUpdated=updateComBindingArtifacts(m3iModel,curBinding,targetBinding)





            srvcInstToPortMapSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass,true);


            seqId=autosar.internal.adaptive.manifest.ManifestUtilities.getSeqOfInstId(m3iModel,curBinding);

            countUpdated=0;

            if strcmp(curBinding,'UD')&&strcmp(targetBinding,'DDS')

                reqServiceInstanceType='Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance';
                provServiceInstanceType='Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance';
                newReqServiceInstanceType='DdsRequiredServiceInstance';
                newProvServiceInstanceType='DdsProvidedServiceInstance';
                newIntfDpl='DdsServiceInterfaceDeployment';
            elseif strcmp(curBinding,'DDS')&&strcmp(targetBinding,'UD')

                reqServiceInstanceType='Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance';
                provServiceInstanceType='Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance';
                newReqServiceInstanceType='RequiredUserDefinedServiceInstance';
                newProvServiceInstanceType='ProvidedUserDefinedServiceInstance';
                newIntfDpl='UserDefinedServiceInterfaceDeployment';
            else
                assert(false,'Only UD and DDS middlewares are supported.');
            end



            for ii=1:srvcInstToPortMapSeq.size()
                srvcInstToPortMap=srvcInstToPortMapSeq.at(ii);
                if~isempty(srvcInstToPortMap.ServiceInstance)
                    if isa(srvcInstToPortMap.ServiceInstance,reqServiceInstanceType)
                        seqId=autosar.internal.adaptive.manifest.ManifestUtilities.addNewBindSrvcInstAndDeployment(srvcInstToPortMap,...
                        m3iModel,newReqServiceInstanceType,seqId,newIntfDpl,curBinding,targetBinding);
                        countUpdated=countUpdated+1;
                    elseif isa(srvcInstToPortMap.ServiceInstance,provServiceInstanceType)
                        seqId=autosar.internal.adaptive.manifest.ManifestUtilities.addNewBindSrvcInstAndDeployment(srvcInstToPortMap,...
                        m3iModel,newProvServiceInstanceType,seqId,newIntfDpl,curBinding,targetBinding);
                        countUpdated=countUpdated+1;
                    end
                end
            end
        end

        function seqId=getSeqOfInstId(m3iModel,type)



            if strcmp(type,'UD')

                metaClass=autosar.internal.adaptive.manifest.ManifestUtilities.getMetaClassForCategory('UserDefinedServiceInterfaceDeployment');
                fullSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,metaClass,true);
                seqId={'x'};
                for ii=1:fullSeq.size()
                    curElem=fullSeq.at(ii);
                    if curElem.adminData.isvalid()
                        seqId{end+1}=['x',curElem.adminData.sdg.at(1).gid];%#ok<AGROW>
                    end
                end
            elseif strcmp(type,'DDS')

                metaClassRequired=autosar.internal.adaptive.manifest.ManifestUtilities.getMetaClassForCategory('DdsRequiredServiceInstance');
                fullSeqRequired=autosar.mm.Model.findObjectByMetaClass(m3iModel,metaClassRequired,true);
                seqId={'x'};
                for ii=1:fullSeqRequired.size()
                    seqId{end+1}=['x',num2str(fullSeqRequired.at(ii).InstanceId)];%#ok<AGROW>
                end
                metaClassProvided=autosar.internal.adaptive.manifest.ManifestUtilities.getMetaClassForCategory('DdsProvidedServiceInstance');
                fullSeqProvided=autosar.mm.Model.findObjectByMetaClass(m3iModel,metaClassProvided,true);
                for ii=1:fullSeqProvided.size()
                    seqId{end+1}=['x',num2str(fullSeqProvided.at(ii).InstanceId)];%#ok<AGROW>
                end
            end
        end

        function destroySeqOfMMObjects(m3iModel,metaClass)



            seqofMMObj=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iModel,metaClass,true);
            for ii=1:seqofMMObj.size()
                curElem=seqofMMObj.at(ii);
                if curElem.isvalid()
                    curElem.destroy();
                end
            end
        end
    end

    methods(Static)
        function val=getRandomNumber()

            old_rng=rng('shuffle');
            cleanup=onCleanup(@()rng(old_rng));

            val=num2str(floor(rand()*10000));
        end

        function[instanceIdentifierVec,instanceSpecifierVec,identifyServiceInstance]=getManifestAttributes(modelH,portNamesVec)
            apiObj=autosar.api.getAUTOSARProperties(modelH);
            numPorts=numel(portNamesVec);
            instanceIdentifierVec=cell(0,numPorts);
            instanceSpecifierVec=cell(0,numPorts);
            mdlName=get_param(modelH,'Name');
            m3iComp=autosar.api.Utils.m3iMappedComponent(mdlName);
            identifyServiceInstance=apiObj.get('XmlOptions','IdentifyServiceInstance');
            for ii=1:numPorts
                m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,portNamesVec{ii});
                if isempty(m3iPort)


                    instanceIdentifierVec{ii}='';
                    if slfeature('AdaptiveAutogenInstanceSpecifier')
                        instanceSpecifierVec{ii}='';
                    else
                        instanceSpecifierVec{ii}=portNamesVec{ii};
                    end
                elseif m3iPort.isvalid()
                    instanceIdentifierVec{ii}=autosar.internal.adaptive.manifest.ManifestUtilities.getInstanceIdentifier(modelH,m3iPort);
                    if slfeature('AdaptiveAutogenInstanceSpecifier')
                        instanceSpecifierVec{ii}=autosar.internal.adaptive.manifest.InstanceSpecifier.getInstanceSpecifier(m3iPort);
                    else
                        instanceSpecifierVec{ii}=apiObj.get(autosar.api.Utils.getQualifiedName(m3iPort),'InstanceSpecifier');
                    end
                end
            end
        end

        function bindingType=getBindingType(m3iModel)
            m3iSrvcToPortMappings=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass,true,true);
            bindingType="";
            for ii=1:m3iSrvcToPortMappings.size()
                siToPortMappingObj=m3iSrvcToPortMappings.at(ii);
                if isempty(siToPortMappingObj.Port)||~siToPortMappingObj.Port.isvalid()
                    continue;
                end
                m3iSrvcInstance=siToPortMappingObj.ServiceInstance;
                if isa(m3iSrvcInstance,'Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance')||...
                    isa(m3iSrvcInstance,'Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance')
                    bindingType='UD';
                    break;
                elseif isa(m3iSrvcInstance,'Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance')||...
                    isa(m3iSrvcInstance,'Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance')
                    bindingType='DDS';
                    break;
                end
            end
        end

        function transformDDSToUD(m3iModel)


            t=M3I.Transaction(m3iModel);
            autosar.internal.adaptive.manifest.ManifestUtilities.transformDDSToUDArtifacts(m3iModel);
            t.commit();

        end

        function value=getInstanceIdentifier(modelH,m3iPort)
            modelName=get_param(modelH,'Name');
            value='';
            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            metaClass=obj.getMetaClassForCategory('ServiceInstanceToPortMapping');
            siToPortMappingPkg=autosar.mm.Model.getArPackage(obj.m3iModel,obj.siToPortMappingPkgName);
            if isempty(siToPortMappingPkg)
                return;
            end

            obj.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
            value=obj.getInstanceIDForPort(m3iPort);
        end

        function setInstanceIdentifier(modelH,m3iPort,value)
            modelName=get_param(modelH,'Name');
            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            autosar.internal.adaptive.manifest.ManifestUtilities.fillManifestMetamodelIfEmpty(obj,...
            'Port',m3iPort,'InstanceId',value);
            t=M3I.Transaction(m3iPort.rootModel);
            obj.setInstanceIDForPort(m3iPort,value);
            t.commit();
        end

        function supportedManifestProperties=getSupportedProperties()
            props=autosar.internal.adaptive.manifest.ManifestUtilities.SupportedProperties;
            supportedManifestProperties=cell(1,size(props,2));
            for i=1:length(supportedManifestProperties)
                supportedManifestProperties{i}=props{i}{1};
            end
        end

        function setInstanceIdForDeploymentObj(modelName,dplObj,instanceID)
            apiObj=autosar.api.getAUTOSARProperties(modelName);
            if strcmp(apiObj.get('XmlOptions','IdentifyServiceInstance'),'InstanceIdentifier')
                [error,instanceID]=autosar.internal.adaptive.manifest.ManifestUtilities.validateServiceInstance(instanceID,'InstanceIdentifier');
                if error
                    DAStudio.error('autosarstandard:validation:errorIdentifyServiceInstance',...
                    modelName,'InstanceIdentifier');
                else
                    obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
                    t=M3I.Transaction(dplObj.rootModel);
                    obj.setInstanceIDForDeployment(dplObj,serviceInstance);
                    t.commit();
                end
            end
        end

        function instanceID=getInstanceIdForDeploymentObj(modelName,dplObj)
            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            instanceID=obj.getInstanceIDFromDeploymentObj(dplObj);
        end

        function syncManifestMetaModelWithAutosarDictionary(modelName,m3iComp)
            if nargin==2
                obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName,m3iComp);
            else
                obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            end
            autosar.internal.adaptive.manifest.ManifestUtilities.fillManifestMetamodelIfEmpty(obj);
            obj.cleanAndSyncManifestMetaModel();
        end

        function verifyUniqueInstanceIdentifiersForPortsDeployment(hModel)



            model=get_param(hModel,'Handle');
            modelName=get_param(model,'Name');

            apiObj=autosar.api.getAUTOSARProperties(modelName);

            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            metaClass=obj.getMetaClassForCategory('ServiceInstanceToPortMapping');
            siToPortMappingPkg=autosar.mm.Model.getArPackage(obj.m3iModel,obj.siToPortMappingPkgName);
            if isempty(siToPortMappingPkg)
                return;
            end
            obj.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);

            mapInstId=containers.Map;
            mapInstSpec=containers.Map;

            for ii=1:obj.m3iSrvcInstToPortMappingSeqObj.size()
                portObj=obj.m3iSrvcInstToPortMappingSeqObj.at(ii).Port;
                if~isempty(portObj)&&portObj.isvalid()&&(isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')||...
                    isa(portObj,'Simulink.metamodel.arplatform.port.ServiceRequiredPort'))

                    keyId=obj.getInstanceIDForPort(portObj);
                    if~mapInstId.isKey(keyId)
                        mapInstId(keyId)=portObj;
                    else
                        if(isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort'))
                            DAStudio.error('autosarstandard:validation:duplicateInstanceIdentifier',...
                            portObj.Name,mapInstId(keyId).Name,keyId,...
                            modelName);
                        else
                            DAStudio.error('autosarstandard:validation:duplicateInstanceIdentifierRequiredPort',...
                            portObj.Name,mapInstId(keyId).Name,keyId,...
                            modelName);
                        end
                    end


                    if slfeature('AdaptiveAutogenInstanceSpecifier')


                        continue
                    end
                    keySpec=apiObj.get(autosar.api.Utils.getQualifiedName(portObj),...
                    'InstanceSpecifier');
                    if~isempty(keySpec)
                        if~mapInstSpec.isKey(keySpec)
                            mapInstSpec(keySpec)=portObj;
                        else
                            if(isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort'))
                                DAStudio.error('autosarstandard:validation:duplicateInstanceSpecifier',...
                                portObj.Name,mapInstSpec(keySpec).Name,keySpec,...
                                modelName);
                            else
                                DAStudio.error('autosarstandard:validation:duplicateInstanceSpecifierRequiredPort',...
                                portObj.Name,mapInstSpec(keySpec).Name,keySpec,...
                                modelName);
                            end
                        end
                    end
                end
            end
        end

        function setTopicNameForEvent(modelName,portName,eventName,topicName)


            eventDeplObj=autosar.internal.adaptive.manifest.ManifestUtilities.getEventDeploymentObj(modelName,portName,eventName);
            if~isempty(eventDeplObj)
                if arxml.convertReleaseToSchema(get_param(modelName,'AutosarSchemaVersion'))>=49
                    [isValid,errMsg]=autosar.validation.AutosarUtils.checkFnmatchPattern(topicName,class(eventDeplObj));
                else
                    [isValid,errMsg]=autosar.validation.AutosarUtils.checkDdsIdentifier(topicName,class(eventDeplObj));
                end
                if isValid
                    t=M3I.Transaction(eventDeplObj.rootModel);
                    eventDeplObj.TopicName=topicName;
                    t.commit();
                else
                    DAStudio.error(errMsg);
                end
            end
        end

        function topicName=getTopicNameForEvent(modelName,portName,eventName)


            topicName=[];
            eventDeplObj=autosar.internal.adaptive.manifest.ManifestUtilities.getEventDeploymentObj(modelName,portName,eventName);
            if~isempty(eventDeplObj)
                topicName=eventDeplObj.TopicName;
            end
        end

        function m3iEventDepl=getEventDeploymentObj(modelName,portName,eventName)

            m3iEventDepl=[];
            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);
            metaClass=obj.getMetaClassForCategory('ServiceInstanceToPortMapping');
            siToPortMappingPkg=autosar.mm.Model.getArPackage(obj.m3iModel,obj.siToPortMappingPkgName);
            if isempty(siToPortMappingPkg)
                return;
            end
            obj.m3iSrvcInstToPortMappingSeqObj=autosar.mm.Model.findObjectByMetaClass(siToPortMappingPkg,metaClass,true);
            for ii=1:obj.m3iSrvcInstToPortMappingSeqObj.size()
                siToPortMapping=obj.m3iSrvcInstToPortMappingSeqObj.at(ii);
                portObj=siToPortMapping.Port;
                if~isempty(portObj)&&portObj.isvalid()&&(isa(portObj,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')||...
                    isa(portObj,'Simulink.metamodel.arplatform.port.ServiceRequiredPort'))
                    if strcmp(portObj.Name,portName)&&~isempty(siToPortMapping.ServiceInstance)...
                        &&~isempty(siToPortMapping.ServiceInstance.Deployment)&&isa(siToPortMapping.ServiceInstance.Deployment,'Simulink.metamodel.arplatform.manifest.DdsServiceInterfaceDeployment')
                        for kk=1:siToPortMapping.ServiceInstance.Deployment.EventDeployment.size()


                            eventDeplObj=siToPortMapping.ServiceInstance.Deployment.EventDeployment.at(kk);
                            if eventDeplObj.Event.isvalid()&&...
                                (strcmp(eventDeplObj.Event.Name,eventName))
                                m3iEventDepl=eventDeplObj;
                            end
                        end
                        break;
                    end
                end
            end
        end

        function[error,serviceInstance]=validateServiceInstance(identifyServiceInstance,propertyName)
            error=false;
            serviceInstance=strtrim(identifyServiceInstance);
            if strcmp(propertyName,'InstanceSpecifier')
                [isValid,~,~]=autosarcore.checkIdentifier(serviceInstance,'shortName',128);
                error=~isValid;
            end
            if isempty(serviceInstance)
                error=true;
            end
        end

        function mClass=getMetaClassForCategory(category)
            import Simulink.metamodel.foundation.*;
            import Simulink.metamodel.arplatform.common.*;
            import Simulink.metamodel.arplatform.component.*;
            import Simulink.metamodel.arplatform.manifest.*;
            import Simulink.metamodel.arplatform.composition.*;
            import Simulink.metamodel.arplatform.documentation.*;
            import Simulink.metamodel.arplatform.instance.*;
            import Simulink.metamodel.arplatform.interface.*;
            import Simulink.metamodel.arplatform.port.*;
            import Simulink.metamodel.arplatform.variant.*;
            import Simulink.metamodel.types.*;

            mClass=eval(strcat(category,'.MetaClass'));
        end

        function m3iChildObj=addPackageableElement(m3iModel,pkgPath,pkgElemName,pkgElemType)

            m3iParentObj=autosar.mm.Model.findObjectByName(m3iModel,pkgPath).at(1);
            childMetaClass=autosar.internal.adaptive.manifest.ManifestUtilities.getMetaClassForCategory(pkgElemType);
            t=M3I.Transaction(m3iModel);
            m3iChildObj=feval(childMetaClass.qualifiedName,m3iModel);
            m3iChildObj.Name=pkgElemName;
            m3iParentObj.('packagedElement').append(m3iChildObj);
            t.commit();
        end

        function[propertyNames,propertyValues]=parseInputParams(varargin)
            propertyNames=cell(0,length(varargin)/2);
            propertyValues=cell(0,length(varargin)/2);

            for ii=1:(length(varargin)/2)
                propertyNames{ii}=varargin{(2*ii)-1};
                propertyValues{ii}=varargin{(2*ii)};
            end
        end

        function portNameToEventNameMap=getAutosarPortToEventMapping(portMappings)

            portNameToEventNameMap=containers.Map;
            for ii=1:numel(portMappings)
                portMappingVal=portMappings(ii);
                if(strcmp(get_param(portMappingVal.Block,'IsBusElementPort'),'off')||...
                    ~autosar.validation.CommonModelingStylesValidator.busElementIsInvalid(portMappingVal.Block))
                    mappedTo=portMappingVal.MappedTo;
                    if~portNameToEventNameMap.isKey(mappedTo.Port)
                        portNameToEventNameMap(mappedTo.Port)={mappedTo.Event};
                    else
                        values=portNameToEventNameMap(mappedTo.Port);
                        portNameToEventNameMap(mappedTo.Port)=[values,{mappedTo.Event}];
                    end
                end
            end
        end

        function portNameToMethodNameMap=getAutosarPortToMethodMapInternal(portMappings)

            portNameToMethodNameMap=containers.Map;
            for ii=1:numel(portMappings)
                mappedTo=portMappings(ii).MappedTo;
                if~portNameToMethodNameMap.isKey(mappedTo.Port)
                    portNameToMethodNameMap(mappedTo.Port)={mappedTo.Method};
                else
                    values=portNameToMethodNameMap(mappedTo.Port);
                    portNameToMethodNameMap(mappedTo.Port)=[values,{mappedTo.Method}];
                end
            end
        end

        function addDdsEventDeploymentAndEventQosProps(model,mapping)



            modelName=get_param(model,'Name');
            obj=autosar.internal.adaptive.manifest.ManifestUtilities(modelName);

            srvcInstToPortMapMetaClass=autosar.internal.adaptive.manifest.ManifestUtilities.getMetaClassForCategory('ServiceInstanceToPortMapping');
            seqObj=autosar.mm.Model.findObjectByMetaClass(obj.m3iModel,srvcInstToPortMapMetaClass,true);

            t=M3I.Transaction(obj.m3iModel);

            for ii=1:seqObj.size
                srvcInstToPortMapObj=seqObj.at(ii);
                portToEventMap=autosar.internal.adaptive.manifest.ManifestUtilities.getAutosarPortToEventMapBasedOnPortObject(srvcInstToPortMapObj.Port,mapping);
                if portToEventMap.isKey(srvcInstToPortMapObj.Port.Name)
                    mappedEvents=portToEventMap(srvcInstToPortMapObj.Port.Name);
                    for jj=1:numel(mappedEvents)
                        obj.addDdsEventInfo(srvcInstToPortMapObj,mappedEvents{jj});
                    end
                end
            end
            t.commit();
        end

        function countUpdated=transformUDToDDSArtifacts(m3iModel)





            countUpdated=autosar.internal.adaptive.manifest.ManifestUtilities.updateComBindingArtifacts(m3iModel,'UD','DDS');
        end

        function countUpdated=transformDDSToUDArtifacts(m3iModel)





            countUpdated=autosar.internal.adaptive.manifest.ManifestUtilities.updateComBindingArtifacts(m3iModel,'DDS','UD');
        end

        function removeAllAdaptiveManifestArtifacts(m3iModel)





            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.Machine.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.Process.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.Executable.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.ProcessToMachineMappingSet.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.StartupConfigSet.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.StartupConfigSet.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.ProvidedUserDefinedServiceInstance.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.RequiredUserDefinedServiceInstance.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance.MetaClass);


            autosar.internal.adaptive.manifest.ManifestUtilities.destroySeqOfMMObjects(m3iModel,Simulink.metamodel.arplatform.manifest.DdsServiceInterfaceDeployment.MetaClass);
        end

        function replacedString=replaceSpecialChars(str)
            splCharArray={'~','!','@','#','$','%','^','&','*','(',')','_','+','/','*','-','`','-','=','{','}','|','+','[',']','\',':','"',';','<','>','?',',','.','/'};
            replacedString=replace(str,splCharArray,'a');
        end

        function unusedNum=getUnusedNumFromSequence(seqId)
            tNum=regexp(genvarname('x',seqId),'\d','match');
            unusedNum=[tNum{:}];

            if isnan(unusedNum)
                unusedNum=strrep(char(matlab.lang.internal.uuid()),'-','');
            end
        end

        function[mdgPkgName,defModeDeclGrpName]=getModeDeclPkgAndGroupNames(modelName)
            maxShortNameLength=autosar.internal.adaptive.manifest.ManifestUtilities.getMaxShortNameLength(modelName);
            mdgPkgName=arxml.arxml_private('p_create_aridentifier',...
            'MachineStates',maxShortNameLength);
            defModeDeclGrpName=arxml.arxml_private('p_create_aridentifier',...
            'DefaultMachineStates',maxShortNameLength);
        end

        function maxShortNameLength=getMaxShortNameLength(modelName)

            if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
            else
                maxShortNameLength=128;
            end
        end

        function markElementAsManifestARXML(m3iElem)


            machineManifestFile=autosar.mm.arxml.Exporter.getMachineManifestArxmlFileName();
            autosar.mm.arxml.Exporter.setDefaultArxmlFileForM3iElem(m3iElem,machineManifestFile);
        end

    end
end






