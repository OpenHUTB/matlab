classdef CustomMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.class'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.RedirectedClass...
        ,codergui.internal.type.AttributeDefs.PropertyAddress...
        ]
    end

    methods
        function this=CustomMetaType()
            this.IsLeaf=false;
            this.IsUserModifiableSubtree=false;
        end
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function initializeChildren(this,parent,children)
            this.autoAssignNameAddresses(parent,children,'prop');
        end

        function coderType=toCoderType(~,node,childTypes)
            [sz,varDims]=node.Size.toNewTypeArgs();
            coderType=coder.newtype(node.Class,sz,varDims);
            for i=1:numel(childTypes)
                coderType.(childTypes(i).Address)=coder.type.Base.applyCustomCoderType(childTypes(i).getCoderType());
            end
        end

        function fromCoderType(~,node,coderType)
            node.Size=codergui.internal.type.Size(coderType.Size,coderType.VarDims);
            node.assignChildTypes(struct2cell(coderType.getProperties()),coderType.getTypeProperties());
        end

        function applyClass(~,node,~)
            node.SizeAttribute.IsEnabled=false;
        end

        function code=toCode(~,~,varName,context)
            code='';
            if strcmp(varName,context.childRoot)
                temp=context.tempVar;
                code=sprintf('%s = %s;\n',temp,context.childRoot);
            end
        end

        function mf0=toMF0(~,~)%#ok<STOUT> 

            error('Not supported');
        end

        function class=fromMF0(~,~,~)%#ok<STOUT> 

            error('Not supported');
        end
    end
end