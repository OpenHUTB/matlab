classdef PropertyInspectorSchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema


    properties
        propertyInspectorID;
        propertiesSter={};
        propertyInspectorSchema;
        multiTabs;
        hiliter;
        selectedConn;
        hilitedConn;
        SourceHandle;
        ArchName;
        bdH;
        contextBdH;

        isChildOfSubRef=false;
        subRefHdl;
        Type;
        isSubRef;




    end
    properties(Constant,Access=private)
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        Separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');
        InterfaceCreateOrSelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
        AnonymousInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');
        EmptyInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Empty');
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        RefreshStr=DAStudio.message('SystemArchitecture:PropertyInspector:Refresh');
        isPIReadOnly=false;
    end

    methods
        function obj=PropertyInspectorSchema(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(varargin{:});
            setType(obj);
            if~isempty(obj.Type)
                obj.SourceHandle=obj.elementWrapper.sourceHandle;
                obj.ArchName=obj.elementWrapper.archName;
                obj.isSubRef=false;
                if ishandle(obj.elementWrapper.h.Handle)
                    if systemcomposer.internal.isSubsystemReferenceComponent(obj.elementWrapper.h.Handle)
                        obj.subRefHdl=obj.elementWrapper.h.Handle;
                        obj.isSubRef=true;
                    end
                end
                obj.bdH=get_param(obj.ArchName,'Handle');
                obj.contextBdH=obj.bdH;

                try
                    obj.isChildOfSubRef=systemcomposer.internal.isSubsystemReferenceComponent(...
                    get_param(obj.elementWrapper.h.Handle,'Parent'));
                    if obj.isChildOfSubRef
                        obj.SourceHandle=obj.elementWrapper.h.Handle;
                        subRefName=get_param(get_param(obj.elementWrapper.h.Handle,'Parent'),'ReferencedSubsystem');
                        obj.subRefHdl=get_param(get_param(obj.elementWrapper.h.Handle,'Parent'),'Handle');
                        obj.ArchName=subRefName;
                        obj.elementWrapper.archName=subRefName;
                        obj.elementWrapper.element=systemcomposer.utils.getArchitecturePeer(obj.SourceHandle);
                    end
                end

                if strcmp(obj.elementWrapper.h.Type,'line')
                    obj.elementWrapper.sourcePortHdl=obj.elementWrapper.h.getSourcePort.Handle;
                    obj.elementWrapper.destPortHdl=obj.elementWrapper.h.Handle;
                    obj.hiliter=obj.elementWrapper.createHighlighterLine;
                    obj.elementWrapper.selectedConn=systemcomposer.architecture.model.design.BinaryConnector.empty;
                    obj.elementWrapper.userSelectionMade=false;
                end
            end
            obj.getSchema();
        end

        function schema=getPropertiesSchema(obj,properties,parentID)
            schema=obj.populatePropertySchema(parentID,properties);
        end

        function getSchema(obj)
            schemaFilePath=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+propertyInspector','+templates',obj.schemaFile);
            if(exist(schemaFilePath,'file')==2)
                propertyInspectorSet=jsondecode(fileread(schemaFilePath)).propertyInspectorSet;
                for itr=1:numel(propertyInspectorSet)
                    obj.propertyInspectorSchema=propertyInspectorSet(itr).propertyInspector;
                    if obj.propertyInspectorSchema.multiType&&ismember(obj.elementWrapper.schemaType,obj.propertyInspectorSchema.allowedTypes)
                        obj.propertyInspectorSchema.type=obj.elementWrapper.schemaType;
                        break;
                    end
                    if strcmp(obj.propertyInspectorSchema.type,obj.elementWrapper.schemaType)
                        break;
                    end
                end
                if~isempty(obj.propertyInspectorSchema)
                    obj.propertyInspectorID=obj.propertyInspectorSchema.id;
                    obj.multiTabs=obj.propertyInspectorSchema.multipleTabs;
                    tabs=obj.propertyInspectorSchema.tabs;
                    for tabItr=1:numel(tabs)
                        tab=tabs(tabItr);
                        tabID=strcat(obj.propertyInspectorID,':',tab.id);
                        if isempty(obj.elementWrapper.h)&&isempty(obj.Type)&&strcmp(tabID,'View:Root')
                            for itr=1:numel(tab.properties)
                                propIdLists=tab.properties(itr).id;

                                if strcmp(propIdLists,'ConnectionInfo')
                                    propIdLists='Main';
                                    tab.properties(itr).id=propIdLists;
                                end
                            end

                        end
                        tab.id=tabID;



                        tab.children=obj.getPropertiesSchema(tab.properties,'');
                        obj.propertyIDMap(tabID)=tab;
                        obj.propertyInspectorSchema.children{tabItr}=tab;
                    end
                    obj.propertyInspectorSchema.UUID=obj.elementWrapper.uuid;
                    obj.propertyInspectorSchema.appName=obj.elementWrapper.archName;

                    obj.propertyInspectorSchema.type=obj.elementWrapper.getObjectType();
                    obj.propertyInspectorSchema.setterOptions=obj.elementWrapper.options;
                else

                end
            end
        end

        function element=getPropElement(this)
            element=this.elementWrapper.element;
        end

        function result=supportTabView(~)
            result=true;
        end


        function mode=rootNodeViewMode(obj,propID)
            if strcmp('Simulink:Dialog:Info',propID)||strcmp('Simulink:Model:Info',propID)
                mode='SlimDialogView';
            else
                property=obj.propertyIDMap(propID);
                mode=property.renderMode;
            end
        end
        function setType(this)
            try
                switch(this.elementWrapper.h.getDisplayClass)
                case{'Simulink.SubSystem','Simulink.ModelReference'}
                    this.Type='Component';
                case 'Simulink.BlockDiagram'
                    this.Type='Architecture';
                case{'Simulink.Inport','Simulink.Outport','Simulink.Port','Simulink.PMIOPort'}
                    this.Type='Port';
                case 'Simulink.Line'
                    this.Type='Connector';
                otherwise

                    this.Type='';

                end
            catch

                this.Type='';
            end


        end

        function result=getOwnerGraphHandle(obj)
            result=obj.elementWrapper.sourceHandle;
        end

        function[propID,tabID]=getPropertyID(~,contextID)
            propID='';
            tabID='';
            splitIDs=split(contextID,':');
            if(numel(splitIDs)>2)
                propID=splitIDs{end};
                tabID=splitIDs{2};
            elseif(numel(splitIDs)==1)
                tabID=splitIDs{1};
            end
        end
        function performPropertyAction(~,prop,~)
            if strcmp(prop,'Sysarch:Port:AInterface:LaunchIE')
                systemcomposer.InterfaceEditor.openEditorInPortScope();
            end
        end

        function toolTip=propertyTooltip(obj,prop)
            property=[];
            if obj.propertyIDMap.isKey(prop)
                property=obj.propertyIDMap(prop);
                if~(isempty(property))&&~isempty(obj.elementWrapper.h)
                    toolTip=obj.propertyDisplayLabel(prop);
                    return;
                end
            elseif~isempty(prop)&&~isempty(obj.propertiesSter)
                for j=1:numel(obj.propertiesSter)
                    if strcmp(obj.propertiesSter{j}.id,prop)
                        property=obj.propertiesSter{j};


                    end
                    for i=1:numel(obj.propertiesSter{j}.children)
                        x=obj.propertiesSter{j}.children;
                        if strcmp(x{i}.id,prop)

                            toolTip=obj.elementWrapper.propertyTooltip(prop);
                            return;
                        end
                    end
                end
            end
            if strcmp(prop,'Sysarch:Port:AInterface:LaunchIE')
                toolTip=obj.propertyDisplayLabel(prop);
                return;
            end
            if~(isempty(property))
                toolTip=property.tooltip;
            else
                toolTip=obj.elementWrapper.propertyTooltip(prop);

                return;
            end
        end
        function renderMode=propertyRenderMode(obj,prop)
            renderMode=[];
            property=[];
            if obj.propertyIDMap.isKey(prop)
                property=obj.propertyIDMap(prop);
            elseif~isempty(prop)&&~isempty(obj.propertiesSter)
                for j=1:numel(obj.propertiesSter)
                    if strcmp(obj.propertiesSter{j}.id,prop)

                        renderMode="RenderAsComboBox";
                        return;

                    else
                        if~isempty(obj.propertiesSter{j}.children)
                            x=obj.propertiesSter{j}.children;
                            for i=1:numel(x)
                                if~isempty(prop(strfind(prop,':')+1:end))&&~isempty(x{i}.id(strfind(x{i}.id,':')+1:end))
                                    if strcmp(x{i}.id(strfind(x{i}.id,':')+1:end),prop(strfind(prop,':')+1:end))

                                        renderMode=obj.elementWrapper.propertyRenderMode(prop);
                                        return;
                                    end

                                end
                            end

                        end

                    end
                end
                if isempty(renderMode)
                    renderMode=obj.elementWrapper.propertyRenderMode(prop);
                    return;
                end
            end
            if~(isempty(property))
                mode=property.renderMode;
                switch(mode)
                case{'editbox','none','actioncallback'}
                    renderMode='RenderAsText';
                case{'combobox'}
                    renderMode='RenderAsComboBox';
                otherwise
                    renderMode='RenderAsText';
                end
                if strcmp(obj.Type,'Connector')&&strcmp(prop,'PortSelection:Destination')
                    [isSelected,selectedLine]=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.DestinationPortConnector(obj.elementWrapper.h);
                    if~isSelected
                        renderMode='RenderAsComboBox';
                        property.renderMode='combobox';
                    else
                        renderMode='RenderAsText';
                        property.renderMode='none';
                    end

                    obj.propertyIDMap(prop)=property;
                end
            end
            switch prop
            case{'Sysarch:Port:InitialCondition','AInterfaceType','AInterfaceDim',...
                'AInterfaceUnit','AInterfaceComplexity','AInterfaceMin','AInterfaceMax'}


                renderMode='RenderAsText';
                return;
            case 'Sysarch:Port:AInterface:LaunchIE'
                renderMode='RenderAsHyperlink';

            end
        end

        function hasSub=hasSubProperties(this,propID)





            hasSub=false;
            if isempty(propID)
                firstLevelChildren=this.propertyInspectorSchema.children;
                if numel(firstLevelChildren)>0
                    hasSub=true;
                else
                    hasSub=false;
                end
            else
                if this.propertyIDMap.isKey(propID)
                    children=this.propertyIDMap(propID).children;
                    if numel(children)>0
                        hasSub=true;
                    else
                        hasSub=false;
                    end
                else
                    if~isempty(this.propertiesSter)
                        for i=1:numel(this.propertiesSter)
                            if strcmp(this.propertiesSter{i}.id,propID)
                                children=this.propertiesSter{i}.children;
                                if numel(children)>0
                                    hasSub=true;
                                    return;
                                else
                                    hasSub=false;
                                    return
                                end

                            end
                        end
                    end
                    if~contains(propID,'Interface')
                        if contains(propID,':')

                            hasSub=false;
                        else

                            hasSub=true;
                        end
                    end
                end
            end
        end
        function delete(obj)

            systemcomposer.internal.propertyInspector.schema.PropertySetSchema.removeHiliterFromConnector(obj);

        end

        function subprops=subProperties(this,propID)
            subprops={};
            if this.isChildOfSubRef
                this.elementWrapper.element=systemcomposer.utils.getArchitecturePeer(this.SourceHandle);
            end
            if strcmp(propID,'View:Root')

                if~this.elementWrapper.userSelectionMade||isempty(this.elementWrapper.selectedConn)



                    [isSelected,selectedLine]=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.DestinationPortConnector(this.elementWrapper.h);
                    if isSelected

                        prt=get_param(selectedLine,'DstPortHandle');
                    else
                        if isempty(selectedLine)
                            this.refresh();
                            return
                        end

                        selectedLines=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getSelectedLineFromConnectors(selectedLine);
                        prt=get_param(selectedLines(1),'DstPortHandle');
                    end
                else


                    prt=this.elementWrapper.destPortHdl;
                    this.elementWrapper.userSelectionMade=false;
                end

                if~isequal(prt,this.elementWrapper.destPortHdl)

                    systemcomposer.internal.propertyInspector.schema.PropertySetSchema.removeHiliterFromConnector(this);
                    if~ishandle(prt)

                        this.elementWrapper.selectedConn=systemcomposer.architecture.model.design.BinaryConnector.empty;
                    else
                        this.elementWrapper.destPortHdl=prt;
                        zcDstPrt=systemcomposer.utils.getArchitecturePeer(prt);
                        zcSrcPrt=systemcomposer.utils.getArchitecturePeer(this.elementWrapper.sourcePortHdl);
                        this.elementWrapper.selectedConn=zcSrcPrt.getConnectorTo(zcDstPrt);
                        this.elementWrapper.stereotypeElement=this.elementWrapper.selectedConn;
                        try
                            this.elementWrapper.elemet.getPrototype=this.elementWrapper.selectedConn.p_PropertySets;
                        catch

                        end
                        this.hiliteSelectedSegment();


                        this.refresh();
                    end
                end
            end

            try
                if strcmp(this.Type,'Connector')
                    if~isempty(this.elementWrapper.selectedConn)
                        this.getSchema();
                    end
                elseif~strcmp(propID,'Sysarch:Root')&&~strcmp(propID,'Main')&&~isempty(propID)
                    this.getSchema();
                end

            catch


            end
            if isempty(propID)
                childProperties=this.propertyInspectorSchema.children;
                for childItr=1:numel(childProperties)
                    subprops{end+1}=childProperties{childItr}.id;
                    if contains('Sysarch:Info',subprops)
                        if~strcmp(this.Type,'Architecture')
                            subprops{end}='Simulink:Dialog:Info';
                        else
                            subprops{end}='Simulink:Model:Info';
                        end
                    end
                end
            else
                if this.propertyIDMap.isKey(propID)
                    children=this.propertyIDMap(propID).children;
                    for childItr=1:numel(children)
                        childProperty=children{childItr};
                        childPropID=childProperty.id;
                        subprops{end+1}=childPropID;
                    end
                end
                if strcmp(propID,'View:Root')
                    if(this.elementWrapper.destPortHdl~=-1)
                        if isa(this.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')
                            ArchElement=this.getArchitectureInContext(this.elementWrapper.element);
                            prototypes=ArchElement.p_Prototype;

                        else
                            prototypes=this.elementWrapper.element.getPrototype;

                        end
                        if length(prototypes)>=1

                            try

                                property=this.addDynamicPropertyAfter('Stereotype');
                                this.propertiesSter=property;
                                for i=1:numel(property)
                                    if~ismember(property{i}.id,subprops)
                                        subprops=horzcat(subprops,property{i}.id);
                                    end
                                end
                            catch

                            end
                        end
                    end
                elseif strcmp(propID,'Sysarch:Root')
                    if isa(this.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')
                        ArchElement=this.getArchitectureInContext(this.elementWrapper.element);
                        prototypes=ArchElement.p_Prototype;
                    else
                        prototypes=this.elementWrapper.element.getPrototype;
                    end

                    if length(prototypes)>=1

                        try
                            property=this.addDynamicPropertyAfter('Stereotype');
                            this.propertiesSter=property;
                            subprop=subPro(this);
                            numsub=numel(subprop);
                            for i=1:numsub
                                if~ismember(subprops,subprop(i))
                                    subprops=horzcat(subprops,subprop(i));
                                end
                            end

                        catch

                        end
                    end
                elseif~isempty(this.propertiesSter)
                    for i=1:numel(this.propertiesSter)
                        if strcmp(this.propertiesSter{i}.id,propID)
                            for k=1:numel(this.propertiesSter{i}.children)
                                property=this.propertiesSter{i}.children{k}.id;
                            end

                        end
                        if~strcmp(propID,'Main')&&~contains(propID,'Interface')&&~contains(propID,'PortSelection')&&~contains(propID,'ConnectionInfo')
                            subprops=this.elementWrapper.getSubPropertiesForPrototype(propID);
                        end
                    end
                end
                if strcmp(propID,'Interface')

                    if(slfeature('ZCCompositeInlinedIntrf')>0)
                        subprops{end+1}='Sysarch:Port:AInterface:LaunchIE';
                    end
                    try
                        PortInterface=this.elementWrapper.element.getPortInterface();
                        if(~isempty(PortInterface)&&PortInterface.isAnonymous()&&isa(PortInterface,'systemcomposer.architecture.model.interface.AtomicSignalInterface'))
                            if~contains('AInterfaceType',subprops)
                                subprops{end+1}='AInterfaceType';
                            end
                            if~contains('AInterfaceDim',subprops)
                                subprops{end+1}='AInterfaceDim';
                            end
                            if~contains('AInterfaceUnit',subprops)
                                subprops{end+1}='AInterfaceUnit';
                            end
                            if~contains('AInterfaceComplexity',subprops)
                                subprops{end+1}='AInterfaceComplexity';
                            end
                            if~contains('AInterfaceMin',subprops)
                                subprops{end+1}='AInterfaceMin';
                            end
                            if~contains('AInterfaceMax',subprops)
                                subprops{end+1}='AInterfaceMax';
                            end
                        end
                    catch

                    end
                end
            end
        end
        function isLive=isSourceLive(obj)

            isLive=true;
            SourceObject=obj.elementWrapper.h;
            if~isempty(SourceObject)

                if ishandle(SourceObject.Handle)
                    blockDiagram=bdroot(SourceObject.Handle);

                else
                    blockDiagram=bdroot(SourceObject.Parent);
                end
                if Simulink.harness.internal.hasActiveHarness(blockDiagram)||...
                    Simulink.harness.isHarnessBD(blockDiagram)||...
                    strcmp(get_param(blockDiagram,'Lock'),'on')
                    isLive=false;
                end
            end
        end
        function makePIReadOnly(obj,bool)

            obj.isPIReadOnly=bool;
        end
        function enabled=isPropertyEnabled(obj,propID)
            enabled=false;
            if~obj.isSourceLive()||obj.isPIReadOnly
                return;
            end

            enabled=obj.isPropertyEnabledHook(propID);




            if isempty(obj.elementWrapper.h)
                enabled=false;
            end
        end
        function editable=isPropertyEditable(obj,propID)
            editable=false;
            if~obj.isSourceLive()||obj.isPIReadOnly
                return;
            end

            editable=obj.isPropertyEditableHook(propID);




            if isempty(obj.elementWrapper.h)
                editable=false;
            end
        end




        function enabled=isPropertyEnabledHook(obj,propID)
            enabled=true;
            try





                if(obj.isChildOfSubRef||obj.isSubRef)&&...
                    slInternal('isSRGraphLockedForEditing',obj.subRefHdl)
                    enabled=false;
                    if obj.isSubRef&&strcmp(propID,'Main:Name')
                        enabled=true;
                    end
                    return;
                end

                if isempty(obj.elementWrapper.selectedConn)
                    enabled=false;
                    return;
                end
            catch

            end
            property=[];
            if strcmp(obj.Type,'Connector')
                if obj.elementWrapper.destPortHdl==-1
                    enabled=false;
                    return;
                end
            end
            if obj.propertyIDMap.isKey(propID)
                property=obj.propertyIDMap(propID);
            elseif~isempty(propID)&&~isempty(obj.propertiesSter)
                for j=1:numel(obj.propertiesSter)
                    if strcmp(obj.propertiesSter{j}.id,propID)
                        property=obj.propertiesSter{j};
                    end
                    for i=1:numel(obj.propertiesSter{j}.children)
                        x=obj.propertiesSter{j}.children;
                        if strcmp(x{i}.id,propID)
                            property=obj.propertiesSter{j}.children{i};
                        end
                    end
                end

            end
            if~isempty(property)
                enabled=property.enabled;
            end
            if contains(propID,{'AInterfaceType','AInterfaceDim','AInterfaceUnit','AInterfaceComplexity','AInterfaceMin','AInterfaceMax'})
                if(obj.isChildOfSubRef)
                    enabled=false;
                elseif(any(strcmp(propID,'AInterfaceType')))
                    enabled=true;
                else
                    architecturePort=obj.elementWrapper.element;
                    pi=architecturePort.getPortInterface();
                    if~isempty(pi)
                        pieType=pi.p_Type();
                        pieType=pieType(~isspace(pieType));
                        if(startsWith(pieType,'Bus:'))
                            enabled=false;
                        else
                            enabled=true;
                        end
                    end
                end
            end
            if contains(propID,DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions'))
                enabled=false;
                return;
            end
            if strcmp(propID,'Interface')||strcmp(propID,'Interface:InterfaceName')
                if obj.isChildOfSubRef
                    enabled=false;
                end
            end
            if obj.isChildOfSubRef&&...
                slInternal('isSRGraphLockedForEditing',obj.subRefHdl)
                enabled=false;
            end
            if contains(propID,':')&&~contains(propID,':Name')&&~contains(propID,'PortSelection:')&&~contains(propID,'Interface')
                propBottom=propID(strfind(propID,':')+1:end);

                if isempty(propBottom)

                    enabled=true;
                else

                    propTop=propID(1:strfind(propID,':')-1);
                    PU=obj.elementWrapper.getPropUsage(propTop,propBottom);
                    if(~PU.isInSyncWithPropDef()||...
                        PU.propertySet.propertySet.prototype.hasMissingParent(true))

                        enabled=false;
                        return
                    else
                        enabled=true;
                    end
                end
            end
        end


        function editable=isPropertyEditableHook(obj,propID)
            property=[];
            try
                if isempty(obj.elementWrapper.selectedConn)
                    editable=false;
                    return
                end
            catch


            end
            editable=true;
            if obj.propertyIDMap.isKey(propID)
                property=obj.propertyIDMap(propID);
            elseif~isempty(propID)&&~isempty(obj.propertiesSter)
                for j=1:numel(obj.propertiesSter)
                    if strcmp(obj.propertiesSter{j}.id,propID)
                        property=obj.propertiesSter{j};
                    end
                    for i=1:numel(obj.propertiesSter{j}.children)
                        x=obj.propertiesSter{j}.children;
                        if strcmp(x{i}.id,propID)
                            property=obj.propertiesSter{j}.children{i};
                        end
                    end
                end

            end
            if~isempty(property)
                editable=property.editable;
            end
            if strcmp(propID,'PortSelection:Destination')&&ishandle(get_param(obj.elementWrapper.sourceHandle,'DstPortHandle'))
                if obj.elementWrapper.isSingleLineSelected
                    editable=false;
                else
                    editable=true;
                end
            end

        end

        function displayLabel=propertyDisplayLabel(obj,propID)

            displayLabel=[];
            property=[];
            if~isempty(propID)
                if obj.propertyIDMap.isKey(propID)
                    property=obj.propertyIDMap(propID);
                    displayLabel=property.label;
                    if strcmp(displayLabel,'Info')
                        displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Info');
                    end
                elseif~isempty(propID)&&~isempty(obj.propertiesSter)
                    for j=1:numel(obj.propertiesSter)
                        if strcmp(obj.propertiesSter{j}.id,propID)
                            property=obj.propertiesSter{j};
                        end
                        for i=1:numel(obj.propertiesSter{j}.children)
                            childStereotype=obj.propertiesSter{j}.children{i};
                            childStereotypeSubPart=childStereotype.id(strfind(childStereotype.id,':')+1:end);
                            propIDSubPart=propID(strfind(propID,':')+1:end);
                            if strcmp(childStereotypeSubPart,propIDSubPart)
                                property=obj.propertiesSter{j}.children{i};
                                if strcmp(propID(strfind(propID,':')+1:end),'NoPropertiesDefined')
                                    displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                                    return;
                                end
                            end
                        end
                    end
                end
                if strcmp(propID,'Simulink:Dialog:Info')||strcmp(propID,'Simulink:Model:Info')
                    displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Info');
                    return;
                end

            end
            if~isempty(property)
                displayLabel=property.label;
                return;
            end

            if isa(obj.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')
                x=obj.propertyInspectorSchema.children{1,1}.children;
                for i=1:numel(x)
                    if strcmp(obj.propertyInspectorSchema.children{1,1}.children{1,i}.id,propID)
                        displayLabel=obj.propertyInspectorSchema.children{1,1}.children{1,i}.label;
                        return;
                    end
                end
            end
            switch(propID)
            case 'Sysarch:Port:AInterface:LaunchIE'
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:ViewPortInIE');
            case{'AInterfaceType'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
            case{'AInterfaceDim'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
            case{'AInterfaceUnit'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
            case{'AInterfaceComplexity'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
            case{'AInterfaceMin'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
            case{'AInterfaceMax'}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
            case{'AInterfaceInitialCondition',''}
                displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:InitialCondition');
            otherwise
                if~isempty(propID)
                    if(contains(propID,':'))


                        displayLabel=propID(strfind(propID,':')+1:end);
                        if contains(displayLabel,'NoPropertiesDefined')
                            displayLabel=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                        end
                    else

                        str=strsplit(propID,'.');
                        displayLabel=str{2};
                    end
                end
            end
        end



        function err=setPropertyVal(obj,prop,newValue)
            err={};
            if obj.propertyIDMap.isKey(prop)
                property=obj.propertyIDMap(prop);
                setterFunction=property.setter;
                changeSet.newValue=newValue;
            elseif~isempty(prop)&&~contains(prop,'Interface')
                err=obj.elementWrapper.setPropertyVal(prop,newValue);
                return;
            end

            switch prop


            case 'PortSelection:Destination'
                systemcomposer.internal.propertyInspector.schema.PropertySetSchema.removeHiliterFromConnector(obj);
                if strcmp(newValue,'Select')
                    return;
                end
                zcSrcPrt=systemcomposer.utils.getArchitecturePeer(obj.elementWrapper.sourcePortHdl);
                zcDstPrt=obj.elementWrapper.findDstPrt(newValue);
                conn=zcSrcPrt.getConnectorTo(zcDstPrt);
                obj.elementWrapper.selectedConn=conn;
                obj.elementWrapper.element=conn;
                obj.elementWrapper.stereotypeElement=conn;

            case 'AInterfaceType'
                if(~strcmp(newValue,obj.Separator))
                    interfaceSemanticModel=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.fetchInterfaceSemanticModelFromBD(bdroot(obj.elementWrapper.sourceHandle));
                    obj.elementWrapper.setInterfaceElementPropertyValue(prop,newValue,interfaceSemanticModel);
                end

            case{'AInterfaceDim','AInterfaceUnit','AInterfaceComplexity','AInterfaceMin','AInterfaceMax'}
                interfaceSemanticModel=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.fetchInterfaceSemanticModelFromBD(bdroot(obj.elementWrapper.sourceHandle));
                obj.elementWrapper.setInterfaceElementPropertyValue(prop,newValue,interfaceSemanticModel);

            case 'Interface:InterfaceName'
                if~isempty(property)
                    portInterfaces=obj.elementWrapper.getPortInterfaces(obj.ArchName);
                    portInterfaces{end+1}=obj.AnonymousInterfaceStr;
                    portInterfaces{end+1}=obj.EmptyInterfaceStr;
                    property.entries=cat(2,portInterfaces);
                end


            end

            try
                if~strcmp(setterFunction,"")
                    callBackFunction=eval(setterFunction);
                    err=callBackFunction(obj.elementWrapper,changeSet,property);

                end
            catch

            end
            if strcmp(obj.Type,'Connector')
                obj.elementWrapper.userSelectionMade=true;
            end
        end

        function errors=setPropertyValues(obj,vals,~)
            errors={};
            for idx=1:2:numel(vals)
                propID=vals{idx};
                value=vals{idx+1};
                error=setPropertyVal(obj,propID,value);
                if~isempty(error)
                    if strcmp(propID,'Stereotype')
                        subError=DAStudio.UI.Util.Error(propID,...
                        'Error',...
                        error.message,...
                        []);
                        subError.DisplayValue=value;

                    else
                        propTags=strsplit(propID,':');
                        if any(strcmp(propTags{end},{'Unit','Value'}))
                            panelID=systemcomposer.internal.propertyInspector.schema.PropertySetSchema.removeFakeProperty(propID);
                            for i=1:numel(obj.elementWrapper.stereotypeElement.p_Prototype)
                                if ismember(panelID,obj.elementWrapper.stereotypeElement.p_Prototype(i).propertySet.getAllPropertyNames)
                                    x=obj.elementWrapper.stereotypeElement.p_Prototype(i).propertySet.prototype.fullyQualifiedName;
                                    x=strcat(x,':',panelID);
                                    panelID=x;
                                end
                            end
                        else
                            panelID=propID;
                        end
                        if~isempty(error.cause)
                            causeMsg=error.cause{1}.message;
                        else
                            causeMsg='';
                        end
                        subError=DAStudio.UI.Util.Error(panelID,...
                        'Error',...
                        [error.message,' ',causeMsg],...
                        []);
                        subError.DisplayValue=obj.propertyValue(panelID);

                        childError=DAStudio.UI.Util.Error(propID,...
                        'Error',...
                        [error.message,' ',causeMsg],...
                        []);
                        childError.DisplayValue=value;
                        subError.Children={childError};
                    end
                    errors=[errors,subError];
                end
            end
            if~isempty(errors)

                errors={errors};
            else
                errors={};
            end
            if strcmp(obj.Type,'Connector')
                refresh(obj);
            else
                systemcomposer.internal.propertyInspector.schema.PropertySetSchema.refresh(obj.elementWrapper.sourceHandle);
            end
        end
        function subprops=subPro(this)
            if isa(this.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')

                elem=this.getArchitectureInContext(this.elementWrapper.element);
            else

                elem=this.elementWrapper.element;
            end
            subprops={};%#ok<NASGU>
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler

            prototypeNames=elem.getPrototypeNames;








            elemProtoName='';
            elemProto=elem.getElementPrototype;
            if~isempty(elemProto)
                elemProtoName=elemProto.fullyQualifiedName;
            end


            if~isempty(elemProtoName)
                idxElemProto=ismember(prototypeNames,elemProtoName);
                prototypeNames(idxElemProto)=[];
            end


            prototypeNames=horzcat(elemProtoName,...
            sort(prototypeNames));





            subprops=prototypeNames;
        end
        function name=getObjectType(this)
            if strcmp(this.propertyInspectorSchema.type,'Architecture')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Architecture');
            elseif strcmp(this.propertyInspectorSchema.type,'Component')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Component');
            elseif strcmp(this.propertyInspectorSchema.type,'Port')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Port');
            elseif strcmp(this.propertyInspectorSchema.type,'Connector')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Connector');
            else
                name='';
            end
        end

        function value=propertyValue(obj,propID)
            property=[];

            if obj.propertyIDMap.isKey(propID)
                property=obj.propertyIDMap(propID);
            elseif~isempty(propID)&&~isempty(obj.propertiesSter)&&~contains(propID,'Interface')
                try
                    value=obj.elementWrapper.propertyValue(propID);
                    return;
                end

            end
            if~isempty(property)
                value=property.value;
                if strcmp(propID,'Interface:InterfaceAction')
                    if strcmp(value,'PROVIDE')
                        value='OUTPUT';
                    elseif strcmp(value,'REQUEST')
                        value='INPUT';
                    end
                end
            end
            switch(propID)
            case 'Main:Name'
                if strcmp(obj.Type,'Port')&&...
                    ~strcmpi(get_param(obj.elementWrapper.sourceHandle,'BlockType'),'PMIOPort')&&...
                    strcmpi(get_param(obj.elementWrapper.sourceHandle,'isBusElementPort'),'on')
                    value=get_param(obj.elementWrapper.sourceHandle,'PortName');
                else
                    value=get_param(obj.elementWrapper.sourceHandle,'Name');
                end

            case 'ConnectionInfo:Name'
                if~isempty(obj.elementWrapper.selectedConn)
                    value=obj.elementWrapper.selectedConn.getName;
                end
            case 'ConnectionInfo'
                if ishandle(obj.elementWrapper.destPortHdl)
                    d=systemcomposer.utils.getArchitecturePeer(obj.elementWrapper.destPortHdl);
                else
                    d=double.empty;
                end
                if~isempty(d)&&isvalid(d)
                    value=[obj.elementWrapper.getSourcePortName,' -> ',d.getName];
                else
                    value='';
                    obj.elementWrapper.userSelectionMade=true;
                    refresh(obj);
                end
            case 'PortSelection:Destination'
                if~isempty(obj.elementWrapper.selectedConn)&&isvalid(obj.elementWrapper.selectedConn)
                    value=obj.elementWrapper.selectedConn.getDestination.getName;
                else
                    value='';
                end

            case 'Sysarch:Port:AInterface:LaunchIE'
                value=DAStudio.message('SystemArchitecture:Adapter:LaunchAssistant');
            case{'AInterfaceType','AInterfaceDim','AInterfaceUnit','AInterfaceComplexity','AInterfaceMin','AInterfaceMax'}
                value=obj.elementWrapper.getInterfaceElementPropertyValue(propID);

            case 'Interface:InterfaceName'
                architecturePort=obj.elementWrapper.element;
                try
                    if(~isempty(architecturePort.getPortInterface()))
                        if(architecturePort.getPortInterface().isAnonymous())
                            value=obj.AnonymousInterfaceStr;
                        else
                            value=architecturePort.getPortInterfaceName();
                        end
                    else
                        value=obj.InterfaceCreateOrSelectStr;
                    end
                catch ex
                    diagnosticViewerStage=sldiagviewer.createStage(message('SystemArchitecture:Interfaces:InterfaceAccess').getString(),'ModelName',get_param(bdroot(obj.SourceHandle),'Name'));%#ok
                    sldiagviewer.reportError(ex);
                    value=architecturePort.getPortInterfaceName();
                end
            end
        end

        function protoClass=getPrototypableClass(this)
            protoClass=strcat('systemcomposer.',this.propertyInspectorSchema.type);
            if strcmp(protoClass,'systemcomposer.Component')
                protoClass='systemcomposer.Component';
            end
        end
        function hiliteSelectedSegment(obj)
            selectedSegDiagObj=diagram.resolver.resolve([obj.elementWrapper.sourcePortHdl,obj.elementWrapper.destPortHdl]);
            obj.hilitedConn=selectedSegDiagObj;
            obj.hiliter.applyClass(selectedSegDiagObj,'ArchConnector')
        end

        function refresh(this)
            systemcomposer.internal.propertyInspector.schema.PropertySetSchema.removeHiliterFromConnector(this);
            h=DAStudio.EventDispatcher;
            h.broadcastEvent('PropertyChangedEvent',this.elementWrapper.h);
            this.hiliteSelectedSegment();
        end

        function editor=propertyEditor(obj,propID)
            editor={};
            if obj.propertyIDMap.isKey(propID)
                property=obj.propertyIDMap(propID);
            elseif~isempty(propID)&&~isempty(obj.propertiesSter)


                editor=obj.elementWrapper.propertyEditor(propID);
                return;
            end
            switch propID
            case 'Stereotype'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=property.value;
                editor.Editable=true;
                editor.Entries=property.entries;


                if(isa(obj.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')&&...
                    obj.elementWrapper.element.hasReferencedArchitecture)
                    allValidPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(obj.elementWrapper.element.getArchitecture.getName,true,obj.getPrototypableClass());
                else
                    allValidPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(obj.elementWrapper.archName,true,obj.getPrototypableClass());
                end
                elemPrototypes={};
                mixinPrototypes={};
                for i=1:numel(allValidPrototypes)
                    if systemcomposer.internal.isPrototypeMixin(allValidPrototypes(i))
                        mixinPrototypes{end+1}=allValidPrototypes(i).fullyQualifiedName;%#ok<AGROW>
                    else
                        elemPrototypes{end+1}=allValidPrototypes(i).fullyQualifiedName;%#ok<AGROW>
                    end
                end
                editor.Entries=horzcat(elemPrototypes,mixinPrototypes);
                if isa(obj.elementWrapper.element,'systemcomposer.architecture.model.design.BaseComponent')
                    ArchElement=obj.getArchitectureInContext(obj.elementWrapper.element);
                    if numel(ArchElement.p_Prototype)>=1

                        editor.Entries{end+1}=obj.RemoveStr;
                    end
                else
                    if numel(obj.elementWrapper.element.p_Prototype)>=1

                        editor.Entries{end+1}=obj.RemoveStr;
                    end
                end
                editor.Entries{end+1}=obj.OpenProfEditorStr;
            case 'PortSelection:Destination'
                if~obj.elementWrapper.isSingleLineSelected
                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.Entries=obj.elementWrapper.findAllDstPrtNames();
                    currentPrt=systemcomposer.utils.getArchitecturePeer(obj.elementWrapper.destPortHdl);
                    currentPrtName=[currentPrt.getComponent.getName,'/',currentPrt.getName];
                    currentPrtIdx=find(strcmp(editor.Entries,currentPrtName));
                    editor.Index=currentPrtIdx-1;
                end
            case 'Interface:InterfaceName'
                editor=DAStudio.UI.Widgets.ComboBox;
                architecturePort=obj.elementWrapper.element;
                if(~isempty(architecturePort.getPortInterfaceName()))
                    editor.CurrentText=architecturePort.getPortInterfaceName();
                else
                    editor.CurrentText=obj.InterfaceCreateOrSelectStr;
                end
                editor.Editable=property.editable;
                portInterfaces=obj.elementWrapper.getPortInterfaces(obj.ArchName);
                portInterfaces{end+1}=obj.AnonymousInterfaceStr;
                portInterfaces{end+1}=obj.EmptyInterfaceStr;
                editor.Entries=cat(2,portInterfaces);


            case 'AInterfaceType'
                architecturePort=obj.elementWrapper.element;
                pi=architecturePort.getPortInterface();
                pie=[];
                if(~isempty(pi))
                    pie=pi.getElement('');
                end

                editor=DAStudio.UI.Widgets.ComboBox;
                if(~isempty(pie))
                    editor.CurrentText=pie.getType();
                else
                    editor.CurrentText='double';
                end
                editor.Editable=false;
                defaultEntries={'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','boolean',obj.Separator,'fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};
                buses=obj.elementWrapper.getPortInterfaces(obj.ArchName);
                if(~isempty(buses))
                    buses=[obj.Separator,cellfun(@(c)['Bus: ',c],buses,'UniformOutput',false)];
                end

                enums=obj.elementWrapper.getEnumerationsFromLinkedDictionary();
                if(~isempty(enums))
                    enums=[obj.Separator,cellfun(@(c)['Enum: ',c],enums,'UniformOutput',false)];
                end

                editor.Entries=[defaultEntries,buses,enums];

            case 'AInterfaceComplexity'
                architecturePort=obj.elementWrapper.element;
                pi=architecturePort.getPortInterface();
                pie=[];
                if(~isempty(pi))
                    pie=pi.getElement('');
                end

                editor=DAStudio.UI.Widgets.ComboBox;
                if(~isempty(pie))
                    editor.CurrentText=pie.getComplexity();
                else
                    editor.CurrentText='real';
                end
                editor.Entries={'real','complex','auto'};

            case{'AInterfaceDim','AInterfaceUnit','AInterfaceMin','AInterfaceMax'}
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=obj.propertyValue(propID);
            end

            if~isempty(editor)
                editor.Tag=propID;
            end
        end

    end

    methods(Static)
        function interfaceSemanticModel=fetchInterfaceSemanticModelFromBD(bdH)
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            interfaceSemanticModel=app.getCompositionArchitectureModel;
        end




        function architecture=getArchitectureInContext(compOrArch)
            if isa(compOrArch,'systemcomposer.architecture.model.design.Architecture')
                component=compOrArch.getParentComponent;
                if isempty(component)


                    architecture=compOrArch;
                    return;
                end
            else
                component=compOrArch;
            end
            if component.isSubsystemReferenceComponent
                architecture=component.getOwnedArchitecture;
            else
                architecture=component.getArchitecture;
            end
        end
    end
end
