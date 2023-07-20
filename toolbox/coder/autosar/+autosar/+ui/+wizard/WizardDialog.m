





classdef WizardDialog<handle
    properties(SetAccess=private)
        State(1,1)autosar.ui.wizard.WizardDialogState;
        DialogH;
        ComponentBuilder;
        Model;
        Editor;
        Option;
        ProtectedNames;
        SelectedNode;
        CloseListner;
        IsAdaptiveWizard;
    end

    methods
        function obj=WizardDialog(varargin)
            if isa(varargin{1},'GLUE2.Editor')
                editor=varargin{1};
                model=editor.getStudio.App.blockDiagramHandle;
            else
                model=varargin{1};
                editors=GLUE2.Util.findAllEditors(model);
                if numel(editors)>0
                    editor=editors(1);
                else
                    editor={};
                end
            end
            argc=length(varargin);
            if argc==4
                option=varargin{2};
                protectedNames=varargin{3};
                selectedNode=varargin{4};
            else
                assert(false,'did not expect to get here');
            end

            modelName=get_param(model,'name');
            mmgr=get_param(modelName,'MappingManager');
            mapping=mmgr.getActiveMappingFor(autosar.api.Utils.getMappingType(modelName));
            if~isempty(mapping)&&~isempty(mapping.MappedTo)
                compName=mapping.MappedTo.Name;
            else
                compName=modelName;
            end
            obj.ComponentBuilder=autosar.ui.wizard.builder.Component(compName,...
            modelName,'IsWizardMode',false,'SelectedNode',selectedNode);
            obj.Model=model;
            obj.Editor=editor;
            obj.IsAdaptiveWizard=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);

            if argc==4
                obj.State=option;
                obj.Option=option;
                obj.ProtectedNames=protectedNames;
                obj.SelectedNode=selectedNode;

                if isequal(obj.Option,autosar.ui.wizard.WizardDialogState.Interfaces)
                    newName=genvarname(autosar.ui.wizard.PackageString.NewName,...
                    protectedNames);
                    if strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                        obj.ComponentBuilder.CSInterfaces(1).setName(newName);
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                        obj.ComponentBuilder.ServiceInterfaces(1).setName(newName);
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                        obj.ComponentBuilder.PersistencyKeyValueInterfaces(1).setName(newName);
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    else
                        obj.ComponentBuilder.Interfaces(1).setName(newName);
                    end
                elseif isequal(obj.Option,autosar.ui.wizard.WizardDialogState.Ports)

                    while length(obj.ComponentBuilder.Ports)>1
                        obj.ComponentBuilder.removePort(obj.ComponentBuilder.Ports(end));
                    end
                    while length(obj.ComponentBuilder.ServicePorts)>1
                        obj.ComponentBuilder.removePort(obj.ComponentBuilder.ServicePorts(end));
                    end
                    while length(obj.ComponentBuilder.PersistencyPorts)>1
                        obj.ComponentBuilder.removePort(obj.ComponentBuilder.PersistencyPorts(end));
                    end


                    if strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.receiverPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{2});
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{1};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.senderPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{1})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{1};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.senderReceiverPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{5})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{1};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.nvSenderPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{8})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{6};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.nvReceiverPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{7})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{6};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{9})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{6};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{3})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{3};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ModeSenderPortNodeName)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{11})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{3};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.serverPortsNode)
                        obj.ComponentBuilder.CSPorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{4})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{2};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.clientPortsNode)
                        obj.ComponentBuilder.CSPorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{6})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{2};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{10});
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{5};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName)
                        obj.ComponentBuilder.Ports(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{12})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{4};
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.requiredPortsNode)
                        obj.ComponentBuilder.ServicePorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{14})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{7};
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.providedPortsNode)
                        obj.ComponentBuilder.ServicePorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{13})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{7};
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode)
                        obj.ComponentBuilder.PersistencyPorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{15})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode)
                        obj.ComponentBuilder.PersistencyPorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{16})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    elseif strcmp(selectedNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode)
                        obj.ComponentBuilder.PersistencyPorts(1).setType(...
                        autosar.ui.wizard.PackageString.PortTypes{17})
                        interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
                        obj.ComponentBuilder.setComponentType('Adaptive');
                    else
                        assert(false,'Unknown port object');
                    end
                    newName=genvarname(autosar.ui.wizard.PackageString.NewName,...
                    protectedNames);
                    if obj.IsAdaptiveWizard
                        obj.ComponentBuilder.ServicePorts(1).setName(newName);
                        obj.ComponentBuilder.PersistencyPorts(1).setName(newName)
                    else
                        obj.ComponentBuilder.Ports(1).setName(newName);
                        obj.ComponentBuilder.CSPorts(1).setName(newName);
                    end

                    if~isempty(obj.ComponentBuilder.Interfaces)
                        obj.ComponentBuilder.removeInterface(...
                        obj.ComponentBuilder.Interfaces(1));
                    end
                    if~isempty(obj.ComponentBuilder.CSInterfaces)
                        obj.ComponentBuilder.removeInterface(...
                        obj.ComponentBuilder.CSInterfaces(1));
                    end
                    if~isempty(obj.ComponentBuilder.ServiceInterfaces)
                        obj.ComponentBuilder.removeInterface(...
                        obj.ComponentBuilder.ServiceInterfaces(1));
                    end
                    if~isempty(obj.ComponentBuilder.PersistencyKeyValueInterfaces)
                        obj.ComponentBuilder.removeInterface(...
                        obj.ComponentBuilder.PersistencyKeyValueInterfaces(1));
                    end

                    selNode=obj.SelectedNode;
                    if isa(selNode,"DAStudio.DAObjectProxy")
                        selNode=selNode.getMCOSObjectReference;
                    end
                    interfaceObjs=autosar.ui.utils.collectObject(...
                    selNode.ParentM3I.modelM3I,...
                    interfaceClass);
                    for i=1:length(interfaceObjs)
                        if strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{1})
                            obj.ComponentBuilder.addSRInterface(interfaceObjs(i).Name,...
                            2,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{3})
                            obj.ComponentBuilder.addMSInterface(interfaceObjs(i).Name,...
                            autosar.ui.wizard.PackageString.NewName,'',...
                            autosar.ui.wizard.PackageString.InterfaceTypes(2));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{2})
                            obj.ComponentBuilder.addCSInterface(interfaceObjs(i).Name,...
                            2,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{4})
                            obj.ComponentBuilder.addTriggerInterface(interfaceObjs(i).Name,...
                            2,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{5})
                            obj.ComponentBuilder.addParameterInterface(interfaceObjs(i).Name,...
                            2,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{6})
                            obj.ComponentBuilder.addNVInterface(interfaceObjs(i).Name,...
                            2,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{7})
                            obj.ComponentBuilder.addServiceInterface(interfaceObjs(i).Name,...
                            1,0,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        elseif strcmp(interfaceClass,autosar.ui.metamodel.PackageString.InterfacesCell{8})
                            obj.ComponentBuilder.addPersistencyKeyValueInterface(interfaceObjs(i).Name,...
                            1,...
                            autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        else
                            assert(false,'Unknown interface object');
                        end
                    end
                end
            end
            modelH=get_param(model,'Handle');
            obj.CloseListner=Simulink.listener(modelH,'CloseEvent',@CloseForWizardCB);

        end

        function setDialog(obj,dlg)
            obj.DialogH=dlg;
        end

        function refresh(obj)
            obj.DialogH.refresh;
        end

        function ret=setData(obj)
            state=obj.State;
            if strcmp(obj.SelectedNode.getDisplayLabel,...
                autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                state=autosar.ui.wizard.WizardDialogState.CSInterfaces;
            elseif strcmp(obj.SelectedNode.getDisplayLabel,...
                autosar.ui.metamodel.PackageString.serverPortsNode)
                state=autosar.ui.wizard.WizardDialogState.CSPorts;
            end
            switch(state)
            case autosar.ui.wizard.WizardDialogState.Interfaces
                ret=obj.setInterfaceData();
            case autosar.ui.wizard.WizardDialogState.CSInterfaces
                ret=obj.setCSInterfaceData();
            case autosar.ui.wizard.WizardDialogState.Ports
                ret=obj.setPortData();
            case autosar.ui.wizard.WizardDialogState.CSPorts
                ret=obj.setCSPortData();
            otherwise
                assert(false,DAStudio.message('autosarstandard:ui:uiCommonInvalidState'));
            end
        end

        function ret=setComponentData(obj)
            compPackage=obj.DialogH.getWidgetValue('ComponentPackage');
            compName=obj.DialogH.getWidgetValue('ComponentName');
            compType=obj.DialogH.getWidgetValue('ComponentType');
            ret=obj.ComponentBuilder.setComponentPackage(compPackage);
            if ret<0
                return;
            end
            ret=obj.ComponentBuilder.setComponentName(compName);
            if ret<0
                return;
            end

            if~obj.IsAdaptiveWizard

                ret=obj.ComponentBuilder.setComponentType(...
                autosar.ui.wizard.PackageString.ComponentTypes{compType+1});
            end
        end

        function ret=setInterfaceData(obj)
            interfacePackage=obj.DialogH.getWidgetValue('InterfacePackage');




            displayLabel=obj.SelectedNode.getDisplayLabel;
            ret=obj.ComponentBuilder.setInterfacePackage(interfacePackage);
            if ret<0
                return;
            end



            if obj.IsAdaptiveWizard
                for i=1:length(obj.ComponentBuilder.ServiceInterfaces)
                    name=obj.DialogH.getTableItemValue('InterfaceTable',i-1,0);
                    eventCount=obj.DialogH.getTableItemValue('InterfaceTable',i-1,1);
                    methodCount=obj.DialogH.getTableItemValue('InterfaceTable',i-1,2);
                    interfaceProperty={eventCount,methodCount};
                    type=autosar.ui.wizard.PackageString.InterfaceTypes{1};
                    qName=[interfacePackage,'/',name];
                    ret=obj.ComponentBuilder.setInterface(i,name,qName,...
                    interfaceProperty,type,displayLabel);
                    if ret<0
                        return;
                    end
                end
                for i=1:length(obj.ComponentBuilder.PersistencyKeyValueInterfaces)
                    name=obj.DialogH.getTableItemValue('InterfaceTable',i-1,0);
                    dataElementCount=obj.DialogH.getTableItemValue('InterfaceTable',i-1,1);
                    interfaceProperty={dataElementCount};
                    type=autosar.ui.wizard.PackageString.InterfaceTypes{1};
                    qName=[interfacePackage,'/',name];
                    ret=obj.ComponentBuilder.setInterface(i,name,qName,...
                    interfaceProperty,type,displayLabel);
                    if ret<0
                        return;
                    end
                end
            else
                for i=1:length(obj.ComponentBuilder.Interfaces)
                    name=obj.DialogH.getTableItemValue('InterfaceTable',i-1,0);
                    interfaceProperty=obj.DialogH.getTableItemValue('InterfaceTable',i-1,1);
                    isService=obj.DialogH.getTableItemValue('InterfaceTable',i-1,2);
                    if strcmp(isService,autosar.ui.metamodel.PackageString.False)
                        type=autosar.ui.wizard.PackageString.InterfaceTypes{1};
                    else
                        type=autosar.ui.wizard.PackageString.InterfaceTypes{2};
                    end
                    qName=[interfacePackage,'/',name];
                    ret=obj.ComponentBuilder.setInterface(i,name,qName,...
                    interfaceProperty,type,displayLabel);
                    if ret<0
                        return;
                    end
                end
            end
        end

        function ret=setCSInterfaceData(obj)




            displayLabel=obj.SelectedNode.getDisplayLabel;
            interfacePackage=obj.DialogH.getWidgetValue('InterfacePackage');
            ret=obj.ComponentBuilder.setCSInterfacePackage(interfacePackage);

            if ret<0
                return;
            end



            for i=1:length(obj.ComponentBuilder.CSInterfaces)
                name=obj.DialogH.getTableItemValue('InterfaceTable',i-1,0);
                interfaceProperty=obj.DialogH.getTableItemValue('InterfaceTable',i-1,1);
                isService=obj.DialogH.getTableItemValue('InterfaceTable',i-1,2);
                if strcmp(isService,autosar.ui.metamodel.PackageString.False)
                    type=autosar.ui.wizard.PackageString.InterfaceTypes{1};
                else
                    type=autosar.ui.wizard.PackageString.InterfaceTypes{2};
                end
                qName=[interfacePackage,'/',name];
                ret=obj.ComponentBuilder.setInterface(i,name,qName,...
                interfaceProperty,type,displayLabel);
                if ret<0
                    return;
                end
            end
        end

        function ret=setPortData(obj)
            ret=0;


            if obj.IsAdaptiveWizard
                portList=obj.ComponentBuilder.ServicePorts;
            else
                portList=obj.ComponentBuilder.Ports;
            end
            for i=1:length(portList)
                name=obj.DialogH.getTableItemValue('PortTable',i-1,0);
                interface=obj.DialogH.getTableItemValue('PortTable',i-1,1);
                type=obj.DialogH.getTableItemValue('PortTable',i-1,2);
                ret=obj.ComponentBuilder.setPort(i,name,interface,type);
                if ret<0
                    return;
                end
            end
        end

        function ret=setCSPortData(obj)
            ret=0;



            for i=1:length(obj.ComponentBuilder.CSPorts)
                name=obj.DialogH.getTableItemValue('PortTable',i-1,0);
                interface=obj.DialogH.getTableItemValue('PortTable',i-1,1);
                type=obj.DialogH.getTableItemValue('PortTable',i-1,2);
                ret=obj.ComponentBuilder.setPort(i,name,interface,type);
                if ret<0
                    return;
                end
            end
        end


        function addInterface(obj)
            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSInterfaces)
                obj.setCSInterfaceData();
            else
                obj.setInterfaceData();
            end

            if obj.IsAdaptiveWizard
                serviceIntLen=length(obj.ComponentBuilder.ServiceInterfaces);
                excludedNames=cell(1,serviceIntLen);
                for i=1:serviceIntLen
                    excludedNames{i}=obj.ComponentBuilder.ServiceInterfaces(i).Name;
                end
                persistencyKeyValueIntLen=length(obj.ComponentBuilder.PersistencyKeyValueInterfaces);
                excludedNames=cell(1,serviceIntLen);
                for i=1:persistencyKeyValueIntLen
                    excludedNames{i}=obj.ComponentBuilder.PersistencyKeyValueInterfaces(i).Name;
                end
            else
                csIntLen=length(obj.ComponentBuilder.CSInterfaces);
                srIntLen=length(obj.ComponentBuilder.Interfaces);
                excludedNames=cell(1,csIntLen+srIntLen);
                for i=1:csIntLen
                    excludedNames{i}=obj.ComponentBuilder.CSInterfaces(i).Name;
                end
                for i=1:srIntLen
                    excludedNames{csIntLen+i}...
                    =obj.ComponentBuilder.Interfaces(i).Name;
                end
            end


            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSInterfaces)
                interfaceFmt=autosar.ui.wizard.PackageString.DefaultCSInterface;
                newInterface=genvarname(interfaceFmt,[excludedNames,obj.ProtectedNames]);
                obj.ComponentBuilder.addCSInterface(newInterface,'1',...
                autosar.ui.wizard.PackageString.InterfaceTypes{1});
            else
                if obj.IsAdaptiveWizard
                    interfaceFmt=autosar.ui.wizard.PackageString.DefaultServiceInterface;
                    newInterface=genvarname(interfaceFmt,[excludedNames,obj.ProtectedNames]);
                    obj.ComponentBuilder.addServiceInterface(newInterface,'1','1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes{1});
                    interfaceFmt=autosar.ui.wizard.PackageString.DefaultPersistencyKeyValueInterface;
                    newInterface=genvarname(interfaceFmt,[excludedNames,obj.ProtectedNames]);
                    obj.ComponentBuilder.addPersistencyKeyValueInterface(newInterface,'1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes{1});
                else
                    interfaceFmt=autosar.ui.wizard.PackageString.DefaultInterface;
                    newInterface=genvarname(interfaceFmt,[excludedNames,obj.ProtectedNames]);
                    obj.ComponentBuilder.addSRInterface(newInterface,'1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes{1});
                end
            end
            obj.DialogH.setUserData('InterfaceTable','Adding');
        end

        function addPort(obj)
            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSPorts)
                obj.setCSPortData();
                newPortName=autosar.ui.wizard.PackageString.DefaultPort3;
            else
                obj.setPortData();
                if obj.IsAdaptiveWizard
                    newPortName=autosar.ui.wizard.PackageString.DefaultServicePort1;
                else
                    newPortName=autosar.ui.wizard.PackageString.DefaultPort1;
                end
            end

            if obj.IsAdaptiveWizard
                servicePortLen=length(obj.ComponentBuilder.ServicePorts);
                excludedNames=cell(1,servicePortLen);
                for i=1:servicePortLen
                    excludedNames{i}=obj.ComponentBuilder.ServicePorts(i).Name;
                end
            else
                srPortLen=length(obj.ComponentBuilder.Ports);
                csPortLen=length(obj.ComponentBuilder.CSPorts);
                excludedNames=cell(1,srPortLen+csPortLen);
                for i=1:csPortLen
                    excludedNames{i}=obj.ComponentBuilder.CSPorts(i).Name;
                end
                for i=1:srPortLen
                    excludedNames{csPortLen+i}=obj.ComponentBuilder.Ports(i).Name;
                end
            end


            portFmt=newPortName;
            newPort=genvarname(portFmt,[excludedNames,obj.ProtectedNames]);
            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSPorts)
                obj.ComponentBuilder.addCSPort(newPort,...
                obj.ComponentBuilder.CSInterfaces(1).Name,...
                autosar.ui.wizard.PackageString.PortTypes{4});
            else
                if obj.IsAdaptiveWizard
                    obj.ComponentBuilder.addServicePort(newPort,...
                    obj.ComponentBuilder.ServiceInterfaces(1).Name,...
                    autosar.ui.wizard.PackageString.PortTypes{14});
                    obj.ComponentBuilder.addPersistencyPort(newPort,...
                    obj.ComponentBuilder.PersistencyKeyValueInterfaces(1).Name,...
                    autosar.ui.wizard.PackageString.PortTypes{16});
                else
                    obj.ComponentBuilder.addPort(newPort,...
                    obj.ComponentBuilder.Interfaces(1).Name,...
                    autosar.ui.wizard.PackageString.PortTypes{2});
                end
            end
            obj.DialogH.setUserData('PortTable','Adding');
        end

        function removeInterface(obj,tableData)
            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSInterfaces)
                obj.setCSInterfaceData();
            else
                obj.setInterfaceData();
            end
            index=obj.DialogH.getSelectedTableRow('InterfaceTable');
            if(index>=0)
                obj.ComponentBuilder.removeInterface(tableData(index+1));
                if index>0
                    obj.DialogH.selectTableItem('InterfaceTable',index-1,0);
                end
            end
        end

        function removePort(obj,tableData)
            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSPorts)
                obj.setCSPortData();
            else
                obj.setPortData();
            end
            index=obj.DialogH.getSelectedTableRow('PortTable');
            if(index>=0)
                obj.ComponentBuilder.removePort(tableData(index+1));
                if index>0
                    obj.DialogH.selectTableItem('PortTable',index-1,0);
                end
            end
        end

        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.HelpMethod='';
            dlgstruct.HelpArgs={};

            if isequal(obj.State,autosar.ui.wizard.WizardDialogState.Interfaces)||...
                isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSInterfaces)
                dlgstruct.DialogTag='Interface';
                dlgstruct.DialogTitle=autosar.ui.wizard.PackageString.InterfacesTitle;
                spacer0.Name='Spacer';
                spacer0.Type='text';
                spacer0.Mode=true;
                spacer0.RowSpan=[1,2];
                spacer0.ColSpan=[1,7];
                spacer0.Visible=0;

                interfaceLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardInterfaceLabel');
                interfaceLabel.Type='text';
                interfaceLabel.Mode=true;
                interfaceLabel.RowSpan=[3,3];
                interfaceLabel.ColSpan=[3,10];
                interfaceLabel.Tag='InterfaceLabel';

                spacer1.Name='Spacer';
                spacer1.Type='text';
                spacer1.Mode=true;
                spacer1.RowSpan=[4,5];
                spacer1.ColSpan=[1,7];
                spacer1.Visible=0;

                spacer2.Name='Spacer';
                spacer2.Type='text';
                spacer2.Mode=true;
                spacer2.RowSpan=[7,8];
                spacer2.ColSpan=[1,7];
                spacer2.Visible=0;

                if strcmp(obj.SelectedNode.getDisplayLabel,...
                    autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName)
                    interfacePackageEdit.Name=[DAStudio.message('RTW:autosar:autosarInterfacePackageNameStr')...
                    ,'      '];
                    interfacePackageEdit.Type='edit';
                    interfacePackageEdit.Mode=true;
                    interfacePackageEdit.Source=obj.ComponentBuilder;
                    interfacePackageEdit.Tag='InterfacePackage';
                    interfacePackageEdit.ObjectProperty='InterfacePackage';
                    interfacePackageEdit.RowSpan=[6,6];
                    interfacePackageEdit.ColSpan=[3,25];
                    interfacePackageEdit.Enabled=true;

                    spacer3.Name='Spacer';
                    spacer3.Type='text';
                    spacer3.Mode=true;
                    spacer3.RowSpan=[13,14];
                    spacer3.ColSpan=[1,7];
                    spacer3.Visible=0;



                    interfacesLabel.Name='Mode Switch Interfaces:';
                    interfacesLabel.Type='text';
                    interfacesLabel.Mode=true;
                    interfacesLabel.Bold=1;
                    interfacesLabel.RowSpan=[15,15];
                    interfacesLabel.ColSpan=[3,10];
                    interfacesLabel.Tag='InterfacesLabel';

                    colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                    autosar.ui.metamodel.PackageString.ModeGroupStr,...
                    DAStudio.message('autosarstandard:ui:uiWizardIsService')};

                    rowData=cell(length(obj.ComponentBuilder.Interfaces),4);
                    for i=1:length(obj.ComponentBuilder.Interfaces)
                        interfaceNameEdit.Type='edit';
                        interfaceNameEdit.Source=obj.ComponentBuilder.Interfaces(i);
                        interfaceNameEdit.ObjectProperty='Name';
                        interfaceNameEdit.Mode=true;
                        interfaceNameEdit.Name='';

                        modeGroupEdit.Type='edit';
                        modeGroupEdit.Source=obj.ComponentBuilder.Interfaces(i);
                        modeGroupEdit.ObjectProperty='ModeGroupName';
                        modeGroupEdit.Mode=true;
                        modeGroupEdit.Name='';

                        interfaceTypeComboBox.Type='combobox';
                        interfaceTypeComboBox.Mode=true;
                        interfaceTypeComboBox.Editable=0;
                        if strcmp(obj.ComponentBuilder.Interfaces(i).InterfaceType,...
                            autosar.ui.wizard.PackageString.InterfaceTypes{1})
                            interfaceTypeComboBox.Value=0;
                        else
                            interfaceTypeComboBox.Value=1;
                        end
                        interfaceTypeComboBox.Entries={autosar.ui.metamodel.PackageString.False,...
                        autosar.ui.metamodel.PackageString.True};
                        interfaceTypeComboBox.Name='';

                        rowData{i,1}=interfaceNameEdit;
                        rowData{i,2}=modeGroupEdit;
                        rowData{i,3}=interfaceTypeComboBox;
                    end

                    dataElementTable.Type='table';
                    dataElementTable.Size=[length(obj.ComponentBuilder.Interfaces),length(colHeaders)];
                    dataElementTable.Grid=true;
                    dataElementTable.HeaderVisibility=[0,1];
                    dataElementTable.ColHeader=colHeaders;
                    dataElementTable.Mode=true;
                    dataElementTable.DialogRefresh=true;
                    dataElementTable.ColumnCharacterWidth=[22,20,15];
                    dataElementTable.ColumnHeaderHeight=2;
                    dataElementTable.Editable=true;
                    dataElementTable.Tag='InterfaceTable';
                    dataElementTable.RowSpan=[16,26];
                    dataElementTable.ColSpan=[3,25];
                    dataElementTable.Data=rowData;
                    dataElementTable.ValueChangedCallback=@interfaceValueChanged;
                    if~isempty(obj.DialogH)
                        userData=obj.DialogH.getUserData('InterfaceTable');
                        if strcmp(userData,'Adding')
                            obj.DialogH.setUserData('InterfaceTable','');
                            if~isempty(obj.ComponentBuilder.Interfaces)
                                dataElementTable.SelectedRow=length(obj.ComponentBuilder.Interfaces)-1;
                            end
                        end
                    end

                    helpButton.Type='pushbutton';
                    helpButton.Name=DAStudio.message('autosarstandard:ui:uiCommonHelp');
                    helpButton.MatlabMethod='helpview';
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_ms'};
                    helpButton.RowSpan=[1,1];
                    helpButton.ColSpan=[1,2];
                    helpButton.Tag='InterfaceHelp';

                    saveButton.Type='pushbutton';
                    saveButton.Name=DAStudio.message('autosarstandard:ui:uiCommonAddNoParam');
                    saveButton.MatlabMethod='autosar.ui.wizard.saveCallback';
                    saveButton.MatlabArgs={obj};
                    saveButton.RowSpan=[1,1];
                    saveButton.ColSpan=[3,4];
                    saveButton.Tag='InterfaceSave';

                    buttonPanel.Type='panel';
                    buttonPanel.LayoutGrid=[1,4];
                    buttonPanel.Items={helpButton,saveButton};
                    dlgstruct.Items={spacer0,interfaceLabel,spacer1,interfacePackageEdit,...
                    spacer2,spacer3,interfacesLabel,dataElementTable};
                else
                    selNodeLabel=obj.SelectedNode.getDisplayLabel;
                    interfacePackageEdit.Name=[DAStudio.message('RTW:autosar:autosarInterfacePackageNameStr')...
                    ,'      '];
                    interfacePackageEdit.Type='edit';
                    interfacePackageEdit.Mode=true;
                    interfacePackageEdit.Source=obj.ComponentBuilder;
                    interfacePackageEdit.Tag='InterfacePackage';
                    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                        interfacePackageEdit.ObjectProperty='CSInterfacePackage';
                    else
                        interfacePackageEdit.ObjectProperty='InterfacePackage';
                    end
                    interfacePackageEdit.RowSpan=[6,6];
                    interfacePackageEdit.ColSpan=[3,25];
                    interfacePackageEdit.Enabled=true;
                    interfaceFormatEdit.Name=[DAStudio.message('RTW:autosar:interfaceStr'),'      '];
                    interfaceFormatEdit.Type='edit';
                    interfaceFormatEdit.Mode=true;
                    interfaceFormatEdit.Source=obj.ComponentBuilder;
                    interfaceFormatEdit.Tag='InterfaceFormatCtl';
                    interfaceFormatEdit.ObjectProperty='InterfaceFormatCtl';
                    interfaceFormatEdit.RowSpan=[1,1];
                    interfaceFormatEdit.ColSpan=[1,20];
                    interfaceFormatEdit.Enabled=false;

                    dataElementFormatEdit.Name=DAStudio.message('RTW:autosar:dataelementStr');
                    dataElementFormatEdit.Type='edit';
                    dataElementFormatEdit.Mode=true;
                    dataElementFormatEdit.Source=obj.ComponentBuilder;
                    dataElementFormatEdit.Tag='DataElementFormatCtl';
                    dataElementFormatEdit.ObjectProperty='DataElementFormatCtl';
                    dataElementFormatEdit.RowSpan=[2,2];
                    dataElementFormatEdit.ColSpan=[1,20];
                    dataElementFormatEdit.Enabled=false;

                    grpFormat.Name=DAStudio.message('autosarstandard:ui:uiWizardIdFormatControl');
                    grpFormat.Type='group';
                    grpFormat.LayoutGrid=[3,25];
                    grpFormat.RowSpan=[9,12];
                    grpFormat.ColSpan=[3,20];
                    grpFormat.RowStretch=[0,0,1];
                    grpFormat.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    grpFormat.Items={interfaceFormatEdit,dataElementFormatEdit};%#ok<STRNU>

                    spacer3.Name='Spacer';
                    spacer3.Type='text';
                    spacer3.Mode=true;
                    spacer3.RowSpan=[13,14];
                    spacer3.ColSpan=[1,7];
                    spacer3.Visible=0;



                    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardClientServerInterfaces');
                        interfaceList=obj.ComponentBuilder.CSInterfaces;
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardNvDataInterfaces');
                        interfaceList=obj.ComponentBuilder.Interfaces;
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardParamInterfaces');
                        interfaceList=obj.ComponentBuilder.Interfaces;
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardTriggerInterfaces');
                        interfaceList=obj.ComponentBuilder.Interfaces;
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardServiceInterfaces');
                        interfaceList=obj.ComponentBuilder.ServiceInterfaces;
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardPersistencyKeyValueInterfaces');
                        interfaceList=obj.ComponentBuilder.PersistencyKeyValueInterfaces;
                    else
                        interfacesLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardSenderReceiverInterfaces');
                        interfaceList=obj.ComponentBuilder.Interfaces;
                    end
                    interfacesLabel.Type='text';
                    interfacesLabel.Mode=true;
                    interfacesLabel.Bold=1;
                    interfacesLabel.RowSpan=[15,15];
                    interfacesLabel.ColSpan=[3,10];
                    interfacesLabel.Tag='InterfacesLabel';

                    numColumns=3;

                    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                        colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumOps'),...
                        DAStudio.message('autosarstandard:ui:uiWizardIsService')};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName)
                        colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumTriggers'),...
                        DAStudio.message('autosarstandard:ui:uiWizardIsService')};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                        numColumns=3;
                        colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumEvents'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumMethods')};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                        numColumns=2;
                        colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumDataElems')};
                    else
                        colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                        DAStudio.message('autosarstandard:ui:uiWizardNumDataElems'),...
                        DAStudio.message('autosarstandard:ui:uiWizardIsService')};
                    end

                    rowData=cell(length(interfaceList),numColumns);
                    for i=1:length(interfaceList)
                        interfaceNameEdit.Type='edit';
                        interfaceNameEdit.Source=interfaceList(i);
                        interfaceNameEdit.ObjectProperty='Name';
                        interfaceNameEdit.Mode=true;
                        interfaceNameEdit.Name='';

                        interfaceCountEdit.Type='edit';
                        interfaceCountEdit.Source=interfaceList(i);
                        if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                            interfaceCountEdit.ObjectProperty='OperationCount';
                        elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)


                            interfaceCountEdit.ObjectProperty='EventCount';
                        elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                            interfaceCountEdit.ObjectProperty='DataElementCount';
                        else
                            interfaceCountEdit.ObjectProperty='DataElementCount';
                        end
                        interfaceCountEdit.Mode=true;



                        if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)

                            interfaceMethodCountEdit.Type='edit';
                            interfaceMethodCountEdit.Source=interfaceList(i);
                            interfaceMethodCountEdit.ObjectProperty='MethodCount';
                            interfaceMethodCountEdit.Mode=true;
                        end

                        interfaceTypeComboBox.Type='combobox';
                        interfaceTypeComboBox.Mode=true;
                        interfaceTypeComboBox.Editable=0;
                        if strcmp(interfaceList(i).InterfaceType,...
                            autosar.ui.wizard.PackageString.InterfaceTypes{1})
                            interfaceTypeComboBox.Value=0;
                        else
                            interfaceTypeComboBox.Value=1;
                        end
                        interfaceTypeComboBox.Entries={autosar.ui.metamodel.PackageString.False,...
                        autosar.ui.metamodel.PackageString.True};
                        interfaceTypeComboBox.Name='';

                        rowData{i,1}=interfaceNameEdit;
                        rowData{i,2}=interfaceCountEdit;
                        if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                            rowData{i,3}=interfaceMethodCountEdit;
                        else
                            rowData{i,3}=interfaceTypeComboBox;
                        end
                    end

                    dataElementTable.Type='table';
                    dataElementTable.Size=[length(interfaceList),length(colHeaders)];
                    dataElementTable.Grid=true;
                    dataElementTable.HeaderVisibility=[0,1];
                    dataElementTable.ColHeader=colHeaders;
                    dataElementTable.Mode=true;
                    dataElementTable.DialogRefresh=true;
                    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)

                        dataElementTable.ColumnCharacterWidth=[20,13,13,15];
                    else
                        dataElementTable.ColumnCharacterWidth=[22,20,15];
                    end
                    dataElementTable.ColumnHeaderHeight=2;
                    dataElementTable.Editable=true;
                    dataElementTable.Tag='InterfaceTable';
                    dataElementTable.RowSpan=[16,26];
                    dataElementTable.ColSpan=[3,25];
                    dataElementTable.Data=rowData;
                    dataElementTable.ValueChangedCallback=@interfaceValueChanged;
                    if~isempty(obj.DialogH)
                        userData=obj.DialogH.getUserData('InterfaceTable');
                        if strcmp(userData,'Adding')
                            obj.DialogH.setUserData('InterfaceTable','');
                            if~isempty(interfaceList)
                                dataElementTable.SelectedRow=length(interfaceList)-1;
                            end
                        end
                    end

                    helpButton.Type='pushbutton';
                    helpButton.Name=DAStudio.message('autosarstandard:ui:uiCommonHelp');
                    helpButton.MatlabMethod='helpview';
                    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_cs'};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_nv'};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_tr'};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_param'};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface_service'};
                    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
                    else
                        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addinterface'};
                    end
                    helpButton.RowSpan=[1,1];
                    helpButton.ColSpan=[1,2];
                    helpButton.Tag='InterfaceHelp';

                    saveButton.Type='pushbutton';
                    saveButton.Name=DAStudio.message('autosarstandard:ui:uiCommonAddNoParam');
                    saveButton.MatlabMethod='autosar.ui.wizard.saveCallback';
                    saveButton.MatlabArgs={obj};
                    saveButton.RowSpan=[1,1];
                    saveButton.ColSpan=[3,4];
                    saveButton.Tag='InterfaceSave';

                    buttonPanel.Type='panel';
                    buttonPanel.LayoutGrid=[1,4];
                    buttonPanel.Items={helpButton,saveButton};

                    dlgstruct.Items={spacer0,interfaceLabel,spacer1,interfacePackageEdit,...
                    spacer2,spacer3,interfacesLabel,dataElementTable};
                end
            elseif isequal(obj.State,autosar.ui.wizard.WizardDialogState.Ports)||...
                isequal(obj.State,autosar.ui.wizard.WizardDialogState.CSPorts)
                dlgstruct.DialogTag='Port';
                dlgstruct.DialogTitle=autosar.ui.wizard.PackageString.PortsTitle;
                spacer0.Name='Spacer';
                spacer0.Type='text';
                spacer0.Mode=true;
                spacer0.RowSpan=[1,2];
                spacer0.ColSpan=[1,7];
                spacer0.Visible=0;

                portLabel.Name=DAStudio.message('autosarstandard:ui:uiWizardPortLabel');
                portLabel.Type='text';
                portLabel.Mode=true;
                portLabel.RowSpan=[3,3];
                portLabel.ColSpan=[3,10];
                portLabel.Tag='PortLabel';

                spacer1.Name='Spacer';
                spacer1.Type='text';
                spacer1.Mode=true;
                spacer1.RowSpan=[4,5];
                spacer1.ColSpan=[1,7];
                spacer1.Visible=0;

                portFormatEdit.Name=[DAStudio.message('autosarstandard:ui:uiWizardPort'),':      '];
                portFormatEdit.Type='edit';
                portFormatEdit.Mode=true;
                portFormatEdit.Source=obj.ComponentBuilder;
                portFormatEdit.Tag='PortFormatCtl';
                portFormatEdit.ObjectProperty='PortFormatCtl';
                portFormatEdit.RowSpan=[1,1];
                portFormatEdit.ColSpan=[1,20];
                portFormatEdit.Enabled=false;

                grpFormat.Name=DAStudio.message('autosarstandard:ui:uiWizardIdFormatControl');
                grpFormat.Type='group';
                grpFormat.LayoutGrid=[3,25];
                grpFormat.RowSpan=[6,8];
                grpFormat.ColSpan=[3,20];
                grpFormat.RowStretch=[0,0,1];
                grpFormat.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                grpFormat.Items={portFormatEdit};%#ok<STRNU>

                spacer2.Name='Spacer';
                spacer2.Type='text';
                spacer2.Mode=true;
                spacer2.RowSpan=[9,10];
                spacer2.ColSpan=[1,7];
                spacer2.Visible=0;



                portDetailsLabel.Type='text';
                portDetailsLabel.Mode=true;
                portDetailsLabel.Bold=1;
                portDetailsLabel.RowSpan=[11,11];
                portDetailsLabel.ColSpan=[3,10];
                portDetailsLabel.Tag='PortDetailsLabel';

                colHeaders={DAStudio.message('autosarstandard:ui:uiCommonName'),...
                DAStudio.message('autosarstandard:ui:uiCommonInterface'),...
                DAStudio.message('autosarstandard:ui:uiCommonType')};

                selNodeLabel=obj.SelectedNode.getDisplayLabel;

                if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.serverPortsNode)||...
                    strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.clientPortsNode)
                    interfaceList=cell(1,length(obj.ComponentBuilder.CSInterfaces));
                    for i=1:length(obj.ComponentBuilder.CSInterfaces)
                        interfaceList{i}=obj.ComponentBuilder.CSInterfaces(i).Name;
                    end
                    portList=obj.ComponentBuilder.CSPorts;
                    portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardCSPorts'),':'];
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.providedPortsNode)||...
                    strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.requiredPortsNode)
                    interfaceList=cell(1,length(obj.ComponentBuilder.ServiceInterfaces));
                    for i=1:length(obj.ComponentBuilder.ServiceInterfaces)
                        interfaceList{i}=obj.ComponentBuilder.ServiceInterfaces(i).Name;
                    end
                    portList=obj.ComponentBuilder.ServicePorts;
                    portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardRequiredProvidedPorts'),':'];
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode)||...
                    strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode)||...
                    strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode)
                    interfaceList=cell(1,length(obj.ComponentBuilder.PersistencyKeyValueInterfaces));
                    for i=1:length(obj.ComponentBuilder.PersistencyKeyValueInterfaces)
                        interfaceList{i}=obj.ComponentBuilder.PersistencyKeyValueInterfaces(i).Name;
                    end
                    portList=obj.ComponentBuilder.PersistencyPorts;
                    portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardPersistencyPorts'),':'];
                else
                    interfaceList=cell(1,length(obj.ComponentBuilder.Interfaces));
                    for i=1:length(obj.ComponentBuilder.Interfaces)
                        interfaceList{i}=obj.ComponentBuilder.Interfaces(i).Name;
                    end
                    portList=obj.ComponentBuilder.Ports;
                    portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardPorts'),':'];
                end
                rowData=cell(length(portList),3);
                for i=1:length(portList)
                    portNameEdit.Type='edit';
                    portNameEdit.Source=portList(i);
                    portNameEdit.ObjectProperty='Name';
                    portNameEdit.Mode=true;
                    portNameEdit.Name='';

                    interfaceCombo.Type='combobox';
                    interfaceCombo.Mode=true;
                    [member,index]=ismember(portList(i).Interface,interfaceList);
                    if~member
                        index=0;
                    end
                    interfaceCombo.Value=index-1;
                    interfaceCombo.Entries=interfaceList;
                    interfaceCombo.Editable=0;
                    interfaceCombo.Name='';

                    portTypeComboBox.Type='combobox';
                    portTypeComboBox.Mode=true;

                    portTypeComboBox.Entries=autosar.ui.wizard.PackageString.PortTypes;

                    if strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{1})
                        portTypeComboBox.Value=0;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.SenderPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{2})
                        portTypeComboBox.Value=1;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.ReceiverPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{3})
                        portTypeComboBox.Value=2;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardModeRPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{11})
                        portTypeComboBox.Value=10;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardModePPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{4})
                        portTypeComboBox.Value=3;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.ServerPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{5})
                        portTypeComboBox.Value=4;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.SenderReceiverPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{6})
                        portTypeComboBox.Value=5;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.ClientPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{7})
                        portTypeComboBox.Value=6;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.NvReceiverPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{8})
                        portTypeComboBox.Value=7;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.NvSenderPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{9})
                        portTypeComboBox.Value=8;
                        portDetailsLabelStr=[autosar.ui.wizard.PackageString.NvSenderReceiverPortsStr,':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{10})
                        portTypeComboBox.Value=9;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardParameterPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{12})
                        portTypeComboBox.Value=11;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardTriggerReceiverPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{13})
                        portTypeComboBox.Value=12;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardProvidedPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{14})
                        portTypeComboBox.Value=13;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardRequiredPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{15})
                        portTypeComboBox.Value=14;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardPersistencyProvidedPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{16})
                        portTypeComboBox.Value=15;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardPersistencyRequiredPorts'),':'];
                    elseif strcmp(portList(i).PortType,autosar.ui.wizard.PackageString.PortTypes{17})
                        portTypeComboBox.Value=16;
                        portDetailsLabelStr=[DAStudio.message('autosarstandard:ui:uiWizardPersistencyProvidedRequiredPorts'),':'];
                    else
                        assert(false,'Unknown port type');
                    end
                    if isequal(obj.Option,autosar.ui.wizard.WizardDialogState.Ports)
                        portTypeComboBox.Enabled=0;
                    else
                        portTypeComboBox.Enabled=1;
                    end
                    portTypeComboBox.Editable=0;
                    portTypeComboBox.Name='';

                    rowData{i,1}=portNameEdit;
                    rowData{i,2}=interfaceCombo;
                    rowData{i,3}=portTypeComboBox;
                end
                portDetailsLabel.Name=portDetailsLabelStr;
                dataElementTable.Type='table';
                dataElementTable.Size=[length(portList),length(colHeaders)];
                dataElementTable.Grid=true;
                dataElementTable.HeaderVisibility=[0,1];
                dataElementTable.ColHeader=colHeaders;
                dataElementTable.Mode=true;
                dataElementTable.DialogRefresh=true;
                dataElementTable.ColumnCharacterWidth=[22,20,15];
                dataElementTable.ColumnHeaderHeight=2;
                dataElementTable.Editable=true;
                dataElementTable.RowSpan=[12,28];
                dataElementTable.Tag='PortTable';
                dataElementTable.ColSpan=[3,25];
                dataElementTable.Data=rowData;
                dataElementTable.ValueChangedCallback=@portValueChanged;
                if~isempty(obj.DialogH)
                    userData=obj.DialogH.getUserData('PortTable');
                    if strcmp(userData,'Adding')
                        obj.DialogH.setUserData('PortTable','');
                        if~isempty(portList)
                            dataElementTable.SelectedRow=length(portList)-1;
                        end
                    end
                end

                helpButton.Type='pushbutton';
                helpButton.Name=DAStudio.message('autosarstandard:ui:uiCommonHelp');
                helpButton.MatlabMethod='helpview';
                if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.clientPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_clnt'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.serverPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_srvr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_mrcvr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ModeSenderPortNodeName)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_msndr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.senderReceiverPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_sr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.senderPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_sndr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.nvReceiverPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_nvrcvr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.nvSenderPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_nvsndr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_nvsr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_trrcvr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_prcvr'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.providedPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_provided'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.requiredPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport_required'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode)
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
                else
                    helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_addport'};
                end
                helpButton.RowSpan=[1,1];
                helpButton.ColSpan=[1,2];
                helpButton.Tag='PortHelp';

                saveButton.Type='pushbutton';
                saveButton.Name=DAStudio.message('autosarstandard:ui:uiCommonAddNoParam');
                saveButton.MatlabMethod='autosar.ui.wizard.saveCallback';
                saveButton.MatlabArgs={obj};
                saveButton.RowSpan=[1,1];
                saveButton.ColSpan=[3,4];
                saveButton.Tag='PortSave';

                buttonPanel.Type='panel';
                buttonPanel.LayoutGrid=[1,4];
                buttonPanel.Items={helpButton,saveButton};

                dlgstruct.Items={spacer0,portLabel,spacer1,...
                spacer2,portDetailsLabel,...
                dataElementTable};

            end




            mdlHdl=obj.Model;
            mdlPos=get_param(mdlHdl,'Location');
            newPos1=mdlPos(1)+100;
            newPos2=mdlPos(2)+100;
            dlgstruct.Geometry=[newPos1,newPos2,700,500];

            dlgstruct.LayoutGrid=[25,25];
            dlgstruct.RowStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
            dlgstruct.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
            dlgstruct.StandaloneButtonSet=buttonPanel;
            dlgstruct.IsScrollable=0;
            dlgstruct.Sticky=1;

        end

    end
