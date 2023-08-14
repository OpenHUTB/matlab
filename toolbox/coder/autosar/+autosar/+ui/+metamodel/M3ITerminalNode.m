




classdef M3ITerminalNode<handle
    properties
        M3iObject;
        HierarchicalChildren=[];
        Children=[];
        Properties={autosar.ui.metamodel.PackageString.Name};
        Name;
        Icon;
        InListView;
        ParentName;
        Listeners;
        MappingEntityAddedListener;
        MappingEntityUpdatedListenerMap;
        MappingEntityRemovedListenerMap;
    end
    properties(Access=private)
        IsCachedProps=false;
    end
    properties(Constant,Access=private)
        IsAUTOSARLicensed=autosar.api.Utils.autosarlicensed();
    end

    methods
        function obj=M3ITerminalNode(m3iObj,parentName,inListView)
            if nargin<3
                inListView=true;
            end
            obj.M3iObject=m3iObj;
            if m3iObj.has('Name')
                obj.Name=m3iObj.Name;
            end
            obj.InListView=inListView;
            obj.ParentName=parentName;
        end

        function installListener(obj,model)

            modelMapping=autosar.api.Utils.modelMapping(model);

            obj.MappingEntityAddedListener=event.listener(modelMapping,'AutosarMappingEntityAdded',...
            @obj.handleMappingEntityAddedEvent);

            obj.MappingEntityUpdatedListenerMap=containers.Map();
            obj.MappingEntityRemovedListenerMap=containers.Map();

            obj.installMappingListeners(modelMapping);
            if isempty(obj.Listeners)
                modelH=get_param(model,'handle');
                modelObj=get_param(modelH,'Object');

                obj.Listeners=Simulink.listener(modelObj,'PostSaveEvent',...
                @(s,e)SaveAsHandler(s,e,obj));
            end
        end

        function label=getDisplayLabel(obj)
            label=obj.Name;
        end

        function Children=getHierarchicalChildren(obj)
            Children=obj.HierarchicalChildren;
        end

        function Children=getChildren(obj)
            Children=obj.Children;
        end

        function b=isHierarchical(~)
            b=true;
        end

        function fname=getDisplayIcon(obj)
            if~isempty(obj.Icon)
                fname=obj.Icon;
            else
                typeName=obj.M3iObject.getMetaType.name;
                if autosar.ui.metamodel.PackageString.IconMap.isKey(typeName)
                    obj.Icon=autosar.ui.metamodel.PackageString.IconMap(typeName);
                elseif autosar.ui.metamodel.PackageString.IconMap.isKey(obj.ParentName)
                    obj.Icon=autosar.ui.metamodel.PackageString.IconMap(obj.ParentName);
                else
                    obj.Icon=autosar.ui.metamodel.PackageString.IconMap('MatrixValueSpecification');
                end
                fname=obj.Icon;
            end
        end

        function b=isHierarchyReadonly(obj)
            b=~obj.IsAUTOSARLicensed;
        end


        function props=getARExplorerProperties(obj)
            if obj.InListView
                if~obj.IsCachedProps
                    obj.ComputeProperties();
                end
            end
            props=obj.Properties;
        end

        function props=getChildProperties(obj)
            if~obj.IsCachedProps
                obj.ComputeProperties();
            end
            props=obj.Properties;
        end

        function propValue=getPropValue(obj,propName)
            import autosar.ui.metamodel.AttributeUtils

            propValue='';

            if strcmp(propName,autosar.ui.metamodel.PackageString.LongName)



                propName='longName';
            end

            if obj.M3iObject.isvalid()
                if obj.M3iObject.has(propName)
                    propValue=obj.transformPropValue(propName);
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.Unit)
                    if isa(obj.M3iObject,'Simulink.metamodel.arplatform.interface.FlowData')
                        propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.UnitExternalToolInfoName).externalId;
                        if isempty(propValue)
                            propValue='';
                        end
                    else
                        propValue=autosar.ui.metamodel.PackageString.NoUnit;
                    end
                elseif any(strcmp(propName,{autosar.ui.metamodel.PackageString.SwAddrMethod,...
                    autosar.ui.metamodel.PackageString.SectionType}))
                    propValue=DAStudio.message('RTW:autosar:uiUnselectOptions');
                elseif strcmp(propName,DAStudio.message('autosarstandard:ui:uiExportedXmlFile'))
                    [isShared,~]=autosar.dictionary.Utils.isSharedM3IModel(obj.M3iObject.rootModel);
                    if isShared
                        fileNamePrefix=autosar.ui.metamodel.PackageString.DictionaryNameToken;
                    else
                        fileNamePrefix=autosar.ui.metamodel.PackageString.ModelNameToken;
                    end
                    propValue=autosar.mm.arxml.Exporter.getArxmlFileForPackagedElement(obj.M3iObject,fileNamePrefix);
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.DupInterface)



                    propValue=DAStudio.message('RTW:autosar:selectERstr');
                elseif strcmpi(propName,'DataType')
                    propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.DataTypeExternalToolInfoName).externalId;
                    if isempty(propValue)
                        propValue='double';
                    end
                elseif strcmpi(propName,'Dimensions')
                    propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.DimensionsExternalToolInfoName).externalId;
                    if isempty(propValue)
                        propValue='1';
                    end
                elseif strcmpi(propName,'Min')
                    propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.MinExternalToolInfoName).externalId;
                    if isempty(propValue)
                        propValue='[]';
                    end
                elseif strcmpi(propName,'Max')
                    propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.MaxExternalToolInfoName).externalId;
                    if isempty(propValue)
                        propValue='[]';
                    end
                elseif strcmpi(propName,'Description')
                    propValue=obj.M3iObject.getExternalToolInfo(AttributeUtils.DescriptionExternalToolInfoName).externalId;
                    if isempty(propValue)
                        propValue='';
                    end
                end
            end
        end

        function propValue=isValidProperty(~,~)
            propValue=true;
        end


        function readOnly=isReadOnly(obj)
            readOnly=autosar.ui.metamodel.M3INode.isUINodeReadOnly(obj.M3iObject);
        end

        function propValue=isReadonlyProperty(obj,propName)
            propValue=~(obj.isEditableProperty(propName));
        end

        function isEditableProperty=isEditableProperty(obj,propName)
            isEditableProperty=false;

            if obj.isReadOnly()
                return;
            end

            if obj.M3iObject.has(propName)
                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                isEditableProperty=(strcmp(propName,autosar.ui.metamodel.PackageString.NamedProperty)||...
                isa(prop.type,...
                autosar.ui.metamodel.PackageString.M3IImmutableEnumeration)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.M3IBoolean)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.M3IString)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.M3IInteger)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{1})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{2})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{3})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{4})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{5})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{6})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{7})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.InterfacesCell{8})||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.ModeDeclarationClass)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.ModeDeclarationGroupElementClass)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.UnitClass)||...
                strcmp(prop.type.qualifiedName,...
                autosar.ui.metamodel.PackageString.SwAddrMethodClass));
            elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{3})
                isEditableProperty=strcmp(propName,autosar.ui.metamodel.PackageString.ModeGroup);
            elseif any(strcmp(propName,{autosar.ui.metamodel.PackageString.Unit,...
                autosar.ui.metamodel.PackageString.SwAddrMethod,...
                autosar.ui.metamodel.PackageString.SectionType,...
                autosar.ui.metamodel.PackageString.LongName}))
                isEditableProperty=true;
            elseif any(strcmp(propName,{autosar.ui.metamodel.PackageString.majorVersionNode,...
                autosar.ui.metamodel.PackageString.minorVersionNode}))
                isEditableProperty=true;
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.DupInterface)



                isEditableProperty=true;
            end
        end

        function setPropValue(obj,propName,propValue)
            isValid=autosar.ui.metamodel.AttributeUtils.isValidNameValue(obj.M3iObject,propName,propValue);
            if isValid
                if strcmp(propName,autosar.ui.metamodel.PackageString.NamedProperty)
                    obj.Name=propValue;
                end
                if strcmp(propName,autosar.ui.metamodel.PackageString.LongName)



                    propName='longName';
                end
                autosar.ui.metamodel.AttributeUtils.setPropValue(obj.M3iObject,propName,propValue);
            end
        end

        function addChild(obj,ch)







            if~isempty(obj.Children)
                obj.Children(end+1)=ch;
            else
                obj.Children=[obj.Children,ch];
            end
        end

        function addHierarchicalChild(obj,ch)







            if~isempty(obj.HierarchicalChildren)
                obj.HierarchicalChildren(end+1)=ch;
            else
                obj.HierarchicalChildren=[obj.HierarchicalChildren,ch];
            end
        end

        function removeChild(obj,index)
            obj.Children(index).delete;
            obj.Children(index)=[];
        end

        function removeHierarchicalChild(obj,index)
            obj.HierarchicalChildren(index).delete;
            obj.HierarchicalChildren(index)=[];
        end

        function ret=getM3iObject(obj)
            ret=obj.M3iObject;
        end

        function setM3iObject(obj,value)
            obj.M3iObject=value;
            obj.Name=obj.M3iObject.Name;
            obj.Properties=obj.filterPropertyNames(obj.M3iObject);
            obj.IsCachedProps=true;
        end

        function validAttributes=filterPropertyNames(~,m3iObj)
            validAttributes=autosar.ui.metamodel.AttributeUtils.getProperties(m3iObj);
        end

        function propValue=transformPropValue(obj,propName)
            import autosar.ui.codemapping.PortCalibrationAttributeHandler;
            propValue='';
            p=obj.M3iObject.getOne(propName);

            if isa(p,autosar.ui.metamodel.PackageString.M3IValueName)...
                ||isa(p,autosar.ui.metamodel.PackageString.M3IImmutableValueName)
                propValue=p.toString;
            elseif p.has(autosar.ui.metamodel.PackageString.NamedProperty)



                if any(strcmp(p.MetaClass.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell))
                    collectedObjects=autosar.ui.utils.collectObject(obj.M3iObject.modelM3I,...
                    p.MetaClass.qualifiedName);
                    propValue=cell(length(collectedObjects),0);
                    for index=1:length(collectedObjects)
                        propValue(index)={collectedObjects(index).Name};
                    end

                    if length(propValue)~=length(unique(propValue))


                        propValue=autosar.api.Utils.getQualifiedName(p);
                    else

                        propValue=p.getOne(autosar.ui.metamodel.PackageString.NamedProperty).toString;
                    end
                else
                    propValue=p.getOne(autosar.ui.metamodel.PackageString.NamedProperty).toString;
                end
            elseif isa(p,autosar.ui.metamodel.PackageString.LongNameClass)
                propValue=PortCalibrationAttributeHandler.getLongNameValueFromMultiLanguageLongName(p);
            end
        end

        function propValue=getPropDataType(obj,propName)
            propValue='edit';
            if obj.M3iObject.has(propName)
                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                if isa(prop.type,...
                    autosar.ui.metamodel.PackageString.M3IImmutableEnumeration)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.M3IBoolean)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{1})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{2})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{3})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{4})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{5})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{6})
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{7})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{8})
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.ModeDeclarationClass)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.UnitClass)
                    propValue='enum';
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                    propValue='enum';
                elseif strcmp(prop.qualifiedName,...
                    autosar.ui.metamodel.PackageString.MemoryAllocationKeywordPolicyClass)||...
                    strcmp(prop.qualifiedName,...
                    autosar.ui.metamodel.PackageString.SectionTypeClass)


                    propValue='enum';
                end
            elseif any(strcmp(propName,{autosar.ui.metamodel.PackageString.Unit,...
                autosar.ui.metamodel.PackageString.SwAddrMethod,...
                autosar.ui.metamodel.PackageString.MemoryAllocationKeywordPolicy,...
                autosar.ui.metamodel.PackageString.SectionType}))
                propValue='enum';
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.DupInterface)



                propValue='enum';
            elseif strcmp(propName,'DataType')
                propValue='combobox';
            end
        end

        function propAllowedValues=getPropAllowedValues(obj,propName)
            propAllowedValues={};
            if obj.M3iObject.has(propName)
                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                if strcmp(prop.type.qualifiedName,'Simulink.metamodel.arplatform.component.AtomicComponentKind')
                    propAllowedValues=autosar.composition.Utils.getSupportedComponentKinds();
                elseif isa(prop.type,...
                    autosar.ui.metamodel.PackageString.M3IImmutableEnumeration)
                    enums=prop.type.ownedLiteral;
                    for i=1:enums.size
                        propAllowedValues(1,end+1)={enums.at(i).name};%#ok<AGROW>
                    end
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.M3IBoolean)
                    propAllowedValues={autosar.ui.metamodel.PackageString.True,...
                    autosar.ui.metamodel.PackageString.False};
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{1})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{2})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{3})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{4})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{5})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{6})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{7})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{8})||...
                    strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.UnitClass)
                    collectedObjects=autosar.ui.utils.collectObject(obj.M3iObject.modelM3I,...
                    prop.type.qualifiedName);
                    propAllowedValues=cell(length(collectedObjects),0);
                    for index=1:length(collectedObjects)
                        propAllowedValues(index)={collectedObjects(index).Name};
                    end


                    if length(propAllowedValues)~=length(unique(propAllowedValues))
                        for index=1:length(collectedObjects)
                            propAllowedValues(index)=...
                            {autosar.api.Utils.getQualifiedName(collectedObjects(index))};
                        end
                    end
                elseif strcmp(prop.type.qualifiedName,...
                    autosar.ui.metamodel.PackageString.ModeDeclarationClass)
                    for index=1:obj.M3iObject.Mode.size()
                        propAllowedValues(end+1)={obj.M3iObject.Mode.at(index).Name};%#ok<AGROW>
                    end
                elseif strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                    propAllowedValues{1}=autosar.ui.metamodel.PackageString.NoneSelection;
                    swAddrMethodCategory=...
                    autosar.mm.util.SwAddrMethodHelper.getSwAddrMethodCategoryFromM3IObject(obj.M3iObject);
                    propAllowedValues=[propAllowedValues,...
                    autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(...
                    obj.M3iObject.modelM3I,swAddrMethodCategory)];
                elseif strcmp(prop.qualifiedName,...
                    autosar.ui.metamodel.PackageString.MemoryAllocationKeywordPolicyClass)
                    propAllowedValues=autosar.ui.metamodel.PackageString.DefaultMemoryAllocationKeywordPolicy;
                end
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.Unit)
                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                collectedObjects=autosar.ui.utils.collectObject(obj.M3iObject.modelM3I,...
                prop.type.qualifiedName);
                result=arrayfun(@(x)strcmp(x.Name,autosar.ui.metamodel.PackageString.NoUnit),...
                collectedObjects,'uniformoutput',true);
                if any(result)
                    propAllowedValues=cell(numel(collectedObjects),0);
                    for index=1:numel(collectedObjects)
                        propAllowedValues{index}=collectedObjects(index).Name;
                    end
                else
                    propAllowedValues=cell(numel(collectedObjects)+1,0);
                    propAllowedValues{1}=autosar.ui.metamodel.PackageString.NoUnit;
                    for index=1:numel(collectedObjects)
                        propAllowedValues{index+1}=collectedObjects(index).Name;
                    end
                end
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.SwAddrMethod)
                propAllowedValues{1}=autosar.ui.metamodel.PackageString.NoneSelection;
                swAddrMethodCategory=...
                autosar.mm.util.SwAddrMethodHelper.getSwAddrMethodCategoryFromM3IObject(obj.M3iObject);
                propAllowedValues=[propAllowedValues,...
                autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(...
                obj.M3iObject.modelM3I,swAddrMethodCategory)];
            elseif strcmp(propName,...
                autosar.ui.metamodel.PackageString.SectionType)
                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                enums=prop.type.ownedLiteral;
                propAllowedValues=m3i.mapcell(@(x)x.name,enums);
            elseif strcmp(propName,autosar.ui.metamodel.PackageString.DupInterface)




                prop=obj.M3iObject.getMetaClass().getProperty(propName);
                collectedObjects=autosar.ui.utils.collectObject(obj.M3iObject.modelM3I,...
                prop.type.qualifiedName);
                propAllowedValues=cell(length(collectedObjects)+1,0);
                propAllowedValues{1}=DAStudio.message('RTW:autosar:selectERstr');
                for index=1:length(collectedObjects)
                    propAllowedValues{index+1}=collectedObjects(index).Name;
                end
            elseif strcmp(propName,'DataType')

                propAllowedValues={'double','single','int8','uint8','int16','uint16',...
                'int32','uint32','int64','uint64','boolean',...
                'fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};
            end

            if strcmp(propName,'Direction')
                m3iInterface=obj.M3iObject.containerM3I.containerM3I;
                propAllowedValues=...
                autosar.mm.util.ArgumentDirectionHelper.getValidDirectionsFor(m3iInterface);
            end
        end

        function getPropertyStyle(obj,aPropName,propertyStyle)
            if strcmp(aPropName,'Interface')
                m3iInterface=obj.M3iObject.Interface;
                propertyStyle.Tooltip=autosar.api.Utils.getQualifiedName(m3iInterface);
            end
        end

        function out=getContextMenu(~,~)
            out=[];
        end

        function dlgstruct=getDialogSchema(obj,~)
            if~obj.M3iObject.isvalid()
                dlgstruct=[];
                return;
            end

            isComponent=isa(obj.M3iObject,'Simulink.metamodel.arplatform.component.Component');
            isAtomicComponent=isa(obj.M3iObject,'Simulink.metamodel.arplatform.component.AtomicComponent');
            isAdaptiveComponent=isa(obj.M3iObject,autosar.ui.metamodel.PackageString.ComponentsCell{4});

            if isa(obj.M3iObject,...
                autosar.ui.configuration.PackageString.Runnables)
                dlgstruct=autosar.ui.utils.getDlgSchemaForRunnable(obj);
                return;
            elseif isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.DataReceiverPort')||...
                isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.DataSenderPort')||...
                isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')||...
                isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.NvDataReceiverPort')||...
                isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.NvDataSenderPort')||...
                isa(obj.M3iObject,'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort')
                dlgstruct=autosar.ui.comspec.getDlgSchema(obj);
                return;
            elseif isa(obj.getM3iObject,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')||...
                isa(obj.getM3iObject,'Simulink.metamodel.arplatform.port.ServiceRequiredPort')
                dlgstruct=autosar.ui.manifest.getDlgSchema(obj);
                return;
            elseif isa(obj.getM3iObject,'Simulink.metamodel.arplatform.port.PersistencyRequiredPort')||...
                isa(obj.getM3iObject,'Simulink.metamodel.arplatform.port.PersistencyProvidedPort')||...
                isa(obj.getM3iObject,'Simulink.metamodel.arplatform.port.PersistencyProvidedRequiredPort')
                dlgstruct=[];
                return;
            elseif(obj.M3iObject~=obj.M3iObject.modelM3I)&&...
                ~isa(obj.M3iObject,autosar.ui.metamodel.PackageString.ComponentClass)&&...
                ~isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfaceClass)&&...
                ~isa(obj.M3iObject,autosar.ui.configuration.PackageString.Operation)&&...
                ~isa(obj.M3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)&&...
                ~isa(obj.M3iObject,autosar.ui.metamodel.PackageString.SwAddrMethodClass)&&...
                ~isa(obj.M3iObject,autosar.ui.metamodel.PackageString.ValueTypeClass)
                dlgstruct=[];
                return;

            end

            isReadOnly=obj.isReadOnly();
            if isComponent

                if isAdaptiveComponent
                    componentType='Adaptive';
                else
                    componentType=obj.M3iObject.Kind.toString;
                end

                browser.Type='textbrowser';
                browser.Tag='browser';
                browser.Text=['<font size="5"><b>'...
                ,DAStudio.message('RTW:autosar:uiComponentName'),'</b> '...
                ,obj.Name,'<br/><br/><b>'...
                ,DAStudio.message('RTW:autosar:uiComponentType'),'</b> '...
                ,componentType...
                ,'</font>'];
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];
                spacer.Visible=1;

                pkgEditRow=[8,8];

                qNameLabel.Name=DAStudio.message('autosarstandard:ui:uiCompXmlOptions');
                qNameLabel.Type='text';
                qNameLabel.Mode=true;
                qNameLabel.Bold=1;
                qNameLabel.RowSpan=[pkgEditRow,pkgEditRow];
                qNameLabel.ColSpan=[1,15];
                qNameLabel.FontPointSize=6;

                if isAtomicComponent
                    pkgEditRow=pkgEditRow+1;
                    columnOffset=1;
                    internalBehaviorText.Name=DAStudio.message('autosarstandard:ui:uiQualifiedIBLabel');
                    internalBehaviorText.Type='text';
                    internalBehaviorText.Mode=true;
                    internalBehaviorText.RowSpan=[pkgEditRow,pkgEditRow];
                    internalBehaviorText.ColSpan=[1,columnOffset];

                    intBehQName=autosar.mm.util.XmlOptionsAdapter.get(obj.M3iObject,'InternalBehaviorQualifiedName');
                    internalBehaviorEdit.Name=DAStudio.message('autosarstandard:ui:uiQualifiedIBLabel');
                    internalBehaviorEdit.HideName=true;
                    internalBehaviorEdit.Type='edit';
                    internalBehaviorEdit.Mode=true;
                    internalBehaviorEdit.Tag='CompIBQName';
                    internalBehaviorEdit.Value=intBehQName;
                    internalBehaviorEdit.RowSpan=[pkgEditRow,pkgEditRow];
                    internalBehaviorEdit.ColSpan=[columnOffset+1,25];
                    internalBehaviorEdit.MatlabMethod='autosar.ui.utils.applyComponentOptionsChange';
                    internalBehaviorEdit.MatlabArgs={'%dialog',obj.M3iObject};

                    pkgEditRow=pkgEditRow+1;
                    implementationText.Name=DAStudio.message('autosarstandard:ui:uiQualifiedImplLabel');
                    implementationText.Type='text';
                    implementationText.Mode=true;
                    implementationText.RowSpan=[pkgEditRow,pkgEditRow];
                    implementationText.ColSpan=[1,columnOffset];

                    impQName=autosar.mm.util.XmlOptionsAdapter.get(obj.M3iObject,'ImplementationQualifiedName');
                    implementationEdit.Name=DAStudio.message('autosarstandard:ui:uiQualifiedImplLabel');
                    implementationEdit.HideName=true;
                    implementationEdit.Type='edit';
                    implementationEdit.Mode=true;
                    implementationEdit.Tag='CompImpQName';
                    implementationEdit.Value=impQName;
                    implementationEdit.RowSpan=[pkgEditRow,pkgEditRow];
                    implementationEdit.ColSpan=[columnOffset+1,25];
                    implementationEdit.MatlabMethod='autosar.ui.utils.applyComponentOptionsChange';
                    implementationEdit.MatlabArgs={'%dialog',obj.M3iObject};
                end

                arRoot=obj.M3iObject.rootModel.RootPackage.front();
                xmlOptionsInlined=autosar.ui.metamodel.M3ITerminalNode.areXmlOptionsInlined(arRoot);
                pkgEditRow=pkgEditRow+1;
                pkgEditLabel.Type='text';
                pkgEditLabel.Tag='CompPkgLabelTag';
                pkgEditLabel.Name=autosar.ui.metamodel.PackageString.packageLabel;
                pkgEditLabel.RowSpan=[pkgEditRow,pkgEditRow];
                pkgEditLabel.ColSpan=[1,1];
                pkgEditLabel.Visible=xmlOptionsInlined;

                pkgEditText.Type='edit';
                pkgEditText.Tag='CompPkgTextTag';
                pkgEditText.Name='';
                pkgEditText.RowSpan=[pkgEditRow,pkgEditRow];
                pkgEditText.ColSpan=[2,22];
                pkgEditText.Value=fileparts(autosar.api.Utils.getQualifiedName(obj.M3iObject));
                pkgEditText.Visible=xmlOptionsInlined;
                pkgEditText.MatlabMethod='autosar.ui.utils.applyComponentOptionsChange';
                pkgEditText.MatlabArgs={'%dialog',obj.M3iObject};

                pkgEditButton.Type='pushbutton';
                pkgEditButton.Tag='compPkgEditButtonTag';
                pkgEditButton.Name=autosar.ui.metamodel.PackageString.browseLabel;
                pkgEditButton.RowSpan=[pkgEditRow,pkgEditRow];
                pkgEditButton.ColSpan=[24,25];
                pkgEditButton.MatlabMethod='autosar.ui.utils.editPackage';
                pkgEditButton.MatlabArgs={obj.M3iObject,'%dialog',pkgEditText.Tag};
                pkgEditButton.Visible=xmlOptionsInlined;

                rowIdx=1;
                componentElemTipText.Type='text';
                componentElemTipText.Tag='componentElemTipText';
                componentElemTipText.Name=DAStudio.message('autosarstandard:ui:uiConfigureCompElementsTip',obj.M3iObject.Name);
                componentElemTipText.RowSpan=[rowIdx,rowIdx];
                componentElemTipText.ColSpan=[1,2];

                grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                grpControl.Type='group';
                grpControl.LayoutGrid=[3,25];
                grpControl.RowSpan=[4,6];
                grpControl.ColSpan=[1,25];
                grpControl.RowStretch=[0,0,1];
                grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                grpControl.Items={componentElemTipText};

                dlgstruct.HelpMethod='helpview';
                if isAdaptiveComponent
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_application_node'};
                else
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props'};
                end

                dlgstruct.DialogTag='autosar_component_dialog';
            elseif isa(obj.M3iObject,'Simulink.metamodel.arplatform.component.ParameterComponent')

                componentType='Parameter';
                browser.Type='textbrowser';
                browser.Tag='browser';
                browser.Text=['<font size="5"><b>'...
                ,DAStudio.message('RTW:autosar:uiComponentName'),'</b> '...
                ,obj.Name,'<br/><br/><b>'...
                ,DAStudio.message('RTW:autosar:uiComponentType'),'</b> '...
                ,componentType...
                ,'</font>'];
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];
                spacer.Visible=1;

                rowIdx=1;
                senderPortsTipText.Type='text';
                senderPortsTipLink.Tag='senderPortsTipLink';
                senderPortsTipText.Name=DAStudio.message('RTW:autosar:uiPportsTip');
                senderPortsTipText.RowSpan=[rowIdx,rowIdx];
                senderPortsTipText.ColSpan=[1,2];

                senderPortsTipLink.Type='hyperlink';
                senderPortsTipLink.Tag='senderPortsTipLink';
                senderPortsTipLink.Name=autosar.ui.metamodel.PackageString.senderPortsNode;
                senderPortsTipLink.RowSpan=[rowIdx,rowIdx];
                senderPortsTipLink.ColSpan=[3,7];
                senderPortsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                senderPortsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.senderPortsNode};

                grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                grpControl.Type='group';
                grpControl.LayoutGrid=[3,25];
                grpControl.RowSpan=[4,6];
                grpControl.ColSpan=[1,25];
                grpControl.RowStretch=[0,0,1];
                grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                grpControl.Items={senderPortsTipText,senderPortsTipLink};

                dlgstruct.HelpMethod='helpview';
                dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props'};

                dlgstruct.DialogTag='autosar_parameter_component_dialog';
            elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfaceClass)
                if obj.M3iObject.has('IsService')&&obj.M3iObject.IsService
                    isservice=autosar.ui.metamodel.PackageString.True;
                else
                    isservice=autosar.ui.metamodel.PackageString.False;
                end

                browser.Type='textbrowser';
                browser.Tag='browser';
                if isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{3})
                    modeGroupName='';
                    if~isempty(obj.M3iObject.ModeGroup)
                        modeGroupName=obj.M3iObject.ModeGroup.Name;
                    end
                    browser.Text=['<font size="5"><b>'...
                    ,DAStudio.message('RTW:autosar:uiInterfaceName'),'</b> '...
                    ,obj.Name,'<br/><br/><b>'...
                    ,DAStudio.message('RTW:autosar:uiIsService'),'</b> '...
                    ,isservice,'<br/><br/><b>'...
                    ,autosar.ui.metamodel.PackageString.ModeGroup,': </b> '...
                    ,modeGroupName,'<br/><br/><b>'...
                    ,'</font>'];
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{7})...
                    ||isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{8})


                    browser.Text=['<font size="5"><b>'...
                    ,DAStudio.message('RTW:autosar:uiInterfaceName'),'</b> '...
                    ,obj.Name,'<br/><br/>'...
                    ,'</font>'];
                else
                    browser.Text=['<font size="5"><b>'...
                    ,DAStudio.message('RTW:autosar:uiInterfaceName'),'</b> '...
                    ,obj.Name,'<br/><br/><b>'...
                    ,DAStudio.message('RTW:autosar:uiIsService'),'</b> '...
                    ,isservice...
                    ,'</font>'];
                end
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];

                arRoot=obj.M3iObject.rootModel.RootPackage.front();
                xmlOptionsInlined=autosar.ui.metamodel.M3ITerminalNode.areXmlOptionsInlined(arRoot);

                [interfacePackage,~,~]=fileparts(autosar.api.Utils.getQualifiedName(obj.M3iObject));
                packageEditText.Type='text';
                packageEditText.Tag='packageEditText';
                packageEditText.Name=autosar.ui.metamodel.PackageString.packageLabel;
                packageEditText.RowSpan=[7,7];
                packageEditText.ColSpan=[1,1];
                packageEditText.Visible=xmlOptionsInlined;

                packageEdit.Type='edit';
                packageEdit.Tag='packageEdit';
                packageEdit.Name='';
                packageEdit.RowSpan=[7,7];
                packageEdit.ColSpan=[2,22];
                packageEdit.Value=interfacePackage;
                packageEdit.Enabled=~isReadOnly;
                packageEdit.Visible=xmlOptionsInlined;
                packageEdit.MatlabMethod='autosar.ui.utils.applyPackageChange';
                packageEdit.MatlabArgs={obj.M3iObject,'%dialog',packageEdit.Tag};

                packageEditButton.Type='pushbutton';
                packageEditButton.Tag='packageEditButton';
                packageEditButton.Name=autosar.ui.metamodel.PackageString.browseLabel;
                packageEditButton.RowSpan=[7,7];
                packageEditButton.ColSpan=[24,25];
                packageEditButton.MatlabMethod='autosar.ui.utils.editPackage';
                packageEditButton.MatlabArgs={obj.M3iObject,'%dialog',packageEdit.Tag};
                packageEditButton.Enabled=~isReadOnly&&xmlOptionsInlined;
                packageEditButton.Visible=xmlOptionsInlined;

                if isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{7})

                    rowIdx=1;

                    msgItemEvents.Type='text';
                    msgItemEvents.Tag='msgItemEventsText';
                    msgItemEvents.Name=DAStudio.message('autosarstandard:ui:uiEventsTip');
                    msgItemEvents.RowSpan=[rowIdx,rowIdx];
                    msgItemEvents.ColSpan=[1,1];

                    msgLinkEvents.Type='hyperlink';
                    msgLinkEvents.Tag='msgItemEventsLink';
                    msgLinkEvents.Name=autosar.ui.metamodel.PackageString.eventsNodeName;
                    msgLinkEvents.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgLinkEvents.MatlabArgs={obj,autosar.ui.metamodel.PackageString.eventsNodeName};
                    msgLinkEvents.RowSpan=[rowIdx,rowIdx];
                    msgLinkEvents.ColSpan=[2,7];
                    rowIdx=rowIdx+1;

                    msgItemMethods.Type='text';
                    msgItemMethods.Type='text';
                    msgItemMethods.Tag='msgItemMethodsText';
                    msgItemMethods.Name=DAStudio.message('autosarstandard:ui:uiMethodsTip');
                    msgItemMethods.RowSpan=[rowIdx,rowIdx];
                    msgItemMethods.ColSpan=[1,1];

                    msgLinkMethods.Type='hyperlink';
                    msgLinkMethods.Tag='msgItemMethodsLink';
                    msgLinkMethods.Name=autosar.ui.metamodel.PackageString.methodsNodeName;
                    msgLinkMethods.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgLinkMethods.MatlabArgs={obj,autosar.ui.metamodel.PackageString.methodsNodeName};
                    msgLinkMethods.RowSpan=[rowIdx,rowIdx];
                    msgLinkMethods.ColSpan=[2,7];
                    rowIdx=rowIdx+1;

                    msgItemNameSpaces.Type='text';
                    msgItemNameSpaces.Tag='msgItemNamespacesText';
                    msgItemNameSpaces.Name=DAStudio.message('autosarstandard:ui:uiNamespacesTip');
                    msgItemNameSpaces.RowSpan=[rowIdx,rowIdx];
                    msgItemNameSpaces.ColSpan=[1,1];

                    msgLinkNameSpaces.Type='hyperlink';
                    msgLinkNameSpaces.Tag='msgItemNamespacesLink';
                    msgLinkNameSpaces.Name=autosar.ui.metamodel.PackageString.namespacesNodeName;
                    msgLinkNameSpaces.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgLinkNameSpaces.MatlabArgs={obj,autosar.ui.metamodel.PackageString.namespacesNodeName};
                    msgLinkNameSpaces.RowSpan=[rowIdx,rowIdx];
                    msgLinkNameSpaces.ColSpan=[2,7];

                    grpControl.Type='group';
                    grpControl.LayoutGrid=[3,25];
                    grpControl.RowSpan=[3,5];
                    grpControl.ColSpan=[1,25];
                    grpControl.RowStretch=[0,0,1];
                    grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                    grpControl.Items={msgItemEvents,msgLinkEvents,...
                    msgItemMethods,msgLinkMethods,...
                    msgItemNameSpaces,msgLinkNameSpaces};
                end

                dlgstruct.HelpMethod='helpview';
                if isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{3})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_msinterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{2})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_csinterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{6})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_nvinterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{5})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_paraminterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{4})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_trinterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{7})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterface'};
                elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfacesCell{8})
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
                else
                    dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_srinterface'};
                end

                dlgstruct.DialogTag='autosar_interface_dialog';

            elseif isa(obj.M3iObject,autosar.ui.configuration.PackageString.Operation)

                browser.Type='textbrowser';
                browser.Tag='browser';
                browser.Text=['<font size="5"><b>'...
                ,DAStudio.message('RTW:autosar:uiOperationName'),'</b> '...
                ,obj.Name,'<br/><br/><b>'...
                ,'</font>'];
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];
                spacer.Visible=1;

                argumentsTipText.Type='text';
                argumentsTipText.Tag='argumentsTipText';
                argumentsTipText.Name=DAStudio.message('RTW:autosar:uiArgumentsTip');
                argumentsTipText.RowSpan=[3,3];
                argumentsTipText.ColSpan=[1,2];

                argumentsTipLink.Type='hyperlink';
                argumentsTipLink.Tag='argumentsTipLink';
                argumentsTipLink.Name=autosar.ui.metamodel.PackageString.argumentsNode;
                argumentsTipLink.RowSpan=[3,3];
                argumentsTipLink.ColSpan=[3,7];
                argumentsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                argumentsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.argumentsNode};

                grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                grpControl.Type='group';
                grpControl.LayoutGrid=[3,25];
                grpControl.RowSpan=[4,6];
                grpControl.ColSpan=[1,25];
                grpControl.RowStretch=[0,0,1];
                grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                grpControl.Items={argumentsTipText,argumentsTipLink};


                dlgstruct.HelpMethod='helpview';
                isMethodInAdaptiveServiceInterface=...
                isa(obj.M3iObject.containerM3I,autosar.ui.metamodel.PackageString.InterfacesCell{7});
                if isMethodInAdaptiveServiceInterface
                    help_link_extension='autosar_config_props_serviceinterface_method';
                else
                    help_link_extension='autosar_config_props_csinterface_op';
                end
                dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),help_link_extension};

                dlgstruct.DialogTag='autosar_operation_dialog';
            elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)||...
                isa(obj.M3iObject,autosar.ui.metamodel.PackageString.ValueTypeClass)||...
                isa(obj.M3iObject,autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                isSwAddrMethod=isa(obj.M3iObject,autosar.ui.metamodel.PackageString.SwAddrMethodClass);
                [packagePath,~,~]=fileparts(autosar.api.Utils.getQualifiedName(obj.M3iObject));

                packageEditText.Type='text';
                packageEditText.Tag='packageEditText';
                packageEditText.Name=autosar.ui.metamodel.PackageString.packageLabel;
                packageEditText.RowSpan=[7,7];
                packageEditText.ColSpan=[1,2];

                packageEdit.Type='edit';
                packageEdit.Tag='packageEdit';
                packageEdit.RowSpan=[7,7];
                packageEdit.ColSpan=[3,22];
                packageEdit.Value=packagePath;
                packageEdit.Enabled=false;
                packageEdit.MatlabMethod='autosar.ui.utils.applyPackageChange';
                packageEdit.MatlabArgs={obj.M3iObject,'%dialog',packageEdit.Tag};

                if~isReadOnly
                    packageEdit.Enabled=true;

                    packageEditButton.Type='pushbutton';
                    packageEditButton.Tag='packageEditButton';
                    packageEditButton.Name=autosar.ui.metamodel.PackageString.browseLabel;
                    packageEditButton.RowSpan=[7,7];
                    packageEditButton.ColSpan=[24,25];
                    packageEditButton.MatlabMethod='autosar.ui.utils.editPackage';
                    packageEditButton.MatlabArgs={obj.M3iObject,'%dialog',packageEdit.Tag};
                end
                if~isSwAddrMethod
                    slTypeLabel.Type='text';
                    slTypeLabel.Name=[autosar.ui.metamodel.PackageString.SLTypes,':'];
                    slTypeLabel.Tag='slTypeLabel';
                    slTypeLabel.RowSpan=[8,8];
                    slTypeLabel.ColSpan=[1,2];


                    toolId=autosar.ui.metamodel.PackageString.SlDataTypesToolID;
                    externalId=obj.M3iObject.getExternalToolInfo(toolId).externalId;

                    slDataTypeList.Type='listbox';
                    slDataTypeList.Tag='slDataTypeList';
                    slDataTypeList.Graphical=true;
                    if~isempty(externalId)
                        slDataTypeList.Entries=regexp(externalId,'#','split');
                    else
                        slDataTypeList.Entries={};
                    end
                    slDataTypeList.Enabled=true;
                    slDataTypeList.RowSpan=[8,10];
                    slDataTypeList.ColSpan=[3,22];

                    setDataTypeBtn.Type='pushbutton';
                    setDataTypeBtn.Tag='setDataTypeBtn';
                    setDataTypeBtn.Name=DAStudio.message('autosarstandard:ui:uiCommonAdd','');
                    if isa(obj.M3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)
                        setDataTypeBtn.Enabled=obj.M3iObject.Category~=Simulink.metamodel.types.CompuMethodCategory.RatFunc;
                    end
                    setDataTypeBtn.RowSpan=[8,8];
                    setDataTypeBtn.ColSpan=[24,25];
                    setDataTypeBtn.MatlabMethod='autosar.ui.utils.assignSimulinkDataTypeDlg';
                    setDataTypeBtn.MatlabArgs={obj.M3iObject,'%dialog'};

                    unsetDataTypeBtn.Type='pushbutton';
                    unsetDataTypeBtn.Tag='unsetDataTypeBtn';
                    unsetDataTypeBtn.Name=DAStudio.message('autosarstandard:ui:uiCommonRemove','');
                    unsetDataTypeBtn.Enabled=numel(slDataTypeList.Entries)>0;
                    unsetDataTypeBtn.RowSpan=[9,9];
                    unsetDataTypeBtn.ColSpan=[24,25];
                    unsetDataTypeBtn.MatlabMethod='autosar.ui.utils.unAssignSimulinkDataType';
                    unsetDataTypeBtn.MatlabArgs={obj.M3iObject,'%dialog'};
                end

                dlgstruct.DialogTag='autosar_package_dialog';
            else

                browser.Type='textbrowser';
                browser.Tag='browser';
                browser.Text=['<font size="5"><b>'...
                ,DAStudio.message('RTW:autosar:uiARRootHelp')...
                ,'</b></font>'];
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];
                spacer.Visible=1;



                isShowingDictForCompositionModel=strcmp(obj.HierarchicalChildren(1).Name,...
                autosar.ui.metamodel.PackageString.Preferences);


                isRefSharedDict=autosar.dictionary.Utils.hasReferencedModels(obj.M3iObject.modelM3I);

                if strcmp(obj.HierarchicalChildren(1).Name,autosar.ui.metamodel.PackageString.AtomicComponentsNodeName)||...
