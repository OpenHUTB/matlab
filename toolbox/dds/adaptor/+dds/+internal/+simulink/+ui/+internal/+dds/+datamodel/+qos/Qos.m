classdef Qos<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mData;
    end

    properties(Constant,Hidden)
        HIDDENPROPS={'Name','Annotations'};
    end

    methods
        function this=Qos(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function icon=getDisplayIcon(this)
            path='toolbox/dds/adaptor/+dds/+internal/+simulink/+ui/+internal/resources/';
            objType='Qos';
            icon=[path,objType,'.png'];
        end
        function refresh(this)
            this.mRefreshChildren=true;
        end

        function dlgstruct=getDialogSchema(this,arg1)
            this.refresh();

            qosDef.Type='spreadsheet';
            qosDef.Hierarchical=true;
            qosDef.Tag='ssQos';
            qosDef.Columns={'Name','Value'};
            qosDef.Source=this;

            qosDef.RowSpan=[1,3];
            qosDef.ColSpan=[1,3];

            panel.Type='panel';
            panel.LayoutGrid=[3,3];
            panel.RowStretch=[0,0,1];
            panel.ColStretch=[0,0,1];
            panel.Items={qosDef};

            dlgstruct.Items={panel};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function children=getChildren(this)
            if isempty(this.mData)||this.mRefreshChildren
                this.mRefreshChildren=false;
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function isValid=isValidProperty(this,propName)
            if~isequal(propName,'QosType')
                isValid=isValidProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            isValid=true;
        end

        function isReadonly=isReadonlyProperty(this,propName)
            if~isequal(propName,'QosType')
                isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            isReadonly=true;
        end

        function propVal=getPropValue(this,propName)
            propVal='';
            if~isequal(propName,'QosType')
                propVal=getPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            try


                name=class(this.mNode);
                parsed=split(name,'.');
                propVal=parsed{numel(parsed)};

            catch
                propVal='';
            end
        end

        function children=generateChildren(this)
            children=[];
            element=this.getElement;
            props=properties(this.getElement);
            idx=find(ismember(props,'Base'));
            if idx>0
                props(idx,:)=[];
                props=[{'Base'};props];
            end

            idxs=ismember(props,dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.HIDDENPROPS);
            props(idxs,:)=[];
            for idx=1:numel(props)
                child=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosPolicy(this.mMdl,this.mTree,this.mNode,props{idx});
                children=[children,child];%#ok<AGROW> 
            end
        end

        function typeChain=getTypeChain(this)
            typeChain={'Qos'};
        end

        function domainObj=duplicate(this)
            qosContainerNode=this.mNode.Container;
            [qosNames,qosObjs]=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.getQosList(qosContainerNode);
            qosSection=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.findSection(qosContainerNode,this.mNode);
            if~isempty(qosSection)
                txn=this.mMdl.beginTransaction;
                qosObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,qosNames,this.mNode,'');
                qosSection.add(qosObj);
                txn.commit;
            end
        end
    end


    methods(Static,Access=public)

        function qosObj=getQosObj(tree,qosType,qosName)
            qosObj=[];
            prefix='';
            if isequal(qosName,message('dds:ui:Default').getString)
                return;
            end
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.parseQos(tree,qosType,map);
            qosObj=map(qosName);
        end

        function qoses=getQos(tree,qosType)
            qoses={};
            prefix='';
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.parseQos(tree,qosType,map);
            qoses=map.keys();
            if isempty(qoses)
                qoses={};
            end
        end

        function topicQosName=getFullPath(qosRef)
            topicQosName=dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.visitParents(qosRef,'');
        end

        function name=visitParents(elem,name)
            if isprop(elem,'Name')
                if~isempty(name)
                    name=['::',name];
                end
                name=[elem.Name,name];
                if isprop(elem,'Container')
                    parent=elem.Container;
                    if~isprop(parent,'QosLibraries')
                        name=dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.visitParents(parent,name);
                    end
                end
            end
        end

        function qoses=parseQos(tree,qosType,map)
            qoses={};
            prefix='';
            keys=tree.System.QosLibraries.keys;
            for i=1:tree.System.QosLibraries.Size
                elem=tree.System.QosLibraries{keys{i}};
                dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.visitElementsIn(elem,qosType,map,[elem.Name,'::']);
            end
        end


        function visitElementsIn(qosLib,qosType,map,prefix)
            keys=eval(['qosLib.',qosType,'.keys']);
            size=eval(['qosLib.',qosType,'.Size']);
            for i=1:size
                map([prefix,keys{i}])=eval(['qosLib.',qosType,'{keys{',num2str(i),'}}']);
            end
            try
                keys=qosLib.QosProfiles.keys;
                for i=1:qosLib.QosProfiles.Size
                    elem=qosLib.QosProfiles{keys{i}};
                    prefix=[prefix,elem.Name,'::'];
                    dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.visitElementsIn(elem,qosType,map,prefix);
                end
            catch
            end
        end

    end



    methods(Access=private)


    end
end
