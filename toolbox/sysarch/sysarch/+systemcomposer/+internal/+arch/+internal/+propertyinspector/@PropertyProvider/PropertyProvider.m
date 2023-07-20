classdef PropertyProvider<handle









    properties
        type;
        bdH;
        UUID;
        Properties={};
        PropertySpecMap;
    end

    properties(SetAccess=private)
        selectedConnDest char='';


        isReference=false;
        isImpl=false;
        isVarComp=false;
        isAdapterComp=false;
        isAUTOSARModel=false;
        contextBdH=-1;
    end

    properties(Constant,Access=private)
        SEPARATOR='<separator>';
        DEL_STEREOTYPE_ICN='deleteInterface_16';
        EDIT_INTERFACE_MAP_ICN='';
        RESET_PROPS_TO_DEFAULT_ICN='resetToDefaultValues_16';
        INTERFACE_TYPES={'double',...
        'single','int8','uint8','int16','uint16','int32','uint32',...
        'int64','uint64','boolean',...
        systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.SEPARATOR,...
        'fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};
        INTERFACE_COMPLEXITY={'real','complex','auto'};
    end

    methods(Access=public)


        function this=PropertyProvider(elem,srcHdlOrName,selection)
            this.bdH=srcHdlOrName;
            this.PropertySpecMap=containers.Map();
            this.setTypeAndContext(elem);



            if(~ischar(this.bdH)&&Simulink.internal.isArchitectureModel(this.bdH,'AUTOSARArchitecture'))
                this.isAUTOSARModel=true;
            end
            if strcmp(this.type,'Connector')&&~isempty(selection)


                this.selectedConnDest=selection;
                this.UUID=this.getSelectedConnector(elem).UUID;
            else
                this.UUID=elem.UUID;
            end
            this.initialize(elem);
        end

    end

    methods(Static,Access=public)

        function interfaceSemanticModel=fetchInterfaceSemanticModelFromBDOrDD(bdH)

            interfaceSemanticModel=get_param(bdH,'SystemComposerMF0Model');
            dd=get_param(bdH,'DataDictionary');
            if~isempty(dd)
                ddObj=Simulink.data.dictionary.open(dd);
                interfaceSemanticModel=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
            end
        end

        function setPropertyValue(srcHdlOrName,elemUuid,propObj,newValue)

            if ishandle(srcHdlOrName)

                mf0Mdl=get_param(srcHdlOrName,'SystemComposerMF0Model');
                elem=mf0Mdl.findElement(elemUuid);

                if isempty(elem)


                    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(srcHdlOrName);
                    viewMdl=app.getArchViewsAppMgr.getModel();
                    elem=viewMdl.findElement(elemUuid);
                end
            else


                ddObj=Simulink.data.dictionary.open([srcHdlOrName,'.sldd']);
                mf0Mdl=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
                elem=mf0Mdl.findElement(elemUuid);
            end

            switch propObj.id


            case 'Main:Name'
                switch class(elem)
                case 'systemcomposer.architecture.model.design.ComponentPort'
                    slHdl=systemcomposer.utils.getSimulinkPeer(elem.getArchitecturePort);
                    if(strcmpi(get_param(slHdl,'isBusElementPort'),'on'))
                        set_param(slHdl,'PortName',newValue);
                    else
                        set_param(slHdl,'Name',newValue);
                    end
                case{'systemcomposer.architecture.model.design.Component',...
                    'systemcomposer.architecture.model.design.VariantComponent'}
                    slHdl=systemcomposer.utils.getSimulinkPeer(elem);
                    set_param(slHdl,'Name',newValue);
                case{'systemcomposer.architecture.model.design.BaseConnector',...
                    'systemcomposer.architecture.model.views.ViewComponent',...
                    'systemcomposer.architecture.model.views.LinkedViewComponent',...
                    'systemcomposer.architecture.model.views.ViewArchitecturePort',...
                    'systemcomposer.architecture.model.views.ViewArchitecture'}
                case{'systemcomposer.architecture.model.interface.CompositeDataInterface',...
                    'systemcomposer.architecture.model.interface.ValueTypeInterface',...
                    'systemcomposer.architecture.model.interface.CompositePhysicalInterface',...
                    'systemcomposer.architecture.model.swarch.ServiceInterface'}
                    elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                    elemWrapper.setName(newValue);
                otherwise
                    error('Trying to set name of an invalid element');
                end

            case 'Main:AdapterMapping'
                elemH=systemcomposer.utils.getSimulinkPeer(elem);
                dObj=systemcomposer.internal.adapter.Dialog(elemH);
                dialogInstance=DAStudio.Dialog(dObj);

                dialogInstance.show();
                dialogInstance.refresh();


            case 'Interface:Name'
                archPort=systemcomposer.internal.getWrapperForImpl(elem.getArchitecturePort);

                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Empty'))
                    architecturePort.setInterface('');

                elseif strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous'))
                    archPort.createInterface('ValueType');

                elseif any(strcmp(newValue,propObj.options))
                    interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.fetchInterfaceSemanticModelFromBDOrDD(srcHdlOrName);
                    portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(interfaceSemanticModel);
                    dictionary=systemcomposer.interface.Dictionary(portInterfaceCatalog);
                    intrf=dictionary.getInterface(newValue);
                    archPort.setInterface(intrf);

                else
                    interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.fetchInterfaceSemanticModelFromBDOrDD(srcHdlOrName);
                    interfaceName=strrep(newValue,' ','');

                    piCatalogImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(interfaceSemanticModel);
                    dictionary=systemcomposer.interface.Dictionary(piCatalogImpl);
                    interface=dictionary.addInterface(interfaceName);

                    archPort.setInterface(interface);
                end


            case{'Interface:AInterfaceType','Interface:AInterfaceDim',...
                'Interface:AInterfaceUnit','Interface:AInterfaceComplexity',...
                'Interface:AInterfaceMin','Interface:AInterfaceMax'}
                archPort=elem.getArchitecturePort;
                interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.fetchInterfaceSemanticModelFromBDOrDD(srcHdlOrName);
                systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.setAnonymousInterfacePropertyValue(interfaceSemanticModel,archPort,propObj.id,newValue);
            case 'ValueTypeProps:AInterfaceType'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setType(newValue);
            case 'ValueTypeProps:AInterfaceDim'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setDimensions(newValue);
            case 'ValueTypeProps:AInterfaceUnit'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setUnits(newValue);
            case 'ValueTypeProps:AInterfaceComplexity'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setComplexity(newValue);
            case 'ValueTypeProps:AInterfaceMin'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setMinimum(newValue);
            case 'ValueTypeProps:AInterfaceMax'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setMaximum(newValue);
            case 'ValueTypeProps:AInterfaceDescription'
                elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                elemWrapper.setDescription(newValue);

            case 'Stereotype'
                if~isempty(newValue)
                    if isa(elem,'systemcomposer.architecture.model.design.ComponentPort')

                        elem=elem.getArchitecturePort;
                    end
                    switch newValue
                    case DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit')

                        systemcomposer.profile.editor
                    case DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll')

                        elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
                        appliedPrototypes=elem.p_Prototype;
                        for i=1:length(appliedPrototypes)
                            appliedPrototype=appliedPrototypes(i);
                            profName=appliedPrototype.profile.getName;
                            if systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.isMathWorksProfile(profName)

                                continue;
                            end
                            elem.removePrototype(appliedPrototype.fullyQualifiedName);
                        end

                    otherwise

                        elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
                        elem.applyPrototype(newValue);
                    end
                end


            otherwise
                if contains(propObj.id,'Stereotype:')
                    maybeStereotypeAndProperty=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.stripStereotypeTag(propObj.id);


                    if contains(maybeStereotypeAndProperty,':')
                        stereotypeAndPropertyName=split(maybeStereotypeAndProperty,':');
                        stereotypeName=stereotypeAndPropertyName{1};
                        propName=stereotypeAndPropertyName{2};
                        elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
                        propUsg=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getPropertyUsage(elem,stereotypeName,propName);
                        propType='Value';
                        switch class(propUsg.propertyDef.type)
                        case 'systemcomposer.property.BooleanType'
                            if newValue&&boolean(eval(newValue))
                                newValue='true';
                            else
                                newValue='false';
                            end
                        case{'systemcomposer.property.StringType',...
                            'systemcomposer.property.StringArrayType'}

                            try
                                propUsg.initialValue.type.validateExpression(newValue);
                            catch ME
                                if strcmp(ME.identifier,'SystemArchitecture:Property:CannotEvalExpression')||...
                                    strcmp(ME.identifier,'SystemArchitecture:Property:InvalidStringPropValue')

                                    newValue="'"+string(newValue)+"'";
                                else
                                    rethrow(ME);
                                end
                            end
                        case{'systemcomposer.property.FloatType',...
                            'systemcomposer.property.IntegerType'}
                            maybeValOrUnit=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.extractTopTag(newValue);
                            valueToSet=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.extractBottomTag(newValue);
                            switch maybeValOrUnit
                            case 'Value'
                                if isempty(valueToSet)
                                    propUsg.clearValue(elem.UUID);
                                    return;
                                end
                                newValue=valueToSet;
                            case 'Unit'
                                propType='Unit';
                                newValue=valueToSet;
                                if isempty(valueToSet)


                                    newValue=propUsg.propertyDef.defaultValue.units;
                                end
                            otherwise
                                error('Invalid tag received on setting property value');
                            end
                        case 'systemcomposer.property.Enumeration'
                            newValue="'"+string(newValue)+"'";
                        otherwise
                            error("Invalid Property")
                        end
                        propFQN=[propUsg.propertySet.getName,'.',propUsg.getName];
                        prevValue=elem.getPropVal(propFQN);
                        setValue=false;
                        if strcmp(propType,'Value')
                            expressionToSet=newValue;
                            setValue=true;
                            if isempty(prevValue.units)
                                unitsToSet='*';
                            else
                                unitsToSet=prevValue.units;
                            end
                        elseif strcmp(propType,'Unit')
                            setValue=true;
                            expressionToSet=prevValue.expression;
                            unitsToSet=newValue;
                        end

                        try
                            if setValue
                                elem.setPropVal(propFQN,expressionToSet,unitsToSet);
                            end
                        catch ME
                            if strcmp(ME.identifier,'SystemArchitecture:Property:ErrorSettingPropertyValue')&&~isempty(ME.cause)



                                throw(ME.cause{1});
                            else
                                rethrow(ME)
                            end
                        end


                    else
                        stereotypeName=maybeStereotypeAndProperty;
                        assert(length(propObj.options)==3);



                        stereotypeFqn=propObj.options{3};
                        assert(contains(stereotypeFqn,stereotypeName));
                        elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
                        switch newValue
                        case{"doRemove",DAStudio.message('SystemArchitecture:PropertyInspector:Remove')}
                            elem.removePrototype(stereotypeFqn);
                        case{"doReset",DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')}
                            systemcomposer.internal.resetToDefaultValues(elem,stereotypeName);
                        end
                    end

                end

            end
        end

        function ret=stripStereotypeTag(tag)
            ret=tag(12:end);
        end

        function ret=extractBottomTag(tag)
            ret=tag(strfind(tag,':')+1:end);
        end

        function ret=extractTopTag(tag)
            ret=tag(1:strfind(tag,':')-1);
        end


        function[stereoName,propName]=getStereotypeAndPropertyNames(id)
            stereoAndPropId=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.stripStereotypeTag(id);
            stereoAndPropName=strsplit(stereoAndPropId,':');
            assert(length(stereoAndPropName)==2);
            stereoName=stereoAndPropName{1};
            propName=stereoAndPropName{2};



            stereo=systemcomposer.profile.Stereotype.find(stereoName);
            prop=stereo.findProperty(propName);
            stereoName=prop.Stereotype.FullyQualifiedName;
            propName=prop.Name;
        end

        function PU=getPropertyUsage(elem,stereoName,propName)
            PU=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.getPropUsage(elem,stereoName,propName);
        end
    end

    methods(Static,Access=private)
        function isMWProfile=isMathWorksProfile(profileName)
            prof=systemcomposer.profile.Profile.find(profileName);
            isMWProfile=~isempty(prof)&&prof.IsMathWorksProfile;
        end

        function addPropertyNodeTooltip(node,elem)
            assert(contains(node.id,'Stereotype:'));
            stereoAndPropName=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.stripStereotypeTag(node.id);
            stereoName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractTopTag(stereoAndPropName);
            propName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractBottomTag(stereoAndPropName);
            elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
            propUsg=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getPropertyUsage(elem,stereoName,propName);

            propFQN=[propUsg.propertySet.getName,'.',propUsg.getName];
            toolTip=propFQN;
            if elem.isPropValDefault(propFQN)
                toolTip=[toolTip,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
            end

            node.tooltip=toolTip;
        end



        function addPropertyNodeValue(node,elem)
            assert(contains(node.id,'Stereotype:'));
            stereoAndPropName=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.stripStereotypeTag(node.id);
            stereoName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractTopTag(stereoAndPropName);
            propName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractBottomTag(stereoAndPropName);
            elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
            propUsg=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getPropertyUsage(elem,stereoName,propName);

            propFQN=[propUsg.propertySet.getName,'.',propUsg.getName];
            val=elem.getPropVal(propFQN);
            switch class(propUsg.propertyDef.type)
            case 'systemcomposer.property.BooleanType'
                propVal=val.expression;
                propUnits='';
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType'}
                propVal=val.expression;
                propUnits='';
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                propVal=val.expression;
                propUnits=val.units;
            case 'systemcomposer.property.Enumeration'
                try
                    enumVal=elem.getPropValObject(propFQN).getValue;
                    propVal=char(enumVal);
                catch ME
                    if(strcmp(ME.identifier,'SystemArchitecture:Property:InvalidEnumPropValue'))
                        propVal=eval(val.expression);
                    else
                        rethrow(ME)
                    end
                end
                propUnits='';
            otherwise
            end

            if~isempty(propUnits)
                displayVal=[propVal,' ',propUnits];
            else
                displayVal=propVal;
            end

            node.value=displayVal;
        end

        function addPropertyNodeRenderMode(node,elem)
            assert(contains(node.id,'Stereotype:'));
            stereoAndPropName=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.stripStereotypeTag(node.id);
            stereoName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractTopTag(stereoAndPropName);
            propName=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.extractBottomTag(stereoAndPropName);
            elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
            propUsg=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getPropertyUsage(elem,stereoName,propName);

            switch class(propUsg.propertyDef.type)
            case 'systemcomposer.property.BooleanType'
                node.rendermode='checkbox';
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType'}
                node.rendermode='editbox';
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                val=elem.getPropVal([propUsg.propertySet.getName,'.',propUsg.getName]);
                propUnits=val.units;
                if isempty(propUnits)
                    node.rendermode='dualedit';
                else
                    node.rendermode='dualeditcombo';
                    compatibleUnits=propUsg.getSimilarUnits();
                    if isempty(compatibleUnits)


                        compatibleUnits={PU.propertyDef.type.units};
                    end
                    node.addOptions(compatibleUnits);
                end
            case 'systemcomposer.property.Enumeration'
                node.rendermode='combobox';
                node.editable=false;
                node.addOptions(propUsg.propertyDef.type.getLiteralsAsStrings);
            otherwise

            end

        end

        function elem=getElementForStereotypeAccess(curElem)


            try
                if(isa(curElem,'systemcomposer.architecture.model.design.BaseComponent'))
                    elem=curElem.getArchitecture;
                elseif(isa(curElem,'systemcomposer.architecture.model.design.ComponentPort'))
                    elem=curElem.getArchitecturePort;
                else
                    elem=curElem;
                end
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                end
                elem={};
            end
        end

        function setAnonymousInterfacePropertyValue(~,port,propId,propVal)
            pi=systemcomposer.internal.getWrapperForImpl(port.getPortInterface());
            switch propId
            case 'Interface:AInterfaceType'
                pi.setType(propVal);
            case 'Interface:AInterfaceDim'
                pi.setDimensions(propVal);
            case 'Interface:AInterfaceUnit'
                pi.setUnits(propVal);
            case 'Interface:AInterfaceComplexity'
                pi.setComplexity(propVal);
            case 'Interface:AInterfaceMin'
                pi.setMinimum(propVal);
            case 'Interface:AInterfaceMax'
                pi.setMaximum(propVal);
            end
        end

    end

    methods(Access=private)

        function setTypeAndContext(this,elem)

            switch class(elem)
            case 'systemcomposer.architecture.model.design.Component'
                if(elem.isAdapterComponent)
                    this.type='Adapter';
                    this.isAdapterComp=true;
                else
                    this.type='Component';
                    this.setContext(elem);
                end
            case 'systemcomposer.architecture.model.design.VariantComponent'
                this.type='Component';
                this.isVarComp=true;
            case 'systemcomposer.architecture.model.design.ComponentPort'
                this.type='Port';
                this.setContext(elem);
            case 'systemcomposer.architecture.model.design.BaseConnector'
                this.type='Connector';
            case{'systemcomposer.architecture.model.views.ViewComponent',...
                'systemcomposer.architecture.model.views.LinkedViewComponent'}
                this.type='ViewComponent';
            case 'systemcomposer.architecture.model.views.ViewArchitecture'
                this.type='ViewArchitecture';
            case 'systemcomposer.architecture.model.views.ViewArchitecturePort'
                this.type='ViewPort';
            case{'systemcomposer.architecture.model.interface.CompositeDataInterface',...
                'systemcomposer.architecture.model.interface.CompositePhysicalInterface',...
                'systemcomposer.architecture.model.interface.ValueTypeInterface',...
                'systemcomposer.architecture.model.interface.AtomicPhysicalInterface',...
                'systemcomposer.architecture.model.swarch.ServiceInterface'}
                this.type='PortInterface';
            otherwise
                error(['Element ''',elem.getName,''' not supported']);
            end
        end

        function setContext(this,elem)


            switch this.type
            case 'Component'
                if elem.isImplComponent
                    this.isImpl=true;
                end
                if elem.isReferenceComponent
                    this.isReference=true;
                end
                if this.isImpl||this.isReference
                    contextElem=this.getElementArchitectureIfExists(elem);
                    if~isempty(contextElem)&&bdIsLoaded(contextElem.getName)
                        this.contextBdH=get_param(contextElem.getName,'Handle');
                    end
                end
            case 'Port'
                if isa(elem.getSourceComponentForPort,'systemcomposer.architecture.model.design.VariantComponent')
                    this.isVarComp=true;
                end
                if elem.getSourceComponentForPort.isImplComponent
                    this.isImpl=true;
                end
                if elem.getSourceComponentForPort.isAdapterComponent
                    this.isAdapterComp=true;
                end
                if elem.getSourceComponentForPort.isReferenceComponent
                    this.isReference=true;
                end
                if this.isImpl||this.isReference
                    contextElem=this.getElementArchitectureIfExists(elem);
                    if~isempty(contextElem)&&bdIsLoaded(contextElem.getName)
                        this.contextBdH=get_param(contextElem.getName,'Handle');
                    end
                end
            end
        end

        function interface=getPortInterfaceIfExists(~,elem)
            try
                interface=elem.getPortInterface;
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                else
                    interface={};
                end
            end
        end

        function interfaceName=getPortInterfaceNameIfExist(~,elem)
            try
                interfaceName=elem.getPortInterfaceName;
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                else
                    interfaceName='';
                end
            end
        end

        function contextElem=getElementArchitectureIfExists(this,elem)
            switch this.type
            case 'Component'
                try
                    contextElem=elem.getArchitecture;
                catch ME
                    if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                        rethrow(ME)
                    else
                        contextElem={};
                    end
                end
            case 'Port'
                try
                    contextElem=elem.getSourceComponentForPort.getArchitecture;
                catch ME
                    if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                        rethrow(ME)
                    else
                        contextElem={};
                    end
                end
            end
        end

        function initialize(this,elem)

            if strcmp(this.type,'Connector')
                this.setupPortSelectionNode(elem);
            end
            this.setupMainNode(elem);
            if any(strcmp(this.type,{'Port','ViewPort'}))
                switch this.type
                case 'Port'
                    isView=false;
                case 'ViewPort'
                    isView=true;
                end
                if~this.isAUTOSARModel
                    this.setupInterfaceNode(elem,isView);
                end
            end

            if(isa(elem,'systemcomposer.architecture.model.interface.ValueTypeInterface'))
                node=this.addRootPropertyNode('ValueTypeProps',...
                DAStudio.message('SystemArchitecture:PropertyInspector:Properties'),true);
                this.addPropertiesForValueTypeInterfaceNode(node,elem);
            end

            if~any(strcmp(this.type,{'ViewComponent','ViewArchitecture','ViewPort'}))

                if~this.isAdapterComp&&~this.isAUTOSARModel
                    this.setupAddStereotypeNode(elem);
                    this.setupAppliedStereotypeNodes(elem);
                elseif this.isAUTOSARModel

                end
            end
        end

        function node=addRootPropertyNode(this,nodeID,nodeName,isGroup)

            node=systemcomposer.internal.arch.internal.propertyinspector.Property.makeRootNode(nodeID,nodeName);
            node.parentId='';
            this.Properties{end+1}=node;
            this.PropertySpecMap(node.id)=node;
            if isGroup



                node.editable=false;
                node.value='';
                node.rendermode='none';
            end
        end

        function node=addChildPropertyNode(this,parentNode,nodeID,nodeName)
            node=parentNode.addChildPropNode(nodeID,nodeName);
            this.PropertySpecMap(node.id)=node;
        end

        function setupMainNode(this,elem)

            mainNodeID='Main';
            mainNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Main');
            mainNode=this.addRootPropertyNode(mainNodeID,mainNodeName,true);
            mainNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:GenProps');


            nameNodeID='Name';
            nameNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
            childProp=this.addChildPropertyNode(mainNode,nameNodeID,nameNodeName);
            switch this.type
            case{'Component','Adapter'}
                childProp.value=elem.getName();
                childProp.tooltip=elem.getQualifiedName;
            case 'Port'
                portArch=this.getElementArchitectureIfExists(elem);
                if~isempty(portArch)
                    if(bdIsLoaded(portArch.getName))
                        portHdl=systemcomposer.utils.getSimulinkPeer(elem.getArchitecturePort);
                        if(strcmpi(get_param(portHdl,'isBusElementPort'),'on'))
                            childProp.value=get_param(portHdl,'PortName');
                        else
                            childProp.value=get_param(portHdl,'Name');
                        end
                    else
                        elemArchPort=elem.getArchitecturePort;
                        childProp.value=elemArchPort.getName;
                    end
                else


                    childProp.value=elem.getName;
                end
                childProp.tooltip=elem.getQualifiedName;
                childProp.enabled=~(this.isReference||this.isImpl);
            case{'ViewArchitecture','ViewComponent'}
                childProp.value=elem.getName();
                childProp.tooltip=elem.getName();
            case 'PortInterface'
                childProp.value=elem.getName();
                childProp.tooltip=elem.getName();
                childProp.editable=true;
                childProp.enabled=true;
            case 'ViewPort'
                childProp.value=elem.getName();
                childProp.tooltip=elem.getName();
                childProp.enabled=false;
            case 'Connector'
                selectedConn=this.getSelectedConnector(elem);
                childProp.value=selectedConn.getName();
                childProp.tooltip=[selectedConn.getSource.getQualifiedName,'->',selectedConn.getDestination.getQualifiedName];
            otherwise
                childProp.tooltip='Name of element';
            end

            if strcmp(this.type,'Adapter')

                mappingNodeID='AdapterMapping';
                mappingNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Mappings');
                mappingNode=this.addChildPropertyNode(mainNode,mappingNodeID,mappingNodeName);
                mappingNode.rendermode='actioncallback';
                mappingNode.value=DAStudio.message('SystemArchitecture:PropertyInspector:Edit');
                mappingNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:EditInterfaceMap');
                mappingNode.addOptions({this.EDIT_INTERFACE_MAP_ICN})
            end
        end

        function setupPortSelectionNode(this,elem)
            nodeID='PortSelection';
            nodeName=DAStudio.message('SystemArchitecture:PropertyInspector:PortSelection');
            prtSelectNode=this.addRootPropertyNode(nodeID,nodeName,true);


            srcNodeID='Source';
            srcNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Source');
            srcNode=this.addChildPropertyNode(prtSelectNode,srcNodeID,srcNodeName);
            srcNode.editable=false;
            if(length(elem)>1)


                allSrcName=arrayfun(@(conn)conn.getSource.getName,elem,'UniformOutput',false);
                assert(all(cellfun(@(name)isequal(name,allSrcName{1}),allSrcName)));
            end
            srcNode.value=elem.getSource.getName;


            dstNodeID='Destination';
            dstNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Destination');
            dstNode=this.addChildPropertyNode(prtSelectNode,dstNodeID,dstNodeName);
            if(length(elem)>1)
                dstNode.editable=true;
                dstNode.rendermode='combobox';
                dstNode.addOptions(arrayfun(@(conn)conn.getDestination.getName,elem,'UniformOutput',false));
                if isempty(this.selectedConnDest)

                    dstNode.value=elem(1).getDestination.getName;
                else
                    selectedConn=this.getSelectedConnector(elem);
                    dstNode.value=selectedConn.getDestination.getName;
                end
            else
                dstNode.editable=false;
                dstNode.value=elem.getDestination.getName;
            end
        end

        function setupInterfaceNode(this,elem,isView)
            if isView
                elem=elem.getDelegateOccurrencePort.getDesignComponentPort;
            end


            interfaceNodeID='Interface';
            interfaceNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Interface');
            interfaceNode=this.addRootPropertyNode(interfaceNodeID,interfaceNodeName,true);
            interfaceNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:PortInterfaces');


            nameNodeID='Name';
            nameNodeIDandName=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
            nameNode=this.addChildPropertyNode(interfaceNode,nameNodeID,nameNodeIDandName);
            nameNode.value=this.getPortInterfaceNameIfExist(elem);
            nameNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:PortInterfacesOnElem',elem.getName);
            nameNode.rendermode='combobox';
            nameNode.editable=true;
            nameNode.enabled=~(isView||this.isReference||this.isImpl);

            interfaceNames=this.getPortInterfaceNames();
            interfaceNames{end+1}=this.SEPARATOR;
            interfaceNames{end+1}=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');
            interfaceNames{end+1}=DAStudio.message('SystemArchitecture:PropertyInspector:Empty');
            nameNode.addOptions(interfaceNames);

            if(~isempty(this.getPortInterfaceIfExists(elem)))
                if(elem.getPortInterface().isAnonymous())
                    value=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');

                    this.addPropertiesForAnonInterfaceNode(interfaceNode,elem,isView);
                else
                    value=elem.getPortInterfaceName();
                end
            else
                value=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
            end
            nameNode.value=value;


            actionNodeID='Action';
            actionNodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Action');
            actionNode=this.addChildPropertyNode(interfaceNode,actionNodeID,actionNodeName);
            actionNode.value=elem.getPortAction();
            actionNode.enabled=false;
            actionNode.editable=false;
            actionNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:PortAction');
        end

        function setupAddStereotypeNode(this,elem)
            nodeID='Stereotype';
            nodeName=DAStudio.message('SystemArchitecture:PropertyInspector:Stereotype');
            strNode=this.addRootPropertyNode(nodeID,nodeName,false);
            strNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:AddStereoToElem',this.type);
            strNode.value=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
            strNode.editable=true;
            strNode.enabled=~this.isReference&&~this.isVarComp;
            strNode.rendermode='combobox';
            this.populateAddStereotypeNode(elem);
        end

        function setupAppliedStereotypeNodes(this,elem)
            if strcmp(this.type,'Connector')
                elem=this.getSelectedConnector(elem);
            else
                elem=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.getElementForStereotypeAccess(elem);
            end

            if~isempty(elem)
                stereotypes=elem.getPrototype;
            else
                stereotypes={};
            end

            for str=stereotypes
                strLabel=str.getName();
                profileName=str.profile.getName;
                strNodeID=['Stereotype:',profileName,'.',strLabel];
                isMWProfile=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.isMathWorksProfile(profileName);
                if isMWProfile
                    strNode=this.addRootPropertyNode(strNodeID,strLabel,true);
                    node.editable=false;
                    node.rendermode='none';
                else
                    strNode=this.addRootPropertyNode(strNodeID,strLabel,false);
                    strNode.rendermode='actioncallback';
                    strNode.tooltip={DAStudio.message('SystemArchitecture:PropertyInspector:RemoveStereo',str.fullyQualifiedName),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')};




                    strNode.addOptions({this.DEL_STEREOTYPE_ICN,this.RESET_PROPS_TO_DEFAULT_ICN,str.fullyQualifiedName});
                end
                strNode.value='';
                strNode.enabled=~this.isReference;
                this.addStereotypePropertyNodes(strNode,elem,str);
            end
        end

        function addStereotypePropertyNodes(this,parentNode,elem,stereotype)



            hasProps=this.recursivelyAddPropNodesForStereoHierarchy(parentNode,elem,stereotype);

            if~hasProps
                propName=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                propNode=this.addChildPropertyNode(parentNode,propName,propName);
                propNode.enabled=false;
                propNode.value='';
                propNode.tooltip=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                propNode.rendermode='editbox';
            end
        end

        function hasProps=recursivelyAddPropNodesForStereoHierarchy(this,parentNode,elem,stereotype)
            hasProps=false;
            for propDef=stereotype.propertySet.getAllProperties
                hasProps=true;
                propName=propDef.getName;
                propNode=this.addChildPropertyNode(parentNode,propName,propName);
                propNode.enabled=~this.isReference;
                systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.addPropertyNodeTooltip(propNode,elem);
                systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.addPropertyNodeValue(propNode,elem);
                systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.addPropertyNodeRenderMode(propNode,elem);
            end

            if~isempty(stereotype.parent)
                parentStereotype=stereotype.parent;
                parentsHaveProps=this.recursivelyAddPropNodesForStereoHierarchy(parentNode,elem,parentStereotype);
                hasProps=hasProps||parentsHaveProps;
            end
        end

        function addPropertiesForValueTypeInterfaceNode(this,parentNode,prtInterface)

            typeId='AInterfaceType';
            typeLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
            AInterfaceTypeNode=this.addChildPropertyNode(parentNode,typeId,typeLabel);

            [pieType,availableTypes]=systemcomposer.internal.getTypeAndAvailableTypes(prtInterface);
            AInterfaceTypeNode.value=pieType;
            pieType=pieType(~isspace(pieType));
            if(startsWith(pieType,'Bus:'))
                isBusType=true;
            else
                isBusType=false;
            end
            AInterfaceTypeNode.rendermode='combobox';
            AInterfaceTypeNode.editable=true;
            AInterfaceTypeNode.enabled=~(this.isReference||this.isImpl);
            AInterfaceTypeNode.comboEditable=true;
            AInterfaceTypeNode.addOptions(availableTypes);

            dimId='AInterfaceDim';
            dimLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
            AInterfaceDimNode=this.addChildPropertyNode(parentNode,dimId,dimLabel);
            AInterfaceDimNode.value=prtInterface.p_Dimensions;
            AInterfaceDimNode.enabled=~(isBusType||this.isReference||this.isImpl);

            unitId='AInterfaceUnit';
            unitLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
            AInterfaceUnitNode=this.addChildPropertyNode(parentNode,unitId,unitLabel);
            AInterfaceUnitNode.value=prtInterface.p_Units;
            AInterfaceUnitNode.enabled=~(isBusType||this.isReference||this.isImpl);

            complexityId='AInterfaceComplexity';
            complexityLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
            AInterfaceComplexityNode=this.addChildPropertyNode(parentNode,complexityId,complexityLabel);
            AInterfaceComplexityNode.value=prtInterface.p_Complexity;
            AInterfaceComplexityNode.rendermode='combobox';
            AInterfaceComplexityNode.editable=true;
            AInterfaceComplexityNode.comboEditable=false;
            AInterfaceComplexityNode.addOptions(this.INTERFACE_COMPLEXITY);
            AInterfaceComplexityNode.enabled=~(isBusType||this.isReference||this.isImpl);

            minId='AInterfaceMin';
            minLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
            AInterfaceMinNode=this.addChildPropertyNode(parentNode,minId,minLabel);
            AInterfaceMinNode.value=prtInterface.p_Minimum;
            AInterfaceMinNode.enabled=~(isBusType||this.isReference||this.isImpl);

            maxId='AInterfaceMax';
            maxLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
            AInterfaceMaxNode=this.addChildPropertyNode(parentNode,maxId,maxLabel);
            AInterfaceMaxNode.value=prtInterface.p_Maximum;
            AInterfaceMaxNode.enabled=~(isBusType||this.isReference||this.isImpl);

            descId='AInterfaceDescription';
            descLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Description');
            AInterfaceDescNode=this.addChildPropertyNode(parentNode,descId,descLabel);
            AInterfaceDescNode.value=prtInterface.getDescription;
            AInterfaceDescNode.enabled=~(isBusType||this.isReference||this.isImpl);
        end

        function addPropertiesForAnonInterfaceNode(this,parentNode,compPort,isView)
            prtInterface=compPort.getPortInterface();

            typeId='AInterfaceType';
            typeLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
            AInterfaceTypeNode=this.addChildPropertyNode(parentNode,typeId,typeLabel);
            pieType=prtInterface.p_Type;
            AInterfaceTypeNode.value=pieType;
            pieType=pieType(~isspace(pieType));
            if(startsWith(pieType,'Bus:'))
                isBusType=true;
            else
                isBusType=false;
            end
            AInterfaceTypeNode.rendermode='combobox';
            AInterfaceTypeNode.editable=false;
            AInterfaceTypeNode.enabled=~(isView||this.isReference||this.isImpl);
            if this.isImpl
                allowedTypes={};
            else

                buses=this.getPortInterfaceNames();
                if(~isempty(buses))
                    buses=[this.SEPARATOR,cellfun(@(c)['Bus: ',c],buses,'UniformOutput',false)];
                end
                enums=this.getEnumerationsFromLinkedDictionary();
                if(~isempty(enums))
                    enums=[this.SEPARATOR,cellfun(@(c)['Enum: ',c],enums,'UniformOutput',false)];
                end
                allowedTypes=horzcat(this.INTERFACE_TYPES,buses,enums);
            end
            AInterfaceTypeNode.comboEditable=true;
            AInterfaceTypeNode.addOptions(allowedTypes);

            dimId='AInterfaceDim';
            dimLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
            AInterfaceDimNode=this.addChildPropertyNode(parentNode,dimId,dimLabel);
            AInterfaceDimNode.value=prtInterface.p_Dimensions;
            AInterfaceDimNode.enabled=~(isView||isBusType||this.isReference||this.isImpl);

            unitId='AInterfaceUnit';
            unitLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
            AInterfaceUnitNode=this.addChildPropertyNode(parentNode,unitId,unitLabel);
            AInterfaceUnitNode.value=prtInterface.p_Units;
            AInterfaceUnitNode.enabled=~(isView||isBusType||this.isReference||this.isImpl);

            complexityId='AInterfaceComplexity';
            complexityLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
            AInterfaceComplexityNode=this.addChildPropertyNode(parentNode,complexityId,complexityLabel);
            AInterfaceComplexityNode.value=prtInterface.p_Complexity;
            AInterfaceComplexityNode.rendermode='combobox';
            AInterfaceComplexityNode.editable=true;
            AInterfaceComplexityNode.comboEditable=false;
            AInterfaceComplexityNode.addOptions(this.INTERFACE_COMPLEXITY);
            AInterfaceComplexityNode.enabled=~(isView||isBusType||this.isReference||this.isImpl);

            minId='AInterfaceMin';
            minLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
            AInterfaceMinNode=this.addChildPropertyNode(parentNode,minId,minLabel);
            AInterfaceMinNode.value=prtInterface.p_Minimum;
            AInterfaceMinNode.enabled=~(isView||isBusType||this.isReference||this.isImpl);

            maxId='AInterfaceMax';
            maxLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
            AInterfaceMaxNode=this.addChildPropertyNode(parentNode,maxId,maxLabel);
            AInterfaceMaxNode.value=prtInterface.p_Maximum;
            AInterfaceMaxNode.enabled=~(isView||isBusType||this.isReference||this.isImpl);
        end

        function populateAddStereotypeNode(this,elem)
            node=this.PropertySpecMap('Stereotype');
            profileSource=[];
            try
                if isa(elem,'systemcomposer.architecture.model.interface.DataInterface')||...
                    isa(elem,'systemcomposer.architecture.model.interface.CompositePhysicalInterface')||...
                    isa(elem,'systemcomposer.architecture.model.swarch.ServiceInterface')


                    piCatalog=elem.getCatalog;
                    if piCatalog.getStorageContext==systemcomposer.architecture.model.interface.Context.DICTIONARY
                        profileSource=[piCatalog.getStorageSource,'.sldd'];
                    end
                end
                if isempty(profileSource)
                    archOrSlddName=this.getBdFromContext;
                    if ishandle(archOrSlddName)

                        profileSource=get_param(this.getBdFromContext,'Name');
                    end
                end
                assert(~isempty(profileSource),'Unable to determine profile source');
                allValidStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(...
                profileSource,true,['systemcomposer.',this.type]);
                elemPrototypes={};
                mixinPrototypes={};
                for i=1:numel(allValidStereotypes)
                    profName=allValidStereotypes(i).profile.getName;
                    if systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.isMathWorksProfile(profName)


                        continue
                    end
                    if systemcomposer.internal.isPrototypeMixin(allValidStereotypes(i))
                        mixinPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                    else
                        elemPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                    end
                end
                entries=horzcat(elemPrototypes,mixinPrototypes);
            catch

                entries={};
            end
            node.addOptions(entries);
        end

        function interfaceNames=getPortInterfaceNames(this)


            interfaceNames={};
            try
                mf0Model=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider.fetchInterfaceSemanticModelFromBDOrDD(this.getBdFromContext);
                portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
                interfaceNames=portInterfaceCatalog.getPortInterfaceNames();
            catch

            end
        end

        function enumList=getEnumerationsFromLinkedDictionary(this)
            enumList={};
            try
                ddName=get_param(this.getBdFromContext,'DataDictionary');
                if(isempty(ddName))
                    return
                end
                ddConn=Simulink.data.dictionary.open(ddName);
                enumList=systemcomposer.getEnumerationsFromDictionary(ddConn);
                ddConn.close();
            catch

            end
        end

        function conn=getSelectedConnector(this,connectors)
            assert(strcmp(this.type,'Connector'));
            if~isempty(this.selectedConnDest)

                allDest=arrayfun(@(x)x.getDestination.getName,connectors,'UniformOutput',false);
                assert(ismember(this.selectedConnDest,allDest));
                idxSelectedDest=cellfun(@(dest)isequal(this.selectedConnDest,dest),allDest);
                conn=connectors(idxSelectedDest);
            else

                conn=connectors(1);
            end
            assert(length(conn)==1);
        end

        function hdl=getBdFromContext(this)
            if this.isImpl||this.isReference
                hdl=this.contextBdH;
            else
                hdl=this.bdH;
            end
        end

        function setupKindNode(this,~)
            nodeID='Kind';

            nodeName='Kind';
            strNode=this.addRootPropertyNode(nodeID,nodeName,false);
            strNode.tooltip="Kind Property";

            strNode.value='Kind';
            strNode.editable=false;
            strNode.enabled=~this.isReference&&~this.isVarComp;
            strNode.rendermode='combobox';


        end

    end

end



