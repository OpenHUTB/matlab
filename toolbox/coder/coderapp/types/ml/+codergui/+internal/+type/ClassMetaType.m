classdef ClassMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.class'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.RedirectedClass...
        ,codergui.internal.type.AttributeDefs.PropertyAddress...
        ]
    end

    methods
        function this=ClassMetaType()
            this.IsLeaf=false;
        end
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function initializeChildren(this,parent,children)
            this.autoAssignNameAddresses(parent,children,'prop');
        end

        function coderType=toCoderType(this,node,childTypes)
            [sz,varDims]=node.Size.toNewTypeArgs();
            coderType=coder.newtype(node.Class,sz,varDims);

            if~coder.type.Base.isEnabled('GUI')&&isa(coderType,'coder.type.Base')
                coderType=coderType.getCoderType();
            end

            coderType.Properties=cell2struct(reshape(...
            childTypes,1,[]),...
            {node.Children.Address},2);
            coderType.RedirectedClass=node.get(this.CustomAttributes(1));
        end

        function fromCoderType(this,node,coderType)
            node.Size=codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims);
            node.set(this.CustomAttributes(1),coderType.RedirectedClass);
            node.assignChildTypes(struct2cell(coderType.Properties),fieldnames(coderType.Properties));
        end

        function applyClass(~,node,~)
            node.SizeAttribute.IsEnabled=false;
        end

        function address=validateAddress(this,address,node)
            address=this.validateNameAddress(address,node,'invalidPropertyName','duplicatePropertyName');
        end

        function code=toCode(~,node,varName,context)
            [sz,varDims]=node.Size.toNewTypeArgs(true);
            code='';
            if isempty(context.childPaths)
                temp='struct';
            elseif strcmp(varName,context.childRoot)
                temp=context.tempVar;
                code=sprintf('%s = %s;\n',temp,context.childRoot);
            else
                temp=context.childRoot;
            end


            if coder.type.Base.isEnabled('CLI')...
                &&~coder.type.Base.isEnabled('GUI')...
                &&coder.type.Base.hasCustomCoderType(node.Class)
                code=sprintf(['%s'...
                ,'%s = coder.newtype(''%s'', %s, %s);\n'...
                ,'%s = %s.getCoderType();\n'...
                ,'%s.Properties = %s;\n'],...
                code,varName,node.Class,sz,varDims,varName,varName,varName,temp);
            else
                code=sprintf(['%s'...
                ,'%s = coder.newtype(''%s'', %s, %s);\n'...
                ,'%s.Properties = %s;\n'],...
                code,varName,node.Class,sz,varDims,varName,temp);
            end
        end

        function classType=toMF0(this,node,model,childTypes)
            classType=coderapp.internal.codertype.ClassType(model);
            classType.ClassName=node.Class;
            classType.RedirectedClassName=node.get(this.CustomAttributes(1));
            classType.Size=node.Size.toMfzDims();

            for i=1:numel(childTypes)
                prop=coderapp.internal.codertype.Property(model);
                prop.Name=node.Children(i).Address;
                prop.Type=childTypes(i);
                classType.Properties(end+1)=prop;
            end
        end

        function class=fromMF0(this,node,mf0)
            class=mf0.ClassName;
            node.Size=codergui.internal.type.Size(mf0.Size);
            node.set(this.CustomAttributes(1),mf0.RedirectedClassName);

            props=mf0.Properties.toArray();
            node.assignChildTypes({props.Type},{props.Name});
        end
    end

    methods
        function compatible=isCompatibleClass(~,className)
            metaClass=meta.class.fromName(className);
            compatible=~isempty(metaClass)&&~metaClass.HandleCompatible&&~metaClass.Enumeration;
        end
    end
end
