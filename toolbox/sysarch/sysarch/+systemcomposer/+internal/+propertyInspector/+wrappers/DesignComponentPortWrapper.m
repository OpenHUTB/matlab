classdef DesignComponentPortWrapper<systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper





    properties
        mdl;
        occurenceElement;
        isAdapterComp;
        isAUTOSARCompositionSubDomain;
    end
    properties(Constant,Access=private)
        CreateOrSelect=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
    end
    methods
        function obj=DesignComponentPortWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper(varargin{:});

            if(obj.isAUTOSARCompositionSubDomain)
                obj.schemaType='AUTOSARCompPort';
            elseif obj.isAdapterComp
                obj.schemaType='AdapterPort';
            else
                obj.schemaType='Port';
            end
        end

        function obj=setPropElement(obj)


            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getModel();
            obj.occurenceElement=obj.mdl.findElement(obj.uuid);
            obj.element=obj.occurenceElement.getArchitecturePort.getDesignComponentPort;
            try
                if(obj.element.getComponent.hasReferencedArchitecture)
                    load_system(obj.element.getComponent.getArchitecture.getName);
                end
            catch

            end
            obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.element);
            if isa(obj.element.getSourceComponentForPort,'systemcomposer.architecture.model.design.VariantComponent')
                obj.isVarComp=true;
            end
            if obj.element.getSourceComponentForPort.isImplComponent
                obj.isImpl=true;
            end
            if obj.element.getSourceComponentForPort.isAdapterComponent
                obj.isAdapterComp=true;
            end
            if obj.element.getSourceComponentForPort.isReferenceComponent
                obj.isReference=true;
            end
            if Simulink.internal.isArchitectureModel(obj.bdH,'AUTOSARArchitecture')
                obj.isAUTOSARCompositionSubDomain=true;
                obj.portArch=obj.element.getArchitecturePort;
                obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.portArch);
                return;
            end
            if obj.isImpl||obj.isReference
                contextElem=obj.element.getSourceComponentForPort.getArchitecture;
                if~isempty(contextElem)&&bdIsLoaded(contextElem.getName)
                    obj.contextBdH=get_param(contextElem.getName,'Handle');
                end
            end
            try
                obj.portArch=obj.element.getSourceComponentForPort.getArchitecture;
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                else
                    obj.portArch={};
                end
            end
        end
        function type=getObjectType(~)
            type='Port';
        end
        function setStereotypeElement(obj)
            obj.stereotypeElement=obj.element.getArchitecturePort;
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
            component=get_param(obj.sourceHandle,'Parent');
            isPortBlockOwnerLinkedComponent=strcmp(get_param(component,'type'),'block_diagram')&&...
            ~autosar.composition.Utils.isModelInCompositionDomain(component);
            enabled=~isPortBlockOwnerLinkedComponent;
        end
        function name=getName(obj,~)
            if~isempty(obj.portArch)
                if(bdIsLoaded(obj.portArch.getName))
                    portHdl=systemcomposer.utils.getSimulinkPeer(obj.element.getArchitecturePort);
                    if(strcmpi(get_param(portHdl,'isBusElementPort'),'on'))
                        name=get_param(portHdl,'PortName');
                    else
                        name=get_param(portHdl,'Name');
                    end
                else
                    elemArchPort=obj.element.getArchitecturePort;
                    name=elemArchPort.getName;
                end
            else


                name=obj.element.getName;
            end
        end

        function status=isNameEditable(obj)
            if obj.isReference||obj.isImpl
                status=false;
            else
                status=true;
            end
        end

        function status=isInterfaceEnabled(obj)
            if obj.isReference||obj.isImpl
                status=false;
            else
                status=true;
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

        function error=setName(obj,changeSet,~)

            error='';
            newName=changeSet.newValue;
            try
                if~isempty(obj.portArch)
                    if(bdIsLoaded(obj.portArch.getName))
                        portHdl=systemcomposer.utils.getSimulinkPeer(obj.element.getArchitecturePort);
                        if(strcmpi(get_param(portHdl,'isBusElementPort'),'on'))
                            set_param(portHdl,'PortName',newName);
                        else
                            set_param(portHdl,'Name',newName);
                        end
                    else
                        elemArchPort=obj.element.getArchitecturePort;
                        elemArchPort.setName(newName);
                    end
                elseif~isempty(obj.sourceHandle)
                    set_param(this.sourceHandle,'Name',newName);
                else


                    obj.element.setName(newName);
                end
            catch
                error='Failed to set Name';
            end
        end
        function hdl=getBdFromContext(this)
            if this.isImpl||this.isReference
                hdl=this.contextBdH;
            else
                hdl=this.bdH;
            end
        end
    end
end


