classdef StructMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.struct'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.TypeName,...
        codergui.internal.type.AttributeDefs.Extern,...
        codergui.internal.type.AttributeDefs.HeaderFile,...
        codergui.internal.type.AttributeDefs.Alignment...
        ,codergui.internal.type.AttributeDefs.FieldAddress...
        ]
    end

    methods
        function this=StructMetaType()
            this.IsLeaf=false;
        end
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function initializeChildren(this,parent,children)
            this.autoAssignNameAddresses(parent,children,'f');
        end

        function validateNode(this,node)
            this.handleExtern(node);
        end

        function coderType=toCoderType(this,node,childTypes)
            [sz,varDims]=node.Size.toNewTypeArgs();
            coderType=coder.newtype('struct',cell2struct(reshape(...
            childTypes,1,[]),...
            {node.Children.Address},2),sz,varDims);
            this.handleExtern(node);
            coderType=this.invokeCStructName(node,coderType);
        end

        function fromCoderType(this,node,coderType)
            node.Size=codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims);
            node.multiSet(this.CustomAttributes(1:end-1),{...
            coderType.TypeName,coderType.Extern,coderType.HeaderFile,...
            coderType.Alignment});
            node=this.handleExtern(node);
            node.assignChildTypes(struct2cell(coderType.Fields),fieldnames(coderType.Fields));
        end

        function address=validateAddress(this,address,node)
            address=this.validateNameAddress(address,node,'invalidFieldName','duplicateFieldName');
        end

        function code=toCode(this,node,varName,context)
            structNameCode=this.cStructNameToCode(node,varName);
            if~isempty(structNameCode)
                structNameCode=[newline(),structNameCode];
            end
            if isempty(context.childPaths)
                child='struct';
            else
                child=context.childRoot;
            end
            [sz,varDims]=node.Size.toNewTypeArgs(true);
            code=sprintf('%s = coder.newtype(''struct'', %s, %s, %s);%s',...
            varName,child,sz,varDims,structNameCode);
        end

        function structType=toMF0(~,node,model,childTypes)
            [typeName,extern,header,alignment]=node.multiGet(...
            {'typeName','extern','headerFile','alignment'},'value','deal');

            structType=coderapp.internal.codertype.StructType(model);
            structType.Extern=extern;
            structType.Alignment=alignment;
            structType.HeaderFile=header;
            structType.TypeName=typeName;
            structType.Size=node.Size.toMfzDims();

            for i=1:numel(childTypes)
                prop=coderapp.internal.codertype.Property(model);
                prop.Name=node.Children(i).Address;
                prop.Type=childTypes(i);
                structType.Fields(end+1)=prop;
            end
        end

        function class=fromMF0(this,node,mf0)
            class='struct';
            node.Size=codergui.internal.type.Size(mf0.Size);
            node.multiSet(this.CustomAttributes(1:end-1),{...
            mf0.TypeName,mf0.Extern,mf0.HeaderFile,...
            mf0.Alignment});
            node=this.handleExtern(node);
            flds=mf0.Fields;
            node.assignChildTypes({flds.Type},{flds.Name});
        end
    end
end
