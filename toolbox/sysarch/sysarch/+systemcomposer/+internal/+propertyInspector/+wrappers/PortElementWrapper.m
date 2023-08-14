classdef PortElementWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper





    properties
        SEPARATOR='<separator>';
        INTERFACE_TYPES={'double',...
        'single','int8','uint8','int16','uint16','int32','uint32',...
        'int64','uint64','boolean',...
        '<separator>',...
        'fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};
        INTERFACE_COMPLEXITY={'real','complex','auto'};
        bdH;
        schemaType;
        isImpl=false;
        isAdapterComp=false;
        isViewPort=false;
        isPhysicalPort=false;
        isClientServerPort=false;
        portArch;
        IsInView;
        isAUTOSARCompositionSubDomain=false;
    end

    methods
        function obj=PortElementWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            obj.schemaType='Port';

            if nargin>3
                obj.IsInView=varargin{4};
            else
                obj.IsInView=false;
            end


            if(obj.isAUTOSARCompositionSubDomain)
                obj.schemaType='AUTOSARCompPort';
            elseif obj.isAdapterComp
                obj.schemaType='AdapterPort';
            elseif obj.element.isComponentPort&&isa(obj.element.getComponent,'systemcomposer.architecture.model.views.ComponentGroup')
                obj.schemaType='View Port';
            else
                obj.schemaType='Port';
            end

            if obj.element.isComponentPort&&isa(obj.element.getComponent,'systemcomposer.architecture.model.views.ComponentGroup')
                obj.isViewPort=true;
            end

            if isequal(obj.element.getPortAction,systemcomposer.architecture.model.core.PortAction.PHYSICAL)
                obj.isPhysicalPort=true;
            end

            if isequal(obj.element.getPortAction,systemcomposer.architecture.model.core.PortAction.CLIENT)||...
                isequal(obj.element.getPortAction,systemcomposer.architecture.model.core.PortAction.SERVER)
                obj.isClientServerPort=true;
            end
        end

        function setStereotypeElement(obj)
            if isa(obj.element,'systemcomposer.architecture.model.design.ComponentPort')
                obj.stereotypeElement=obj.element.getArchitecturePort;
            else
                obj.stereotypeElement=obj.element;
            end
        end

        function obj=setPropElement(obj)


            if isempty(obj.sourceHandle)

                obj.element=obj.getZCElement();
                obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.element);
            else
                obj.archName=bdroot(getfullname(obj.sourceHandle));
                obj.element=systemcomposer.utils.getArchitecturePeer(obj.sourceHandle);
            end
            obj.bdH=get_param(obj.archName,'Handle');

            if isa(obj.element,'systemcomposer.architecture.model.design.ComponentPort')
                parComp=obj.element.getComponent;
                obj.isImpl=parComp.isImplComponent;
                obj.isAdapterComp=parComp.isAdapterComponent;
                obj.isReference=parComp.isReferenceComponent;
                if isa(parComp,'systemcomposer.architecture.model.design.VariantComponent')
                    obj.isVarComp=true;
                end
            end

            try
                if isa(obj.element,'systemcomposer.architecture.model.design.ComponentPort')
                    obj.portArch=obj.element.getArchitecturePort;
                else
                    obj.portArch=obj.element;
                end
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                else
                    obj.portArch={};
                end
            end

            if Simulink.internal.isArchitectureModel(obj.bdH,'AUTOSARArchitecture')
                obj.isAUTOSARCompositionSubDomain=true;
                if isa(obj.element,'systemcomposer.architecture.model.design.ComponentPort')
                    if obj.element.getComponent.hasReferencedArchitecture
                        load_system(obj.element.getComponent.getArchitecture.getName);
                    end
                end
                obj.portArch=obj.element.getArchitecturePort;
                obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.portArch);
                return;
            end

            if obj.isImpl||obj.isReference
                contextElem=obj.portArch.getArchitecture;
                if~isempty(contextElem)&&bdIsLoaded(contextElem.getName)
                    obj.contextBdH=get_param(contextElem.getName,'Handle');
                end
            end

        end
        function name=getName(obj)
            elem=obj.getElementForInterface;
            if(obj.isViewPort)
                archPort=[];
            elseif~isa(elem,'systemcomposer.architecture.model.design.ArchitecturePort')
                archPort=elem.getArchitecturePort;
            else
                archPort=elem;
            end
            if~isempty(archPort)
                if(bdIsLoaded(archPort.getName))
                    portHdl=systemcomposer.utils.getSimulinkPeer(archPort);
                    if(strcmpi(get_param(portHdl,'isBusElementPort'),'on'))
                        name=get_param(portHdl,'PortName');
                    else
                        name=get_param(portHdl,'Name');
                    end
                else
                    name=archPort.getName;
                end
            else


                name=obj.element.getName;
            end
        end

        function name=getNameTooltip(obj)

            elem=obj.element;
            if~obj.isViewPort
                elem=obj.getElemToSetPropFor();
            end
            name=elem.getQualifiedName;
        end

        function status=isNameEditable(obj)
            if obj.isReference||obj.isImpl||obj.isViewPort
                status=false;
            else
                status=true;
            end
        end

        function error=setName(obj,changeSet,~)
            error='';
            newValue=changeSet.newValue;
            try
                obj.getElemToSetPropFor().Name=newValue;
            catch
                error='Failed to set Name';
            end
        end
        function actionType=getInterfaceActionType(obj)


            elem=obj.getElementForInterface;
            actionType=char(elem.getPortAction());
        end
        function elem=getElementForInterface(obj)
            elem=obj.element;
        end

        function[value,entries]=getInterfaces(obj)


            AnonymousInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');
            EmptyInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Empty');
            InterfaceCreateOrSelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
            value=obj.getInterfaceName();
            if strcmp(value,'empty')
                value=InterfaceCreateOrSelectStr;
            elseif strcmp(value,'anonymous')
                value=AnonymousInterfaceStr;
            end
            portInterfaces=obj.getPortInterfaces(obj.archName);

            if~obj.isAUTOSARCompositionSubDomain&&~obj.isClientServerPort
                portInterfaces{end+1}=AnonymousInterfaceStr;
            end
            portInterfaces{end+1}=EmptyInterfaceStr;
            entries=cat(2,portInterfaces);
        end

        function interfaceName=getInterfaceName(obj)
            architecturePort=obj.getElementForInterface;
            interfaceName='empty';
            if~isempty(architecturePort.getPortInterface())
                try
                    if(architecturePort.getPortInterface().isAnonymous())
                        interfaceName='anonymous';
                    else
                        interfaceName=architecturePort.getPortInterfaceName();
                    end
                catch ex
                    diagnosticViewerStage=sldiagviewer.createStage(message('SystemArchitecture:Interfaces:InterfaceAccess').getString(),'ModelName',get_param(bdroot(this.SourceHandle),'Name'));%#ok
                    sldiagviewer.reportError(ex);
                    interfaceName=architecturePort.getPortInterfaceName();
                end
            end
        end

        function status=isInterfaceEnabled(obj)
            if obj.isReference||obj.isImpl||obj.isViewPort
                status=false;
            else
                status=true;
            end
        end
        function setInterfaceElementPropertyValue(port,prop,propval,interfaceSemanticModel)
            pi=systemcomposer.internal.getWrapperForImpl(port.element.getPortInterface());
            switch(prop)
            case 'AInterfaceType'
                pi.setType(propval);
            case 'AInterfaceDim'
                pi.setDimensions(propval);
            case 'AInterfaceUnit'
                pi.setUnits(propval);
            case 'AInterfaceComplexity'
                pi.setComplexity(propval);
            case 'AInterfaceMin'
                pi.setMinimum(propval);
            case 'AInterfaceMax'
                pi.setMaximum(propval);
            end
        end
        function err=setInterface(obj,changeSet,propObj)


            err='';
            newValue=changeSet.newValue;
            elem=obj.getElementForInterface;
            archPort=systemcomposer.internal.getWrapperForImpl(elem);
            archPort.setInterface('');

            if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Empty'))
                archPort.setInterface('');

            elseif strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous'))
                if archPort.Direction==systemcomposer.arch.PortDirection.Physical
                    archPort.createInterface('PhysicalDomain');
                else
                    archPort.createInterface('ValueType');
                end
            else
                interfaceSemanticModel=obj.fetchInterfaceSemanticModelFromBDOrDD();
                piCatalogImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(interfaceSemanticModel);
                dictionary=systemcomposer.interface.Dictionary(piCatalogImpl);

                if any(strcmp(newValue,propObj.entries))


                    interface=dictionary.getInterface(newValue);
                    ddInfo=split(newValue,'::');

                    if numel(ddInfo)==2




                        intrfName=ddInfo{2};
                        interfaces=dictionary.Interfaces;
                        for i=1:numel(interfaces)
                            if strcmp(intrfName,interfaces(1,i).Name)
                                interface=interfaces(1,i);
                            end
                        end
                    end

                else

                    interfaceName=strrep(newValue,' ','');

                    interface=dictionary.addInterface(interfaceName);
                end
                archPort.setInterface(interface);
            end
        end
        function propval=getInterfaceElementPropertyValue(port,prop)
            pi=port.element.getPortInterface();
            if isa(pi,'systemcomposer.architecture.model.interface.CompositeSignalInterface')


                assert(strcmp(prop,'Sysarch:Port:AInterface:Type'));
                propval=pi.getName();
                return;
            end
            switch(prop)
            case 'AInterfaceType'
                propval=pi.p_Type;
            case 'AInterfaceDim'
                propval=pi.p_Dimensions;
            case 'AInterfaceUnit'
                propval=pi.p_Units;
            case 'AInterfaceComplexity'
                propval=pi.p_Complexity;
            case 'AInterfaceMin'
                propval=pi.p_Minimum;
            case 'AInterfaceMax'
                propval=pi.p_Maximum;
            end
        end
        function enumList=getEnumerationsFromLinkedDictionary(obj)
            enumList={};
            try
                ddName=get_param(obj.bdH,'DataDictionary');
                if(isempty(ddName))
                    return
                end
                ddConn=Simulink.data.dictionary.open(ddName);
                enumList=systemcomposer.getEnumerationsFromDictionary(ddConn);
                ddConn.close();
            catch

            end
        end
        function interfaceSemanticModel=fetchInterfaceSemanticModelFromBDOrDD(obj)

            interfaceSemanticModel=get_param(obj.bdH,'SystemComposerMF0Model');
            dd=get_param(obj.bdH,'DataDictionary');
            if~isempty(dd)
                ddObj=Simulink.data.dictionary.open(dd);
                interfaceSemanticModel=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
            end
        end

        function err=setAnonymousInterfacePropertyValue(obj,changeSet,propObj)
            err='';
            id=propObj.id;
            elemNameSet=split(id,':');
            elemType=elemNameSet{end};
            propVal=changeSet.newValue;

            elem=obj.getElementForInterface;
            archPort=elem.getArchitecturePort;
            prtInterface=systemcomposer.internal.getWrapperForImpl(archPort.getPortInterface());
            switch elemType
            case 'AInterfaceType'
                prtInterface.setType(propVal);
            case 'AInterfaceDim'
                prtInterface.setDimensions(propVal);
            case 'AInterfaceUnit'
                prtInterface.setUnits(propVal);
            case 'AInterfaceComplexity'
                prtInterface.setComplexity(propVal);
            case 'AInterfaceMin'
                prtInterface.setMinimum(propVal);
            case 'AInterfaceMax'
                prtInterface.setMaximum(propVal);
            end
        end

        function kind=getPortKind(obj,~)
            if autosar.composition.Utils.isDataSenderPort(obj.sourceHandle)
                kind='Sender';
            else
                kind='Receiver';
            end
        end
        function[value,entries]=getDataType(obj,~)
            value=autosar.simulink.bep.Utils.getParam(...
            obj.sourceHandle,true,'OutDataTypeStr');


            dts=slprivate('slGetUserDataTypesFromWSDD',...
            get_param(obj.sourceHandle,'Object'),[],[],true);
            dts=dts(startsWith(dts,'Bus:'));


            entries=[{'Inherit: auto'},dts];
        end
        function enabled=isDataTypeEnabled(obj,~)
            if obj.isViewPort
                enabled=false;
            else
                component=get_param(obj.sourceHandle,'Parent');
                isPortBlockOwnerLinkedComponent=strcmp(get_param(component,'type'),'block_diagram')&&...
                ~autosar.composition.Utils.isModelInCompositionDomain(component);
                enabled=~isPortBlockOwnerLinkedComponent;
            end
        end
        function portInterfaceNames=getPortInterfaces(obj,archName)

            try
                bd=get_param(archName,'handle');
                dd=get_param(bd,'DataDictionary');

                if~isempty(dd)
                    ddObj=Simulink.data.dictionary.open(dd);
                    mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
                    portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
                    if obj.isPhysicalPort
                        portInterfaces=portInterfaceCatalog.getPortInterfacesInClosure('Physical');
                    elseif obj.isClientServerPort
                        portInterfaces=portInterfaceCatalog.getPortInterfacesInClosure('Service');
                    else
                        portInterfaces=portInterfaceCatalog.getPortInterfacesInClosure('Data');
                    end
                    primaryNames={};
                    referenceNames={};
                    for idx=1:numel(portInterfaces)
                        intrf=portInterfaces(idx);
                        piCatalog=intrf.getCatalog;
                        if piCatalog==portInterfaceCatalog

                            primaryNames=[primaryNames,intrf.getName];
                        else


                            referenceNames=[referenceNames,[piCatalog.getStorageSource,'::',intrf.getName]];
                        end
                    end
                    portInterfaceNames=[primaryNames,referenceNames];
                else

                    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bd);
                    mf0Model=app.getCompositionArchitectureModel;
                    portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
                    if obj.isPhysicalPort
                        portInterfaceNames=portInterfaceCatalog.getPortInterfaceNamesInClosure('Physical');
                    elseif obj.isClientServerPort
                        portInterfaceNames=portInterfaceCatalog.getPortInterfaceNamesInClosure('Service');
                    else
                        portInterfaceNames=portInterfaceCatalog.getPortInterfaceNamesInClosure('Data');
                    end
                end
            catch
                portInterfaceNames={};
            end
        end


        function interfaceLabel=getInterfaceLabel(~)
            interfaceLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Interface');
        end

        function error=setDataType(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            newBusDataTypeValue=newValue;
            autosar.simulink.bep.Utils.setParam(...
            obj.sourceHandle,true,'OutDataTypeStr',newBusDataTypeValue);
        end
    end

    methods(Access=private)
        function elem=getElemToSetPropFor(obj)
            elem=obj.element;
            if(obj.IsInView)
                elem=elem.p_Redefines;
            end
            elem=systemcomposer.internal.getWrapperForImpl(elem);
        end
    end
end


