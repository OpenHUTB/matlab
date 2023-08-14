classdef Model<handle









    properties(Transient,GetAccess=private,SetAccess=private)


        m3iModelTransLevel=0;
    end

    properties(Hidden=true,GetAccess=public,SetAccess=private)

        m3iModel;
    end

    methods(Access=public)



        function self=Model(arg)
            if nargin>0&&autosar.mm.Model.isValid(arg,'Simulink.metamodel.foundation.Domain')

                self.m3iModel=arg;
            else

                self.m3iModel=autosar.mm.Model.newM3IModel();
            end
            self.m3iModelTransLevel=0;
        end



        function beginTransaction(self)
            self.m3iModel.beginTransaction();
            self.m3iModelTransLevel=self.m3iModelTransLevel+1;
        end



        function commitTransaction(self)
            if self.m3iModelTransLevel>0
                self.m3iModel.commitTransaction();
                self.m3iModelTransLevel=self.m3iModelTransLevel-1;
            end
        end



        function cancelTransaction(self)
            if self.m3iModelTransLevel>0
                self.m3iModel.cancelTransaction();
                self.m3iModelTransLevel=self.m3iModelTransLevel-1;
            end
        end



        function ret=isTransactionStarted(self)
            ret=self.m3iModelTransLevel>0;
        end



        function model=getModel(self)
            model=self.m3iModel;
        end



        function delete(self)
            while self.isTransactionStarted()
                self.cancelTransaction();
            end
        end



        function bytes=saveobj(self)
            bytes=self.toBytes(false);
        end



        function toXmi(self,xmiFileName)
            opts=M3I.XmiWriterSettings;
            opts.AutoFlush=false;
            xwf=M3I.XmiWriterFactory;
            xw=xwf.createXmiWriter(opts);
            xw.write(xmiFileName,self.m3iModel);
        end



        function bytes=toBytes(self,keepFiles)
            if nargin<2
                keepFiles=false;
            end

            tmpDir=tempdir();
            rootTmpFile=tempname(tmpDir);
            xmiFileName=[rootTmpFile,'.xmi'];
            zipFileName=[rootTmpFile,'.zip'];

            self.toXmi(xmiFileName);
            zip(zipFileName,xmiFileName);
            fid=fopen(zipFileName,'rb');
            bytes=fread(fid,inf,'*uint8');
            fclose(fid);

            if keepFiles==false
                delete(xmiFileName);
                delete(zipFileName);
            end
        end

    end

    methods(Static)


        function obj=loadobj(in)
            obj=autosar.mm.Model.fromBytes(in,false);
        end

        function m3iModel=newM3IModel()
            m3iModel=Simulink.metamodel.foundation.Factory.createNewModel();
            m3iModel.beginTransaction();
            m3iModel.Name='AUTOSAR';

            autosarPkg=Simulink.metamodel.arplatform.common.AUTOSAR(m3iModel);
            autosarPkg.Name='AUTOSAR';
            m3iModel.RootPackage.append(autosarPkg);
            m3iModel.commitTransaction();
        end



        function obj=fromXmi(xmiFileName)
            xrf=M3I.XmiReaderFactory;
            xr=xrf.createXmiReader();

            model=xr.read(xmiFileName);
            obj=autosar.mm.Model(model);
        end



        function obj=fromBytes(bytes,keepFiles)
            if nargin<2
                keepFiles=false;
            end

            tmpDir=tempdir();
            rootTmpFile=tempname(tmpDir);
            zipFileName=[rootTmpFile,'.zip'];

            fid=fopen(zipFileName,'wb');
            fwrite(fid,bytes,'*uint8');
            fclose(fid);

            xmiFileName=unzip(zipFileName,tmpDir);

            if(iscellstr(xmiFileName)||isstring(xmiFileName))&&~isempty(xmiFileName)&&~ismissing(xmiFileName)
                assert(numel(xmiFileName)==1,'Multiple XMI files not supported.');
                obj=autosar.mm.Model.fromXmi(xmiFileName{1});
            else
                obj=autosar.mm.Model();
            end

            if keepFiles==false
                if iscellstr(xmiFileName)||isstring(xmiFileName)
                    delete(xmiFileName{1});
                else
                    delete(xmiFileName);
                end
                delete(zipFileName);
            end
        end



        function ret=isValid(aM3IObject,aClsStr)
            ret=(isa(aM3IObject,'M3I.ImmutableClassObject')||isa(aM3IObject,'M3I.ClassObject'))&&...
            isa(aM3IObject,aClsStr)&&aM3IObject.isvalid();
        end



        function toolId=setExternalToolInfo(obj,toolName,toolId)
            narginchk(2,3);

            if nargin<3||~(ischar(toolId)||isStringScalar(toolId))
                toolId=char(matlab.lang.internal.uuid());
            end

            autosarcore.ModelUtils.setExternalToolInfo(obj,toolName,toolId);
        end












        function extraInfo=getExtraExternalToolInfo(m3iObj,toolId,fields,fmt)

            extraInfo=autosarcore.ModelUtils.getExtraExternalToolInfo(...
            m3iObj,toolId,fields,fmt);
        end







        function externalId=setExtraExternalToolInfo(m3iObj,toolId,fmt,values)

            externalId=autosarcore.ModelUtils.setExtraExternalToolInfo(...
            m3iObj,toolId,fmt,values);
        end



        function extraInfo=getExtraInternalBehaviorInfo(m3iIb)

            assert(m3iIb.getMetaClass()==Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior.MetaClass(),...
            'Expected a Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior');

            extraInfo=autosar.mm.Model.getExtraExternalToolInfo(m3iIb,...
            'ARXML_IB_INFO',{'qName'},{'%s'});
        end



        function m3iSeq=findObjectByName(parent,childName,caseInsensitive)
            if nargin==2
                caseInsensitive=false;
            end
            m3iSeq=autosarcore.MetaModelFinder.findObjectByName(parent,childName,caseInsensitive);
        end






        function child=findChildByName(parent,childName,caseInsensitive)
            if nargin==2
                caseInsensitive=false;
            end
            child=autosarcore.MetaModelFinder.findChildByName(parent,childName,caseInsensitive);
        end





        function childNames=findObjectNamesByCategory(modelName,category,attributeName)
            if nargin==2
                attributeName='';
            end
            if iscell(category)
                childNames={};
                for ii=1:numel(category)
                    names=autosar.mm.Model.i_findObjectNamesByCategory(modelName,category{ii},attributeName);
                    childNames=[childNames,names];%#ok<AGROW>

                end
            else
                childNames=autosar.mm.Model.i_findObjectNamesByCategory(modelName,category,attributeName);
            end
        end







        function elementNames=findContaineeElementsByPortName(modelName,portName,isCS)
            if nargin==2
                isCS=false;
            end
            elementNames={};

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPort=autosar.mm.Model.findM3IPortByName(m3iComp,portName);
            if isempty(m3iPort)
                return
            end

            m3iElements=autosar.mm.Model.findM3IPortContaineeElements(m3iPort,isCS);
            if~isempty(m3iElements)
                if isa(m3iElements,'Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement')
                    elementNames={m3iElements.Name};
                else
                    elementNames=m3i.mapcell(@(x)x.Name,m3iElements);
                end
            end
        end

        function m3iElements=findM3IPortContaineeElements(m3iPort,isCS)
            if nargin==1
                isCS=false;
            end
            m3iElements=[];

            if~m3iPort.Interface.isvalid()



                return;
            end

            portType=m3iPort.MetaClass.qualifiedName;

            switch portType
            case{'Simulink.metamodel.arplatform.port.DataReceiverPort',...
                'Simulink.metamodel.arplatform.port.DataSenderPort',...
                'Simulink.metamodel.arplatform.port.DataSenderReceiverPort',...
                'Simulink.metamodel.arplatform.port.NvDataReceiverPort',...
                'Simulink.metamodel.arplatform.port.NvDataSenderPort',...
                'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort',...
                'Simulink.metamodel.arplatform.port.ParameterReceiverPort'}
                m3iElements=m3iPort.Interface.DataElements;
            case{'Simulink.metamodel.arplatform.port.ModeReceiverPort',...
                'Simulink.metamodel.arplatform.port.ModeSenderPort'}
                m3iElements=m3iPort.Interface.ModeGroup;
            case 'Simulink.metamodel.arplatform.port.ClientPort'
                m3iElements=m3iPort.Interface.Operations;
            case{'Simulink.metamodel.arplatform.port.ServiceRequiredPort',...
                'Simulink.metamodel.arplatform.port.ServiceProvidedPort'}
                if isCS
                    m3iElements=m3iPort.Interface.Methods;
                else
                    m3iElements=m3iPort.Interface.Events;
                end
            case{'Simulink.metamodel.arplatform.port.PersistencyRequiredPort',...
                'Simulink.metamodel.arplatform.port.PersistencyProvidedPort',...
                'Simulink.metamodel.arplatform.port.PersistencyProvidedRequiredPort'}
                m3iElements=m3iPort.Interface.DataElements;
            otherwise
                assert(false,sprintf('%s is not supported by function autosar.mm.Model.findM3IPortContaineeElements().',portType));
            end
        end


        function isArraySizeOne=isPortDataElementArraySizeOne(modelName,...
            arPortName,arDataElementName)

            isArraySizeOne=false;

            if~autosar.api.Utils.isMapped(modelName)
                return
            end

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPort=[];
            m3iPortSeq=autosar.mm.Model.findObjectByName(m3iComp,arPortName);
            if m3iPortSeq.size()==1
                m3iPort=m3iPortSeq.at(1);
                portType=m3iPort.MetaClass.qualifiedName;
            end

            if~isempty(m3iPort)&&any(strcmp(portType,...
                {'Simulink.metamodel.arplatform.port.DataReceiverPort',...
                'Simulink.metamodel.arplatform.port.DataSenderPort'}))
                dataElemsSeq=m3iPort.Interface.DataElements;
                for i=1:dataElemsSeq.size()
                    m3iDataElement=dataElemsSeq.at(i);
                    if strcmp(m3iDataElement.Name,arDataElementName)&&...
                        autosar.api.Utils.isArraySizeOne(m3iDataElement.Type)
                        isArraySizeOne=true;
                        return;
                    end
                end
            end
        end




        function childSeq=findObjectByMetaClass(parent,metaClass,doRecursion,isSuperClass)
            if nargin==3
                isSuperClass=false;
            elseif nargin<3
                doRecursion=true;
                isSuperClass=false;
            end
            childSeq=autosarcore.MetaModelFinder.findObjectByMetaClass(parent,metaClass,doRecursion,isSuperClass);
        end






        function childList=findChildByTypeName(parent,childType,doRecursion,isSuperClass)
            if nargin==3
                isSuperClass=false;
            elseif nargin<3
                doRecursion=true;
                isSuperClass=false;
            end
            childList=autosarcore.MetaModelFinder.findChildByTypeName(parent,childType,doRecursion,isSuperClass);
        end



        function child=findObjectByNameAndMetaClass(parent,childName,childType,caseInsensitive)
            if nargin==3
                caseInsensitive=false;
            end
            child=autosarcore.MetaModelFinder.findObjectByNameAndMetaClass(parent,childName,childType,caseInsensitive);
        end





        function child=findChildByNameAndTypeName(parent,childName,childType,caseInsensitive)
            if nargin==3
                caseInsensitive=false;
            end
            child=autosarcore.MetaModelFinder.findChildByNameAndTypeName(parent,childName,childType,caseInsensitive);
        end



        function idx=findObjectIndexInSequence(seq,item)
            idx=-1;
            if~item.isvalid()||~seq.isvalid()
                return
            end

            if isa(seq,'M3I.SequenceOfObject')&&isa(item,'M3I.Object')
                idx=Simulink.metamodel.arplatform.ModelFinder.findObjectIndexInSequence(seq,item);
            elseif isa(seq,'M3I.ImmutableSequenceOfObject')&&isa(item,'M3I.Object')
                idx=Simulink.metamodel.arplatform.ModelFinder.findObjectIndexInImmutableSequence(seq,item);
            elseif isa(seq,'M3I.SequenceOfImmutableObject')&&isa(item,'M3I.ImmutableObject')
                idx=Simulink.metamodel.arplatform.ModelFinder.findImmutableObjectIndexInImmutableSequence(seq,item);
            elseif isa(seq,'M3I.ImmutableSequenceOfImmutableObject')&&isa(item,'M3I.ImmutableObject')
                idx=Simulink.metamodel.arplatform.ModelFinder.findImmutableObjectIndexInImmutableSequence(seq,item);
            else

                [~,idx]=autosar.mm.Model.sequenceContainsItem(seq,item);
            end
        end





        function[found,idx]=sequenceContainsItem(seq,item)
            currIt=seq.begin();
            endIt=seq.end();
            found=false;
            idx=-1;
            currIdx=1;
            while currIt~=endIt
                currItem=currIt.item();
                if currItem.isvalid()&&currItem==item
                    found=true;
                    idx=currIdx;
                    return
                end
                currIt.getNext();
                currIdx=currIdx+1;
            end
        end





        function found=changeSequenceOwner(m3iObj,m3iContainer,currentSeqRole,newSeqRole)
            if strcmp(currentSeqRole,newSeqRole)

                return
            end

            if isempty(m3iContainer)||~m3iContainer.isvalid()||...
                isempty(m3iObj)||~m3iObj.isvalid()

                assert(false,'Unexpected invalid M3I Objects');
            end


            [found,idx]=autosar.mm.Model.sequenceContainsItem(m3iContainer.(currentSeqRole),m3iObj);
            if found==true
                m3iContainer.(currentSeqRole).erase(idx);
                m3iContainer.(newSeqRole).append(m3iObj);
            end
        end






        function portInfo=findPortInfo(port,key,role)
            portInfo=[];
            isNvPort=autosar.api.Utils.isNvPort(port);
            if isNvPort
                infoStr='Info';
            else
                infoStr='info';
            end
            for jj=1:port.(infoStr).size()
                if port.(infoStr).at(jj).(role)==key
                    portInfo=port.(infoStr).at(jj);
                    break
                end
            end
        end



        function m3iComSpec=findComSpecForDataElement(m3iPort,dataElementName,isRead)
            m3iComSpec=[];

            isNvPort=autosar.api.Utils.isNvPort(m3iPort);
            if isNvPort
                infoStr='Info';
                comSpecStr='ComSpec';
            else
                infoStr='info';
                comSpecStr='comSpec';
            end
            m3iInfoSeq=m3iPort.(infoStr);

            if isRead
                matchInfoType={'Simulink.metamodel.arplatform.port.DataReceiverPortInfo',...
                'Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo',...
                'Simulink.metamodel.arplatform.port.ParameterReceiverPortInfo'};
            else
                matchInfoType={'Simulink.metamodel.arplatform.port.DataSenderPortInfo',...
                'Simulink.metamodel.arplatform.port.NvDataSenderPortInfo',...
                'Simulink.metamodel.arplatform.port.ParameterSenderPortInfo'};
            end

            portInfo=[];
            for jj=1:m3iInfoSeq.size()
                m3iInfo=m3iInfoSeq.at(jj);
                if m3iInfo.DataElements.isvalid()&&...
                    strcmp(m3iInfo.DataElements.Name,dataElementName)&&...
                    any(strcmp(m3iInfo.MetaClass.qualifiedName,matchInfoType))
                    portInfo=m3iInfo;
                    break;
                end
            end

            if~isempty(portInfo)
                m3iComSpec=portInfo.(comSpecStr);
            end
        end


        function m3iSeq=findPortsUsingInterface(m3iInterface,m3iParent)
            assert(isa(m3iInterface,'Simulink.metamodel.arplatform.interface.PortInterface'),...
            'invalid interface');
            if nargin==1
                m3iParent=m3iInterface.rootModel;
            end
            m3iSeq=Simulink.metamodel.arplatform.port.SequenceOfPort.make(m3iInterface.rootModel);
            m3iPorts=autosar.mm.Model.findObjectByMetaClass(m3iParent,...
            Simulink.metamodel.arplatform.port.Port.MetaClass,true,true);
            for i=1:m3iPorts.size()
                m3iPort=m3iPorts.at(i);
                if m3iPort.Interface==m3iInterface
                    m3iSeq.append(m3iPort);
                end
            end
        end

        function m3iPort=findM3IPortByName(m3iComp,ARPortName)

            m3iPort=Simulink.metamodel.arplatform.port.Port.empty();

            m3iPortSeq=autosar.mm.Model.findObjectByName(m3iComp,ARPortName);
            if m3iPortSeq.size()==1
                m3iPort=m3iPortSeq.at(1);
            end
        end

        function m3iSeq=findPackageableElements(m3iModel)

            m3iSeq=M3I.SequenceOfClassObject.make(m3iModel);
            m3iPkgElms=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.foundation.PackageableElement.MetaClass,true,true);
            for i=1:m3iPkgElms.size()
                m3iPkgElm=m3iPkgElms.at(i);
                if~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.Package')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.AUTOSAR')
                    m3iSeq.push_back(m3iPkgElm);
                end
            end
        end

        function interfaceToPortSeqMap=captureInterfaceToPortSeqMap(m3iModel,m3iRoot)

            interfaceToPortSeqMap=containers.Map;


            m3iPorts=autosar.mm.Model.findObjectByMetaClass(m3iRoot,...
            Simulink.metamodel.arplatform.port.Port.MetaClass,true,true);

            for ii=1:m3iPorts.size()
                m3iPort=m3iPorts.at(ii);
                if m3iPort.Interface.isvalid()
                    m3iInterfaceName=m3iPort.Interface.Name;

                    if~interfaceToPortSeqMap.isKey(m3iInterfaceName)
                        interfaceToPortSeqMap(m3iInterfaceName)=Simulink.metamodel.arplatform.port.SequenceOfPort.make(m3iModel);
                    end
                    currSeq=interfaceToPortSeqMap(m3iInterfaceName);
                    currSeq.append(m3iPort);
                    interfaceToPortSeqMap(m3iInterfaceName)=currSeq;
                end
            end
        end




        function m3iRun=findRunnableByName(runnableName,m3iComp)
            m3iRun=[];
            if m3iComp.Behavior.isvalid()
                for rIndex=1:m3iComp.Behavior.Runnables.size()
                    runnable=m3iComp.Behavior.Runnables.at(rIndex);
                    if strcmp(runnable.Name,runnableName)
                        m3iRun=runnable;
                        break;
                    end
                end
            end
        end




        function m3iElement=findElementInSequenceByName(m3iSeq,name)
            m3iElement=[];
            for rIndex=1:m3iSeq.size()
                element=m3iSeq.at(rIndex);
                if strcmp(element.Name,name)
                    m3iElement=element;
                    break;
                end
            end
        end






        function ref=findInstanceRef(m3iComp,refType,ref1,ref1Role,ref2,ref2Role,ref3,ref3Role)
            narginchk(4,8);

            ref=[];
            if isempty(ref1)
                return
            end

            if nargin>=6
                skipRef2=false;
                if isempty(ref2)
                    return
                end
            else
                skipRef2=true;
            end

            if nargin>=8
                skipRef3=false;
            else
                skipRef3=true;
            end

            if isempty(m3iComp.instanceMapping)||~m3iComp.instanceMapping.isvalid()
                return
            end

            m3iInstance=m3iComp.instanceMapping.instance;
            for ii=1:m3iComp.instanceMapping.instance.size()
                iRef=m3iInstance.at(ii);


                if isa(iRef,refType)&&(iRef.(ref1Role)==ref1)&&...
                    (skipRef2||iRef.(ref2Role)==ref2)&&...
                    (skipRef3||iRef.(ref3Role)==ref3)
                    ref=iRef;
                    break
                end
            end

        end






        function m3iRef=getOrCreateInstanceRef(m3iComp,refType,ref1,ref1Role,ref2,ref2Role)
            narginchk(4,6);

            isSingleRef=true;
            if nargin>=6&&~isempty(ref2)&&~isempty(ref2Role)
                isSingleRef=false;
                m3iRef=autosar.mm.Model.findInstanceRef(m3iComp,refType,ref1,ref1Role,ref2,ref2Role);
            else
                m3iRef=autosar.mm.Model.findInstanceRef(m3iComp,refType,ref1,ref1Role);
            end

            if isempty(m3iRef)||~m3iRef.isvalid()
                if isempty(m3iComp.instanceMapping)||~m3iComp.instanceMapping.isvalid()
                    m3iComp.instanceMapping=...
                    Simulink.metamodel.arplatform.instance.ComponentInstanceRef(m3iComp.rootModel);
                end
                m3iRef=feval(refType,m3iComp.rootModel);
                m3iRef.(ref1Role)=ref1;
                if~isSingleRef
                    m3iRef.(ref2Role)=ref2;
                end
                m3iComp.instanceMapping.instance.append(m3iRef);
            end

        end








        function ret=getQualifiedName(namedElement,sep)

            if nargin<2
                sep='/';
            end

            function str=nGetName(obj)
                name=obj.getOne('name');
                if name.isvalid()
                    str=name.toString();
                else
                    str=obj.getMetaClass().qualifiedName;
                end
            end

            ret=nGetName(namedElement);
            rootModel=namedElement.rootModel;
            parent=namedElement.containerM3I;
            while parent.isvalid()
                str=nGetName(parent);
                ret=sprintf('%s%s%s',str,sep,ret);
                if parent==rootModel
                    break
                end
                parent=parent.containerM3I;
            end
        end






        function pkgChild=getOrAddPackage(pkgParent,pkgName,isFromARName,onlyGet)
            if nargin<3
                isFromARName=false;
            end
            if nargin<4
                onlyGet=false;
            end
            pkgChild=autosarcore.MetaModelFinder.getOrAddPackage(pkgParent,pkgName,isFromARName,onlyGet);
        end






        function pkgChild=getOrAddARPackage(pkgParent,pkgName)
            pkgChild=autosarcore.MetaModelFinder.getOrAddARPackage(pkgParent,pkgName);
        end

        function pkgChild=getArPackage(pkgParent,pkgName)
            pkgChild=autosarcore.MetaModelFinder.getArPackage(pkgParent,pkgName);
        end
    end

    methods(Static,Access='public')




        function[route,parent]=splitObjectPath(parent,childName,isFromARName)

            if nargin<3
                isFromARName=false;
            end
            [route,parent]=autosarcore.MetaModelFinder.splitObjectPath(parent,childName,isFromARName);
        end
    end

    methods(Static,Access='private')
        function childNames=i_findObjectNamesByCategory(modelName,category,attributeName)
            metaClass=autosar.api.getAUTOSARProperties.getMetaClassFromCategory(category);
            childType=metaClass.qualifiedName;
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            compObj=autosar.api.Utils.m3iMappedComponent(modelName);

            if strcmp(childType,'Simulink.metamodel.arplatform.behavior.Runnable')
                childList=compObj.Behavior.Runnables;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.DataReceiverPort')
                childList=compObj.ReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.NvDataReceiverPort')
                childList=compObj.NvReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.DataSenderPort')
                childList=compObj.SenderPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.NvDataSenderPort')
                childList=compObj.NvSenderPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')
                childList=compObj.SenderReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort')
                childList=compObj.NvSenderReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ModeReceiverPort')
                childList=compObj.ModeReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ModeSenderPort')
                childList=compObj.ModeSenderPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ClientPort')
                childList=compObj.ClientPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ServiceRequiredPort')
                childList=compObj.RequiredPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                childList=compObj.ProvidedPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.PersistencyProvidedPort')
                childList=compObj.PersistencyProvidedPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.PersistencyRequiredPort')
                childList=compObj.PersistencyRequiredPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.PersistencyProvidedRequiredPort')
                childList=compObj.PersistencyProvidedRequiredPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')
                childList=compObj.ParameterReceiverPorts;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.behavior.IrvData')
                childList=compObj.Behavior.IRV;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.interface.ParameterData')
                childList=compObj.Behavior.Parameters;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.interface.VariableData')
                childList=compObj.Behavior.(attributeName);
            elseif strcmp(childType,'Simulink.metamodel.arplatform.behavior.PerInstanceMemory')
                childList=compObj.Behavior.PIM;
            elseif strcmp(childType,'Simulink.metamodel.arplatform.common.SwAddrMethod')
                childList=autosar.mm.Model.findObjectByMetaClass(m3iModel,metaClass,true);
            else
                assert(false,sprintf('%s is not supported by function autosar.mm.Model.findObjectNamesByCategory().',category));
            end

            childNames=cell(1,childList.size());
            for i=1:childList.size()
                childNames{i}=childList.at(i).Name;
            end
        end
    end
end