end

function interfaceValueChanged(dialog,row,column,value)
    obj=dialog.getDialogSource;
    selNodeLabel=obj.SelectedNode.getDisplayLabel;
    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
        interfaceList=obj.ComponentBuilder.CSInterfaces;
        otherInterfaceList=obj.ComponentBuilder.Interfaces;
    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
        interfaceList=obj.ComponentBuilder.ServiceInterfaces;
        otherInterfaceList=obj.ComponentBuilder.Interfaces;
    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
        interfaceList=obj.ComponentBuilder.PersistencyKeyValueInterfaces;
        otherInterfaceList=obj.ComponentBuilder.Interfaces;
    else
        interfaceList=obj.ComponentBuilder.Interfaces;
        otherInterfaceList=obj.ComponentBuilder.CSInterfaces;
    end
    if column==0
        for i=1:length(interfaceList)
            name=interfaceList(i).Name;
            if i~=(row+1)&&strcmp(name,value)
                errMsg=DAStudio.message('RTW:autosar:errorDuplicateInterface',...
                name);
                errordlg(errMsg,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                dialog.setTableItemValue('InterfaceTable',row,column,...
                interfaceList(row+1).Name);
                break;
            end
        end
        for i=1:length(otherInterfaceList)
            name=otherInterfaceList(i).Name;
            if strcmp(name,value)
                errMsg=DAStudio.message('RTW:autosar:errorDuplicateInterface',...
                name);
                errordlg(errMsg,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                dialog.setTableItemValue('InterfaceTable',row,column,...
                interfaceList(row+1).Name);
                break;
            end
        end
        maxShortNameLength=get_param(obj.Model,'AutosarMaxShortNameLength');
        idcheckmessage=autosar.ui.utils.isValidARIdentifier({value},'shortName',maxShortNameLength);
        if~isempty(idcheckmessage)
            errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
        else
            interfaceList(row+1).setName(value);
        end
    elseif column==1||...
        (obj.IsAdaptiveWizard&&column>0&&column<4)
        if strcmp(obj.SelectedNode.getDisplayLabel(),...
            autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName)
            maxShortNameLength=get_param(obj.Model,'AutosarMaxShortNameLength');
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({value},'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            else
                interfaceList(row+1).setModeGroupName(value);
            end
        else
            n=str2num(value);%#ok<ST2NM>
            if~(~isempty(n)&&n>0&&rem(n,1)==0)
                if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                    errMsg=DAStudio.message('RTW:autosar:OperationError',...
                    interfaceList(row+1).Name);
                    dialog.setTableItemValue('InterfaceTable',row,column,...
                    dialog.getDialogSource.ComponentBuilder.CSInterfaces.OperationCount);
                elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                    if n==0

                        errMsg='';
                    else
                        if column==1

                            errMsg=DAStudio.message('RTW:autosar:EventError',...
                            interfaceList(row+1).Name);
                            dialog.setTableItemValue('InterfaceTable',row,column,...
                            dialog.getDialogSource.ComponentBuilder.ServiceInterfaces.EventCount);
                        elseif column==2

                            errMsg=DAStudio.message('RTW:autosar:MethodError',...
                            interfaceList(row+1).Name);
                            dialog.setTableItemValue('InterfaceTable',row,column,...
                            dialog.getDialogSource.ComponentBuilder.ServiceInterfaces.MethodCount);
                        end
                    end
                else
                    errMsg=DAStudio.message('RTW:autosar:DataElementError',...
                    interfaceList(row+1).Name);
                    dialog.setTableItemValue('InterfaceTable',row,column,...
                    dialog.getDialogSource.ComponentBuilder.Interfaces.DataElementCount);
                end
                if~isempty(errMsg)
                    errordlg(errMsg,...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                end
            end
        end
    end
    if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
        obj.ComponentBuilder.CSInterfaces=interfaceList;
    elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
        obj.ComponentBuilder.ServiceInterfaces=interfaceList;
    else
        obj.ComponentBuilder.Interfaces=interfaceList;
    end
end

function portValueChanged(dialog,row,column,value)
    if column==0
        obj=dialog.getDialogSource;
        selNodeLabel=obj.SelectedNode.getDisplayLabel;
        if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.serverPortsNode)
            portList=obj.ComponentBuilder.CSPorts;
            otherPortList=obj.ComponentBuilder.Ports;
        elseif any(strcmp(selNodeLabel,{autosar.ui.metamodel.PackageString.requiredPortsNode,...
            autosar.ui.metamodel.PackageString.providedPortsNode}))
            portList=obj.ComponentBuilder.ServicePorts;
            otherPortList=obj.ComponentBuilder.Ports;
        else
            portList=obj.ComponentBuilder.Ports;
            otherPortList=obj.ComponentBuilder.CSPorts;
        end
        for i=1:length(portList)
            name=portList(i).Name;
            if i~=(row+1)&&strcmp(name,value)
                errMsg=DAStudio.message('RTW:autosar:errorDuplicatePort',...
                name);
                errordlg(errMsg,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                dialog.setTableItemValue('PortTable',row,column,...
                portList(row+1).Name);
                break;
            end
        end
        for i=1:length(otherPortList)
            name=otherPortList(i).Name;
            if strcmp(name,value)
                errMsg=DAStudio.message('RTW:autosar:errorDuplicatePort',...
                name);
                errordlg(errMsg,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                dialog.setTableItemValue('PortTable',row,column,...
                portList(row+1).Name);
                break;
            end
        end
        maxShortNameLength=get_param(obj.Model,'AutosarMaxShortNameLength');
        idcheckmessage=autosar.ui.utils.isValidARIdentifier({value},'shortName',maxShortNameLength);
        if~isempty(idcheckmessage)
            errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
        else
            portList(row+1).setName(value);
        end
        if strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.serverPortsNode)
            obj.ComponentBuilder.CSPorts=portList;
        elseif strcmp(selNodeLabel,autosar.ui.metamodel.PackageString.requiredPortsNode)
            obj.ComponentBuilder.ServicePorts=portList;
        else
            obj.ComponentBuilder.Ports=portList;
        end
    end
end
function CloseForWizardCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    dlgTags={'Component','Interface','Port'};
    for index=1:length(dlgTags)
        allDialogs=root.getOpenDialogs;
        arDialog=allDialogs.find('dialogTag',dlgTags{index});
        for i=1:length(arDialog)
            dlgSrc=arDialog.getDialogSource();
            modelH=get_param(dlgSrc.Model,'Handle');
            if modelH==eventSrc.Handle
                dlgSrc.delete;
                break;
            end
        end
    end
end





