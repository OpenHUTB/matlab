classdef MetaConfig<handle


    properties
config
parent
    end

    methods
        function obj=MetaConfig(parent)
            obj.parent=parent;

            baseBeh=struct('name','BaseBehavior','label',...
            DAStudio.message('SystemArchitecture:ProfileDesigner:RequirementLinkBaseBehavior'),...
            'type','selection');
            baseBeh.selections={'Functional','Container','Informational'};

            baseBeh1=struct('name','BaseBehavior','label',...
            DAStudio.message('SystemArchitecture:ProfileDesigner:RequirementLinkBaseBehavior'),...
            'type','selection');
            baseBeh1.selections={'Relate','Confirm','Derive','Implement','Refine','Verify'};

            forwd=struct('name','ForwardName','label',...
            DAStudio.message('SystemArchitecture:ProfileDesigner:LinkForwardName'),...
            'type','string');
            bckwd=struct('name','BackwardName','label',...
            DAStudio.message('SystemArchitecture:ProfileDesigner:LinkBackwardName'),...
            'type','string');
            obj.config.Requirement={baseBeh};
            obj.config.Link={baseBeh1,forwd,bckwd};
        end

        function addMetaProperties(obj,prtType,selType)
            if~any(strcmp(selType,obj.getMetaTypes()))
                return;
            end

            mdl=mf.zero.getModel(prtType);
            if isempty(prtType.metaAttributes)
                prtType.metaAttributes=mf.zero.meta.AttributeMap(mdl);
            end


            if isempty(prtType.appliesTo.toArray)||~strcmp(prtType.appliesTo.toArray{1},selType)
                obj.clearMetaProperties(prtType);
                typePropArr=obj.config.(selType);
                for i=1:length(typePropArr)
                    propStruct=typePropArr{i};
                    name=propStruct.name;

                    sAttr=mf.zero.meta.StringAttribute(mdl);
                    sAttr.key=name;
                    prtType.metaAttributes.insert(sAttr);
                end

                typePropArr=obj.config.(selType);
                prtType.metaAttributes.at('BaseBehavior').value=...
                append("'",typePropArr{1}.selections{1},"'");
            end
        end

        function types=getMetaTypes(obj)
            types=fieldnames(obj.config)';
        end

        function propStruct=getPropStructByName(obj,typeName,propName)
            propStruct=[];
            typePropArr=obj.config.(typeName);
            for i=1:length(typePropArr)
                prStruct=typePropArr{i};
                if strcmp(prStruct.name,propName)
                    propStruct=prStruct;
                end
            end
        end

        function handlePropValueChanged(obj,value,name)
            prtType=obj.parent.getCurrentPrototype();
            if~isempty(prtType)
                types=fieldnames(obj.config)';
                for i=1:length(types)
                    type=types{i};
                    if obj.parent.isPrototypeType(prtType,type)
                        propStruct=obj.getPropStructByName(type,name);
                        if strcmp(propStruct.type,'selection')
                            if~isempty(propStruct)
                                sels=propStruct.selections;
                                prtType.metaAttributes.at(name).value=...
                                append("'",string(sels{value+1}),"'");
                            end
                        elseif strcmp(propStruct.type,'string')
                            prtType.metaAttributes.at(name).value=...
                            append("'",string(value),"'");
                        end
                    end
                end
            end

        end
        function schema=getAppliesToPropSchema(obj,selType,prtType)
            schema=[];

            if~any(strcmp(selType,obj.getMetaTypes()))
                return;
            end

            typePropArr=obj.config.(selType);
            schema.Items={};
            for i=1:length(typePropArr)
                propStruct=typePropArr{i};
                name=propStruct.name;
                label=propStruct.label;
                type=propStruct.type;

                if strcmp(type,'selection')

                    propItem=struct('Type','combobox','Name',[label,':'],...
                    'RowSpan',[1,1],'ColSpan',[i,i]);
                    sel=prtType.metaAttributes.at(name).value;
                    propItem.Entries=propStruct.selections;
                    propItem.Value=obj.getSelIndex(sel,propStruct.selections);
                else

                    propItem=struct('Type','edit','Name',[label,':'],...
                    'RowSpan',[1,1],'ColSpan',[i,i]);
                    v=prtType.metaAttributes.at(name).value;
                    propItem.Value=v(2:end-1);
                end
                propItem.Mode=true;
                propItem.Source=obj;
                propItem.ObjectMethod='handlePropValueChanged';
                propItem.MethodArgs={'%value',name};
                propItem.ArgDataTypes={'char','char'};
                propItem.Tag=propStruct.name;

                schema.Items{end+1}=propItem;
            end

            schema.Type='group';
            schema.Name='';
            schema.Tag='ReqLinkMetaAttributes';
            schema.RowStretch=[0,1];
            schema.LayoutGrid=[2,3];
            schema.ColStretch=[1,1,1];
        end
    end
    methods(Static)

        function val=getSelIndex(value,sels)
            val=0;
            v=value(2:end-1);
            if any(strcmp(v,sels))
                val=find(strcmp(v,sels))-1;
            end
        end

        function clearMetaProperties(prtType)
            keys=prtType.metaAttributes.attributes.keys();
            for i=1:length(keys)
                prtType.metaAttributes.remove(keys{i});
            end
        end
    end
end