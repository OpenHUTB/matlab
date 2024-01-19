classdef Dialog<systemcomposer.internal.mixin.ModelClose&...
    systemcomposer.internal.mixin.CenterDialog

    properties(Access=private)
pModelH
pEventChain
        pDirty=false
pPortEvent
NodeIdMap
TreeModel

styler
styledObjs

    end


    properties(Constant)
        styleClass='EventChainStyleClass'
        stylerName='EventChainStyle'
    end


    methods(Static)
        function dlg=dialogFor(pr,dlg)
            persistent DialogMap;
            if isempty(DialogMap)
                DialogMap=containers.Map('KeyType','char','ValueType','any');
            end

            uid=pr.getZCIdentifier;
            if nargin>1
                if DialogMap.isKey(uid)
                    DialogMap.remove(uid);
                end
                if~isempty(dlg)
                    DialogMap(uid)=dlg;
                end
            else
                if DialogMap.isKey(uid)
                    dlg=DialogMap(uid);
                else
                    dlg=[];
                end
            end
        end
    end


    methods
        function this=Dialog(ec,isStimulus,modelH)

            this.NodeIdMap=containers.Map('KeyType','double','ValueType','any');
            this.pEventChain=ec;
            this.pModelH=modelH;

            if isStimulus
                this.pPortEvent=ec.stimulus;
            else
                this.pPortEvent=ec.response;
            end
            assert(~isempty(this.pPortEvent),'Must have a port event.');
            assert(~isempty(this.getPortInterface()),'Port must have interface applied to open dialog.');
            this.registerCloseListener(modelH);
            this.TreeModel=this.createTreeModel();
        end


        function dlgstruct=getDialogSchema(this)

            componentLabel.Type='text';
            componentLabel.Name=DAStudio.message('SoftwareArchitecture:PortRelationship:OwnerComponentLabel');
            componentLabel.Tag='componentLabel';
            componentLabel.RowSpan=[1,1];
            componentLabel.ColSpan=[1,1];

            componentValue.Type='text';
            componentValue.Name=getPortOwnerName(this);
            componentValue.Tag='componentValue';
            componentValue.RowSpan=[1,1];
            componentValue.ColSpan=[2,3];

            portLabel.Type='text';
            portLabel.Name=DAStudio.message('SoftwareArchitecture:PortRelationship:OwnerPortLabel');
            portLabel.Tag='portLabel';
            portLabel.RowSpan=[2,2];
            portLabel.ColSpan=[1,1];

            portValue.Type='text';
            portValue.Name=getPortName(this);
            portValue.Tag='portValue';
            portValue.RowSpan=[2,2];
            portValue.ColSpan=[2,3];
            portInterfaceInfoGrp.Name=getEventTitle(this.pPortEvent);
            portInterfaceInfoGrp.Type='group';
            portInterfaceInfoGrp.Tag='portRelationshipPortMappingsGrpTag';
            portInterfaceInfoGrp.Items={componentLabel,componentValue,portLabel,portValue};
            portInterfaceInfoGrp.Expand=true;
            portInterfaceInfoGrp.LayoutGrid=[2,3];
            interfaceElementsTree.Type='tree';
            interfaceElementsTree.TreeModel=getTreeModel(this);
            interfaceElementsTree.TreeMultiSelect=false;
            interfaceElementsTree.Tag='interfaceElementsTreeTag';
            interfaceElementsTree.RowSpan=[1,1];
            interfaceElementsTree.ColSpan=[1,2];
            interfaceElementsTree.CheckStateChangedCallback=@(dlg,id,val)this.cbTreeValueChanged(dlg,id,val);
            interfaceElementsTree.Enabled=~isempty(pi);
            interfaceElementsTree.Graphical=true;
            interfaceElementsTree.DialogRefresh=true;
            interfaceElementsTree.Mode=true;

            selectAllElementsButton.Name=...
            DAStudio.message('SoftwareArchitecture:PortRelationship:SelectAllInterfaceElements');
            selectAllElementsButton.Type='pushbutton';
            selectAllElementsButton.Tag='selectAllButton';
            selectAllElementsButton.ObjectMethod='cbSelectAllPressed';
            selectAllElementsButton.MethodArgs={'%dialog'};
            selectAllElementsButton.ArgDataTypes={'%handle'};
            selectAllElementsButton.Mode=true;
            selectAllElementsButton.DialogRefresh=true;
            selectAllElementsButton.Graphical=true;

            editPortElementMappingGrp.Name=...
            DAStudio.message('SoftwareArchitecture:PortRelationship:EditPortElementMappingGroupPanel');
            editPortElementMappingGrp.Type='group';
            editPortElementMappingGrp.Tag='editPortElementMappingGrpTag';
            editPortElementMappingGrp.Items={interfaceElementsTree,selectAllElementsButton};
            editPortElementMappingGrp.Flat=true;
            editPortElementMappingGrp.Expand=true;
            editPortElementMappingGrp.LayoutGrid=[3,2];
            editPortElementMappingGrp.ColSpan=[1,2];
            editPortElementMappingGrp.ColStretch=[0,1];

            dlgstruct.DialogTitle=DAStudio.message('SoftwareArchitecture:PortRelationship:MappingDialogName',this.pEventChain.getName());
            dlgstruct.DisplayIcon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','Port.png');
            dlgstruct.Items={portInterfaceInfoGrp,editPortElementMappingGrp};
            dlgstruct.LayoutGrid=[2,2];
            dlgstruct.RowStretch=[0,1];
            dlgstruct.DialogTag='system_composer_port_relationship_mapping';
            dlgstruct.HelpMethod='cbHandleClickHelp';
            dlgstruct.HelpArgs={};
            dlgstruct.HelpArgsDT={};
            dlgstruct.OpenCallback=@(dlg)this.cbHandleOpenDialog(dlg);
            dlgstruct.CloseMethod='cbHandleCloseDialog';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','char'};
            dlgstruct.PreApplyMethod='cbPreApply';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};
            dlgstruct.MinMaxButtons=false;
            dlgstruct.ShowGrid=false;

            dlgstruct.Sticky=true;
        end


        function cbHandleClickHelp(~)
            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'portrelationship');
        end


        function cbHandleOpenDialog(this,dlg)
            this.positionDialog(dlg,this.pModelH);
        end


        function cbHandleCloseDialog(this,dlg,action)

            if strcmpi(action,'ok')&&this.changesAreValid()
                this.doCommit(dlg);
            elseif strcmpi(action,'cancel')
                this.doCancel(dlg);
            end
            swarch.internal.portrelationship.Dialog.dialogFor(this.pEventChain,[]);
        end


        function cbPreApply(this,dlg)

            if this.changesAreValid()
                this.doCommit(dlg)
            else

                dp=DAStudio.DialogProvider;
                msg=...
                DAStudio.message('SoftwareArchitecture:PortRelationship:InterfaceElementsCannotBeEmpty');
                title=...
                DAStudio.message('SoftwareArchitecture:PortRelationship:InterfaceElementsCannotBeEmptyDlgTitle');
                dp.errordlg(msg,title,true);
            end
        end


        function cbSelectAllPressed(this,dlg)

            if all(cellfun(@isChecked,this.TreeModel))

                return;
            end

            this.setDirty(dlg,true);
            cellfun(@(node)node.setChecked(dlg,'interfaceElementsTreeTag'),this.TreeModel);
        end


        function cbTreeValueChanged(this,dlg,id,state)
            this.setDirty(dlg,true);
            node=this.NodeIdMap(id);
            node.setCheckState(dlg,'interfaceElementsTreeTag',state);
        end
    end


    methods(Access=private)
        function setDirty(this,dlg,val)

            this.pDirty=val;
            dlg.enableApplyButton(val);
        end


        function doCommit(this,dlg)
            portEvent=this.pPortEvent;

            if all(cellfun(@isChecked,this.TreeModel))
                portEvent.addNestedInterfaceElements(...
                systemcomposer.architecture.model.interface.InterfaceElement.empty);
            else
                txn=mf.zero.getModel(portEvent).beginTransaction();
                for idx=1:numel(this.TreeModel)
                    this.TreeModel{idx}.addInterfaceIfSelected(portEvent);
                end
                txn.commit();
            end
            this.setDirty(dlg,false);
        end


        function interf=getPortInterface(this)
            interf=this.pPortEvent.port.getPortInterface();
        end


        function name=getPortName(this)
            name=this.pPortEvent.port.getName();
        end


        function name=getPortOwnerName(this)

            portEvent=this.pPortEvent;
            port=portEvent.port;
            if port.isArchitecturePort()
                portOwner=port.getArchitecture();
            else
                assert(port.isComponentPort());
                portOwner=port.getComponent();
            end
            name=portOwner.getName();
        end


        function treeModel=getTreeModel(this)
            treeModel=this.TreeModel;
        end


        function valid=changesAreValid(this)
            valid=true;
            if~this.pDirty
                return;
            end
            allNodes=this.NodeIdMap.values();
            for idx=1:numel(allNodes)
                if allNodes{idx}.isChecked()
                    return;
                end
            end
            valid=false;
        end


        function highlightElement(this,el)
            sobj=systemcomposer.utils.getSimulinkPeer(el);
            this.styler=diagram.style.getStyler(this.stylerName);
            if isempty(this.styler)
                diagram.style.createStyler(this.stylerName);
            end

            purple=[0.5,0.0,0.5,0.8];
            stroke=MG2.Stroke;
            stroke.Color=purple;
            stroke.Width=3;
            trace=MG2.TraceEffect(stroke,'Outer');
            glow=MG2.GlowEffect();
            glow.Color=purple;
            glow.Spread=10;
            glow.Gain=1;
            style=diagram.style.Style;
            style.set('Trace',trace);
            style.set('Glow',glow);
            selector=diagram.style.ClassSelector(this.styleClass);
            this.styler.addRule(style,selector);
            do=diagram.resolver.resolve(sobj);
            this.styler.applyClass(do,this.styleClass);
            this.styledObjs=[this.stylesObjs,do];
        end


        function removeAllStyles(this)
            for idx=1:length(this.styledObjs)
                do=this.styledObjs(idx);
                this.styler.removeClass(do,this.styleClass);
            end
        end


        function elements=pathToInterfaceElements(this,qualifiedName)

            pi=this.getPortInterface();
            elements=[];
            ss=strsplit(qualifiedName,'.');
            for elemName=ss
                assert(~isempty(pi.getElementNames));
                el=pi.getElement(elemName{1});
                elements=[elements,el];%#ok
                pi=el.getTypeAsInterface;
            end
        end


        function treeModel=createTreeModel(this)
            remove(this.NodeIdMap,keys(this.NodeIdMap));

            id=1;
            treeModel={};
            elements=this.getPortInterface().getElements();
            emptyParent=[];
            for idx=1:numel(elements)
                node=this.createInterfaceElementNode(id,elements(idx),emptyParent);
                treeModel{end+1}=node;%#ok<AGROW>

                id=node.nextSiblingID();
            end
        end
    end


    methods(Access={?swarch.internal.portrelationship.InterfaceElementNode})
        function node=createInterfaceElementNode(this,id,interfaceElements,parentNode)
            checked=this.pPortEvent.containsNestedInterfaceElement(interfaceElements);
            node=swarch.internal.portrelationship.InterfaceElementNode(...
            id,interfaceElements,parentNode,checked);
            childElements=interfaceElements(end).getTypeAsInterface().getElements();
            children=cell(1,length(childElements));

            nextId=id+1;
            for idx=1:length(childElements)
                elementPath=[interfaceElements,childElements(idx)];
                children{idx}=this.createInterfaceElementNode(nextId,elementPath,node);
                nextId=children{idx}.nextSiblingID();
            end

            node.setChildren(children);
            this.NodeIdMap(id)=node;
        end
    end
end


function name=getEventTitle(event)
    import systemcomposer.architecture.model.traits.EventTypeEnum;

    switch event.eventType
    case EventTypeEnum.MESSAGE_SEND
        name=DAStudio.message('SoftwareArchitecture:PortRelationship:ResponsePortTitle');
    case EventTypeEnum.MESSAGE_RECEIVE
        name=DAStudio.message('SoftwareArchitecture:PortRelationship:StimulusPortTitle');
    otherwise
        assert(false,strcat("Unsupported event type ",string(event.eventType)));
    end
end


