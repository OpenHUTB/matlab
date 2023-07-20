classdef Topic<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
    end

    methods
        function this=Topic(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function dlgstruct=getDialogSchema(this,arg)
            registerTypeLabel.Type='text';
            registerTypeLabel.Name=message('dds:ui:RegisteredName').getString;
            registerTypeLabel.RowSpan=[1,1];
            registerTypeLabel.ColSpan=[1,1];

            registerType.Type='combobox';
            registerType.Tag='RegisterType';
            registerType.RowSpan=[1,1];
            registerType.ColSpan=[2,2];
            registerType.Source=this;
            registerType.Mode=1;
            registerType.ObjectProperty='RegisterTypeRef';

            typeRefLabel.Type='text';
            typeRefLabel.Name=message('dds:ui:TopicType').getString;
            typeRefLabel.RowSpan=[2,2];
            typeRefLabel.ColSpan=[1,1];

            useText=true;
            if(useText)
                typeRef.Type='text';
                typeRef.Name=this.getPropValue('TopicType');
            else
                typeRef.ObjectProperty='TopicType';
                typeRef.Type='edit';
                typeRef.Enabled=false;
            end
            typeRef.Tag='TypeRef';
            typeRef.RowSpan=[2,2];
            typeRef.ColSpan=[2,2];
            typeRef.Source=this;


            topicQosLabel.Type='text';
            topicQosLabel.Name=message('dds:ui:TopicQos').getString;
            topicQosLabel.RowSpan=[3,3];
            topicQosLabel.ColSpan=[1,1];

            topicQos.Type='combobox';
            topicQos.Tag='TopicQos';
            topicQos.RowSpan=[3,3];
            topicQos.ColSpan=[2,2];
            topicQos.Source=this;
            topicQos.Mode=1;
            topicQos.ObjectProperty='QosRef';

            panel.Type='panel';
            panel.LayoutGrid=[4,2];
            panel.ColStretch=[0,1];
            panel.RowStretch=[0,0,0,1];
            panel.Items={registerTypeLabel,registerType,typeRefLabel,typeRef,topicQosLabel,topicQos};

            dlgstruct.Items={panel};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function isValid=isValidProperty(this,propName)
            if isequal(propName,'TopicType')
                isValid=true;
                return;
            end
            isValid=isValidProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function isReadonly=isReadonlyProperty(this,propName)
            if isequal(propName,'TopicType')
                isReadonly=true;
                return;
            end
            isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function dataType=getPropDataType(this,propName)
            if isequal(propName,'RegisterTypeRef')||isequal(propName,'QosRef')
                dataType='enum';
                return;
            end
            dataType=getPropDataType@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function values=getPropAllowedValues(this,propName)
            if isequal(propName,'TopicType')
                values=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList_Full(this.mTree);


                propVal=this.getPropValue(propName);
                if~any(ismember(values,propVal))
                    values{end+1}=this.getPropValue(propName);
                end
            elseif isequal(propName,'RegisterTypeRef')
                values=this.getRegisteredNames();
            elseif isequal(propName,'QosRef')
                values=this.getTopicQos();
            else
                values=getPropAllowedValues@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
        end
        function propVal=getPropDisplayValue(this,propName)
            if isequal(propName,'TopicType')

                try
                    regTypeRef=this.mNode.RegisterTypeRef;
                    typeRef=regTypeRef.TypeRef;
                    propVal=typeRef.Name;
                catch
                    propVal='';
                end
            else
                propVal=this.getPropValue(propName);
            end
        end

        function propVal=getPropValue(this,propName)
            if isequal(propName,'TopicType')
                propVal=this.getTypeNamePath();
            elseif isequal(propName,'RegisterTypeRef')
                regTypeRef=this.mNode.RegisterTypeRef;
                propVal=regTypeRef.Name;
            elseif isequal(propName,'QosRef')
                propVal=getQosNamePath(this);
                if isempty(propVal)
                    propVal=message('dds:ui:Default').getString;
                end
            else
                propVal=getPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
        end

        function setPropValue(this,propName,propVal)
            if isequal(propName,'RegisterTypeRef')
                regNameObj=this.getRegisteredNameObj(propVal);
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,regNameObj);
            elseif isequal(propName,'QosRef')
                qosObj=this.getTopicQosObj(propVal);
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,qosObj);
            elseif~isequal(propName,'TopicType')
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,propVal);
                return;
            end
        end

        function addObject(this,type)
            if isequal(type,'Topic')
                parent=this.mNode.Container;
                dds.internal.simulink.ui.internal.dds.datamodel.domain.Topic.create(this.mMdl,this.mTree,parent,'');
            end
        end

        function topicObj=duplicate(this)
            domainNode=this.mNode.Container;
            topics=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getTopicsList(domainNode);
            txn=this.mMdl.beginTransaction;
            topicObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,topics,this.mNode,'');
            domainNode.Topics.add(topicObj);
            txn.commit;
        end

        function typeChain=getTypeChain(this)
            typeChain={this.getClassName()};
        end
    end



    methods(Access=private)

        function topicQoses=getTopicQos(this)
            topicQoses={};
            topicQosClass='dds.datamodel.qos.TopicQos';
            dataClass=['dds.internal.simulink.ui.internal.',topicQosClass];
            topicQoses=feval([dataClass,'.getQos'],this.mTree);
            topicQoses{end+1}=message('dds:ui:Default').getString;
        end

        function qosName=getQosNamePath(this)
            topicQosClass='dds.datamodel.qos.TopicQos';
            dataClass=['dds.internal.simulink.ui.internal.',topicQosClass];
            qosName=feval([dataClass,'.getFullPath'],this.mNode.QosRef);
        end

        function topicQosObj=getTopicQosObj(this,topicQosName)
            topicQosObj=[];
            topicQosClass='dds.datamodel.qos.TopicQos';
            dataClass=['dds.internal.simulink.ui.internal.',topicQosClass];
            topicQosObj=feval([dataClass,'.getQosObj'],this.mTree,topicQosName);
        end

        function registeredNames=getRegisteredNames(this)
            registeredNames={};
            domain=this.mNode.Container;
            domainClass='dds.datamodel.domain.Domain';
            dataClass=['dds.internal.simulink.ui.internal.',domainClass];
            registeredNames=feval([dataClass,'.getRegisteredNames'],domain);
        end

        function regNameObj=getRegisteredNameObj(this,regName)
            regNameObj=[];
            domain=this.mNode.Container;
            domainClass='dds.datamodel.domain.Domain';
            dataClass=['dds.internal.simulink.ui.internal.',domainClass];
            regNameObj=feval([dataClass,'.getRegisteredNameObj'],domain,regName);
        end

        function typeName=getTypeNamePath(this)
            try
                regTypeRef=this.mNode.RegisterTypeRef;
                typeRef=regTypeRef.TypeRef;
                typeName=typeRef.Name;

                typeObj='dds.datamodel.types.Type';
                dataClass=['dds.internal.simulink.ui.internal.',typeObj];
                typeName=feval([dataClass,'.getFullPath'],typeRef);
            catch
                typeName='';
            end
        end
    end


    methods(Static,Access=public)

        function topicObj=create(ddsMdl,ddsTree,domainNode,name)
            topicObj=[];
            regTypes=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNames(domainNode);
            if isempty(regTypes)
                regTypeObj=dds.internal.simulink.ui.internal.dds.datamodel.domain.RegisterType.create(ddsMdl,ddsTree,domainNode,'');
            else
                regTypeObj=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNameObj(domainNode,regTypes{1});
            end
            if~isempty(regTypeObj)
                topics=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getTopicsList(domainNode);
                txn=ddsMdl.beginTransaction;
                topicObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,topics,'dds.datamodel.domain.Topic',name);
                topicObj.RegisterTypeRef=regTypeObj;
                domainNode.Topics.add(topicObj);
                txn.commit;
            end
        end

    end
end
