classdef SysarchPropertySchema<systemcomposer.internal.arch.internal.propertyinspector.SysarchBaseSchema





    properties(SetAccess=private)
ArchName
bdH
SourceHandle
Type
PropertySpecMap
Elem
contextBdH
PortHandle
CompPort
IsSWArchIC
IsAUTOSARArchModel
    end

    properties(Constant,Access=private)
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        Separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');
        InterfaceCreateOrSelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:CreateOrSelect');
        SelectStr=DAStudio.message('SystemArchitecture:PropertyInspector:Select');
        AnonymousInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Anonymous');
        EmptyInterfaceStr=DAStudio.message('SystemArchitecture:PropertyInspector:Empty');
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        RefreshStr=DAStudio.message('SystemArchitecture:PropertyInspector:Refresh');
        OpenParameterEditor=DAStudio.message('SystemArchitecture:PropertyInspector:OpenEditor');
        ResetParameterToDefault=DAStudio.message('SystemArchitecture:PropertyInspector:ResetDefault');
        NavigateToSource=DAStudio.message('SystemArchitecture:PropertyInspector:NavigateToSource');


        SourceProperties={'Sysarch:objName'};
        AllowedTypes={'Architecture','Component','Connector','Port'};


        isPrototypeProp=@(prop)contains(prop,'Sysarch:Prototype:');

        isTopDownWorkflowEnabled=slfeature('TopDownParameterWorkflow');
    end

    methods

        function this=SysarchPropertySchema(h,contextBdH)
            this.setSchemaSource(h);
            this.setType(h);
            this.SourceHandle=h.Handle;
            this.PortHandle=[];

            if~strcmp(this.Type,'Architecture')
                this.Elem=systemcomposer.utils.getArchitecturePeer(h.Handle);
                if isa(this.Elem,'systemcomposer.architecture.model.design.ComponentPort')
                    this.CompPort=this.Elem;
                    this.PortHandle=h.Handle;

                    this.Elem=this.Elem.getArchitecturePort();

                    slBlocks=systemcomposer.utils.getSimulinkPeer(this.Elem);
                    this.SourceHandle=slBlocks(1);
                end
            else
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(this.SourceHandle);
                this.Elem=app.getTopLevelCompositionArchitecture;
            end

            parentBlock=get_param(h.Handle,'Parent');
            isChildOfSubRef=systemcomposer.internal.isSubsystemReferenceComponent(parentBlock);
            if isChildOfSubRef
                this.ArchName=get_param(parentBlock,'ReferencedSubsystem');
            else
                this.ArchName=bdroot(getfullname(this.SourceHandle));
            end



            if bdIsLoaded(this.ArchName)
                this.bdH=get_param(this.ArchName,'Handle');
            else
                this.bdH=-1;
            end

            if(nargin>1)
                this.contextBdH=contextBdH;
            else
                this.contextBdH=this.bdH;
            end
            this.IsSWArchIC=(slfeature('SoftwareModelingIC')>0)&&...
            strcmp(get_param(this.contextBdH,'SimulinkSubDomain'),'SoftwareArchitecture');
            this.IsAUTOSARArchModel=Simulink.internal.isArchitectureModel(this.contextBdH,'AUTOSARArchitecture');


            this.PropertySpecMap=containers.Map();
            this.PropertySpecMap('Sysarch:objName')=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
            if this.IsAUTOSARArchModel
                this.addAUTOSARPropsToSpecMap();
                if slfeature('ZCProfilesForAUTOSAR')
                    this.PropertySpecMap('Sysarch:Prototype')=DAStudio.message('SystemArchitecture:PropertyInspector:Stereotype');
                end
            else
                this.PropertySpecMap('Sysarch:Prototype')=DAStudio.message('SystemArchitecture:PropertyInspector:Stereotype');
            end
            if slfeature('ZCParameters')
                this.PropertySpecMap('Sysarch:Parameters')=DAStudio.message('SystemArchitecture:PropertyInspector:Parameters');
            end

        end


        function name=getObjectType(this)
            if strcmp(this.Type,'Architecture')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Architecture');
            elseif strcmp(this.Type,'Component')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Component');
            elseif strcmp(this.Type,'Port')
                name=DAStudio.message('SystemArchitecture:PropertyInspector:Port');
            end
        end


        function toolTip=propertyTooltip(this,prop)
            if contains(prop,'Sysarch:Prototype:')
                toolTip=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyTooltip(this.Elem,prop);
            else
                toolTip=this.propertyDisplayLabel(prop);
            end
        end


        function hasSub=hasSubProperties(this,prop)
            if isempty(this.Elem)
                hasSub=false;
                systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(this.SourceHandle);
                return
            end
            if any(strcmp(prop,{'Sysarch:root','Sysarch:Main',...
                'Sysarch:Port:Interface'}))
                hasSub=true;
            elseif contains(prop,'Sysarch:Prototype:')
                hasSub=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.hasSubProperties(this.Elem,prop);
            elseif contains(prop,'Sysarch:Parameters')
                hasSub=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.hasSubProperties(this.Elem,prop);
            else
                hasSub=false;
            end
        end


        function subprops=subProperties(this,prop)
            subprops={};

            if(isempty(this.Elem))
                systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(this.SourceHandle);
                return;
            end


            if isempty(prop)


                subprops{end+1}='Sysarch:root';

                if strcmp(this.Type,'Architecture')

                    subprops{end+1}='Simulink:Model:Info';
                else

                    subprops{end+1}='Simulink:Dialog:Info';
                end
            elseif this.isSysarchRootProperty(prop)

                switch(prop)
                case 'Sysarch:root'
                    subprops{end+1}='Sysarch:Main';
                    if strcmp(this.Type,'Port')
                        if this.IsAUTOSARArchModel



                            dictName=get_param(bdroot(this.SourceHandle),'DataDictionary');
                            if~isempty(which(dictName))&&...
                                Simulink.interface.dictionary.internal.DictionaryClosureUtils.hasInterfaceDictInClosure(dictName)
                                subprops{end+1}='Sysarch:Port:Interface';
                            end
                        else

                            subprops{end+1}='Sysarch:Port:Interface';
                        end
                    end

                    if this.IsAUTOSARArchModel
                        subprops=this.addAUTOSARSubProps(subprops);
                    end

                    if~this.IsAUTOSARArchModel||(this.IsAUTOSARArchModel&&slfeature('ZCProfilesForAUTOSAR'))
                        if(isa(this.Elem,'systemcomposer.architecture.model.design.ArchitecturePort'))
                            if(this.Elem.getArchitecture.hasParentComponent)
                                component=this.Elem.getArchitecture.getParentComponent;
                                if~component.isAdapterComponent
                                    subprops{end+1}='Sysarch:Prototype';
                                end
                            else
                                subprops{end+1}='Sysarch:Prototype';
                            end
                        else
                            subprops{end+1}='Sysarch:Prototype';
                        end
                    end

                    elem=systemcomposer.internal.getArchitectureInContext(this.Elem);



                    prototypes=elem.getResolvedPrototypes;
                    if length(prototypes)>=1
                        prototypeProps=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.subProperties(elem,'Sysarch:Prototype');
                        subprops=horzcat(subprops,prototypeProps);
                    end

                    if slfeature('ZCParameters')&&...
                        (isa(this.Elem,'systemcomposer.architecture.model.design.BaseComponent')||isa(this.Elem,'systemcomposer.architecture.model.design.Architecture'))
                        if this.Elem.getTopLevelArchitecture~=this.Elem
                            slHdl=systemcomposer.utils.getSimulinkPeer(this.Elem);
                            if this.IsAUTOSARArchModel...
                                &&autosar.bsw.ServiceComponent.isBswServiceComponent(slHdl)
                                return;
                            end
                        end
                        subprops{end+1}='Sysarch:Parameters';
                        paramProps=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.subProperties(elem,'Sysarch:Parameters');
                        subprops=horzcat(subprops,paramProps);
                    end
                case 'Sysarch:Main'

                    subprops=this.SourceProperties;

                    if this.IsSWArchIC&&strcmp(this.Type,'Port')&&~isempty(this.PortHandle)&&...
                        strcmp(get_param(get_param(this.PortHandle,'Parent'),'BlockType'),'ModelReference')

                        subprops{end+1}='Sysarch:Port:InitialCondition';
                    end
                case 'Sysarch:Port:Interface'

                    subprops{end+1}='Sysarch:Port:AInterface:Name';
                    subprops{end+1}='Sysarch:Port:AInterface:Action';


                    if this.IsAUTOSARArchModel
                        if slfeature('ShowZCInterfaceEditorForAUTOSAR')&&...
                            autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(...
                            this.ArchName)
                            subprops{end+1}='Sysarch:Port:AInterface:LaunchIE';
                        end
                    else
                        subprops{end+1}='Sysarch:Port:AInterface:LaunchIE';
                    end

                    try
                        if(isa(this.Elem.getPortInterface(),'systemcomposer.architecture.model.swarch.ServiceInterface'))


                        elseif(~isempty(this.Elem.getPortInterface())&&this.Elem.getPortInterface().isAnonymous()&&isa(this.Elem.getPortInterface(),'systemcomposer.architecture.model.interface.ValueTypeInterface'))
                            subprops{end+1}='Sysarch:Port:AInterface:Type';
                            subprops{end+1}='Sysarch:Port:AInterface:Dimensions';
                            subprops{end+1}='Sysarch:Port:AInterface:Units';
                            subprops{end+1}='Sysarch:Port:AInterface:Complexity';
                            subprops{end+1}='Sysarch:Port:AInterface:Minimum';
                            subprops{end+1}='Sysarch:Port:AInterface:Maximum';
                        elseif(~isempty(this.Elem.getPortInterface())&&this.Elem.getPortInterface().isAnonymous()&&isa(this.Elem.getPortInterface(),'systemcomposer.architecture.model.interface.AtomicPhysicalInterface'))
                            subprops{end+1}='Sysarch:Port:AInterface:Type';
                        end
                    catch

                    end
                end
            else
                if contains(prop,'Sysarch:Parameters')
                    subprops=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.subProperties(this.Elem,prop);
                else

                    elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                    subprops=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.subProperties(elem,prop);
                end
            end
        end

        function performPropertyAction(this,prop,~)
            if strcmp(prop,'Sysarch:Port:AInterface:LaunchIE')
                systemcomposer.InterfaceEditor.openEditorInPortScope();
            elseif strcmp(prop,'Sysarch:Parameters')
                if isa(this.Elem,'systemcomposer.architecture.model.design.Architecture')&&...
                    ~this.Elem.hasParentComponent
                    blkHdl=this.bdH;
                else
                    blkHdl=systemcomposer.utils.getSimulinkPeer(this.Elem);
                end
                maskeditor('Create',blkHdl,false,false,false);
            end
        end


        function enabled=isPropertyEnabledHook(this,prop)
            if contains(prop,':NoPropertiesDefined')

                enabled=false;
                return
            end

            if~ishandle(this.bdH)
                enabled=false;
                return
            end
            if contains(prop,'Sysarch:Prototype')

                enabled=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.isPropertyEnabled(this.Elem,prop,this.bdH,this.contextBdH);
                return
            end
            if contains(prop,'Sysarch:Parameters')
                enabled=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.isPropertyEnabled(this.Elem,prop);
                return
            end

            if this.isAUTOSARProperty(prop)

                enabled=autosar.composition.pi.PropertyProvider.isPropertyEnabled(this.SourceHandle,prop);
                return;
            end

            switch prop
            case 'Sysarch:objName'
                enabled=true;

                if~isa(this.Elem,'systemcomposer.architecture.model.design.ArchitecturePort')
                    return;
                end

                owningArch=this.Elem.getContainingArchitecture();
                if~owningArch.hasParentComponent
                    return;
                end
            case 'Sysarch:Port:AInterface:Action'
                enabled=false;

            case{'Sysarch:Port:Interface','Sysarch:Port:AInterface:Name'}


                if(this.bdH~=this.contextBdH)&&~systemcomposer.internal.isSubsystemReferencePort(this.Elem)
                    enabled=false;
                else
                    enabled=true;
                end
            case{'Sysarch:Port:AInterface:Type','Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'}
                if(this.bdH~=this.contextBdH)&&~systemcomposer.internal.isSubsystemReferencePort(this.Elem)
                    enabled=false;
                elseif(any(strcmp(prop,'Sysarch:Port:AInterface:Type')))
                    enabled=true;
                else
                    architecturePort=this.Elem;
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

            otherwise
                enabled=true;
            end
        end


        function editable=isPropertyEditableHook(this,prop)
            if this.hasSubProperties(prop)


                if strcmp(prop,'Sysarch:Prototype')
                    editable=true;
                elseif contains(prop,'Sysarch:Prototype:')
                    editable=true;
                elseif strcmp(prop,'Sysarch:Parameters')
                    editable=true;
                else
                    editable=false;
                end
            elseif strcmp(prop,'Sysarch:Port:AInterface:Name')
                editable=true;
            elseif any(strcmp(prop,{'Sysarch:Port:AInterface:Type','Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'}))
                editable=true;
            elseif strcmp(prop,'Sysarch:Port:AInterface:Action')
                editable=false;
            else
                editable=true;
            end
        end

        function errors=setPropertyValues(this,vals,~)
            errors={};





            tfArray=cellfun(@(val)strcmp(DAStudio.message('SystemArchitecture:PropertyInspector:Remove'),val),vals);
            if any(tfArray)
                idx=find(tfArray);
                idx=idx(1);
                vals={vals{idx-1},vals{idx}};
            end

            for idx=1:2:numel(vals)
                prop=vals{idx};
                value=vals{idx+1};
                err=this.setPropertyVal(prop,value);
                if~isempty(err)
                    if strcmp(prop,'Sysarch:Prototype')
                        subError=DAStudio.UI.Util.Error(prop,...
                        'Error',...
                        err.message,...
                        []);
                        subError.DisplayValue=value;

                    else
                        propTags=strsplit(prop,':');
                        if any(strcmp(propTags{end},{'Unit','Value'}))
                            panelID=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.removeFakeProperty(prop);
                        else
                            panelID=prop;
                        end
                        if~isempty(err.cause)
                            causeMsg=err.cause{1}.message;
                        else
                            causeMsg='';
                        end
                        subError=DAStudio.UI.Util.Error(panelID,...
                        'Error',...
                        [err.message,' ',causeMsg],...
                        []);
                        subError.DisplayValue=this.propertyValue(panelID);
                        childError=DAStudio.UI.Util.Error(prop,...
                        'Error',...
                        [err.message,' ',causeMsg],...
                        []);
                        childError.DisplayValue=value;
                        subError.Children={childError};
                    end
                else
                    subError='';
                end
                errors=[errors,subError];%#ok<AGROW>
            end
            if~isempty(errors)

                errors={errors};
            else
                errors={};
            end


            if(ishandle(this.SourceHandle))
                systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(this.SourceHandle);
            else
                allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                ed=allStudios(1).App.getActiveEditor;
                ed.clearSelection();
            end
        end


        function err=setPropertyVal(this,prop,newValue)

            err={};

            if this.isAUTOSARProperty(prop)

                autosar.composition.pi.PropertyProvider.setPropertyValue(this.SourceHandle,prop,newValue);
                return;
            end

            if this.isPrototypeProp(prop)
                elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                err=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.setPropertyVal(elem,prop,newValue);
            elseif contains(prop,'Sysarch:Parameters:')
                err=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.setParameterVal(this.Elem,prop,newValue);
            else
                switch prop
                case 'Sysarch:objName'
                    if strcmp(this.Type,'Port')
                        if(strcmpi(get_param(this.SourceHandle,'BlockType'),'PMIOPort'))
                            set_param(this.SourceHandle,'Name',newValue);
                        else
                            if(strcmpi(get_param(this.SourceHandle,'isBusElementPort'),'on'))
                                set_param(this.SourceHandle,'PortName',newValue);
                            else
                                set_param(this.SourceHandle,'Name',newValue);
                            end
                        end
                    else
                        set_param(this.SourceHandle,'Name',newValue);


                        if strcmp(this.Type,'Architecture')
                            this.ArchName=newValue;
                        end
                    end

                case 'Sysarch:Port:InitialCondition'
                    assert(this.IsSWArchIC&&~isempty(this.PortHandle));
                    this.CompPort.setInitialCondition(newValue);

                case 'Sysarch:Port:AInterface:Name'
                    architecturePort=systemcomposer.internal.getWrapperForImpl(this.Elem);
                    rootHdl=bdroot(this.SourceHandle);
                    architecturePort.setInterface('');
                    interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.fetchInterfaceSemanticModelFromBDOrDD(rootHdl);
                    if strcmp(newValue,this.EmptyInterfaceStr)
                        architecturePort.setInterface('');
                    elseif strcmp(newValue,this.AnonymousInterfaceStr)
                        systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.setOwnedInterface(architecturePort);
                    elseif any(strcmp(newValue,this.getPortInterfaces(this.ArchName)))
                        portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(interfaceSemanticModel);
                        ddInfo=split(newValue,'::');
                        if numel(ddInfo)==2



                            source=ddInfo{1};
                            intrfName=ddInfo{2};
                            intrf=systemcomposer.internal.getWrapperForImpl(...
                            portInterfaceCatalog.getPortInterfaceInClosureByName(source,intrfName));
                            architecturePort.setInterface(intrf);
                        else

                            dictionary=systemcomposer.interface.Dictionary(portInterfaceCatalog);
                            intrf=dictionary.getInterface(newValue);
                            architecturePort.setInterface(intrf);
                        end
                    else
                        if this.IsAUTOSARArchModel


                            DAStudio.error('autosarstandard:editor:SelectedInterfaceNotFound',newValue);
                        end
                        interfaceName=strrep(newValue,' ','');
                        piCatalogImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(interfaceSemanticModel);
                        dictionary=systemcomposer.interface.Dictionary(piCatalogImpl);
                        if(architecturePort.Direction==systemcomposer.arch.PortDirection.Physical)

                            interface=dictionary.addPhysicalInterface(interfaceName);
                        elseif architecturePort.Direction==systemcomposer.arch.PortDirection.Server||...
                            architecturePort.Direction==systemcomposer.arch.PortDirection.Client
                            interface=dictionary.addServiceInterface(interfaceName);
                        else

                            interface=dictionary.addInterface(interfaceName);
                        end
                        architecturePort.setInterface(interface);
                    end

                case 'Sysarch:Port:AInterface:Type'
                    if(~strcmp(newValue,this.Separator))
                        interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.fetchInterfaceSemanticModelFromBD(bdroot(this.SourceHandle));
                        this.setInterfaceElementPropertyValue(interfaceSemanticModel,this.Elem,prop,newValue);
                    end

                case{'Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'}
                    interfaceSemanticModel=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.fetchInterfaceSemanticModelFromBD(bdroot(this.SourceHandle));
                    this.setInterfaceElementPropertyValue(interfaceSemanticModel,this.Elem,prop,newValue);

                case 'Sysarch:objTag'
                    this.setElemTagValue(newValue);

                case 'Sysarch:Prototype'
                    if strcmp(newValue,this.RemoveStr)
                        dp=DAStudio.DialogProvider;
                        dp.questdlg(DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes',this.Elem.getName),...
                        DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Title'),...
                        {DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'),...
                        DAStudio.message('SystemArchitecture:PropertyInspector:Cancel')},...
                        DAStudio.message('SystemArchitecture:PropertyInspector:Cancel'),...
                        @(response)this.handleRemoveAllStereotypes(response));

                    elseif strcmp(newValue,this.OpenProfEditorStr)
                        systemcomposer.internal.profile.Designer.launch
                        return

                    elseif any(strcmp(newValue,{this.AddStr,''}))
                        return

                    else
                        try
                            elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                            topArch=elem.getTopLevelArchitecture;
                            thatZCModel=topArch.p_Model;
                            profInfo=strsplit(newValue,'.');
                            systemcomposer.internal.arch.applyPrototype(elem,newValue);
                        catch ME
                            err=ME;
                        end
                    end
                case 'Sysarch:Parameters'
                    if strcmp(newValue,this.OpenParameterEditor)

                        if isa(this.Elem,'systemcomposer.architecture.model.design.BaseComponent')
                            if this.Elem.hasReferencedArchitecture
                                DAStudio.error('SystemArchitecture:PropertyInspector:CannotDefineOnReferenceComponent');
                            elseif this.Elem.isStateflowComponent
                                DAStudio.error('SystemArchitecture:PropertyInspector:NoParametersOnStateflow');
                            end
                        end
                        if isa(this.Elem,'systemcomposer.architecture.model.design.Architecture')&&...
                            ~this.Elem.hasParentComponent
                            blkHdl=this.bdH;
                        else
                            blkHdl=systemcomposer.utils.getSimulinkPeer(this.Elem);
                        end
                        maskeditor('Create',blkHdl,false,false,false);
                    elseif strcmp(newValue,this.ResetParameterToDefault)
                        dialog=systemcomposer.internal.parameters.ParameterSelectionDialog(this.Elem,'multiple');
                        DAStudio.Dialog(dialog);
                    elseif strcmp(newValue,this.NavigateToSource)
                        dialog=systemcomposer.internal.parameters.ParameterSelectionDialog(this.Elem,'single');
                        DAStudio.Dialog(dialog);
                    end
                otherwise



                    try
                        set_param(this.SourceHandle,prop,newValue)
                    catch ME
                        err=ME;
                    end
                end
            end
        end


        function value=propertyValue(this,prop)

            if isempty(this.Elem)
                value='';
                systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(this.SourceHandle);
                return
            end

            if this.isAUTOSARProperty(prop)

                value=autosar.composition.pi.PropertyProvider.getPropertyValue(this.SourceHandle,prop);
                return;
            end

            switch(prop)
            case 'Sysarch:objName'
                if strcmp(this.Type,'Port')&&...
                    ~strcmpi(get_param(this.SourceHandle,'BlockType'),'PMIOPort')&&...
                    strcmpi(get_param(this.SourceHandle,'isBusElementPort'),'on')
                    value=get_param(this.SourceHandle,'PortName');
                else
                    value=get_param(this.SourceHandle,'Name');
                end
            case 'Sysarch:Port:InitialCondition'
                assert(this.IsSWArchIC&&~isempty(this.PortHandle));
                value=this.CompPort.getInitialCondition();
            case 'Sysarch:objTag'
                value=this.getElemTagValue();
            case 'Sysarch:Prototype'
                value=this.AddStr;
            case 'Sysarch:Port:AInterface:Name'
                architecturePort=this.Elem;
                try
                    if(~isempty(architecturePort.getPortInterface()))
                        if(architecturePort.getPortInterface().isAnonymous())
                            value=this.AnonymousInterfaceStr;
                        else


                            value=architecturePort.getPortInterface().getName();
                        end
                    else
                        value=this.getInterfaceCreateOrSelectStr();
                    end
                catch ex
                    diagnosticViewerStage=sldiagviewer.createStage(message('SystemArchitecture:Interfaces:InterfaceAccess').getString(),'ModelName',get_param(bdroot(this.SourceHandle),'Name'));%#ok
                    sldiagviewer.reportError(ex);
                    value=architecturePort.getPortInterfaceName();
                end
            case 'Sysarch:Port:AInterface:LaunchIE'
                value=DAStudio.message('SystemArchitecture:Adapter:LaunchAssistant');
            case 'Sysarch:Parameters'
                value='';
                if this.isTopDownWorkflowEnabled
                    value=this.SelectStr;
                end
            case 'Sysarch:Port:AInterface:Action'

                switch this.Elem.getPortAction()
                case systemcomposer.internal.arch.PROVIDE
                    value='OUTPUT';
                case systemcomposer.internal.arch.REQUEST
                    value='INPUT';
                otherwise
                    value=char(this.Elem.getPortAction());
                end
            case 'Sysarch:Parameters:NoParametersDefined'
                value='';
            case{'Sysarch:Port:AInterface:Type','Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'}
                value=this.getInterfaceElementPropertyValue(this.Elem,prop);
            case{'Sysarch:Main','Sysarch:Port:Interface'}
                value='';
            otherwise
                if contains(prop,'Sysarch:Parameters:')
                    value=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.propertyValue(this.Elem,prop);
                else
                    elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                    value=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyValue(elem,prop);
                end
            end
        end


        function result=propertyDisplayLabel(this,prop)

            if this.isAUTOSARProperty(prop)

                result=autosar.composition.pi.PropertyProvider.getPropertyDisplayLabel(prop);
                return;
            end


            if any(strcmp(prop,this.SourceProperties))
                result=this.PropertySpecMap(prop);
            else
                switch(prop)
                case 'Sysarch:root'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Architecture');
                case 'Sysarch:Main'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Main');
                case 'Sysarch:Parameters'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Parameters');
                case 'Sysarch:Prototype'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Stereotype');
                case{'Simulink:Dialog:Parameters'}
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Parameters');
                case{'Simulink:Dialog:Properties','Simulink:Model:Properties'}
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Properties');
                case{'Simulink:Dialog:Info','Simulink:Model:Info'}
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Info');
                case 'Sysarch:Port:Interface'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Interface');
                case{'Simulink:Dialog:Domain','Simulink:Model:Domain'}
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Domain');
                case 'Sysarch:Port:AInterface:Name'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Name');
                case 'Sysarch:Port:AInterface:LaunchIE'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:ViewPortInIE');
                case 'Sysarch:Port:AInterface:Action'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Action');
                case 'Sysarch:Port:AInterface:Type'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
                case 'Sysarch:Port:AInterface:Dimensions'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
                case 'Sysarch:Port:AInterface:Units'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
                case 'Sysarch:Port:AInterface:Complexity'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
                case 'Sysarch:Port:AInterface:Minimum'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
                case 'Sysarch:Port:AInterface:Maximum'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
                case 'Sysarch:Port:InitialCondition'
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:InitialCondition');
                otherwise
                    if contains(prop,'Sysarch:Parameters:')
                        result=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.propertyDisplayLabel(prop);
                    else
                        result=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyDisplayLabel(prop);
                    end
                end
            end
        end


        function editor=propertyEditor(this,prop)
            editor={};%#ok<NASGU>

            if this.isAUTOSARProperty(prop)

                editor=autosar.composition.pi.PropertyProvider.getPropertyEditor(this.SourceHandle,prop);
                return;
            end

            switch(prop)
            case 'Sysarch:Parameters'
                if this.isTopDownWorkflowEnabled
                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.CurrentText='';
                    editor.Editable=true;
                    editor.Entries={editor.CurrentText,this.OpenParameterEditor,this.ResetParameterToDefault,this.NavigateToSource};
                else
                    editor=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.propertyEditor(this.Elem,prop);
                end
            case 'Sysarch:Prototype'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=this.AddStr;
                editor.Editable=true;
                if(isa(this.Elem,'systemcomposer.architecture.model.design.BaseComponent')&&...
                    this.Elem.hasReferencedArchitecture)
                    allValidPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(this.Elem.getReferencedArchitecture.getName,true,this.getPrototypableClass());
                else
                    allValidPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(this.ArchName,true,this.getPrototypableClass());
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
                architecture=systemcomposer.internal.getArchitectureInContext(this.Elem);



                prototypes=architecture.getResolvedPrototypes;
                if numel(prototypes)>=1

                    editor.Entries{end+1}=this.RemoveStr;
                end
                editor.Entries{end+1}=this.OpenProfEditorStr;
            case 'Sysarch:Port:AInterface:Name'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Editable=true;
                architecturePort=this.Elem;
                if(~isempty(architecturePort.getPortInterfaceName()))
                    editor.CurrentText=architecturePort.getPortInterfaceName();
                else
                    editor.CurrentText=this.getInterfaceCreateOrSelectStr();
                end

                portInterfaces=this.getPortInterfaces(this.ArchName,this.Elem);

                isClientServerPort=(architecturePort.getPortAction==systemcomposer.architecture.model.core.PortAction.CLIENT||...
                architecturePort.getPortAction==systemcomposer.architecture.model.core.PortAction.SERVER);


                if this.IsAUTOSARArchModel||isClientServerPort||this.isAdapterPort(architecturePort)
                    entries=[portInterfaces,{this.EmptyInterfaceStr}];
                else
                    entries=[portInterfaces,{this.AnonymousInterfaceStr},{this.EmptyInterfaceStr}];
                end
                editor.Entries=cat(2,entries);

            case 'Sysarch:Port:AInterface:Type'
                architecturePort=this.Elem;
                pi=architecturePort.getPortInterface();
                if(isa(pi,'systemcomposer.architecture.model.interface.ValueTypeInterface')||...
                    isa(pi,'systemcomposer.architecture.model.interface.AtomicPhysicalInterface'))
                    [value,entries]=systemcomposer.internal.getTypeAndAvailableTypes(pi);
                end

                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=value;
                editor.Entries=entries;
                editor.Editable=true;

            case 'Sysarch:Port:AInterface:Complexity'
                architecturePort=this.Elem;
                pi=architecturePort.getPortInterface();

                editor=DAStudio.UI.Widgets.ComboBox;
                if(isa(pi,'systemcomposer.architecture.model.interface.ValueTypeInterface'))
                    editor.CurrentText=pi.p_Complexity;
                else
                    pie=pi.getElement('');
                    editor.CurrentText=pie.getComplexity();
                end
                editor.Entries={'real','complex','auto'};

            case{'Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'}
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=this.propertyValue(prop);
            case{'Sysarch:objName','Sysarch:objTag','Sysarch:Port:InitialCondition'}
                editor={};
            otherwise
                if contains(prop,'Sysarch:Parameters:')
                    editor=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.propertyEditor(this.Elem,prop);
                else
                    editor=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyEditor(this.Elem,prop);
                end
            end
            if~isempty(editor)
                editor.Tag=prop;
            end
        end

        function mode=propertyRenderMode(this,prop)

            if this.isAUTOSARProperty(prop)

                mode=autosar.composition.pi.PropertyProvider.getPropertyRenderMode(prop);
                return;
            end

            switch prop
            case{'Sysarch:Prototype','Sysarch:Port:AInterface:Name','Sysarch:Port:AInterface:Type'}
                mode='RenderAsComboBox';
            case horzcat({'Sysarch:Port:Interface','Sysarch:Port:AInterface:Action',...
                'Sysarch:Port:AInterface:Dimensions',...
                'Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity',...
                'Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum',...
                'Sysarch:Main','Sysarch:Port:InitialCondition'},this.SourceProperties)
                mode='RenderAsText';
            case 'Sysarch:Port:AInterface:LaunchIE'
                mode='RenderAsHyperlink';
            case 'Sysarch:Parameters'
                mode='RenderAsText';
                if this.isTopDownWorkflowEnabled
                    mode='RenderAsComboBox';
                end
            otherwise
                if contains(prop,'Sysarch:Parameters:')
                    mode=systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler.propertyRenderMode(this.Elem,prop);
                else
                    elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                    mode=systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler.propertyRenderMode(elem,prop);
                end
            end
        end


        function result=supportTabView(~)
            result=true;
        end


        function result=rootNodeViewMode(this,rootnode)
            if this.isSysarchRootProperty(rootnode)
                result='TreeView';
            else
                result='SlimDialogView';
            end
        end


        function result=getOwnerGraphHandle(this)
            result=this.SourceHandle;
        end

        function result=implicityGroupPropertySet(~)
            result=true;
        end

    end



    methods(Static,Access=public)
        refresh(hdl);

        function setOwnedInterface(architecturePort)
            if architecturePort.Direction==systemcomposer.arch.PortDirection.Physical
                architecturePort.createInterface('PhysicalDomain');
            else
                architecturePort.createInterface('ValueType');
            end
        end
    end


    methods(Access=private)

        portInterfaces=getPortInterfaces(obj,archName,port)
        enums=getEnumerationsFromLinkedDictionary(obj,archName)


        function result=isSysarchRootProperty(~,prop)
            result=any(strcmp(prop,{'Sysarch:root',...
            'Sysarch:Main',...
            'Sysarch:Port:Interface',...
            'Sysarch:Port:AInterface:Name',...
            'Sysarch:Port:AInterface:LaunchIE',...
            'Sysarch:Port:AInterface:Action',...
            'Sysarch:Port:AInterface:Type','Sysarch:Port:AInterface:Dimensions','Sysarch:Port:AInterface:Units','Sysarch:Port:AInterface:Complexity','Sysarch:Port:AInterface:Minimum','Sysarch:Port:AInterface:Maximum'...
            ,'Sysarch:Prototype'}));
        end


        function result=isSLProperty(~,prop)
            result=any(strcmp(prop,{'Simulink:Dialog:Parameters',...
            'Simulink:Dialog:Properties',...
            'Simulink:Dialog:Info',...
            'Simulink:Dialog:Domain',...
            'Simulink:Model:Properties',...
            'Simulink:Model:Info',...
'Simulink:Model:Domain'...
            }));
        end


        function setType(this,h)
            switch(h.getDisplayClass)
            case{'Simulink.SubSystem','Simulink.ModelReference'}
                this.Type='Component';
            case 'Simulink.BlockDiagram'
                this.Type='Architecture';
            case{'Simulink.Inport','Simulink.Outport','Simulink.Port','Simulink.PMIOPort'}
                this.Type='Port';
            otherwise

                error('Selected element not supported')
            end
        end

        function protoClass=getPrototypableClass(this)
            protoClass=strcat('systemcomposer.',this.Type);
            if strcmp(protoClass,'systemcomposer.Architecture')
                protoClass='systemcomposer.Component';
            end
        end

        function setElemTagValue(this,val)



            tags=split(string(val),[","," ",";"]);
            tags(arrayfun(@(x)strlength(x)==0,tags))=[];
            tagVal="{'"+strjoin(tags,"','")+"'}";
            systemcomposer.internal.arch.setPropertyValue(this.Elem,'Common','Tag',tagVal);
        end

        function val=getElemTagValue(this)


            if isvalid(this.Elem)
                elem=this.Elem;
                if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                    elem=elem.getArchitecture;
                end
                tagsCell=systemcomposer.internal.arch.getPropertyValue(elem,'Common','Tag');
                if isempty(tagsCell)
                    val='';
                else
                    tagsArray=eval(tagsCell);
                    val=strjoin(tagsArray,', ');
                    val=char(val);
                end
            else
                val='';
            end
        end

        function propval=getInterfaceElementPropertyValue(~,port,prop)
            pi=port.getPortInterface();
            if isa(pi,'systemcomposer.architecture.model.interface.CompositeDataInterface')||isa(pi,'systemcomposer.architecture.model.interface.CompositePhysicalInterface')


                assert(strcmp(prop,'Sysarch:Port:AInterface:Type'));
                propval=pi.getName();
                return;
            end
            switch(prop)
            case 'Sysarch:Port:AInterface:Type'
                propval=strrep(pi.p_Type,'Connection: ','');
            case 'Sysarch:Port:AInterface:Dimensions'
                propval=pi.p_Dimensions;
            case 'Sysarch:Port:AInterface:Units'
                propval=pi.p_Units;
            case 'Sysarch:Port:AInterface:Complexity'
                propval=pi.p_Complexity;
            case 'Sysarch:Port:AInterface:Minimum'
                propval=pi.p_Minimum;
            case 'Sysarch:Port:AInterface:Maximum'
                propval=pi.p_Maximum;
            end
        end

        function setInterfaceElementPropertyValue(~,~,port,prop,propval)
            pi=systemcomposer.internal.getWrapperForImpl(port.getPortInterface());
            switch(prop)
            case 'Sysarch:Port:AInterface:Type'
                pi.setType(propval);
            case 'Sysarch:Port:AInterface:Dimensions'
                pi.setDimensions(propval);
            case 'Sysarch:Port:AInterface:Units'
                pi.setUnits(propval);
            case 'Sysarch:Port:AInterface:Complexity'
                pi.setComplexity(propval);
            case 'Sysarch:Port:AInterface:Minimum'
                pi.setMinimum(propval);
            case 'Sysarch:Port:AInterface:Maximum'
                pi.setMaximum(propval);
            end
        end

        function handleRemoveAllStereotypes(this,response)
            if strcmp(response,DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'))
                elem=systemcomposer.internal.getArchitectureInContext(this.Elem);
                systemcomposer.internal.arch.removePrototype(elem,'all');
                systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(this.SourceHandle);
            end
        end

        function addAUTOSARPropsToSpecMap(this)
            propSpecs=autosar.composition.pi.PropertyProvider.getAUTOSARPropertySpecs();
            for propSpec=propSpecs
                if strcmp(propSpec.AppliesTo,'CompBlock')&&systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isCompBlock(this.SourceHandle)
                    this.PropertySpecMap(propSpec.Tag)=propSpec.DisplayLabel;
                elseif strcmp(propSpec.AppliesTo,'ArchModel')&&systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlockDiagram(this.SourceHandle)
                    this.PropertySpecMap(propSpec.Tag)=propSpec.DisplayLabel;
                elseif strcmp(propSpec.AppliesTo,'PortBlock')&&systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isPortBlock(this.SourceHandle)
                    this.PropertySpecMap(propSpec.Tag)=propSpec.DisplayLabel;
                end
            end
        end

        function subprops=addAUTOSARSubProps(this,subprops)
            propSpecs=autosar.composition.pi.PropertyProvider.getAUTOSARPropertySpecs();
            for propSpec=propSpecs
                if strcmp(propSpec.AppliesTo,'CompBlock')&&...
                    systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isCompBlock(this.SourceHandle)
                    subprops{end+1}=propSpec.Tag;%#ok<AGROW>
                elseif strcmp(propSpec.AppliesTo,'ArchModel')&&...
                    systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlockDiagram(this.SourceHandle)
                    subprops{end+1}=propSpec.Tag;%#ok<AGROW>
                elseif strcmp(propSpec.AppliesTo,'PortBlock')&&...
                    systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isPortBlock(this.SourceHandle)&&...
                    ~any(strcmp(subprops,'Sysarch:Port:Interface'))
                    subprops{end+1}=propSpec.Tag;%#ok<AGROW>
                end
            end
        end

        function tf=isAUTOSARProperty(this,prop)
            tf=this.IsAUTOSARArchModel&&any(strcmp(prop,autosar.composition.pi.PropertyProvider.AUTOSARPropertyTagNames));
        end

        function str=getInterfaceCreateOrSelectStr(this)
            if this.IsAUTOSARArchModel
                str=this.SelectStr;
            else
                str=this.InterfaceCreateOrSelectStr;
            end
        end
    end

    methods(Static,Access=private)
        function interfaceSemanticModel=fetchInterfaceSemanticModelFromBDOrDD(bdH)
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            interfaceSemanticModel=app.getCompositionArchitectureModel;
            dd=get_param(bdH,'DataDictionary');
            if~isempty(dd)
                ddObj=Simulink.data.dictionary.open(dd);
                interfaceSemanticModel=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
            end
        end
        function interfaceSemanticModel=fetchInterfaceSemanticModelFromBD(bdH)
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            interfaceSemanticModel=app.getCompositionArchitectureModel;
        end


        function tf=isCompBlock(sysH)
            tf=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlock(sysH)&&...
            (systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isSubSystem(sysH)||...
            systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isModelBlock(sysH));
        end

        function tf=isBlockDiagram(sysH)
            tf=strcmp(get_param(sysH,'Type'),'block_diagram');
        end

        function tf=isBlock(sysH)
            tf=strcmp(get_param(sysH,'Type'),'block');
        end

        function tf=isSubSystem(sysH)
            tf=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'SubSystem');
        end

        function tf=isPortBlock(sysH)
            tf=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlock(sysH)&&...
            any(strcmp(get_param(sysH,'BlockType'),{'Inport','Outport'}));
        end

        function[tf,refModelName]=isModelBlock(sysH)
            refModelName='';
            tf=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'ModelReference');
            if(tf)
                refModelName=get_param(sysH,'ModelName');
            end
        end

        function tf=isAdapterPort(archPort)
            tf=false;
            if~isempty(archPort)
                parentArch=archPort.getArchitecture();
                parentComp=parentArch.getParentComponent();
                if~isempty(parentComp)
                    tf=parentComp.isAdapterComponent;
                end
            end
        end
    end
end