isRefSharedDict

                    componentsTipText.Type='text';
                    componentsTipText.Tag='componentsTipText';
                    componentsTipText.Name=DAStudio.message('RTW:autosar:uiComponentsTip');
                    componentsTipText.RowSpan=[1,1];
                    componentsTipText.ColSpan=[1,1];

                    componentsTipLink.Type='hyperlink';
                    componentsTipLink.Tag='componentsTipLink';
                    componentsTipLink.Name=autosar.ui.metamodel.PackageString.AtomicComponentsNodeName;
                    componentsTipLink.RowSpan=[1,1];
                    componentsTipLink.ColSpan=[2,7];
                    componentsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    componentsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.AtomicComponentsNodeName};

                    srInterfacesTipText.Type='text';
                    srInterfacesTipText.Tag='srInterfacesTipText';
                    srInterfacesTipText.Name=DAStudio.message('RTW:autosar:uiInterfacesTip');
                    srInterfacesTipText.RowSpan=[2,2];
                    srInterfacesTipText.ColSpan=[1,1];

                    srInterfacesTipLink.Type='hyperlink';
                    srInterfacesTipLink.Tag='srInterfacesTipLink';
                    srInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.InterfacesNodeName;
                    srInterfacesTipLink.RowSpan=[2,2];
                    srInterfacesTipLink.ColSpan=[2,7];
                    srInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    srInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.InterfacesNodeName};

                    msInterfacesTipText.Type='text';
                    msInterfacesTipText.Tag='msInterfacesTipText';
                    msInterfacesTipText.Name=DAStudio.message('RTW:autosar:uiMSInterfacesTip');
                    msInterfacesTipText.RowSpan=[3,3];
                    msInterfacesTipText.ColSpan=[1,1];

                    msInterfacesTipLink.Type='hyperlink';
                    msInterfacesTipLink.Tag='msInterfacesTipLink';
                    msInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName;
                    msInterfacesTipLink.RowSpan=[3,3];
                    msInterfacesTipLink.ColSpan=[2,7];
                    msInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName};

                    csInterfacesTipText.Type='text';
                    csInterfacesTipText.Tag='csInterfacesTipText';
                    csInterfacesTipText.Name=DAStudio.message('RTW:autosar:uiCSInterfacesTip');
                    csInterfacesTipText.RowSpan=[4,4];
                    csInterfacesTipText.ColSpan=[1,1];

                    csInterfacesTipLink.Type='hyperlink';
                    csInterfacesTipLink.Tag='csInterfacesTipLink';
                    csInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName;
                    csInterfacesTipLink.RowSpan=[4,4];
                    csInterfacesTipLink.ColSpan=[2,7];
                    csInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    csInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName};

                    rowIdx=5;
                    nvInterfacesTipText.Type='text';
                    nvInterfacesTipText.Tag='nvInterfacesTipText';
                    nvInterfacesTipText.Name=DAStudio.message('autosarstandard:ui:uiNVInterfacesTip');
                    nvInterfacesTipText.RowSpan=[rowIdx,rowIdx];
                    nvInterfacesTipText.ColSpan=[1,1];

                    nvInterfacesTipLink.Type='hyperlink';
                    nvInterfacesTipLink.Tag='nvInterfacesTipLink';
                    nvInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName;
                    nvInterfacesTipLink.RowSpan=[rowIdx,rowIdx];
                    nvInterfacesTipLink.ColSpan=[2,7];
                    nvInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    nvInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName};

                    rowIdx=rowIdx+1;

                    paramInterfacesTipText.Type='text';
                    paramInterfacesTipText.Tag='paramInterfacesTipText';
                    paramInterfacesTipText.Name=DAStudio.message('autosarstandard:ui:uiParamInterfacesTip');
                    paramInterfacesTipText.RowSpan=[rowIdx,rowIdx];
                    paramInterfacesTipText.ColSpan=[1,1];

                    paramInterfacesTipLink.Type='hyperlink';
                    paramInterfacesTipLink.Tag='paramInterfacesTipLink';
                    paramInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName;
                    paramInterfacesTipLink.RowSpan=[rowIdx,rowIdx];
                    paramInterfacesTipLink.ColSpan=[2,7];
                    paramInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    paramInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName};

                    rowIdx=rowIdx+1;

                    triggerInterfacesTipText.Type='text';
                    triggerInterfacesTipText.Tag='triggerInterfacesTipText';
                    triggerInterfacesTipText.Name=DAStudio.message('autosarstandard:ui:uiTriggerInterfacesTip');
                    triggerInterfacesTipText.RowSpan=[rowIdx,rowIdx];
                    triggerInterfacesTipText.ColSpan=[1,1];

                    triggerInterfacesTipLink.Type='hyperlink';
                    triggerInterfacesTipLink.Tag='triggerInterfacesTipLink';
                    triggerInterfacesTipLink.Name=autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName;
                    triggerInterfacesTipLink.RowSpan=[rowIdx,rowIdx];
                    triggerInterfacesTipLink.ColSpan=[2,7];
                    triggerInterfacesTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    triggerInterfacesTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName};

                    rowIdx=rowIdx+1;

                    compuMethodsTipText.Type='text';
                    compuMethodsTipText.Tag='compuMethodsTipText';
                    compuMethodsTipText.Name=DAStudio.message('RTW:autosar:uiConfigureGoToTip',...
                    autosar.ui.metamodel.PackageString.CompuMethods);
                    compuMethodsTipText.RowSpan=[rowIdx,rowIdx];
                    compuMethodsTipText.ColSpan=[1,1];

                    compuMethodsTipLink.Type='hyperlink';
                    compuMethodsTipLink.Tag='compuMethodsTipLink';
                    compuMethodsTipLink.Name=autosar.ui.metamodel.PackageString.CompuMethods;
                    compuMethodsTipLink.RowSpan=[rowIdx,rowIdx];
                    compuMethodsTipLink.ColSpan=[2,7];
                    compuMethodsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    compuMethodsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.CompuMethods};
                    rowIdx=rowIdx+1;

                    swAddrMethodTipText.Type='text';
                    swAddrMethodTipText.Tag='swAddrMethodTipText';
                    swAddrMethodTipText.Name=DAStudio.message('RTW:autosar:uiConfigureGoToTip',...
                    autosar.ui.metamodel.PackageString.SwAddrMethods);
                    swAddrMethodTipText.RowSpan=[rowIdx,rowIdx];
                    swAddrMethodTipText.ColSpan=[1,1];

                    swAddrMethodTipLink.Type='hyperlink';
                    swAddrMethodTipLink.Tag='swAddrMethodTipLink';
                    swAddrMethodTipLink.Name=autosar.ui.metamodel.PackageString.SwAddrMethods;
                    swAddrMethodTipLink.RowSpan=[rowIdx,rowIdx];
                    swAddrMethodTipLink.ColSpan=[2,7];
                    swAddrMethodTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    swAddrMethodTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.SwAddrMethods};
                    rowIdx=rowIdx+1;

                    xmlOptionsTipText.Type='text';
                    xmlOptionsTipText.Tag='xmlOptionsTipText';
                    xmlOptionsTipText.Name=DAStudio.message('RTW:autosar:uiXMLOptionsTip');
                    xmlOptionsTipText.RowSpan=[rowIdx,rowIdx];
                    xmlOptionsTipText.ColSpan=[1,1];

                    xmlOptionsTipLink.Type='hyperlink';
                    xmlOptionsTipLink.Tag='xmlOptionsTipLink';
                    xmlOptionsTipLink.Name=autosar.ui.metamodel.PackageString.Preferences;
                    xmlOptionsTipLink.RowSpan=[rowIdx,rowIdx];
                    xmlOptionsTipLink.ColSpan=[2,7];
                    xmlOptionsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    xmlOptionsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.Preferences};
                    rowIdx=rowIdx+1;

                    grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                    grpControl.Tag='tipsGroup';
                    grpControl.Type='group';
                    grpControl.LayoutGrid=[3,25];
                    grpControl.RowSpan=[rowIdx,rowIdx+1];
                    grpControl.ColSpan=[1,25];
                    grpControl.RowStretch=[0,0,1];
                    grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    grpControl.Items={componentsTipText,componentsTipLink,srInterfacesTipText,...
                    srInterfacesTipLink,msInterfacesTipText,msInterfacesTipLink,csInterfacesTipText,csInterfacesTipLink,...
                    nvInterfacesTipText,nvInterfacesTipLink,paramInterfacesTipText,paramInterfacesTipLink,triggerInterfacesTipText,...
                    triggerInterfacesTipLink,compuMethodsTipText,compuMethodsTipLink,...
                    swAddrMethodTipText,swAddrMethodTipLink,xmlOptionsTipText,xmlOptionsTipLink};
                    grpControl.Visible=~isRefSharedDict;
                    rowIdx=rowIdx+1;
                    rowIdx=rowIdx+1;%#ok<NASGU>

                    helpViewID='autosar_config_props_component';
                elseif isShowingDictForCompositionModel
                    rowIdx=1;

                    xmlOptionsTipText.Type='text';
                    xmlOptionsTipText.Tag='xmlOptionsTipText';
                    xmlOptionsTipText.Name=DAStudio.message('RTW:autosar:uiXMLOptionsTip');
                    xmlOptionsTipText.RowSpan=[rowIdx,rowIdx];
                    xmlOptionsTipText.ColSpan=[1,1];

                    xmlOptionsTipLink.Type='hyperlink';
                    xmlOptionsTipLink.Tag='xmlOptionsTipLink';
                    xmlOptionsTipLink.Name=autosar.ui.metamodel.PackageString.Preferences;
                    xmlOptionsTipLink.RowSpan=[rowIdx,rowIdx];
                    xmlOptionsTipLink.ColSpan=[2,7];
                    xmlOptionsTipLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    xmlOptionsTipLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.Preferences};
                    rowIdx=rowIdx+1;

                    grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                    grpControl.Type='group';
                    grpControl.LayoutGrid=[3,25];
                    grpControl.RowSpan=[rowIdx,rowIdx+1];
                    grpControl.ColSpan=[1,25];
                    grpControl.RowStretch=[0,0,1];
                    grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    grpControl.Items={xmlOptionsTipText,xmlOptionsTipLink};
                    rowIdx=rowIdx+1;
                    rowIdx=rowIdx+1;%#ok<NASGU>

                    helpViewID='autosar_config_props';
                elseif strcmp(obj.HierarchicalChildren(1).Name,...
                    autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName)
                    rowIdx=1;

                    msgAdaptiveAppText.Type='text';
                    msgAdaptiveAppText.Tag='msgAdaptiveAppText';
                    msgAdaptiveAppText.Name=DAStudio.message('autosarstandard:ui:uiAdaptiveApplicationsTip');
                    msgAdaptiveAppText.RowSpan=[rowIdx,rowIdx];
                    msgAdaptiveAppText.ColSpan=[1,1];

                    msgAdaptiveAppLink.Type='hyperlink';
                    msgAdaptiveAppLink.Tag='msgAdaptiveCompLink';
                    msgAdaptiveAppLink.Name=autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName;
                    msgAdaptiveAppLink.RowSpan=[rowIdx,rowIdx];
                    msgAdaptiveAppLink.ColSpan=[2,7];
                    msgAdaptiveAppLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgAdaptiveAppLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName};
                    rowIdx=rowIdx+1;

                    msgServiceInterfacesText.Type='text';
                    msgServiceInterfacesText.Tag='msgServiceInterfacesText';
                    msgServiceInterfacesText.Name=DAStudio.message('autosarstandard:ui:uiServiceInterfacesTip');
                    msgServiceInterfacesText.RowSpan=[rowIdx,rowIdx];
                    msgServiceInterfacesText.ColSpan=[1,1];

                    msgServiceInterfacesLink.Type='hyperlink';
                    msgServiceInterfacesLink.Tag='msgServiceInterfacesLink';
                    msgServiceInterfacesLink.Name=autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName;
                    msgServiceInterfacesLink.RowSpan=[rowIdx,rowIdx];
                    msgServiceInterfacesLink.ColSpan=[2,7];
                    msgServiceInterfacesLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgServiceInterfacesLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName};
                    rowIdx=rowIdx+1;

                    msgPersistencyKeyValueInterfacesText.Type='text';
                    msgPersistencyKeyValueInterfacesText.Tag='msgPersistencyKeyValueInterfacesText';
                    msgPersistencyKeyValueInterfacesText.Name=DAStudio.message('autosarstandard:ui:uiPersistencyKeyValueInterfacesTip');
                    msgPersistencyKeyValueInterfacesText.RowSpan=[rowIdx,rowIdx];
                    msgPersistencyKeyValueInterfacesText.ColSpan=[1,1];

                    msgPersistencyKeyValueInterfacesLink.Type='hyperlink';
                    msgPersistencyKeyValueInterfacesLink.Tag='msgPersistencyKeyValueInterfacesLink';
                    msgPersistencyKeyValueInterfacesLink.Name=autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName;
                    msgPersistencyKeyValueInterfacesLink.RowSpan=[rowIdx,rowIdx];
                    msgPersistencyKeyValueInterfacesLink.ColSpan=[2,7];
                    msgPersistencyKeyValueInterfacesLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgPersistencyKeyValueInterfacesLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName};
                    rowIdx=rowIdx+1;

                    msgPreferencesText.Type='text';
                    msgPreferencesText.Tag='msgPreferencesText';
                    msgPreferencesText.Name=DAStudio.message('RTW:autosar:uiXMLOptionsTip');
                    msgPreferencesText.RowSpan=[rowIdx,rowIdx];
                    msgPreferencesText.ColSpan=[1,1];

                    msgPreferencesLink.Type='hyperlink';
                    msgPreferencesLink.Tag='msgPreferencesLink';
                    msgPreferencesLink.Name=autosar.ui.metamodel.PackageString.Preferences;
                    msgPreferencesLink.RowSpan=[rowIdx,rowIdx];
                    msgPreferencesLink.ColSpan=[2,7];
                    msgPreferencesLink.MatlabMethod='autosar.ui.utils.selectTargetTreeElement';
                    msgPreferencesLink.MatlabArgs={obj,autosar.ui.metamodel.PackageString.Preferences};
                    rowIdx=rowIdx+1;

                    grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                    grpControl.Type='group';
                    grpControl.LayoutGrid=[3,25];
                    grpControl.RowSpan=[rowIdx,rowIdx+1];
                    grpControl.ColSpan=[1,25];
                    grpControl.RowStretch=[0,0,1];
                    grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    grpControl.Items={msgAdaptiveAppText,msgAdaptiveAppLink,...
                    msgServiceInterfacesText,msgServiceInterfacesLink,...
                    msgPreferencesText,msgPreferencesLink};
                    grpControl.Items={msgAdaptiveAppText,msgAdaptiveAppLink,...
                    msgServiceInterfacesText,msgServiceInterfacesLink,...
                    msgPersistencyKeyValueInterfacesText,msgPersistencyKeyValueInterfacesLink,...
                    msgPreferencesLink};

                    helpViewID='autosar_config_props_component_adaptive';
                end

                dlgstruct.HelpMethod='helpview';
                dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),helpViewID};

                dlgstruct.DialogTag='autosar_root_dictionary_dialog';
            end


            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={'Help'};
            dlgstruct.ExplicitShow=true;
            dlgstruct.DialogTitle='';
            if isa(obj.M3iObject,autosar.ui.metamodel.PackageString.CompuMethodClass)||...
                isa(obj.M3iObject,autosar.ui.metamodel.PackageString.ValueTypeClass)||...
                isa(obj.M3iObject,autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                if isReadOnly
                    if isSwAddrMethod
                        dlgstruct.Items={packageEditText,packageEdit};
                    else
                        dlgstruct.Items={packageEditText,packageEdit,slTypeLabel,slDataTypeList,setDataTypeBtn,unsetDataTypeBtn};
                    end
                else
                    if isSwAddrMethod
                        dlgstruct.Items={packageEditText,packageEdit,packageEditButton};
                    else
                        dlgstruct.Items={packageEditText,packageEdit,packageEditButton,slTypeLabel,slDataTypeList,setDataTypeBtn,unsetDataTypeBtn};
                    end
                end
                dlgstruct.EmbeddedButtonSet={''};
            else
                if exist('grpControl','var')
                    dlgstruct.Items={browser,spacer,grpControl};
                else
                    dlgstruct.Items={browser,spacer};
                end
            end

            if isComponent
                if isAtomicComponent


                    dlgstruct.Items=[dlgstruct.Items,...
                    {qNameLabel,...
                    internalBehaviorText,internalBehaviorEdit,...
                    implementationText,implementationEdit,...
                    pkgEditLabel,pkgEditText,pkgEditButton}];
                else


                    dlgstruct.Items=[dlgstruct.Items,...
                    {qNameLabel,...
                    pkgEditLabel,pkgEditText,pkgEditButton}];
                end
                dlgstruct.EmbeddedButtonSet={'Help'};
            elseif isa(obj.M3iObject,autosar.ui.metamodel.PackageString.InterfaceClass)
                dlgstruct.Items=[dlgstruct.Items,{packageEditText,packageEdit,packageEditButton}];
                dlgstruct.EmbeddedButtonSet={'Help'};
            end
            dlgstruct.LayoutGrid=[20,10];
            dlgstruct.RowStretch=[0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        end

        function ComputeProperties(obj)
            obj.Properties=obj.filterPropertyNames(obj.M3iObject);
            obj.IsCachedProps=true;
        end

        function modelName=getModelName(obj)
            explorer=autosar.ui.utils.findExplorer(obj.M3iObject.modelM3I);
            assert(~isempty(explorer),'explorer should not be empty');
            mapping=explorer.MappingManager.getActiveMappingFor('AutosarTarget');
            if isempty(mapping)
                mapping=explorer.MappingManager.getActiveMappingFor('AutosarTargetCPP');
            end
            assert(~isempty(mapping),'mapping should not be empty');
            modelName=autosar.api.Utils.getModelNameFromMapping(mapping);
        end

        function handleMappingEntityUpdatedEvent(obj,portMapping,~)

            root=obj;
            if isempty(root.HierarchicalChildren(1).HierarchicalChildren)

                return;
            end
            if isa(portMapping.MappedTo,'Simulink.AutosarTarget.PortElement')

                newARPortName=portMapping.MappedTo.Port;
                newARDataName=portMapping.MappedTo.Element;
                newARDataAccessModeStr=portMapping.MappedTo.DataAccessMode;

                mdlName=bdroot(portMapping.Block);
                autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(newARPortName,...
                newARDataName,newARDataAccessModeStr,mdlName);
            end
            autosar.ui.utils.updateEventsTriggerPort(obj,portMapping);
        end

        function handleMappingEntityRemovedEvent(obj,src,~)


            remove(obj.MappingEntityUpdatedListenerMap,src.Block);
            remove(obj.MappingEntityRemovedListenerMap,src.Block);
        end

        function handleMappingEntityAddedEvent(obj,src,~)


            obj.installMappingListeners(src);
        end

        function installMappingListeners(obj,modelMapping)


            mapping_children=properties(modelMapping);
            for childIdx=1:length(mapping_children)
                blockMappingList=modelMapping.(mapping_children{childIdx});
                if~isa(blockMappingList,'Simulink.AutosarTarget.BlockMapping')

                    continue;
                end
                for ii=1:numel(blockMappingList)
                    blockMapping=blockMappingList(ii);
                    if~isKey(obj.MappingEntityUpdatedListenerMap,blockMapping.Block)

                        obj.MappingEntityUpdatedListenerMap(blockMapping.Block)=...
                        event.listener(blockMapping,'AutosarMappingEntityUpdated',...
                        @obj.handleMappingEntityUpdatedEvent);
                        obj.MappingEntityRemovedListenerMap(blockMapping.Block)=...
                        event.listener(blockMapping,'AutosarMappingEntityDeleted',...
                        @obj.handleMappingEntityRemovedEvent);
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function retVal=areXmlOptionsInlined(arRoot)
            retVal=strcmp(autosar.mm.util.XmlOptionsAdapter.get(arRoot,'XmlOptionsSource'),...
            char(autosar.mm.util.XmlOptionsSourceEnum.Inlined));
        end
    end
end



function SaveAsHandler(~,eventData,rootNode)
    src=eventData.Source;
    if isa(src,'Simulink.BlockDiagram')
        me=autosar.ui.utils.findExplorer(rootNode.M3iObject);
        if~isempty(me)
            me.title=[autosar.ui.configuration.PackageString.UITitle,' ',src.Name];
        end
    end
end







